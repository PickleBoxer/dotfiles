#!/usr/bin/env bash
# Checks for wize-back, on PHP files changed since a base ref plus untracked ones.
#
# Per chunk (default, base HEAD, so the uncommitted chunk):
#   1. Pint (fixes in place)
#   2. the 4 PHPStan configs CI runs
#   3. the changed test files
#
# --full (base defaults to the branch point with origin/master), once all chunks are in:
#   1-3 as above, on the whole branch's files
#   4. every touched container's whole test suite, in parallel
#   5. tests outside those containers that reference a changed class
#
# Usage: check-chunk.sh [--full] [--base <ref>] [--dry-run] [Container ...]
# Containers default to those the changed files live in.

base=
full=0
dry_run=0
containers=()

while [ $# -gt 0 ]; do
    case $1 in
        --base) base=$2; shift 2 ;;
        --full) full=1; shift ;;
        --dry-run) dry_run=1; shift ;;
        *) containers+=("$1"); shift ;;
    esac
done

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not in a git repository."; exit 2; }
cd "$repo_root" || exit 2
[ -d project/app ] || { echo "Run this inside wize-back."; exit 2; }

if [ -z "$base" ]; then
    if [ $full -eq 1 ]; then
        base=$(git merge-base HEAD origin/master) || { echo "No merge base with origin/master; pass --base."; exit 2; }
    else
        base=HEAD
    fi
fi

strip_ansi() { sed 's/\x1b\[[0-9;]*[A-Za-z]//g'; }

files=()
while IFS= read -r file; do
    [ -n "$file" ] && [ -f "project/$file" ] && files+=("$file")
done < <(
    { git diff --name-only --diff-filter=d "$base" -- project; git ls-files --others --exclude-standard -- project; } \
        | grep '\.php$' | sed 's#^project/##' | sort -u
)

if [ ${#files[@]} -eq 0 ]; then
    echo "No changed PHP files since $base."
    exit 0
fi

tests=()
for file in "${files[@]}"; do
    case $file in
        *Test.php) tests+=("$file") ;;
    esac
done

if [ ${#containers[@]} -eq 0 ]; then
    while IFS= read -r container; do
        [ -n "$container" ] && containers+=("$container")
    done < <(printf '%s\n' "${files[@]}" | sed -n 's#^app/Containers/\([^/]*\)/.*#\1#p' | sort -u)
fi

# Test files outside the touched containers and the changed tests that name a changed class.
affected=()
if [ $full -eq 1 ]; then
    patterns=()
    for file in "${files[@]}"; do
        case $file in
            *Test.php) ;;
            app/*)
                fqcn="App/${file#app/}"
                fqcn=${fqcn%.php}
                patterns+=("${fqcn//\//\\\\}([^A-Za-z0-9_]|\$)")
                ;;
        esac
    done

    if [ ${#patterns[@]} -gt 0 ]; then
        grep_args=()
        for pattern in "${patterns[@]}"; do
            grep_args+=(-e "$pattern")
        done

        while IFS= read -r test; do
            test=${test#project/}
            for container in "${containers[@]}"; do
                case $test in "app/Containers/$container/"*) continue 2 ;; esac
            done
            for changed in "${tests[@]}"; do
                [ "$test" = "$changed" ] && continue 2
            done
            affected+=("$test")
        done < <(
            grep -rlE --include='*Test.php' "${grep_args[@]}" project/app/Containers/*/Tests project/tests 2>/dev/null | sort -u
        )
    fi
fi

echo "Mode: $([ $full -eq 1 ] && echo full || echo chunk)"
echo "Base: $base"
echo "Files (${#files[@]}):"
printf '  %s\n' "${files[@]}"
if [ $full -eq 1 ]; then
    echo "Containers: ${containers[*]:-none}"
    echo "Affected tests outside them (${#affected[@]}):"
    [ ${#affected[@]} -gt 0 ] && printf '  %s\n' "${affected[@]}"
fi
echo

if [ $dry_run -eq 1 ]; then
    summary="Dry run: would run Pint and 4 PHPStan configs on the files above, ${#tests[@]} changed test file(s)"
    [ $full -eq 1 ] && summary="$summary, each container's suite and ${#affected[@]} affected test file(s)"
    echo "$summary."
    exit 0
fi

failed=0

# Prints one status line per step; on failure, the last 40 lines of output.
run_step() {
    local name=$1
    shift
    local output status summary
    output=$(mktemp)

    if "$@" >"$output" 2>&1; then
        status=PASS
    else
        status=FAIL
        failed=1
    fi

    summary=$(strip_ansi <"$output" | grep -E 'Tests:|\[OK\]|\[ERROR\]|PASS|FAIL' | tail -1 | sed 's/^ *//')
    printf '%-4s  %-34s %s\n' "$status" "$name" "$summary"

    if [ $status = FAIL ]; then
        strip_ansi <"$output" | tail -40 | sed 's/^/      /'
    fi

    rm -f "$output"
}

run_step "pint" docker exec backend ./vendor/bin/pint "${files[@]}"

for config in phpstan.neon phpstan-types.neon phpstan-closure-params.neon phpstan-queue-payload.neon; do
    run_step "$config" docker exec backend ./vendor/bin/phpstan analyse -c "$config" --memory-limit=2G --no-progress "${files[@]}"
done

if [ ${#tests[@]} -gt 0 ]; then
    run_step "changed tests (${#tests[@]})" docker exec backend php artisan test --compact "${tests[@]}"
fi

if [ $full -eq 1 ]; then
    for container in "${containers[@]}"; do
        run_step "container $container" docker exec backend php artisan test --compact --parallel "app/Containers/$container"
    done

    if [ ${#affected[@]} -gt 0 ]; then
        run_step "affected tests (${#affected[@]})" docker exec backend php artisan test --compact --parallel "${affected[@]}"
    fi
fi

exit $failed

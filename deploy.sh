#!/bin/bash
#
# deploy.sh — Deploy, pause, or resume the ITEA 2026 RAG slides
#
# Usage:
#   ./deploy.sh            Push changes and rebuild the site
#   ./deploy.sh --pause    Take the site offline (returns 404)
#   ./deploy.sh --resume   Bring the site back online and rebuild
#   ./deploy.sh --status   Check if the site is live or paused
#

set -e

REPO="michaelsoltys/ITEA2026-RAG"
SITE_URL="https://michaelsoltys.github.io/ITEA2026-RAG/"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

case "${1:-deploy}" in

  deploy|--deploy)
    if ! git diff --quiet HEAD -- slides_rag_itea2026.md public/ .github/ 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard -- slides_rag_itea2026.md public/ .github/)" ]; then
      git add slides_rag_itea2026.md public/ .github/
      git commit -m "Update slides — $(date '+%Y-%m-%d %H:%M')"
      git push
      echo ""
      echo "Pushed. GitHub Actions will rebuild in ~1 minute."
      echo "Site:  $SITE_URL"
      echo "Repo:  https://github.com/$REPO/actions"
    else
      echo "No changes to deploy."
      echo "Site:  $SITE_URL"
      echo "Repo:  https://github.com/$REPO/actions"
    fi
    ;;

  --pause)
    echo "Disabling GitHub Pages..."
    gh api -X DELETE "repos/$REPO/pages" 2>/dev/null && \
      echo "Site paused. $SITE_URL will return 404." || \
      echo "Pages may already be disabled."
    ;;

  --resume)
    echo "Re-enabling GitHub Pages..."
    gh api -X POST "repos/$REPO/pages" --silent --input - <<'EOF'
{
  "build_type": "workflow"
}
EOF
    echo "Pages re-enabled. Triggering rebuild..."
    gh workflow run deploy.yml --repo "$REPO" 2>/dev/null || \
      git commit --allow-empty -m "Trigger rebuild" && git push
    echo ""
    echo "Site will be live in ~1 minute at: $SITE_URL"
    ;;

  --status)
    if gh api "repos/$REPO/pages" >/dev/null 2>&1; then
      echo "Site is LIVE"
      echo "URL: $SITE_URL"
    else
      echo "Site is PAUSED (GitHub Pages disabled)"
    fi
    ;;

  --help|-h)
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  (none)     Push slides changes and rebuild the site"
    echo "  --pause    Take the site offline (visitors get 404)"
    echo "  --resume   Bring the site back online and rebuild"
    echo "  --status   Check whether the site is live or paused"
    ;;

  *)
    echo "Unknown option: $1"
    echo "Run ./deploy.sh --help for usage."
    exit 1
    ;;
esac

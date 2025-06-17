#!/bin/bash

# =====================================================================================
# AGENTICWAVES PACKAGE WEBSITE DEPLOYMENT SCRIPT
# Automates the complete deployment process to GitHub Pages
# =====================================================================================

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                     🌐 AGENTICWAVES WEBSITE DEPLOYMENT                      ║"
echo "║                    https://avishekb9.github.io/AgenticWaves/                ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check requirements
echo "🔍 Checking requirements..."
if ! command_exists git; then
    echo "❌ Git not found. Please install Git first."
    exit 1
fi

if ! command_exists R; then
    echo "❌ R not found. Please install R first."
    exit 1
fi

echo "✅ All requirements satisfied"

# Check if we're in the right directory
if [[ ! -f "DESCRIPTION" ]]; then
    echo "❌ DESCRIPTION file not found. Please run from AgenticWaves package directory."
    exit 1
fi

echo "📁 Current directory: $(pwd)"

# Build the website
echo ""
echo "🏗️ Building package website..."
R -e "
if(!requireNamespace('pkgdown', quietly = TRUE)) {
  install.packages('pkgdown', quiet = TRUE)
}
pkgdown::build_site(preview = FALSE, install = FALSE, new_process = FALSE)
" || {
    echo "❌ Website build failed!"
    exit 1
}

echo "✅ Website built successfully!"

# Check git status
echo ""
echo "📊 Checking git status..."
git status --porcelain

# Add all files
echo ""
echo "📝 Adding files to git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️ No changes to commit"
    exit 0
fi

# Commit changes
echo ""
echo "💾 Committing changes..."
git commit -m "📚 Add professional package website with pkgdown

Features:
- Complete function documentation and reference
- Comprehensive tutorials and vignettes  
- Getting started guides
- Agent-based modeling guide
- Network analysis guide
- Visualization guide
- Professional Bootstrap 5 theme with Cosmo bootswatch
- Mobile-responsive design
- Search functionality
- GitHub Actions workflow for automatic deployment

🌐 Website URL: https://avishekb9.github.io/AgenticWaves/

🤖 Generated with Claude Code (https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push origin main || git push origin master || {
    echo "❌ Push failed! Please check your git configuration and try again."
    echo "💡 Make sure you have proper authentication set up for GitHub."
    exit 1
}

echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🌐 Enable GitHub Pages (IMPORTANT - Updated Instructions):"
echo "   • Go to: https://github.com/avishekb9/AgenticWaves/settings/pages"
echo "   • Source: Deploy from a branch"
echo "   • Branch: main (NOT gh-pages)"
echo "   • Folder: /docs (NOT root)"
echo "   • Click 'Save'"
echo ""
echo "   📖 If this doesn't work, see MANUAL_DEPLOYMENT_GUIDE.md for alternatives"
echo ""
echo "2. ⏰ Wait for deployment (usually 5-10 minutes)"
echo ""
echo "3. 🎯 Access your website:"
echo "   • Primary URL: https://avishekb9.github.io/AgenticWaves/"
echo "   • Getting Started: https://avishekb9.github.io/AgenticWaves/articles/getting-started.html"
echo "   • Function Reference: https://avishekb9.github.io/AgenticWaves/reference/"
echo ""
echo "4. 🔄 Automatic Updates:"
echo "   • GitHub Actions will rebuild the site on every push to main/master"
echo "   • No manual intervention needed for future updates"
echo ""
echo "✨ Your professional package website is now live! ✨"
echo ""
echo "📧 Support: bavisek@gmail.com"
echo "🐛 Report issues: https://github.com/avishekb9/AgenticWaves/issues"
#!/usr/bin/env Rscript
# =============================================================================
# AGENTICWAVES PACKAGE WEBSITE BUILDER
# Creates professional website using pkgdown
# =============================================================================

cat("
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🌐 AGENTICWAVES WEBSITE BUILDER                        ║
║                    https://avishekb9.github.io/AgenticWaves/                ║
╚══════════════════════════════════════════════════════════════════════════════╝

📚 Building professional package website...

")

# Check if we're in the right directory
if(!file.exists("DESCRIPTION")) {
  stop("❌ DESCRIPTION file not found. Please run from AgenticWaves package directory.")
}

# Function to install pkgdown if needed
ensure_pkgdown <- function() {
  if(!requireNamespace("pkgdown", quietly = TRUE)) {
    cat("📦 Installing pkgdown package...\n")
    install.packages("pkgdown", quiet = TRUE)
  }
  
  library(pkgdown)
  cat("✅ pkgdown loaded successfully\n")
}

# Function to build the website
build_website <- function() {
  cat("🏗️ Building package website...\n")
  
  tryCatch({
    # Configure and build site
    pkgdown::build_site(
      preview = FALSE,
      install = FALSE,
      new_process = FALSE
    )
    
    cat("✅ Website built successfully!\n")
    
  }, error = function(e) {
    cat("❌ Website build failed:", e$message, "\n")
    stop("Website build failed")
  })
}

# Function to create additional website files
create_website_assets <- function() {
  cat("📁 Creating additional website assets...\n")
  
  # Create docs directory if it doesn't exist
  if(!dir.exists("docs")) {
    dir.create("docs")
  }
  
  # Create CNAME file for GitHub Pages custom domain (optional)
  # writeLines("agenticwaves.com", "docs/CNAME")  # Uncomment if you have a custom domain
  
  # Create .nojekyll file for GitHub Pages
  file.create("docs/.nojekyll")
  
  # Create robots.txt
  writeLines(c(
    "User-agent: *",
    "Allow: /",
    "",
    "Sitemap: https://avishekb9.github.io/AgenticWaves/sitemap.xml"
  ), "docs/robots.txt")
  
  cat("✅ Website assets created\n")
}

# Function to add GitHub Actions for automatic website deployment
create_github_actions <- function() {
  cat("⚙️ Creating GitHub Actions workflow...\n")
  
  # Create .github/workflows directory
  workflows_dir <- ".github/workflows"
  if(!dir.exists(workflows_dir)) {
    dir.create(workflows_dir, recursive = TRUE)
  }
  
  # Create pkgdown workflow
  workflow_content <- '
name: pkgdown

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]
  release:
    types: [published]
  workflow_dispatch:

jobs:
  pkgdown:
    runs-on: ubuntu-latest
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-pandoc@v2

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgdown, local::.
          needs: website

      - name: Build site
        run: pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
        shell: Rscript {0}

      - name: Deploy to GitHub pages 🚀
        if: github.event_name != "pull_request"
        uses: JamesIves/github-pages-deploy-action@v4.4.1
        with:
          clean: false
          branch: gh-pages
          folder: docs
'
  
  writeLines(workflow_content, file.path(workflows_dir, "pkgdown.yaml"))
  
  cat("✅ GitHub Actions workflow created\n")
}

# Function to display completion information
show_website_info <- function() {
  cat("\n")
  cat("🎉 WEBSITE CREATION COMPLETED!\n")
  cat("═══════════════════════════════════════════════════════════════════════════════\n\n")
  
  cat("🌐 Website Information:\n")
  cat("   • Local preview: docs/index.html\n")
  cat("   • GitHub Pages URL: https://avishekb9.github.io/AgenticWaves/\n")
  cat("   • Source repository: https://github.com/avishekb9/AgenticWaves\n\n")
  
  cat("📋 Next Steps for GitHub Pages Deployment:\n\n")
  
  cat("1. 🚀 Push website files to GitHub:\n")
  cat("   git add .\n")
  cat("   git commit -m \"📚 Add package website with pkgdown\"\n")
  cat("   git push origin main\n\n")
  
  cat("2. ⚙️ Enable GitHub Pages:\n")
  cat("   • Go to: https://github.com/avishekb9/AgenticWaves/settings/pages\n")
  cat("   • Source: Deploy from a branch\n")
  cat("   • Branch: gh-pages\n")
  cat("   • Folder: / (root)\n")
  cat("   • Click \"Save\"\n\n")
  
  cat("3. 🔄 Automatic Updates:\n")
  cat("   • GitHub Actions workflow will automatically rebuild the site\n")
  cat("   • Updates deploy on every push to main branch\n")
  cat("   • Manual trigger available in Actions tab\n\n")
  
  cat("📚 Website Features:\n")
  cat("   • Professional Bootstrap 5 theme\n")
  cat("   • Complete function reference\n")
  cat("   • Comprehensive tutorials and vignettes\n")
  cat("   • Getting started guides\n")
  cat("   • Interactive examples\n")
  cat("   • News and changelog\n")
  cat("   • Mobile-responsive design\n")
  cat("   • Search functionality\n")
  cat("   • Social media integration\n\n")
  
  cat("🎨 Customization Options:\n")
  cat("   • Modify _pkgdown.yml for layout changes\n")
  cat("   • Add custom CSS in pkgdown/extra.css\n")
  cat("   • Update vignettes for new content\n")
  cat("   • Add more articles in vignettes/\n\n")
  
  cat("🔗 Direct Links:\n")
  cat("   • Getting Started: /articles/getting-started.html\n")
  cat("   • Function Reference: /reference/index.html\n")
  cat("   • Agent-Based Modeling: /articles/agent-based-modeling.html\n")
  cat("   • Network Analysis: /articles/network-analysis.html\n")
  cat("   • News & Updates: /news/index.html\n\n")
  
  cat("📧 Support:\n")
  cat("   • GitHub Issues: https://github.com/avishekb9/AgenticWaves/issues\n")
  cat("   • Email: bavisek@gmail.com\n")
  cat("   • Documentation: Built-in help system\n\n")
  
  cat("✨ Your professional package website is ready for the world! ✨\n")
}

# Main execution
main <- function() {
  tryCatch({
    # Step 1: Ensure pkgdown is available
    ensure_pkgdown()
    
    # Step 2: Build the website
    build_website()
    
    # Step 3: Create additional assets
    create_website_assets()
    
    # Step 4: Create GitHub Actions workflow
    create_github_actions()
    
    # Step 5: Show completion info
    show_website_info()
    
  }, error = function(e) {
    cat("\n❌ Website creation failed:", e$message, "\n")
    cat("💡 Make sure you're in the AgenticWaves package directory.\n")
    cat("💡 Ensure all package dependencies are installed.\n")
    quit(status = 1)
  })
}

# Run if script is executed directly
if(sys.nframe() == 0) {
  main()
}
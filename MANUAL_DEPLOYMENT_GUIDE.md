# 🌐 Manual GitHub Pages Deployment Guide

The GitHub Actions automated deployment encountered an issue. Here's how to deploy your website manually:

## 🚀 **Method 1: Direct GitHub Pages (Recommended)**

### Step 1: Push Current Changes
```bash
cd /home/avisek/Documents/WaveQTE-master/AgenticWaves
git add .
git commit -m "📚 Add professional package website with pkgdown"
git push origin main
```

### Step 2: Enable GitHub Pages
1. Go to: **https://github.com/avishekb9/AgenticWaves/settings/pages**
2. **Source**: Deploy from a branch
3. **Branch**: Select `main` (not gh-pages)
4. **Folder**: Select `/ (root)`
5. Click **"Save"**

### Step 3: Configure GitHub Pages for /docs folder
1. Go back to: **https://github.com/avishekb9/AgenticWaves/settings/pages**
2. **Source**: Deploy from a branch
3. **Branch**: Select `main`
4. **Folder**: Select `/docs` (this is where our website is built)
5. Click **"Save"**

## 🔧 **Method 2: Manual gh-pages Branch**

If Method 1 doesn't work, create a gh-pages branch manually:

```bash
cd /home/avisek/Documents/WaveQTE-master/AgenticWaves

# Create and switch to gh-pages branch
git checkout --orphan gh-pages

# Remove all files except docs
git rm -rf . 2>/dev/null || true

# Copy docs contents to root
cp -r docs/* .
cp docs/.nojekyll .

# Add and commit
git add .
git commit -m "🌐 Deploy AgenticWaves website to GitHub Pages"

# Push gh-pages branch
git push origin gh-pages

# Switch back to main
git checkout main
```

Then configure GitHub Pages:
1. Go to: **https://github.com/avishekb9/AgenticWaves/settings/pages**
2. **Source**: Deploy from a branch
3. **Branch**: Select `gh-pages`
4. **Folder**: Select `/ (root)`
5. Click **"Save"**

## 🛠️ **Method 3: Using GitHub CLI**

If you have GitHub CLI installed:

```bash
cd /home/avisek/Documents/WaveQTE-master/AgenticWaves

# Enable GitHub Pages
gh repo edit --enable-pages --pages-branch main --pages-path /docs

# Or for gh-pages branch
gh repo edit --enable-pages --pages-branch gh-pages --pages-path /
```

## ✅ **Verification Steps**

After deployment:

1. **Check Actions Tab**: https://github.com/avishekb9/AgenticWaves/actions
2. **Check Pages Settings**: https://github.com/avishekb9/AgenticWaves/settings/pages
3. **Wait 5-10 minutes** for deployment to complete
4. **Visit Your Website**: https://avishekb9.github.io/AgenticWaves/

## 🔧 **Fixing GitHub Actions (Optional)**

The updated workflow should work better. To test it:

1. **Enable GitHub Pages Actions**:
   - Go to repository settings → Pages
   - Source: "GitHub Actions"
   - This uses the new workflow instead of branch deployment

2. **Trigger the workflow**:
   ```bash
   git add .github/workflows/pkgdown.yaml
   git commit -m "🔧 Fix GitHub Actions workflow for website deployment"
   git push origin main
   ```

## 📋 **Troubleshooting**

### If deployment fails:
- **Check repository is public** (or GitHub Pro for private repo Pages)
- **Verify GitHub Pages is enabled** in repository settings
- **Wait longer** - deployment can take up to 10 minutes
- **Check GitHub status page** for any outages

### If website shows 404:
- **Verify folder structure** - docs folder should contain index.html
- **Check branch selection** in Pages settings
- **Clear browser cache** and try again

### If styling is broken:
- **Check .nojekyll file** exists in docs folder
- **Verify all assets** are properly linked
- **Check browser console** for errors

## 🎯 **Expected Result**

Your website will be available at:
- **Primary URL**: https://avishekb9.github.io/AgenticWaves/
- **Getting Started**: https://avishekb9.github.io/AgenticWaves/articles/getting-started.html
- **Function Reference**: https://avishekb9.github.io/AgenticWaves/reference/
- **Network Analysis**: https://avishekb9.github.io/AgenticWaves/articles/network-analysis.html

## 📧 **Need Help?**

If you continue having issues:
1. **Check GitHub Status**: https://www.githubstatus.com/
2. **GitHub Pages Documentation**: https://docs.github.com/en/pages
3. **Repository Issues**: https://github.com/avishekb9/AgenticWaves/issues

---

**Method 1 (using /docs folder) is usually the simplest and most reliable approach.**
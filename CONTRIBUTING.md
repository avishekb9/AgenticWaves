# Contributing to AgenticWaves

Thank you for your interest in contributing to AgenticWaves! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Install development dependencies: `devtools::install_dev_deps()`
4. Make your changes
5. Test your changes: `devtools::test()`
6. Submit a pull request

## 🐛 Reporting Issues

- Use the GitHub issue tracker
- Provide a clear description of the problem
- Include reproducible examples when possible
- Specify your R version and operating system

## 💻 Development Setup

```r
# Install development tools
install.packages(c("devtools", "roxygen2", "testthat"))

# Install dependencies
devtools::install_deps()

# Load package for development
devtools::load_all()

# Run tests
devtools::test()

# Check package
devtools::check()
```

## 📝 Code Style

- Follow R coding standards
- Use roxygen2 for documentation
- Include examples in function documentation
- Add tests for new functionality
- Use descriptive variable and function names

## 🧪 Testing

- All new functions must include tests
- Tests should cover edge cases and error conditions
- Run `devtools::test()` before submitting PR
- Maintain test coverage above 80%

## 📚 Documentation

- Use roxygen2 comments for all exported functions
- Include parameter descriptions and examples
- Update README.md for new features
- Add vignettes for complex workflows

## 🔄 Pull Request Process

1. Create a feature branch from main
2. Make your changes with clear commit messages
3. Update documentation and tests
4. Ensure all tests pass
5. Submit PR with description of changes

## 📜 Code of Conduct

Be respectful and inclusive in all interactions. This project follows standard open source community guidelines.

## ❓ Questions

For questions about contributing, please open an issue or contact: bavisek@gmail.com

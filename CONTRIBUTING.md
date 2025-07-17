# Contributing to CalendarSync

We welcome contributions to the CalendarSync PowerShell module! This document provides guidelines for contributing to the project.

## Development Setup

### Prerequisites

- PowerShell 5.1 or higher
- Microsoft Graph PowerShell SDK
- PSFramework module
- Git for version control
- Visual Studio Code (recommended)

### Environment Setup

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/yourusername/CalendarSync.git
   cd CalendarSync
   ```

3. Install required modules:
   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   Install-Module PSFramework -Scope CurrentUser
   ```

4. Import the module for development:
   ```powershell
   Import-Module .\CalendarSync -Force
   ```

## Code Style Guidelines

### PowerShell Best Practices

- Use approved PowerShell verbs (Get-, Set-, New-, Remove-, etc.)
- Follow PowerShell naming conventions (PascalCase for functions, camelCase for variables)
- Include comprehensive help documentation with examples
- Use proper error handling with try/catch blocks
- Implement parameter validation where appropriate
- Use PSFramework for logging (Write-PSFMessage)

### Function Structure

```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
        Brief description of the function
    .DESCRIPTION
        Detailed description of what the function does
    .PARAMETER ParameterName
        Description of the parameter
    .EXAMPLE
        Verb-Noun -ParameterName "value"
        Description of what this example does
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterName
    )
    
    try {
        # Function implementation
        Write-PSFMessage -Level Verbose -Message "Processing $ParameterName"
        
        # Your code here
        
        return $result
    }
    catch {
        Write-PSFMessage -Level Error -Message "Error in Verb-Noun: $($_.Exception.Message)"
        throw
    }
}
```

## Project Structure

### Adding New Functions

**Public Functions** (in `functions/` directory):
- Main functionality that users will call directly
- Must be exported in the module manifest
- Should have comprehensive help documentation
- Include parameter validation and error handling

**Internal Functions** (in `internal/` directory):
- Helper functions used internally by public functions
- Not exported to users
- Can have simpler documentation
- Should still include error handling

### File Organization

- One function per file
- File name should match function name
- Use descriptive function names
- Group related functionality logically

## Testing

### Manual Testing

Before submitting changes:

1. Import the module and test your changes:
   ```powershell
   Import-Module .\CalendarSync -Force
   Get-Command -Module CalendarSync
   ```

2. Test main functionality:
   ```powershell
   Sync-CalendarEvents -DebugMode
   ```

3. Test individual functions if applicable
4. Verify help documentation works:
   ```powershell
   Get-Help Your-Function -Examples
   ```

### Future: Unit Testing

We plan to implement unit testing using Pester framework. All new functions should be designed with testability in mind.

## Submitting Changes

### Pull Request Process

1. Create a feature branch from main:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "Add: Your descriptive commit message"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub

### Commit Message Guidelines

Use clear, descriptive commit messages:

- **Add:** New features or functions
- **Fix:** Bug fixes
- **Update:** Changes to existing functionality
- **Docs:** Documentation changes
- **Style:** Code style improvements
- **Refactor:** Code restructuring without functionality changes

Examples:
- `Add: New function for email notifications`
- `Fix: Handle null values in date parsing`
- `Update: Improve error handling in Graph API calls`
- `Docs: Add examples to README`

### Pull Request Guidelines

- Provide a clear description of what your PR does
- Reference any related issues
- Include examples of how to test your changes
- Update documentation if needed
- Ensure your code follows the style guidelines

## Documentation

### Help Documentation

All public functions must include:
- Synopsis
- Description
- Parameter descriptions
- At least one example
- Notes if applicable

### README Updates

When adding new functionality:
- Update the main README.md
- Update the module README.md in CalendarSync/
- Add examples showing how to use new features

## Reporting Issues

When reporting bugs or requesting features:

1. Use the GitHub issue tracker
2. Provide a clear description of the problem
3. Include steps to reproduce (for bugs)
4. Mention your PowerShell version and OS
5. Include relevant error messages or output

## Code Review Process

All submissions go through code review:

1. Automated checks (when implemented)
2. Manual review by maintainers
3. Testing on different environments
4. Documentation review

## Questions?

If you have questions about contributing:

- Check existing issues and discussions on GitHub
- Create a new issue for questions
- Follow the project for updates

Thank you for contributing to CalendarSync!

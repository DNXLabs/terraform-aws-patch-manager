# Manual Release Steps for v0.9.0

Since there are permission issues with pushing directly to the repository, here are the manual steps to complete the release:

## Step 1: Push Changes to GitHub

You'll need to push the changes manually. Here are the options:

### Option A: Push to Your Fork (Recommended)
1. Fork the repository to your personal GitHub account if you haven't already
2. Add your fork as a remote:
   ```bash
   git remote add fork https://github.com/YOUR_USERNAME/terraform-aws-patch-manager.git
   ```
3. Push the feature branch to your fork:
   ```bash
   git push fork feature/multiple-schedules-support
   ```
4. Create a Pull Request from your fork to the main repository

### Option B: Request Push Access
1. Contact the repository maintainers to request push access
2. Once you have access, push the branch:
   ```bash
   git push origin feature/multiple-schedules-support
   ```

## Step 2: Create Pull Request

1. Go to the GitHub repository: https://github.com/DNXLabs/terraform-aws-patch-manager
2. Click "New Pull Request"
3. Select the `feature/multiple-schedules-support` branch
4. Use this title: **"feat: Add support for multiple patching schedules per month"**
5. Use this description:

```markdown
## 🚀 Multiple Patching Schedules Support

This PR adds support for configuring multiple patching schedules per month while maintaining full backward compatibility.

### ✨ Key Features
- **Multiple Schedules**: New `scan_schedules` and `install_schedules` variables
- **Flexible Configuration**: Each schedule can have individual settings
- **Complex Patterns**: Support for "second and fourth Sundays" type schedules
- **Zero Breaking Changes**: Full backward compatibility maintained
- **Enhanced Outputs**: Comprehensive outputs for all resources

### 📋 What's Changed
- Added `scan_schedules` and `install_schedules` variables
- Updated resources to use `for_each` instead of `count`
- Added comprehensive outputs for all maintenance windows
- Created dedicated CloudWatch log groups per schedule
- Added examples and documentation

### 🔄 Backward Compatibility
- All existing configurations continue to work unchanged
- Legacy variables and outputs maintained
- No migration required for existing users

### 📁 Files Added/Modified
- Modified: `_variables.tf`, `_data.tf`, `maintenance-window.tf`, `cloud-watch.tf`, `README.md`
- Added: `outputs.tf`, `CHANGELOG.md`, `UPGRADE_GUIDE.md`
- Added: `examples/multiple-schedules/`, `examples/backward-compatibility/`, `test/`

### 🧪 Testing
- Added test configuration in `test/main.tf`
- Examples provided for both new and legacy usage
- Terraform formatting applied

### 📚 Documentation
- Updated README with comprehensive examples
- Added upgrade guide and changelog
- Included release notes

Closes: Multiple schedules support request
```

## Step 3: After PR is Merged

Once the PR is merged to master, create a new release:

1. Go to the repository's Releases page
2. Click "Create a new release"
3. Use these details:

**Tag version:** `v0.9.0`
**Release title:** `v0.9.0: Multiple Schedules Support`
**Description:** Copy the content from `RELEASE_NOTES_v0.9.0.md`

## Step 4: Update Version References

After the release is created, you may want to update any documentation that references version numbers to point to v0.9.0.

## Current Status

✅ All code changes completed and committed
✅ Feature branch created: `feature/multiple-schedules-support`
✅ Documentation and examples created
✅ Release notes prepared
⏳ Waiting for push to GitHub
⏳ Waiting for PR creation and merge
⏳ Waiting for release creation

## Files Ready for Release

All the following files are ready and committed:

### Core Changes
- `_variables.tf` - Added multiple schedule variables
- `_data.tf` - Added backward compatibility logic
- `maintenance-window.tf` - Updated to support multiple schedules
- `cloud-watch.tf` - Updated log groups for multiple schedules
- `outputs.tf` - Added comprehensive outputs

### Documentation
- `README.md` - Updated with examples and usage
- `CHANGELOG.md` - Detailed changelog
- `UPGRADE_GUIDE.md` - Migration guide
- `RELEASE_NOTES_v0.9.0.md` - Release notes

### Examples & Tests
- `examples/multiple-schedules/main.tf` - Multiple schedules example
- `examples/backward-compatibility/main.tf` - Legacy compatibility example
- `test/main.tf` - Test configuration

## Git Commands Summary

Current branch: `feature/multiple-schedules-support`
Commit hash: `87c5678`
Files changed: 11 files, 881 insertions(+), 55 deletions(-)

The changes are ready to be pushed to GitHub!

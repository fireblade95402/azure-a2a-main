# Azure Storage Managed Identity Setup

This document explains how to configure Azure Storage to use Managed Identity instead of connection strings for enhanced security.

## Changes Made

### 1. Environment Configuration (.env)
- **Removed**: `AZURE_STORAGE_CONNECTION_STRING` (commented out for backup)
- **Updated**: `AZURE_STORAGE_ACCOUNT_NAME` with the actual storage account name
- **Added**: `AZURE_STORAGE_USE_MANAGED_IDENTITY="true"` to enable managed identity

### 2. Backend Code Changes (backend_production.py)
- Updated `upload_to_azure_blob()` function to support both managed identity and connection string authentication
- Added support for user delegation SAS tokens when using managed identity
- Maintained backward compatibility with connection string method

## Required Azure Configuration

### For Local Development
When running locally, you'll need to authenticate using Azure CLI:
```bash
az login
```

### For Azure-hosted Applications
Configure the managed identity and assign appropriate roles:

#### 1. Enable System-Assigned Managed Identity
For App Service, Container Apps, or other Azure services:
- Go to your service in Azure Portal
- Navigate to **Identity** → **System assigned**
- Set Status to **On**

#### 2. Assign Storage Roles
Your managed identity needs these roles on the storage account:

**Required Roles:**
- **Storage Blob Data Contributor** - For read/write access to blobs
- **Storage Blob Delegator** - For generating user delegation SAS tokens

**To assign roles:**
1. Go to your storage account in Azure Portal
2. Navigate to **Access Control (IAM)**
3. Click **Add** → **Add role assignment**
4. Select the role and assign it to your managed identity

#### 3. Storage Account Configuration
Ensure your storage account allows:
- **Blob public access** (if needed for public URLs)
- **Shared access signature (SAS)** permissions

## Benefits of Managed Identity

### Security Improvements
- ✅ No secrets in code or configuration files
- ✅ Automatic credential rotation
- ✅ Azure AD-based authentication
- ✅ Fine-grained access control with RBAC

### Operational Benefits
- ✅ Simplified deployment (no secret management)
- ✅ Better audit trail
- ✅ Reduced credential exposure risk

## Troubleshooting

### Common Issues

1. **"DefaultAzureCredential failed" error**
   - Ensure you're logged in with `az login` for local development
   - Verify managed identity is enabled for Azure-hosted services

2. **"Insufficient permissions" for SAS token generation**
   - Verify the **Storage Blob Delegator** role is assigned
   - Check that the **Storage Blob Data Contributor** role is assigned

3. **Cannot access storage account**
   - Verify the storage account name in `AZURE_STORAGE_ACCOUNT_NAME`
   - Ensure network access rules allow your service

### Fallback Behavior
The code maintains backward compatibility:
- If `AZURE_STORAGE_USE_MANAGED_IDENTITY` is `false` or not set, it uses connection strings
- If managed identity fails, it falls back to local file storage
- Detailed error logging helps identify configuration issues

## Testing the Configuration

1. Set `AZURE_STORAGE_USE_MANAGED_IDENTITY="true"` in your `.env` file
2. Ensure your managed identity has the required roles
3. Upload a file through the application
4. Check the logs for successful managed identity authentication

The application will log whether it's using managed identity or falling back to other methods.
# Azure AI Foundry Image Generation Configuration

This document describes the changes made to convert the OpenAI client to Azure AI Foundry for image generation.

## Changes Made

### 1. Client Configuration Updates

**Before (OpenAI):**
```python
from openai import OpenAI

client = OpenAI(api_key=api_key)
```

**After (Azure AI Foundry):**
```python
from openai import AzureOpenAI, OpenAI
from azure.identity import get_bearer_token_provider

# With API Key
client = AzureOpenAI(
    api_key=api_key,
    azure_endpoint=endpoint,
    api_version=api_version
)

# With Managed Identity (Recommended)
token_provider = get_bearer_token_provider(
    credential, 
    "https://cognitiveservices.azure.com/.default"
)
client = OpenAI(
    base_url=f"{endpoint}/openai/v1/",
    api_key=token_provider,
)
```

### 2. Environment Variables

**Required Environment Variables:**
- `AZURE_OPENAI_ENDPOINT` - Your Azure OpenAI resource endpoint
- `AZURE_OPENAI_API_KEY` - Your API key (optional if using managed identity)
- `AZURE_OPENAI_API_VERSION` - API version (defaults to "2024-02-01")
- `AZURE_OPENAI_IMAGE_DEPLOYMENT_NAME` - Your deployed model name (defaults to "gpt-image-1")
- `AZURE_AI_FOUNDRY_PROJECT_ENDPOINT` - Your AI Foundry project endpoint

**Example Values:**
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_API_VERSION=2024-02-01
AZURE_OPENAI_IMAGE_DEPLOYMENT_NAME=gpt-image-1
AZURE_AI_FOUNDRY_PROJECT_ENDPOINT=https://your-foundry-project.azure.com/
```

### 3. Authentication Methods

The implementation now supports two authentication methods:

#### API Key Authentication (Simpler)
Set `AZURE_OPENAI_API_KEY` environment variable.

#### Managed Identity Authentication (Recommended)
- Don't set `AZURE_OPENAI_API_KEY`
- Ensure your environment has managed identity configured
- Uses `DefaultAzureCredential` for authentication

### 4. Model Deployment Support

The agent now properly uses Azure deployment names instead of raw model names:

- Supports `gpt-image-1`, `dalle3`, and other Azure OpenAI image models
- Uses the deployment name from `AZURE_OPENAI_IMAGE_DEPLOYMENT_NAME`
- Falls back to "gpt-image-1" if not specified

### 5. Tool Description Updates

Updated the function tool description to reflect Azure deployment names:
```python
"model": {
    "type": "string", 
    "description": "Azure OpenAI deployment name (typically 'gpt-image-1' or 'dalle3')."
}
```

## Benefits of Azure AI Foundry Integration

1. **Enterprise Security**: Managed identity support eliminates need for API key management
2. **Compliance**: Uses Azure security and compliance features
3. **Integration**: Better integration with other Azure AI services
4. **Scalability**: Leverages Azure's global infrastructure
5. **Cost Management**: Better cost tracking and management through Azure

## Migration Checklist

- [x] Update imports to use `AzureOpenAI`
- [x] Add managed identity authentication support
- [x] Update environment variable handling
- [x] Update model deployment name logic
- [x] Update type hints and method signatures
- [x] Update tool descriptions
- [x] Add comprehensive error handling
- [x] Maintain backward compatibility

## Testing

Run the test script to verify configuration:
```bash
cd remote_agents/azurefoundry_image_generator
python test_azure_openai.py
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Ensure environment variables are set correctly
2. **Model Not Found**: Verify your deployment name matches the environment variable
3. **Quota Issues**: Azure AI Foundry agents require minimum 20,000 TPM quota
4. **Managed Identity**: Ensure your environment supports managed identity

### Debug Information

The agent logs authentication method being used:
- "Using API key authentication for Azure OpenAI"
- "Using managed identity authentication for Azure OpenAI"

Check the logs to verify the correct authentication method is being used.
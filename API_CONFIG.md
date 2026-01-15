# API Configuration Guide

## Environment Setup

This app supports multiple environments with different API configurations:

### Development Environment
- **Debug builds**: Uses local development server
- **Default URL**: `http://10.0.2.2:3333` (Android emulator localhost)
- **Features**: Detailed error messages, logging enabled, shorter timeouts

### Production Environment
- **Release builds**: Uses production server
- **Default URL**: `https://api.myexpense.app` (NEEDS TO BE UPDATED)
- **Features**: User-friendly error messages, no logging, longer timeouts

## Configuration Files

### 1. API Constants (`lib/core/constants/api_constants.dart`)

```dart
static String _getProductionBaseUrl() {
  // UPDATE THIS with your actual production API URL
  return 'https://api.myexpense.app'; // <-- UPDATE THIS
}
```

**Action Required**: Replace `https://api.myexpense.app` with your actual production API URL.

### 2. Fallback URLs

The app includes fallback URLs that will be tried if the primary URL fails:
- `https://api.myexpense.app`
- `https://myexpense-api.herokuapp.com`
- `https://api.myexpense.herokuapp.com`
- `https://my-expense-api.onrender.com`

Update these as needed for your deployment.

## Network Configuration

### Timeouts
- **Development**: 10 seconds
- **Production**: 15 seconds

### Error Handling
- **Development**: Shows detailed error messages and technical details
- **Production**: Shows user-friendly error messages

### Retry Logic
- **Development**: 1 retry
- **Production**: 3 retries with exponential backoff

## Testing API Connectivity

The app includes built-in connectivity testing:

```dart
final apiService = ApiService();
bool isConnected = await apiService.testConnectivity();
```

## Common Production Issues

1. **CORS Issues**: Ensure your backend allows requests from your app's domain
2. **SSL/TLS**: Use HTTPS in production
3. **Timeouts**: Adjust timeouts based on server response times
4. **API Versioning**: Consider versioning your API endpoints

## Deploying to Production

1. Update the production URL in `api_constants.dart`
2. Test with `flutter build apk --release` or `flutter build ios --release`
3. Verify API connectivity in the release build
4. Monitor error logs for production issues

## Environment-Specific Features

### Debug Mode Only:
- Detailed error messages
- Request/response logging
- shorter timeouts
- Fallback URL testing disabled

### Release Mode Only:
- User-friendly error messages
- No sensitive information exposed
- Longer timeouts for better reliability
- Fallback URL testing enabled
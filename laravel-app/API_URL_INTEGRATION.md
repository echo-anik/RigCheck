# API URL Integration for RigCheck App

To connect your application to the deployed API, use the following base URL:

```
https://yellow-dinosaur-111977.hostingersite.com
```

## How to use
- In your frontend or mobile app, set the API base URL to the above address.
- Example endpoint: `https://yellow-dinosaur-111977.hostingersite.com/api/v1/your-endpoint`
- Update any environment variables (e.g., `NEXT_PUBLIC_API_URL`, `REACT_APP_API_URL`, etc.) to this URL.
- Remove any references to `localhost` or `127.0.0.1` in your app config.

**Tip:**
If you use environment files, set:
```
NEXT_PUBLIC_API_URL=https://yellow-dinosaur-111977.hostingersite.com
```

That’s it! Your app will now communicate with the live API.

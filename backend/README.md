# Backend API

Express.js API server for the Decentralized Identity and Resume Management platform.

## Setup

```bash
cd backend
npm install
```

## Configuration

1. Copy `.env.example` to `.env`
2. Fill in your configuration:
   - MongoDB connection string
   - Blockchain RPC URL
   - Contract addresses (after deployment)
   - IPFS configuration

## Development

```bash
npm run dev
# Server runs on http://localhost:3001
```

## API Endpoints

### Identity
- `POST /api/identity/register` - Register or update identity
- `GET /api/identity/:address` - Get user profile

### Credentials
- `POST /api/credentials/issue` - Issue a credential
- `GET /api/credentials/user/:address` - Get user's credentials
- `GET /api/credentials/:credentialId` - Get credential by ID
- `POST /api/credentials/:credentialId/revoke` - Revoke credential

### Resumes
- `POST /api/resumes/create` - Create a resume
- `GET /api/resumes/user/:address` - Get user's resumes
- `GET /api/resumes/:resumeId` - Get resume by ID
- `PUT /api/resumes/:resumeId` - Update resume
- `POST /api/resumes/:resumeId/revoke` - Revoke resume

### Access
- `POST /api/access/grant` - Grant access to resume
- `POST /api/access/verify` - Verify access token
- `POST /api/access/revoke` - Revoke access

### Issuers
- `POST /api/issuers/register` - Register as issuer
- `GET /api/issuers/:address` - Get issuer info

## Database Models

- **User** - User profiles and identity data
- **Credential** - Verifiable credentials
- **Resume** - Resume documents
- **AccessGrant** - Access control tokens

## IPFS Integration

The backend automatically uploads data to IPFS:
- User profiles
- Credential data
- Resume content

IPFS CIDs are stored in the database and can be retrieved via gateway URLs.

## Testing

```bash
npm test
```

## Production

```bash
npm run build
npm start
```

## Environment Variables

See `.env.example` for all required variables.


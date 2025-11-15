# Project Requirements Document
## Project: Decentralized Identity and Resume Management (Blockchain-Based)

## 1. Purpose

Design and implement a blockchain-based platform that allows individuals to own and control their verified digital identity, resumes, and references. Employers and organizations can instantly validate this information without relying on centralized intermediaries.

## 2. Objectives

1. Give users cryptographic ownership of their identity and career data.
2. Enable employers/organizations to verify identity, education, work history, and references quickly and securely.
3. Prevent tampering and fraud in resumes and references.
4. Support privacy-preserving, selective sharing of data (only what is needed, only with consent).

**Success metrics (examples):**

- Identity verification time reduced vs traditional methods.
- Number of verified credentials stored on-chain.
- Number of successful resume/reference verification operations.

## 3. Stakeholders and User Roles

- **Individual User (Candidate):** Student or professional creating and sharing a verified identity/resume.
- **Employer/Recruiter:** Validates candidate data and references for jobs or internships.
- **Issuer/Verifier Organizations:** Universities, companies, certifying bodies that issue verified credentials.
- **Platform Admin/Governance Entity:** Manages network parameters, contract upgrades, dispute resolution.

## 4. Scope

### In Scope

- Creation and management of decentralized identities (e.g., via wallet/DID).
- Storage and verification of:
  - Identity attributes (name, email, university ID, etc.).
  - Educational credentials, employment history, certifications.
  - References (signed by referees).
- Resume assembly from verified credentials plus optional self-claimed data.
- Fine-grained consent and secure sharing links/tokens for employers.
- Employer-side verification workflows (view, verify, log access).
- Basic reputation/audit trail of verifications (on-chain or off-chain logs).

### Out of Scope (for initial version)

- Full ATS (Applicant Tracking System) features.
- On-chain storage of full resume PDFs or large files (use off-chain storage like IPFS/cloud with hashes on-chain).
- KYC/identity proofing beyond cryptographic verification (e.g., passport checks), unless specifically integrated via a partner.

## 5. System Overview / High-Level Architecture

- **Client Applications:**
  - Web or mobile app for candidates and employers.
  - Integrated wallet for key management (or connection to existing wallets).
- **Blockchain Layer:**
  - Smart contracts that manage:
    - Identity registry (mapping wallets/DIDs to user identities).
    - Credential issuance and verification.
    - Resume “views” that reference sets of credentials.
    - Access control and consent management.
- **Off-Chain Services:**
  - Metadata and file storage (e.g., resumes, certificates) via IPFS or secure cloud; only hashes or pointers on-chain.
  - Notification and email services.
  - Indexing/API layer for efficient queries.
- **Standards (recommended):**
  - Decentralized Identifiers (DID) and Verifiable Credentials (VC) where possible.

## 6. Functional Requirements

### 6.1 Identity and Onboarding

- **FR-1:** The system shall allow a new user to create or connect a blockchain wallet (or DID) as their identity anchor.
- **FR-2:** The system shall register the user’s identity in an on-chain identity registry smart contract.
- **FR-3:** Users shall be able to update basic profile data (e.g., name, headline, location) stored off-chain, with a hash recorded on-chain for integrity.

### 6.2 Credential Issuance and Verification

- **FR-4:** The system shall allow issuer organizations (e.g., universities, companies) to register as verified issuers via an admin or governance process.
- **FR-5:** Verified issuers shall be able to issue credentials to a user’s on-chain identity.
- **FR-6:** Each credential shall include:
  - Issuer identity
  - Subject identity (user)
  - Credential type (degree, employment, certification, reference)
  - Issue date and optional expiry
  - Cryptographic signature and on-chain reference
- **FR-7:** Employers shall be able to verify the authenticity and integrity of a credential by:
  - Checking the issuer’s registered status.
  - Checking the credential hash/signature on-chain.

### 6.3 Resume Management

- **FR-8:** Users shall be able to build one or more resumes by selecting a subset of their credentials plus optional self-claimed items (skills, summary, etc.).
- **FR-9:** Each resume shall be represented by an off-chain document (e.g., JSON or PDF) with a content hash stored on-chain.
- **FR-10:** Users shall be able to update or revoke a resume; new versions must have new hashes and timestamps.

### 6.4 References

- **FR-11:** Users shall be able to send reference requests to potential referees (e.g., professors, managers).
- **FR-12:** Referees shall be able to:
  - Authenticate as themselves (via wallet or verified account).
  - Issue a signed reference credential linked to the user’s identity.
- **FR-13:** Employers shall be able to verify that a reference was indeed issued by the claimed referee identity and has not been tampered with or revoked.

### 6.5 Sharing and Consent

- **FR-14:** Users shall be able to generate share links or access tokens granting employers view access to specific resumes and subsets of credentials.
- **FR-15:** The system shall enforce that only authorized viewers (e.g., via signed access tokens or on-chain permissions) can see protected data.
- **FR-16:** Users shall be able to revoke previously granted access, invalidating further views through that link/token.

### 6.6 Employer/Recruiter Workflows

- **FR-17:** Employers shall be able to view a candidate’s shared resume and associated credentials via the platform.
- **FR-18:** Employers shall be able to verify all linked credentials and references with a single operation (batch verification).
- **FR-19:** The system shall show which parts of a resume are verified vs self-claimed.

### 6.7 Audit, Logs, and Reputation

- **FR-20:** The system shall log access and verification events (viewer, timestamp, operations performed) in an immutable or append-only store (on-chain or off-chain with integrity proofs).
- **FR-21:** Users shall be able to see which organizations have accessed their data.
- **FR-22:** The system shall support revocation of credentials by issuers (e.g., rescinded certificates) and reflect revocation in future verifications.

### 6.8 Administration and Governance

- **FR-23:** Admins shall be able to approve or revoke issuer status for organizations.
- **FR-24:** Admins shall be able to upgrade smart contracts or configuration via a governed process (e.g., multisig, DAO-like voting).
- **FR-25:** The system shall provide dispute channels (e.g., flag incorrect or fraudulent credentials).

## 7. Non-Functional Requirements

- **NFR-1 (Security):**
  - All private keys remain under the user’s control; the platform shall not store user private keys in plaintext.
  - End-to-end encryption for data in transit (HTTPS/TLS).

- **NFR-2 (Privacy):**
  - No sensitive personal data should be stored directly on-chain; only hashes, identifiers, or pseudonymous references.
  - Support for selective disclosure: users share only necessary attributes.

- **NFR-3 (Scalability & Performance):**
  - Normal verification operations should complete within a few seconds under typical network conditions.
  - Design must support thousands of users and credentials without prohibitive gas costs.

- **NFR-4 (Availability):**
  - Target 99% uptime for the web/API layer.
  - Read-only verification should still be possible even if some off-chain services are temporarily down, as long as the blockchain is available.

- **NFR-5 (Usability):**
  - Non-technical users should be able to create an identity and share a resume with minimal blockchain knowledge.
  - Clear UX around what is “verified” vs “self-claimed.”

- **NFR-6 (Interoperability):**
  - Prefer existing standards (DID, VC) to allow later integration with other identity providers/job platforms.

- **NFR-7 (Maintainability):**
  - Smart contracts should be modular and upgradeable (proxy pattern or similar).
  - Codebase with tests, CI, and documentation.

## 8. Data Model Overview (Conceptual)

**Entities (simplified):**

- **UserIdentity**
  - id (on-chain address/DID)
  - profile metadata (off-chain, hashed)
- **Issuer**
  - id (address/DID)
  - verification status (approved/revoked)
- **Credential**
  - credential_id
  - subject_user_id
  - issuer_id
  - type (degree, employment, certificate, reference)
  - fields (structured data off-chain + hash on-chain)
  - issue_date, expiry_date, revoked_flag
- **Resume**
  - resume_id
  - owner_user_id
  - list of credential_ids
  - additional self-claimed fields
  - off-chain document URI + hash
- **AccessGrant**
  - grant_id
  - owner_user_id
  - target_employer_id or link_token
  - allowed_resume_id(s) and credential scope
  - created_at, revoked_at

On-chain: identifiers, hashes, permissions, and status flags.
Off-chain: large or sensitive data (full resumes, reference text, transcripts).

## 9. Blockchain-Specific Requirements

- **BC-1:** The platform shall run on a chosen blockchain network (public, permissioned, or L2) with support for smart contracts and reasonable transaction costs.
- **BC-2:** Smart contracts shall be written in an appropriate language (e.g., Solidity if EVM-based).
- **BC-3:** The system shall minimize on-chain storage and focus on storing hashes and pointers to off-chain data.
- **BC-4:** The system shall provide a clear strategy for handling gas/fees (e.g., meta-transactions, sponsor contracts for certain operations).
- **BC-5:** Identity and credential data formats should be compatible with DID/VC standards where possible.

## 10. Assumptions and Dependencies

- Users can access a wallet or embedded key management solution.
- At least some universities/employers are willing to act as verified issuers.
- Chosen chain and off-chain storage (IPFS or cloud provider) are available and reliable.
- Legal and compliance requirements (e.g., data protection laws) are addressed at design time.

## 11. Risks (High-Level) and Considerations

- User key loss (risk of losing access to identity and credentials).
- Gas price volatility affecting transaction costs.
- Privacy concerns if too much identifiable data is pushed on-chain.
- Adoption barriers from issuers/employers unfamiliar with blockchain.

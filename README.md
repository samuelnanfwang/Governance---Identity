# 🎓 University Degree Verifier

A blockchain-based degree verification system that enables universities to issue tamper-proof digital certificates and allows employers to instantly verify academic credentials.

## 🌟 Features

- 🏛️ **University Registration**: Contract owner can register verified universities
- 📜 **Degree Issuance**: Universities can issue digital degree certificates as NFTs
- 🔍 **Instant Verification**: Employers can verify degree authenticity on-chain
- 👨‍💼 **Admin Management**: Universities can delegate issuance rights to admins
- 🔒 **Fraud Prevention**: Immutable records prevent certificate forgery
- 📊 **Comprehensive Tracking**: Track total universities and degrees issued

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity smart contracts

### Installation

```bash
git clone <repository-url>
cd Governance---Identity
clarinet console
```

## 📖 Usage

### 1. Register a University 🏛️

Only the contract owner can register universities:

```clarity
(contract-call? .governance-identity register-university 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 "Harvard University")
```

### 2. Add University Admin 👨‍💼

```clarity
(contract-call? .governance-identity add-university-admin 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE)
```

### 3. Issue a Degree 🎓

Universities or their admins can issue degrees:

```clarity
(contract-call? .governance-identity issue-degree 
    'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE  ;; student
    "Bachelor of Science"                          ;; degree-type
    "Computer Science"                             ;; field-of-study
    u2023                                          ;; graduation-year
    "3.75"                                         ;; gpa
    (some "https://metadata.uri"))                 ;; metadata-uri
```

### 4. Verify a Degree ✅

Anyone can verify a degree's authenticity:

```clarity
(contract-call? .governance-identity verify-degree u1)
```

### 5. Check Student's Degrees 📚

```clarity
(contract-call? .governance-identity get-student-degrees 'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

## 🔧 Smart Contract Functions

### Public Functions

| Function | Description | Who Can Call |
|----------|-------------|--------------|
| `register-university` | Register a new university | Contract owner only |
| `add-university-admin` | Add admin for university | Contract owner only |
| `issue-degree` | Issue a degree certificate | Universities/Admins |
| `revoke-degree` | Revoke a degree | University/Admin/Owner |
| `transfer-degree` | Transfer degree ownership | Current owner |
| `update-university-verification` | Update university status | Contract owner only |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-university-info` | Get university details | University info |
| `get-degree-info` | Get degree details | Degree info |
| `verify-degree` | Verify degree authenticity | Verification result |
| `get-student-degrees` | Get all student degrees | List of degree IDs |
| `get-total-universities` | Total registered universities | Number |
| `get-total-degrees` | Total degrees issued | Number |

## 🎯 Use Cases

### For Universities 🏛️
- Issue tamper-proof digital degrees
- Manage degree issuance through admins
- Maintain institutional credibility

### For Employers 👔
- Instantly verify candidate credentials
- Reduce hiring fraud and verification costs
- Access comprehensive degree information

### For Students 🎓
- Own immutable proof of academic achievement
- Share verifiable credentials with employers
- Transfer degree ownership if needed

## 🛡️ Security Features

- **Access Control**: Role-based permissions for different actions
- **University Verification**: Only verified universities can issue valid degrees
- **Immutable Records**: Blockchain ensures degree data cannot be altered
- **Ownership Tracking**: Clear ownership and transfer mechanisms

## 📊 Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | `err-owner-only` | Action requires contract owner |
| u101 | `err-not-authorized` | User not authorized for action |
| u102 | `err-already-exists` | Entity already exists |
| u103 | `err-not-found` | Entity not found |
| u104 | `err-invalid-degree` | Invalid degree parameters |
| u105 | `err-university-not-registered` | University not registered |

## 🧪 Testing

Run the test suite:

```bash
clarinet test
```



## 📄 License

This project is licensed under the MIT License.

---

Built with ❤️ for transparent academic verification

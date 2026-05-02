# Self-Hosting Repos on a Business Cloud

"Instead of putting sensitive Git repos on GitHub (even private ones), or using heavy encryption layers on top of GitHub, I’ll run my own Git server (Gitea, Forgejo, GitLab, etc.) but hosted on a proper business cloud provider like Microsoft Azure, AWS, or Google Cloud."

This approach sits between the two other strategies and is often the **sweet spot** for many organizations.

### The Three Strategies Compared

| Strategy | Encryption Level | Git Experience | Operational Effort | Best For | Main Weakness |
|---------|------------------|----------------|--------------------|----------|---------------|
| **1. git-remote-gcrypt on GitHub** | Very High (full repo encrypted) | Good (but no PRs, broken web UI) | Low | Maximum encryption with minimal hosting | Slow pushes, broken GitHub features |
| **2. Filter tools (transcrypt/git-crypt) on GitHub** | Medium-High (selective or full) | Excellent (transparent) | Very Low | Simplicity + speed | History bloat if encrypting most files |
| **3. Self-hosted Git on Azure/AWS/GCP** | High (provider + optional customer keys) | **Excellent** (full Git features) | Medium-High | Balance of control + normal workflow | You manage the server |

### Encryption by Default vs. Optional Hardening

Strategies 1 and 2 (git-remote-gcrypt and filter-based tools) provide true end-to-end encryption by default. The data is encrypted on your machine before it ever leaves, and the Git host (GitHub, etc.) never has access to the plaintext or the encryption keys.
Strategy 3 (Self-hosted Git on Azure/AWS/GCP) only provides provider-managed encryption at rest by default. While the data is encrypted on disk, the cloud provider holds the keys. To achieve comparable protection (where even the cloud provider cannot easily decrypt your data), you must enable Customer-Managed Keys (CMK). This requires additional configuration, ongoing key management, vendor-specific workflows (e.g. Azure Key Vault, AWS KMS), and more operational expertise.

### Why Strategy 3 Can Make Sense

Many companies consider even **private repositories on GitHub** insufficient for sensitive business data because:

- GitHub is ultimately controlled by Microsoft, but it's a **consumer-oriented platform** with different compliance boundaries.
- Data residency, access by Microsoft employees, and legal requests can be concerns in highly regulated industries.
- Business cloud providers (Azure, AWS, GCP) offer much stronger enterprise features:
  - Customer-managed encryption keys
  - Private networking (no public exposure)
  - Advanced logging and auditing
  - Integration with corporate identity systems (Entra ID, Okta, etc.)
  - Better compliance certifications (ISO, SOC2, HIPAA, etc.)

### Pros of Self-Hosting on a Business Cloud

- You get a **normal Git experience** (full Pull Requests, web UI, CI/CD integration, etc.).
- You can use **Customer-Managed Keys** so even the cloud provider has limited access.
- Much better control over data location and access.
- You can harden the instance significantly (private endpoints, network security groups, etc.).
- Easier to meet strict internal security policies.

### Cons

- You have to **manage the server** (updates, backups, monitoring, security patches).
- Higher operational cost and complexity than just using GitHub or GitLab.com.
- Still ultimately depends on the underlying cloud provider’s infrastructure.
- Not true end-to-end encryption by default. As long as the cloud provider holds the encryption keys (i.e. without enabling Customer-Managed Keys), the protection is significantly weaker. In the event of a major breach or government request, data can still leak.
- Vendor lock-in: Maintaining multiple remotes across different providers (or migrating the instance to a new provider) becomes significantly more complex and costly compared to using hosted services like GitHub.

### Common Choices in Practice

| Self-Hosted Option     | Popularity | Difficulty | Notes |
|------------------------|------------|------------|-------|
| **Gitea / Forgejo**    | Very High  | Low        | Lightweight, easy to run |
| **GitLab Self-Managed**| High       | Medium     | Very feature-rich |
| **GitHub Enterprise Server** | Medium | Medium-High | If you want GitHub features on your own infra |
| **Azure DevOps Server** | Medium    | Medium     | Good Microsoft integration |

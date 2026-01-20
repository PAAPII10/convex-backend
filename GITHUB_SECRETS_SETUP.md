# GitHub Secrets Setup Guide

## Required Secrets

Add these secrets in your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

### 1. AWS_ACCESS_KEY_ID
- **What**: AWS access key for programmatic access
- **How to get**:
  1. AWS Console → IAM → Users
  2. Select your user (or create one)
  3. Security credentials tab → Create access key
  4. Copy the Access key ID
- **Example**: `AKIAIOSFODNN7EXAMPLE`

### 2. AWS_SECRET_ACCESS_KEY
- **What**: AWS secret access key (paired with above)
- **How to get**: Same as above, copy the Secret access key
- **Example**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
- **⚠️ Important**: Save this immediately, you can't view it again

### 3. EC2_SSH_KEY
- **What**: The private key file content (`.pem` file)
- **How to get**:
  1. When you created your EC2 instance, you downloaded a `.pem` file
  2. Open the `.pem` file in a text editor
  3. Copy the entire content including:
     ```
     -----BEGIN RSA PRIVATE KEY-----
     ... (all the content) ...
     -----END RSA PRIVATE KEY-----
     ```
  4. Paste the entire content as the secret value
- **⚠️ Important**: Include the BEGIN and END lines

### 4. EC2_USERNAME
- **What**: The default username for your EC2 instance
- **How to find**: Depends on your AMI (Amazon Machine Image)

| AMI Type | Username |
|----------|----------|
| **Ubuntu** | `ubuntu` |
| Amazon Linux 2 | `ec2-user` |
| Amazon Linux 2023 | `ec2-user` |
| Debian | `admin` |
| RHEL | `ec2-user` |
| CentOS | `centos` |

**Most common**: `ubuntu` (if using Ubuntu AMI)

**How to verify**:
```bash
# If you can SSH in, the username you use is correct
ssh -i your-key.pem ubuntu@your-ec2-ip
#                    ^^^^^^ This is your EC2_USERNAME
```

### 5. HOST_DNS
- **What**: Your EC2 instance's public IP address or public DNS name
- **How to find**:

  **Method 1: AWS Console**
  1. Go to AWS Console → EC2 → Instances
  2. Click on your EC2 instance
  3. Look for "Public IPv4 address" or "Public IPv4 DNS"
  4. Copy either one (both work)

  **Method 2: Command Line (if SSH'd in)**
  ```bash
  # Get public IP
  curl http://169.254.169.254/latest/meta-data/public-ipv4
  
  # Get public DNS
  curl http://169.254.169.254/latest/meta-data/public-hostname
  ```

- **Examples**:
  - Public IP: `3.123.45.67`
  - Public DNS: `ec2-3-123-45-67.compute-1.amazonaws.com`
  - Either format works!

### 6. AWS_REGION
- **What**: The AWS region where your EC2 instance is located
- **How to find**:
  1. AWS Console → EC2 → Instances
  2. Look at the "Availability Zone" column
  3. The region is the part before the last dash
  4. Example: `us-east-1a` → region is `us-east-1`

- **Common regions**:
  - `us-east-1` (N. Virginia)
  - `us-west-2` (Oregon)
  - `eu-west-1` (Ireland)
  - `ap-south-1` (Mumbai)

### 7. CONVEX_ENV ⭐ **REQUIRED**
- **What**: The complete content of your `.env` file
- **How to create**:
  1. On your local machine, create a `.env` file with all your Convex configuration:
     ```env
     DATABASE_URL=postgresql://postgres:password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543
     CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key_here
     INSTANCE_SECRET=your_instance_secret_here
     CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
     CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
     ```
  2. Copy the entire content of the `.env` file
  3. Paste it as the `CONVEX_ENV` secret value
- **⚠️ Important**: 
  - Include all variables (DATABASE_URL, CONVEX_SELF_HOSTED_ADMIN_KEY, INSTANCE_SECRET, etc.)
  - Don't include comments or empty lines (or they'll be included in the file)
  - Keep this secret secure - it contains sensitive credentials

## Quick Checklist

- [ ] `AWS_ACCESS_KEY_ID` - From IAM user credentials
- [ ] `AWS_SECRET_ACCESS_KEY` - From IAM user credentials (save immediately!)
- [ ] `EC2_SSH_KEY` - Content of your `.pem` file (entire file including BEGIN/END)
- [ ] `EC2_USERNAME` - Usually `ubuntu` (check your AMI type)
- [ ] `HOST_DNS` - Public IP or DNS from EC2 console
- [ ] `AWS_REGION` - Region from EC2 instance details
- [ ] `CONVEX_ENV` ⭐ - Complete `.env` file content (all environment variables)

## Testing Your Secrets

After adding secrets, you can test the connection:

```bash
# Test SSH connection (replace with your values)
ssh -i your-key.pem ubuntu@your-ec2-ip
```

If this works, your secrets should work in GitHub Actions too.

## Troubleshooting

### "Permission denied (publickey)"
- Check `EC2_USERNAME` is correct for your AMI
- Verify `EC2_SSH_KEY` includes BEGIN/END lines
- Ensure `.pem` file permissions: `chmod 400 your-key.pem` (for local testing)

### "Connection timeout"
- Check `HOST_DNS` is correct (public IP or DNS)
- Verify Security Group allows SSH (port 22) from GitHub Actions IP
- Check EC2 instance is running

### "Invalid credentials"
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correct
- Check IAM user has necessary permissions
- Ensure access keys are active (not disabled)

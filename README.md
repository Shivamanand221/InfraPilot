# InfraPilot

An intelligent infrastructure automation platform that combines cloud infrastructure provisioning with intelligent automation capabilities. InfraPilot streamlines infrastructure deployment, management, and monitoring through a unified interface.

**Note**: This project includes a cloned [Strapi](https://strapi.io/) instance in the `Strapi/` directory for headless CMS capabilities. See `Strapi/README.md` for Strapi-specific documentation.

## 🚀 Features

- **Infrastructure as Code (IaC)**: Terraform-based infrastructure provisioning with HCL configurations
- **Automation Engine**: Intelligent workflow automation and orchestration
- **CLI Tools**: Command-line utilities for infrastructure management and deployment
- **API Integration**: RESTful APIs for seamless integration with existing systems
- **Monitoring & Logging**: Built-in monitoring capabilities for infrastructure health
- **Cloud-Agnostic**: Support for multiple cloud providers (AWS, Azure, GCP)
- **Deployment Automation**: Scripts and tools for automated infrastructure deployment

## 📋 Prerequisites

- **Node.js** (v16 or higher)
- **Terraform** (v1.0 or higher)
- **Git**
- Cloud provider credentials (AWS, Azure, or GCP)

## 💻 Tech Stack (InfraPilot Core)

- **Orchestration & Automation**: JavaScript, TypeScript
- **Infrastructure as Code**: HCL (Terraform)
- **Scripting & Deployment**: Shell scripts
- **Runtime**: Node.js

## 📦 Installation

### Clone the repository

```bash
git clone https://github.com/Shivamanand221/InfraPilot.git
cd InfraPilot
```

### Install dependencies

```bash
npm install
```

### Build the project

```bash
npm run build
```

## 🔧 Configuration

1. **Environment Setup**: Create a `.env` file in the root directory with your cloud provider credentials:

```env
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
REGION=us-east-1
```

2. **Terraform Configuration**: Update `terraform/` directory with your infrastructure definitions in HCL format.

3. **Application Config**: Configure application settings in `config/` directory.

## 🚀 Usage

### Running the application

```bash
npm start
```

### Building for production

```bash
npm run build:prod
```

### Infrastructure deployment

```bash
npm run deploy:infrastructure
```

### Running CLI commands

```bash
npm run cli -- [command] [options]
```

## 📁 Project Structure

```
InfraPilot/
├── src/
│   ├── core/           # Core application logic
│   ├── services/       # Business logic and services
│   ├── api/           # API endpoints
│   ├── cli/           # CLI commands
│   └── utils/         # Utility functions
├── terraform/         # Terraform configurations (HCL)
├── scripts/           # Shell scripts for automation and deployment
├── tests/             # Test files
├── config/            # Configuration files
├── Strapi/            # Cloned Strapi CMS (open source)
└── dist/              # Compiled output
```

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `NODE_ENV` | Environment (development, production) | Yes |
| `AWS_ACCESS_KEY_ID` | AWS access key | Conditional |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Conditional |
| `REGION` | Cloud region | Yes |
| `LOG_LEVEL` | Logging level (debug, info, warn, error) | No |
| `PORT` | Application port | No |

## 📧 Contact

For questions or support, please open an issue on the [GitHub repository](https://github.com/Shivamanand221/InfraPilot/issues).

---

**Last Updated**: 2026-07-12

# CI/CD Pipeline with Automated Docker Security Scanning & Kubernetes Deployment

A production-style DevSecOps project that demonstrates how to build a secure CI/CD pipeline using Jenkins, Docker, Trivy, and Kubernetes.

This pipeline automatically scans Docker images for vulnerabilities before deployment and blocks insecure images from reaching production.

---

# Project Objective

The security team discovered vulnerabilities inside production containers.  
To solve this problem, a secure CI/CD workflow was implemented where:

- Docker images are automatically scanned using Trivy
- Jenkins pipeline fails if CRITICAL vulnerabilities are detected
- Only secure images are pushed and deployed to Kubernetes

This project demonstrates how DevSecOps practices can be integrated into modern CI/CD workflows.

---

# Architecture Diagram

![Architecture Diagram](screenshots/architecture.png)

---

# Tech Stack

| Tool | Purpose |
|---|---|
| Jenkins | CI/CD Automation |
| Docker | Containerization |
| Trivy | Vulnerability Scanning |
| Kubernetes | Container Orchestration |
| GitHub | Source Code Management |
| DockerHub | Container Registry |
| Node.js | Application Runtime |

---

# Project Workflow

```text
Developer pushes code to GitHub
                │
                ▼
        Jenkins Pipeline Starts
                │
        ┌──── Clone Repository
        │
        ├──── Build Docker Image
        │
        ├──── Trivy Security Scan
        │          │
        │          ├── CRITICAL Vulnerabilities Found ❌
        │          │         → Pipeline Fails
        │          │
        │          └── No CRITICAL Vulnerabilities ✅
        │
        ├──── Push Image to DockerHub
        │
        └──── Deploy to Kubernetes
                       │
                       ▼
              Application Running
```

---

# Infrastructure Setup

| Server | Role | OS |
|---|---|---|
| Jenkins Server | Jenkins + Docker + Trivy | Ubuntu 22.04 |
| Kubernetes Master | Kubernetes Control Plane | Ubuntu 22.04 |
| Kubernetes Worker | Application Workloads | Ubuntu 22.04 |

### AWS Region
- ap-south-1 (Mumbai)

### Open Ports
- 22 → SSH
- 8080 → Jenkins
- 6443 → Kubernetes API
- 30000–32767 → NodePort Services

---

# Project Structure

```bash
jenkins-trivy-k8s-pipeline/
│
├── app.js
├── Dockerfile
├── Jenkinsfile
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
└── screenshots/
    ├── architecture.png
    ├── pipeline-pass.png
    ├── pipeline-fail.png
    ├── dockerhub.png
    ├── kubectl-output.png
    └── app-output.png
```

---

# Application

Simple Node.js web application:

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  res.end('<h1>Secure CI/CD Pipeline Working Successfully</h1>');
});

server.listen(3000, '0.0.0.0');
```

---

# Dockerfile

```dockerfile
FROM node:22-alpine3.21

RUN apk update && apk upgrade --no-cache

WORKDIR /app

COPY app.js .

EXPOSE 3000

CMD ["node", "app.js"]
```

### Why `apk upgrade`?

This step updates Alpine packages and helps reduce known vulnerabilities before the Trivy scan runs.

---

# Jenkins Pipeline

The Jenkins pipeline performs the following tasks:

1. Pull source code from GitHub
2. Build Docker image
3. Scan image using Trivy
4. Fail pipeline if CRITICAL vulnerabilities are found
5. Push secure image to DockerHub
6. Deploy application to Kubernetes

---

# Security Gating Logic

The most important part of this project is the security gate implemented using Trivy.

```text
Docker Image Built
        │
        ▼
Trivy Vulnerability Scan
        │
        ├── CRITICAL Vulnerabilities Found
        │           │
        │           └── Jenkins Build Fails ❌
        │
        └── No CRITICAL Vulnerabilities
                    │
                    └── Deployment Continues ✅
```

### Trivy Scan Command

```bash
trivy image --exit-code 1 --severity CRITICAL image-name
```

### How It Works

- `--severity CRITICAL` checks only critical vulnerabilities
- `--exit-code 1` forces Jenkins to fail the pipeline if vulnerabilities are detected
- Deployment stages are skipped automatically after failure

This ensures that insecure Docker images never reach the Kubernetes environment.

---

# Important Jenkinsfile Snippet

```groovy
stage('Trivy Security Scan') {
    steps {
        sh """
        trivy image --exit-code 1 \
        --severity CRITICAL \
        --no-progress \
        ${DOCKER_IMAGE}:${DOCKER_TAG}
        """
    }
}
```

---

# Kubernetes Deployment

### deployment.yaml

```yaml
replicas: 2

containers:
- name: nodejs-app
  image: poojanerkar/jenkins-trivy-k8s-pipeline:latest
```

### service.yaml

```yaml
type: NodePort
nodePort: 30001
```

Complete Kubernetes manifests are available inside the `k8s/` directory.

---

# Security Validation

To validate the security gate, a vulnerable Docker image was intentionally used.

### Vulnerable Base Image

```dockerfile
FROM node:18-alpine
```

### Trivy Scan Result

```text
Total: 19 Vulnerabilities
HIGH: 15
CRITICAL: 4
```

Result:
- Jenkins pipeline failed successfully
- Deployment was blocked
- Vulnerable image was never deployed

---

# Secure Deployment

After upgrading the base image:

```dockerfile
FROM node:22-alpine3.21
```

and updating packages using:

```dockerfile
RUN apk update && apk upgrade --no-cache
```

the Trivy scan passed successfully and the application was deployed to Kubernetes.

---

# Deployment Verification

```bash
kubectl get pods
kubectl get svc
```

Expected Output:

```text
NAME                          READY   STATUS
nodejs-app-xxxxx              1/1     Running
nodejs-app-yyyyy              1/1     Running
```

---

# Application Access

The application is exposed using a Kubernetes NodePort service.

```text
http://<worker-node-ip>:30001
```

---

# Screenshots

## Jenkins Pipeline Success

![Pipeline Success](screenshots/pipeline-pass.png)

---

## Jenkins Pipeline Failure

![Pipeline Failure](screenshots/pipeline-fail.png)

---

## DockerHub Repository

![DockerHub](screenshots/dockerhub.png)

---

## Kubernetes Pods Running

![Kubectl Output](screenshots/kubectl-output.png)

---

## Application Running

![Application Output](screenshots/app-output.png)

---

# Learning Outcomes

Through this project, I learned:

- CI/CD pipeline automation using Jenkins
- Docker image creation and optimization
- Kubernetes deployment basics
- Vulnerability scanning using Trivy
- DevSecOps security practices
- Automated deployment workflows
- Containerized application deployment

---

# Future Improvements

- Integrate SonarQube for code quality analysis
- Add Slack or email notifications
- Implement GitHub Webhooks
- Use Helm charts for Kubernetes deployment
- Add rolling updates and rollback strategies
- Store secrets securely using Kubernetes Secrets or Vault

---

# Conclusion

This project demonstrates how security can be integrated directly into a CI/CD pipeline using DevSecOps practices.

By implementing automated vulnerability scanning with Trivy, the pipeline ensures that insecure Docker images never reach the Kubernetes cluster. Only validated and secure images are deployed, improving production security and deployment reliability.

This project also demonstrates practical experience with:
- Jenkins
- Docker
- Kubernetes
- Trivy
- GitHub
- CI/CD Automation
- DevSecOps Workflows
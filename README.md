# Urban Fantasy Application

Containerized multi-service application deployed to Amazon EKS through a GitOps CI/CD workflow.

## Services

### Frontend

NGINX-based static web application.

Route:

`/`

Docker image:

`ajaxatx/urban-fantasy-app`

### Status API

Lightweight Python service used to demonstrate independent service deployment and ingress routing.

Route:

`/api/status`

Example response:

```json
{
  "service": "urban-fantasy-status-api",
  "status": "healthy"
}
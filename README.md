# Python CD to AWS Staging (Docker + Jenkins + ECR + EC2)

Minimal Flask app with pytest tests, Dockerized, and a Jenkins pipeline that:
- builds and tests the image
- pushes to Amazon ECR
- deploys to an EC2 staging server by pulling the new image and running it on port 80

## Quick Start (Local)
```bash
docker build -t flask-staging:local .
docker run --rm -p 8000:8000 -e GIT_SHA=local flask-staging:local
# open http://localhost:8000
```

## Project Structure
```
.
├── app/
│   ├── __init__.py
│   └── app.py
├── tests/
│   └── test_app.py
├── scripts/
│   ├── deploy_to_ec2.sh
│   └── ec2_bootstrap.sh
├── .dockerignore
├── Dockerfile
├── gunicorn.conf.py
├── Jenkinsfile
├── requirements.txt
└── README.md
```

## Environment Variables used at runtime
- `GIT_SHA` (optional): passed by the pipeline to identify the deployed commit.

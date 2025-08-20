FROM python:3.12-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir --upgrade pip

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY gunicorn.conf.py ./
EXPOSE 8000

# Default command runs gunicorn on port 8000
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app.app:app"]

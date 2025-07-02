FROM python:3.10-slim

WORKDIR /app

COPY . /app

# Ajoute curl
RUN apt-get update && apt-get install -y curl

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
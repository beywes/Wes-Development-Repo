FROM python:3.11-slim

# Install MySQL client
RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY wait-for-mysql.sh .
RUN chmod +x wait-for-mysql.sh

COPY app.py .

# Use wait-for script as entrypoint
ENTRYPOINT ["./wait-for-mysql.sh", "db"]
CMD ["python", "app.py"]

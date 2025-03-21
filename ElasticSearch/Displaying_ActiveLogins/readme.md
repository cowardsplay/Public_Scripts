This application requires two separate machines to function effectively.

1. Elasticsearch Setup: The first machine must host an operational Elasticsearch instance with an agent running to ensure logs are being collected and indexed appropriately.

2. Web Server Deployment: The second machine will act as the web server, hosting an Apache setup that serves the index.html homepage and processes data using the logs.php backend code.

It is essential to configure communication between these two systems to enable the web server to retrieve logs from Elasticsearch. Without this connection, the web application cannot access the required data.

After establishing the infrastructure, ensure the necessary fields in the code are correctly modified to reflect your specific setup. Upon successful completion of these steps, the dashboard will be operational, providing real-time updates on active logins with a refresh interval of 10 seconds.

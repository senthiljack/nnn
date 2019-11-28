# Use an official Python runtime as a parent image
FROM httpd

# Set the working directory to /app
WORKDIR /var/www/html/

# Copy the current directory contents into the container at /app
COPY *.jar /var/www/html/

# Install any needed packages specified in requirements.txt
#RUN apt-get update -y
#RUN apt-get install apache2 -y
#RUN sudo systemctl start httpd

# Make port 80 available to the world outside this container
#EXPOSE 80

# Define environment variable
#ENV NAME World

# Run app.py when the container launches
#CMD ["python", "app.py"]
#CMD service httpd start
CMD java -jar /var/www/html/*.jar

# Spring Boot Docker

A containerized Spring Boot REST API application built with Maven and Java 17, ready for deployment on Docker and Red Hat OpenShift.

## Project Overview

This project provides a lightweight Spring Boot web application that exposes two REST endpoints:

| Endpoint  | Method | Description                          |
|-----------|--------|--------------------------------------|
| `/health` | GET    | Returns `OK` — useful for liveness/readiness probes |
| `/search` | GET    | Returns a sample JSON response: `{"query":"example","result":"sample data"}` |

### Tech Stack

- **Java** 17
- **Spring Boot** 3.2.5
- **Maven** (build tool)
- **Docker** (containerization)

### Project Structure

```
springboot-docker/
├── Dockerfile
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/com/example/springbootdocker/
│   │   │   ├── SpringbootDockerApplication.java
│   │   │   └── ApplicationController.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/com/example/springbootdocker/
│           └── SpringbootDockerApplicationTests.java
└── README.md
```

## Prerequisites

- **Java 17** or later
- **Maven 3.8+**
- **Docker** (for container builds)
- **oc CLI** (for OpenShift deployment)

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/nparekh127/springboot-docker.git
cd springboot-docker
```

### 2. Build the Project

```bash
mvn clean package
```

This compiles the source code, runs tests, and produces an executable JAR in the `target/` directory.

### 3. Run Locally

```bash
java -jar target/springboot-docker-0.0.1-SNAPSHOT.jar
```

Or use the Maven Spring Boot plugin:

```bash
mvn spring-boot:run
```

The application starts on **port 8080** by default.

### 4. Verify the Endpoints

```bash
curl http://localhost:8080/health
# OK

curl http://localhost:8080/search
# {"query":"example","result":"sample data"}
```

### 5. Run Tests

```bash
mvn test
```

## Creating and Running the Docker Image

### Build the Docker Image

The included `Dockerfile` uses a multi-stage build to keep the final image small:

1. **Build stage** — compiles the application using Maven on an Alpine JDK image.
2. **Runtime stage** — runs the JAR on a minimal Alpine JRE image.

```bash
docker build -t springboot-docker:latest .
```

### Run the Docker Container

```bash
docker run -d -p 8080:8080 --name springboot-docker springboot-docker:latest
```

Verify the container is running:

```bash
curl http://localhost:8080/health
# OK
```

Stop and remove the container:

```bash
docker stop springboot-docker
docker rm springboot-docker
```

## Deploying to Red Hat OpenShift

### 1. Log In to OpenShift

```bash
oc login <openshift-cluster-url> --token=<your-token>
```

You can obtain the login token from the OpenShift web console under **Copy Login Command**.

### 2. Create a New Project (Namespace)

```bash
oc new-project springboot-docker
```

### 3. Push the Docker Image to OpenShift Registry

#### Option A: Use the OpenShift Internal Registry

Retrieve the internal registry URL:

```bash
oc registry info
```

Tag and push the image:

```bash
docker tag springboot-docker:latest <registry-url>/springboot-docker/springboot-docker:latest
docker push <registry-url>/springboot-docker/springboot-docker:latest
```

#### Option B: Use an External Registry (e.g., Quay.io, Docker Hub)

```bash
docker tag springboot-docker:latest <registry>/<namespace>/springboot-docker:latest
docker push <registry>/<namespace>/springboot-docker:latest
```

### 4. Deploy the Application

Create a deployment from the image:

```bash
oc new-app --name=springboot-docker --image=<registry>/springboot-docker/springboot-docker:latest
```

Or, if using the internal registry:

```bash
oc new-app --name=springboot-docker --image-stream=springboot-docker:latest
```

### 5. Expose the Service

Create a route to make the application accessible externally:

```bash
oc expose svc/springboot-docker
```

Get the route URL:

```bash
oc get route springboot-docker
```

### 6. Configure Health Probes

Add liveness and readiness probes using the `/health` endpoint:

```bash
oc set probe deployment/springboot-docker \
  --liveness \
  --get-url=http://:8080/health \
  --initial-delay-seconds=30 \
  --period-seconds=10

oc set probe deployment/springboot-docker \
  --readiness \
  --get-url=http://:8080/health \
  --initial-delay-seconds=15 \
  --period-seconds=10
```

### 7. Verify the Deployment

Check that the pod is running:

```bash
oc get pods
```

Test the endpoint via the route:

```bash
curl http://<route-url>/health
# OK

curl http://<route-url>/search
# {"query":"example","result":"sample data"}
```

### 8. View Logs

```bash
oc logs deployment/springboot-docker
```

### Cleanup

To remove all OpenShift resources:

```bash
oc delete all -l app=springboot-docker
oc delete project springboot-docker
```

## License

This project is provided as-is for demonstration purposes.

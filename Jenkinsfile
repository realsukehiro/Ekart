pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-token')
        DOCKER_CREDENTIALS = 'docker-hub-credentials'
        DOCKER_IMAGE = 'sukehiro03/shopping'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/realsukehiro/Ekart.git'
            }
        }
        stage('Compile') {
            steps {
                bat "mvn clean compile -DskipTests=true"
            }
        }
        stage('Verify Compilation') {
            steps {
                bat 'dir target\\classes'
            }
        }
        stage('Verify Scanner Path') {
            steps {
                bat 'echo %SCANNER_HOME%'
                bat 'dir %SCANNER_HOME%\\bin'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SONARQUBE') {
                    bat """
                        "%SCANNER_HOME%\\bin\\sonar-scanner" -X ^
                            -Dsonar.projectKey=shopping-cart ^
                            -Dsonar.projectName=shopping-cart ^
                            -Dsonar.host.url=http://localhost:9000 ^
                            -Dsonar.login=%SONAR_TOKEN% ^
                            -Dsonar.java.binaries=target/classes ^
                            -Dsonar.sources=src/main/java ^
                            -Dsonar.working.directory=.java
                    """
                }
            }
        }
        stage('Check Scanner Output') {
            steps {
                bat 'dir .java'
            }
        }
        stage('Build Application') {
            steps {
                bat 'mvn clean install -DskipTests=true'
            }
        }
        stage('Build & Push Docker Image') {
            steps {
                withDockerRegistry(credentialsId: DOCKER_CREDENTIALS, url: 'https://index.docker.io/v1/') {
                    bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% -f docker/Dockerfile ."
                    bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
                }
            }
        }
        stage('Trigger CD Pipeline') {
            steps {
                build job: 'CD_Pipeline', wait: true
            }
        }
    }
}

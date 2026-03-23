pipeline {
    agent any

    tools {
        nodejs 'NodeJS 25.8.1'
    }

    environment {
        APP_PORT = ''
        CONTAINER_NAME = ''
        IMAGE_NAME = ''
        IMAGE_TAG = 'v1.0'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checkout completo — rama: ${env.BRANCH_NAME}"
            }
        }

        stage('Set Environment') {
            steps {
                script {
                    def branch = env.BRANCH_NAME
                    if (branch == 'main') {
                        APP_PORT = '3000'
                        CONTAINER_NAME = 'app-main'
                        IMAGE_NAME = 'nodemain'
                    } else if (branch == 'dev') {
                        APP_PORT = '3001'
                        CONTAINER_NAME = 'app-dev'
                        IMAGE_NAME = 'nodedev'
                    } else {
                        error("Rama no reconocida: ${branch}")
                    }
                    echo "Puerto: ${APP_PORT} | Contenedor: ${CONTAINER_NAME} | Imagen: ${IMAGE_NAME}"
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
                echo "Dependencias instaladas"
            }
        }

        stage('Test') {
            steps {
                sh 'npm test -- --watchAll=false'
                echo "Tests completados"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def fullImageName = "${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker build -t ${fullImageName} ."
                    echo "Imagen construida: ${fullImageName}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def fullImageName = "${IMAGE_NAME}:${IMAGE_TAG}"
                    
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    
                    sh """
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${APP_PORT}:3000 \
                            ${fullImageName}
                    """
                    
                    echo "App desplegada en http://localhost:${APP_PORT}"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline exitoso — ${env.BRANCH_NAME} -> http://localhost:${APP_PORT}"
        }
        failure {
            echo "Pipeline fallo en rama ${env.BRANCH_NAME}"
        }
    }
}

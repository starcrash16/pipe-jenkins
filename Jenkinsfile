// Jenkinsfile — raíz del proyecto
// Pipeline: CICD (Multibranch)

pipeline {
    agent any

    tools {
        nodejs 'NodeJS 25.8.1'   // nombre exacto configurado en Global Tools
    }

    environment {
        // Imagen base por rama
        IMAGE_NAME = "node${BRANCH_NAME}"   // nodemain o nodedev
        IMAGE_TAG  = "v1.0"
    }

    stages {

        // ─────────────────────────────────────────
        stage('Checkout') {
            steps {
                checkout scm
                echo "✅ Checkout completo — rama: ${BRANCH_NAME}"
            }
        }

        // ─────────────────────────────────────────
        stage('Set Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.APP_PORT      = '3000'
                        env.CONTAINER_NAME = 'app-main'
                    } else if (env.BRANCH_NAME == 'dev') {
                        env.APP_PORT      = '3001'
                        env.CONTAINER_NAME = 'app-dev'
                    } else {
                        error("Rama no reconocida: ${BRANCH_NAME}")
                    }
                    echo "🔧 Puerto: ${env.APP_PORT} | Contenedor: ${env.CONTAINER_NAME}"
                }
            }
        }

        // ─────────────────────────────────────────
        stage('Build') {
            steps {
                sh 'npm install'
                echo "📦 Dependencias instaladas"
            }
        }

        // ─────────────────────────────────────────
        stage('Test') {
            steps {
                sh 'npm test -- --watchAll=false --passWithNoTests'
                echo "🧪 Tests completados"
            }
        }

        // ─────────────────────────────────────────
        stage('Build Docker Image') {
            steps {
                script {
                    def fullImageName = "${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    sh """
                        docker build \
                          --build-arg APP_PORT=${env.APP_PORT} \
                          -t ${fullImageName} .
                    """
                    echo "🐳 Imagen construida: ${fullImageName}"
                }
            }
        }

        // ─────────────────────────────────────────
        stage('Deploy') {
            steps {
                script {
                    def fullImageName = "${env.IMAGE_NAME}:${env.IMAGE_TAG}"

                    // ⚡ Eliminar SOLO el contenedor de este env (no el del otro)
                    sh """
                        docker rm -f ${env.CONTAINER_NAME} || true
                    """

                    sh """
                        docker run -d \
                          --name ${env.CONTAINER_NAME} \
                          -p ${env.APP_PORT}:3000 \
                          ${fullImageName}
                    """
                    echo "🚀 App desplegada en http://localhost:${env.APP_PORT}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline exitoso — ${BRANCH_NAME} → http://localhost:${env.APP_PORT}"
        }
        failure {
            echo "❌ Pipeline falló en rama ${BRANCH_NAME}"
        }
    }
}

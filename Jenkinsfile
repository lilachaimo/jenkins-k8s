

pipeline {

    agent any
    
    environment {
        PASS = credentials('registry-pass')
	PROJECT_ID = 'PROJECT-ID'
        CLUSTER_NAME = 'CLUSTER-NAME'
        LOCATION = 'CLUSTER-LOCATION'
        CREDENTIALS_ID = 'gke' 
    }

    stages {

	 stage("Checkout code") {
            steps {
                checkout scm
            }
        }

        stage('Build image') {
            steps {
                sh '''
                    ./jenkins/build/mvn.sh mvn -B -DskipTests clean package
                    ./jenkins/build/build.sh
                '''
            }
	   post {
              success {
                  archiveArtifacts artifacts: 'java-app/target/*.jar', fingerprint: true

               }
            }

        }

        stage('Test') {
            steps {
                sh './jenkins/test/mvn.sh mvn test'

            }
            post {
              always {
                  junit 'java-app/target/surefire-reports/*.xml'
               }
            }


        }

        stage('Push image') {
            steps {
               

		  sh "sed -i 's/hello:latest/hello:${env.BUILD_ID}/g' deployment.yaml"
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME_TEST, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
            }
        }

        stage('Deploy to GKE') {
            steps {
               sh "sed -i 's/hello:latest/hello:${env.BUILD_ID}/g' deployment.yaml"
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
            }
        }
    }    
}
This script defines some environment variables related to the Kubernetes cluster and a four-stage pipeline, as follows:

The first stage checks out the code from GitHub.
The second stage uses the docker.build command to build the application using the supplied Dockerfile. The built container is tagged with the build ID.
The third stage pushes the built container to Docker Hub using the dockerhub credential created in Step 5. The pushed container is tagged with both the build ID and the latest tag in the registry.
The fourth stage uses the GKE plugin to deploy the application to the Kubernetes cluster using the deployment.yaml file.
 Tip
It is worth pointing out here that the GKE plugin internally uses kubectl and kubectl will only trigger a redeployment if the deployment.yaml file changes. Therefore, the first step of the the fourth stage uses sed to manually modify Jenkins' local copy of the deployment.yaml file (by updating the container's build ID) so as to trigger a new deployment with the updated container.

Scenario 2: Deployment to two clusters
If you wish to deploy to two clusters, use this version of the pipeline script instead. Replace the placeholders as before, noting that in this version, the CLUSTER-NAME-1 and CLUSTER-NAME-2 placeholders should reflect the names of your test and production Kubernetes clusters respectively.

pipeline {
    agent any
    environment {
        PROJECT_ID = 'PROJECT-ID'
        LOCATION = 'CLUSTER-LOCATION'
        CREDENTIALS_ID = 'gke'
        CLUSTER_NAME_TEST = 'CLUSTER-NAME-1'
        CLUSTER_NAME_PROD = 'CLUSTER-NAME-2'          
    }
    stages {
        stage("Checkout code") {
            steps {
                checkout scm
            }
        }
        stage("Build image") {
            steps {
                script {
                    myapp = docker.build("DOCKER-HUB-USERNAME/hello:${env.BUILD_ID}")
                }
            }
        }
        stage("Push image") {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                            myapp.push("latest")
                            myapp.push("${env.BUILD_ID}")
                    }
                }
            }
        }       
        stage('Deploy to GKE test cluster') {
            steps{
                sh "sed -i 's/hello:latest/hello:${env.BUILD_ID}/g' deployment.yaml"
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME_TEST, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
            }
       
            }
        }
    }
}

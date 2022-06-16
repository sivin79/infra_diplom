pipeline {
  environment {
    imagename = "sivin79/my_flask_app"
    registryCredential = "sivin79"    
    tag = "latest"
    dockerImage = ''
  }

  agent { label 'flask' }
  stages {
    stage('Cloning Git') {
      steps {
        git([url: 'https://github.com/sivin79/my_flask_app.git', branch: 'main', credentialsId: 'dockerhub_sivenkov'])
      }
    }
        
    
    stage('CD') {
        steps {
            echo '========== starting terraform ==========='            
            dir("${env.WORKSPACE}/terraform"){
              withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "AWS-CREDS",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
              ]]) {
                    // AWS Code
                    sh "terraform init"
                    sh "terraform plan"                    
                  }
            }                
        }
    }
        stage ("Terraform Plan Approval") {            
            steps {
              echo '========== Approval ==========='
              withCredentials([string(credentialsId: 'TELEGRAM_TOKEN', variable: 'TELEGRAM_TOKEN'), string(credentialsId: 'TELEGRAM_CHAT_ID', variable: 'TELEGRAM_CHAT_ID')]) {
                sh 'curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Need to approve terraform plan!"'
              }
                script {
                    def userInput = input(id: 'confirm', message: 'Apply Terraform?', 
                                          parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, 
                                                         description: 'Apply terraform', name: 'confirm'] ])
                }
            }
          post {
            aborted { 
                withCredentials([string(credentialsId: 'TELEGRAM_TOKEN', variable: 'TELEGRAM_TOKEN'), string(credentialsId: 'TELEGRAM_CHAT_ID', variable: 'TELEGRAM_CHAT_ID')]) {
                sh 'curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Approve canceled!"'
              } 
            }
            success { echo 'APPROVED!!!'}
            
          }
          
        }
        stage ("Terraform infra") {            
            steps {
              echo '========== Terraform infra ==========='
              dir("${env.WORKSPACE}/terraform"){
              withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "AWS-CREDS",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
              ]]) {                    
                    sh "terraform apply --auto-approve"                                       
                  }
              }
              withCredentials([string(credentialsId: 'TELEGRAM_TOKEN', variable: 'TELEGRAM_TOKEN'), string(credentialsId: 'TELEGRAM_CHAT_ID', variable: 'TELEGRAM_CHAT_ID')]) {
                sh 'curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Creating infra finished success!"'
              }                 
            }
        }

  }
  post {
    failure {
      withCredentials([string(credentialsId: 'TELEGRAM_TOKEN', variable: 'TELEGRAM_TOKEN'), string(credentialsId: 'TELEGRAM_CHAT_ID', variable: 'TELEGRAM_CHAT_ID')]) {
      sh 'curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Creating ifrastructure finished FAILURE :("'
      }
    }
    success {
      withCredentials([string(credentialsId: 'TELEGRAM_TOKEN', variable: 'TELEGRAM_TOKEN'), string(credentialsId: 'TELEGRAM_CHAT_ID', variable: 'TELEGRAM_CHAT_ID')]) {
      sh 'curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Creating ifrastructure finished SUCCES!!! :)"'
      }
    }
  }
}

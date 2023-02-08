## Project Date:
> July, 2020.

## Project Description: 
> Influencers and experts use one2one to offer you personalized services such as advice, exclusive content, and coaching of any kind. One2one had a small engineering and operations team and as Head of Operations at One2One, i ran managerial tasks alongside running some needed Operation tasks like provisioning our Client-Request API using Docker, Terraform, Azure  and Azure DevOps.

## Concept:
This repo and guide does not entail One2One Client-API as it is an organization resource so I utlized the weatherForecast template API. 
> Oh well, In the spirit of DevOps, i wrote this guide in Yaml declarative syntax as an Infrastructure Guide (literally😉). This is just a concept i came up with just for the love of DevOps and IaaC. So you need a basic understanding of Yaml to follow-through.

Oh Yeah, I will help you out😉: <br />
Sample of pipeline code you will see in this guide:

> 
```yaml
stages:
- stage: Create demo.text file in VS Code
  jobs:
  - job: Open VSCode
    steps:
    - Tap: Windows key
    - Type: "VS Code" 
    - Click: Open 
   
  - job: Create .txt File
    steps:
    - Click: File
    - Select: New File
    - Type: "demo.text"
    - Tap: Enter

```
So what did we do? Here we wanted to create a demo.txt file in VS Code. So the first "job" was to "Open VS Code" by tapping the windows key, and searching and opening for VS Code in the windows pane. After we open VS code, we clciked on the file menu, chose "new file" from the drop down and created a text file.

```yaml
stages:
- stage: Create Demo API Template:
  jobs:
  - job: Create Tempale using dotnet
    steps:
    Open: Command Line 
    Run: "dotnet new webapi -n myapi" #create API called myapi
    Run: "dotnet run" #build and run API
   
  - job: Test API
    steps:
    Visit: "localhost:{port}/weatherForecast"
    Check: Successful or Unsucessful

- stage: Build and Push Docker Image
  jobs:
  - job: Create Dockerfile in root directory
    steps:
      Create:
        file: Dockerfile
        where: Root Directory
        content:
          Copy&Paste: 
              code:
                  [   # Get Base Image (Full .NET Core SDK)
                  FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
                  WORKDIR /app

                  # Copy csproj and restore
                  COPY *.csproj ./
                  RUN dotnet restore

                  # Copy everything else and build
                  COPY . ./
                  RUN dotnet publish -c Release -o out

                  # Generate runtime image
                  FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
                  WORKDIR /app
                  EXPOSE 80
                  COPY --from=build-env /app/out .
                  ENTRYPOINT ["dotnet", "weatherapi.dll"]
              ] 
  - job: Build Image
      steps:
         Run: "docker build -t {username}/{image-name}" #replace {username} with username and {image-name} with image name you prefer.
         
  - job: Run Image
      steps:
         Run: "docker run -p 8080:{exposed-port} {username}/{image-name}" #replace {exposed-port} with the specified exposed port in your Dockerfile {username} with username and {image-name} with image name you prefer
            
  - job: View Container
      steps:
        Check:
          Run: "docker ps"
          Successful: -If Container
          
  - job: Stop Container
      steps:
         Run: "docker stop <conatiner_id>" #Replace the <container_id> with the id of the container shown above.
                        
  - job: Push Image to DockerHub
      steps:
          Run: "docker push {username}/{image-name}" #replace {username} with username and {image-name} with image name you prefer.
   
- stage: Push to Github Repo
  jobs:
  - job: Create .gitignore file
    steps:
      Create:
        file: .gitignore
        where: Root Directory
        content:
          Copy&Paste: 
              code:
                  [
                    *.swp
                    *.*~
                    project.lock.json
                    .DS_Store
                    *.pyc

                    # Visual Studio Code
                    .vscode

                    # User-specific files
                    *.suo
                    *.user
                    *.userosscache
                    *.sln.docstates

                    # Build results
                    [Dd]ebug/
                    [Dd]ebugPublic/
                    [Rr]elease/
                    [Rr]eleases/
                    x64/
                    x86/
                    build/
                    bld/
                    [Bb]in/
                    [Oo]bj/
                    msbuild.log
                    msbuild.err
                    msbuild.wrn

                    # Visual Studio 2015
                    .vs/

                    # Compiled Source
                    *.com
                    *.class
                    *.dll
                    *.exe
                    *.o
                    *.so

                    # Terraform
                    .terraform
                ]
  - job: Push to Github
      steps:
        Create: Github Repo
        Return: CLI
        Run: "git init"
        Run: "git add ."
        Run: "git commit -m 'initial commit' "
        Run: "git remote add origin <REPO URL>"
        Run: "git push origin master"

- stage: Begin Provisioning Infrastructre with Terraform
  jobs:
    - job: Install 
        steps:
          Intall: Azure CLI
          Install: Terraform
          
    - job: Create Configuration File
        steps:
          Create:
            file: main.tf
            where: Root Directory
            content:
              Copy&Paste: 
                  code:
                      [
                          provider "azurerm" {
                              version = "3.0.0"
                              features {}
                          }


                          terraform {
                                  backend "azurerm" {
                                      resource_group_name = 'one2oneapi'
                                      storage_account_name = 'one2onestorageaccount'
                                      container_name = 'one2oneblobcontainer'
                                      key = "terraform.tfstate"
                                  }
                              }

                          variable imagebuild {
                            type        = string
                            description = "Latest One2one API Image Build"
                          }


                          resource "azurerm_resource_group" "one2one-rgf" {
                              name = "one2one-rg"
                              location = "UAE North"
                          }

                          resource "azurerm_container_group" "" {
                              name = "one2one-cn-rsc"
                              location = azurerm_resource_group.one2one.location
                              resource_group_name = azurerm_resource_group.one2one.name
                              ip_address_type     = "Public"
                              dns_name_label      = "one2one-api-cn"
                              os_type             = "Linux"
                              container {
                                  name            = "one2one-cn"
                                  image           = "dbobola/one2oneapi:${var.imagebuild}"
                                      cpu             = "1"
                                      memory          = "1"

                                      ports {
                                          port        = 80
                                          protocol    = "TCP"
                                      }
                              }
                          }
                    ]
    
    
- stage: Implement Service Principle for automatic authentication
  jobs:
    - job: Get Credentails
        steps:
            Visit: Azure Portal
            GoTo: Active Directory > App Registrations
            Click: New Registration
            Type: Name
            Select: Account Type ${.... Single Tenant}
            Copy: CLIENT ID
            Copy: TENANT ID
            Click: Certificates
            Type: Description
            Select: Duration
            Copy: CLIENT SECRET
            GoTo: Portal Home > Subscription
            Copy: SUBSCRIPTION ID
            Select: Access Control (IAM)
            Click: Add a Role Assignment
            Select: Contributor Role
            Select: Member${App Registration}
            
    - job: Save Credentials as Envrionment Variables
        steps:
            Run: "setx ARM_CLIENT_SECRET <CLIENT_SECRET>" #replace <CLIENT_SECRET> with the previously Client Secret copied from Azure Portal.
            Run: "setx ARM_CLIENT_ID <CLIENT_ID>" #replace <CLIENT_ID> with the previously Client ID copied from Azure Portal.
            Run: "setx ARM_TENANT_ID <TENANT_ID>" #replace <CLIENT_SECRET> with the previously Tenant ID copied from Azure Portal.
            Run: "setx ARM_SUBSCRIPTION_ID <SUBSCRIPTION_ID>" #replace <SUBSCRIPTION_ID> with the previously Subscription ID copied from Azure Portal.
            
            
- stage: Setup Automated Pipeline on AzureDevOps
  jobs
    - job: Create New Project
        steps:
            Visit: Azure DevOps
            Click: Create New Project:
            Type: Name
            Select: Visibility${Public}
            Select: Version Control${Git}
            Select: Work Item Process${Agile}

    - job: Create Service Connections - Docker Registry:
        steps:
            GoTo: Created Project
            Click: Project settings
            Click Service Connections
            Click: Create Service Connections:
            Select: Docker Registry
            Select: Registry Type: DockerHub
            Type: Docker credentials
            Type: Service Connection name
            Select: Grant access to all Pipelines
            
     - job: Create Service Connections - Azure Manager:
        steps:
            GoTo: Created Project
            Click: Project settings
            Click Service Connections                  
            Select: Azure Resource Manager:
            Select: Service Principal
            Select: Subscription
            Type: Service Name
            Select: Grant access to all pipelines
            
      - job: Configure and Run Pipeline
         steps:
            GoTo: Created Project
            Select: Pipelines
            Select: Create Pipeline
            Select: Github
            Select: Repository${Project Repo}
            Edit: 
                pane: Configure your Pipeline
                to-do: Input containerRegistry and Repository
                where: 
                        [
                            # Docker
                            # Build a Docker image
                            # https://docs.microsoft.com/azure/devops/pipelines/languages/docker

                            trigger:
                            - master

                            resources:
                            - repo: self

                            variables:
                            tag: '$(Build.BuildId)'

                            stages:
                            - stage: Build
                            displayName: Build image
                            jobs:
                            - job: Build
                                displayName: Build
                                pool:
                                vmImage: ubuntu-latest
                                steps:
                                - task: Docker@2
                                inputs:
                                    containerRegistry: ''
                                    repository: ''
                                    command: 'buildAndPush'
                                    Dockerfile: '**/Dockerfile'
                                    tags: |
                                    $(tag)
                        ]
            Select: Save & Run
    
    
- stage: Synchronize Local and Github Repo
    jobs:
      - job: Update Local Repo
          steps:
              Run: "git pull origin master" # to pull the just created azure pipeline yaml file by Azure DevOps.           
              
      - job: Update Github Repo
          steps:
              Run: "git add ."
              Run: "git commit -m 'added terraform config'"
              Run: "git push origin master" #to push the main.tf file

- stage: Create credential variables in Library
    jobs:
      - job:
          steps:
              GoTo: Azure Devops > Project
              Select: Project(Current Project)
              Select: Library
              Select: New Variable Group
              Type: Name
              Select: Allow access to all pipelines.
              Select: Add Variables
              Add: "ARM_CLIENT_ID":${ARM_CLIENT_ID} #use the previosuly copied ID.
              Select: Lock (Icon)
              Add: "ARM_CLIENT_SECRET":${ARM_CLIENT_SECRET} #use the previosuly copied ID.
              Select: Lock (Icon)
              Add: "ARM_TENANT_ID":${ARM_TENANT_ID} #use the previosuly copied ID.
              Select: Lock (Icon)
              Add: "ARM_SUBSCRIPTION_ID":${ARM_SUBSCRIPTION_ID} #use the previosuly copied ID.
              Select: Lock (Icon)
              Select: Save
     

- stage:Setup Blob Storage on Azure to store Terraform Statefile
    jobs:
      - job: Create Storage Account
          steps:
              Create: Resource Group
              Create: 
                  what: Storage Account
                  steps:
                      GoTo: All Resources
                      Search: Storage account - blob, file, table, queue
                      Select: Create
                      Select: Resource Group:${JUST-CREATED}
                      Type: Storage Name
                      Select: Location
                      Select: Performance:${Standard}
                      Select: Account Kind:{....general purpose} 
                      Select: Replication:${....LRS}
                      Select: Access Tier:${Cool}
                      Click: Create
      - job: Create Container in Blob storage
          steps:
              GoTo: Storage Account
              Scroll-SideMenu: Down-to-Blob_Service
              Click: Containers
              Click: New Container
              Type: Name
              Select: Private
              Select: Create
                                  
- stage: Update Azure pipeline for Provisioning stage
    jobs:
      - job: Append Provisioning Stage to the Pipeline
          steps:
              Edit:
                where: azure-pipeline.yaml file
                to-do: Append Provisioning Stage
                code-append: [
                    - stage: Provision
                        displayName: 'Terraforming on Azure...'
                        dependsOn: Build
                        jobs:
                        - job: Provision
                            displayName: 'Provisioning Container Instance'
                            pool:
                            vmImage: 'ubuntu-latest'
                            variables: 
                            - group: <NAME OF PREVIOUSLY CREATED VARIABle in section 8>
                            steps:
                            - script: |
                                set -e

                                terraform init -input=false
                                terraform apply -input=false -auto-approve
                            name: 'RunTerraform'
                            displayName: 'Run Terraform'
                            env:
                                ARM_CLIENT_ID: $(ARM_CLIENT_ID)
                                ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
                                ARM_TENANT_ID: $(ARM_TENANT_ID)
                                ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
                                TF_VAR_imagebuild: $(tag)

                ]
          
            


- stage: Push and Test
    jobs:
        - job: Trigger Pipeline
            steps:
                GoTo: CLI
                Run: "git add ."
                Run: "git commit -m 'updated pipeline' "
                Run: "git push origin master"
                
         
        - job: Observe Pipeline
            steps:
              GoTo: Azure DevOps > Projects > Pipeline
              check: If Success
              GoTo: DockerHub > Repository
              check: If Pushed
              
        - job: Visit API
            steps:
              GoTo: Azure > Resource Groups
              Visit: Container URL:${weatherForecast}
              


```
> Oh well, I feel like  just created another programming language or framework, haha.
<br /> I hope this was fun utilizing. 





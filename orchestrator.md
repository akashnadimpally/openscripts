To modify the **`spring-boot-backend.sw.yaml`** workflow to use **Azure Repos** instead of GitHub, we'll update the workflow and any associated configurations, including functions and arguments, to interact with Azure Repos using the **Azure DevOps REST API**.

Below are the necessary updates:

---

### **Updated Workflow: `spring-boot-backend.sw.yaml`**

```yaml
id: spring-boot-backend
version: '1.0'
specVersion: '0.8'
name: Spring Boot Backend application
description: Create a starter Spring Boot backend application with a CI pipeline
dataInputSchema: schemas/spring-boot-backend__main-schema.json
functions:
  - name: runActionFetchTemplate
    operation: specs/actions-openapi.json#fetch:template
  - name: runActionPublishAzureRepos
    operation: specs/actions-openapi.json#publish:azure-repos
  - name: runActionCatalogRegister
    operation: specs/actions-openapi.json#catalog:register
  - name: fs:delete
    operation: specs/actions-openapi.json#fs:delete
  - name: sysout
    type: custom
    operation: sysout
errors:
  - name: Error on Action
    code: java.lang.RuntimeException
start: Generating the Source Code Component
states:
  - name: Generating the Source Code Component
    type: operation
    actionMode: sequential
    actions:
      - name: Fetch Template Action - Source Code
        functionRef:
          refName: runActionFetchTemplate
          arguments:
            url: >-
              https://dev.azure.com/{organization}/{project}/_git/{repo}/path/to/spring-boot-backend-template
            values:
              orgName: .newComponent.orgName
              repoName: .newComponent.repoName
              owner: .newComponent.owner
              system: .newComponent.system
              applicationType: api
              description: .newComponent.description
              namespace: .ciMethod.namespace
              port: .newComponent.port
              ci: .ciMethod.ci
              sourceControl: azure-repos
              groupId: .javaMetadata.groupId
              artifactId: .javaMetadata.artifactId
              javaPackageName: .javaMetadata.javaPackageName
              version: .javaMetadata.version
        actionDataFilter:
          toStateData: .actionFetchTemplateSourceCodeResult
    onErrors:
      - errorRef: Error on Action
        transition: Handle Error
    compensatedBy: Clear File System - Source Code
    transition: Generating the CI Component
  - name: Generating the CI Component
    type: switch
    dataConditions:
      - condition: ${ .ciMethod.ci == "azure-devops" }
        transition: Generating the CI Component - Azure Repos
    defaultCondition:
      transition: Generating the CI Component - Azure Repos
  - name: Generating the CI Component - Azure Repos
    type: operation
    actionMode: sequential
    actions:
      - name: Run Template Fetch Action - CI - Azure Repos
        functionRef:
          refName: runActionFetchTemplate
          arguments:
            url: >-
              https://dev.azure.com/{organization}/{project}/_git/{repo}/path/to/azure-pipelines-template
            values:
              orgName: .newComponent.orgName
              repoName: .newComponent.repoName
              owner: .newComponent.owner
              system: .newComponent.system
              applicationType: api
              description: .newComponent.description
              namespace: .ciMethod.namespace
              port: .newComponent.port
              ci: .ciMethod.ci
              sourceControl: azure-repos
              groupId: .javaMetadata.groupId
              artifactId: .javaMetadata.artifactId
              javaPackageName: .javaMetadata.javaPackageName
              version: .javaMetadata.version
        actionDataFilter:
          toStateData: .actionTemplateFetchCIResult
    onErrors:
      - errorRef: Error on Action
        transition: Handle Error
    compensatedBy: Clear File System - CI
    transition: Generating the Catalog Info Component
  - name: Generating the Catalog Info Component
    type: operation
    actions:
      - name: Fetch Template Action - Catalog Info
        functionRef:
          refName: runActionFetchTemplate
          arguments:
            url: >-
              https://dev.azure.com/{organization}/{project}/_git/{repo}/path/to/catalog-info-template
            values:
              orgName: .newComponent.orgName
              repoName: .newComponent.repoName
              owner: .newComponent.owner
              system: .newComponent.system
              applicationType: api
              description: .newComponent.description
              namespace: .ciMethod.namespace
              imageUrl: .ciMethod.imageUrl
              imageRepository: .ciMethod.imageRepository
              imageBuilder: s2i-go
              port: .newComponent.port
              ci: .ciMethod.ci
              sourceControl: azure-repos
              groupId: .javaMetadata.groupId
              artifactId: .javaMetadata.artifactId
              javaPackageName: .javaMetadata.javaPackageName
              version: .javaMetadata.version
        actionDataFilter:
          toStateData: .actionFetchTemplateCatalogInfoResult
    onErrors:
      - errorRef: Error on Action
        transition: Handle Error
    compensatedBy: Clear File System - Catalog
    transition: Publishing to the Source Code Repository
  - name: Publishing to the Source Code Repository
    type: operation
    actionMode: sequential
    actions:
      - name: Publish Azure Repos
        functionRef:
          refName: runActionPublishAzureRepos
          arguments:
            allowedHosts:
              - '"dev.azure.com"'
            description: Workflow Action
            repoUrl: '"https://dev.azure.com/{organization}/{project}/_git/" + .newComponent.repoName'
            defaultBranch: main
            gitCommitMessage: Initial commit
        actionDataFilter:
          toStateData: .actionPublishResult
    onErrors:
      - errorRef: Error on Action
        transition: Handle Error
    compensatedBy: Remove Source Code Repository
    transition: Registering the Catalog Info Component
  - name: Registering the Catalog Info Component
    type: operation
    actionMode: sequential
    actions:
      - name: Catalog Register Action
        functionRef:
          refName: runActionCatalogRegister
          arguments:
            repoContentsUrl: .actionPublishResult.repoContentsUrl
            catalogInfoPath: '"/catalog-info.yaml"'
        actionDataFilter:
          toStateData: .actionCatalogRegisterResult
    onErrors:
      - errorRef: Error on Action
        transition: Handle Error
    compensatedBy: Remove Catalog Info Component
    end: true
  - name: Handle Error
    type: operation
    actions:
      - name: Error Action
        functionRef:
          refName: sysout
          arguments:
            message: Error on workflow, triggering compensations
    end:
      compensate: true
  - name: Clear File System - Source Code
    type: operation
    usedForCompensation: true
    actions:
      - name: Clear FS Action
        functionRef:
          refName: fs:delete
          arguments:
            files:
              - ./
  - name: Clear File System - CI
    type: operation
    usedForCompensation: true
    actions:
      - name: Clear FS Action
        functionRef:
          refName: fs:delete
          arguments:
            files:
              - ./
  - name: Clear File System - Catalog
    type: operation
    usedForCompensation: true
    actions:
      - name: Clear FS Action
        functionRef:
          refName: fs:delete
          arguments:
            files:
              - ./
  - name: Remove Source Code Repository
    type: operation
    usedForCompensation: true
    actions:
      - name: Remove Source Code Repository
        functionRef:
          refName: sysout
          arguments:
            message: Remove Source Code Repository
  - name: Remove Catalog Info Component
    type: operation
    usedForCompensation: true
    actions:
      - name: Remove Catalog Info Component
        functionRef:
          refName: sysout
          arguments:
            message: Remove Catalog Info Component
```

---

### **Updated Files**

#### **1. `application.properties`**
Update the API endpoint to point to Azure DevOps REST API:
```properties
quarkus.rest-client.actions_openapi_json.url=https://dev.azure.com/{organization}/{project}/_apis
```

#### **2. `specs/actions-openapi.json`**
Add operations for Azure Repos, such as fetching templates, publishing commits, and creating pull requests:
```json
{
  "paths": {
    "/git/repositories/{repositoryId}/pullrequests": {
      "post": {
        "operationId": "publish:azure-repos",
        "summary": "Create a pull request in Azure Repos",
        "parameters": [
          { "name": "repositoryId", "in": "path", "required": true },
          { "name": "body", "in": "body", "required": true }
        ]
      }
    }
  }
}
```

---

This workflow now uses **Azure Repos** for all repository-related tasks while retaining its original functionality. Let me know if you need further assistance! 😊

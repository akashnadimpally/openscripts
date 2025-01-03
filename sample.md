Below is a **complete, step-by-step** solution to create a new SonataFlow workflow (and its JSON Schema) **in the same `workflows` folder** that demonstrates **re-run from the failed step** rather than starting from the beginning. This solution includes:

- **Directory structure** (where to place files).  
- **The complete workflow definition** (`azure-check-file.sw.yaml`).  
- **The complete JSON schema** (`azure-check-file__main-schema.json`).  
- **Explanation of key points** to show how retries happen from the failed step.

> **Regarding your question:**  
> "**Does Janus IDP orchestrator + SonataFlow have an inbuilt re-run capability in case of a task failure?**"  
> **Answer**: Yes. By configuring the workflow’s states to handle errors (with `onErrors` or `retry`), you can ensure that when a state fails, it **retries** or transitions to a wait state and then **re-enters the failed state**—**without** returning to the start of the workflow.

---

## 1. Directory Structure

Within your **`tiagodolphine-backstage-orchestrator-workflows`** project, locate the `workflows` folder. Your final structure will look like this (only showing relevant files):

```bash
tiagodolphine-backstage-orchestrator-workflows/
└── workflows/
    ├── ansible-job-template.sw.yaml
    ├── application.properties
    ├── assessment.sw.json
    ├── azure-check-file.sw.yaml               <-- NEW WORKFLOW
    ├── go-backend.sw.yaml
    ├── hello.sw.json
    ├── nodejs-backend.sw.yaml
    ├── quarkus-backend.sw.yaml
    ├── spring-boot-backend.sw.yaml
    ├── wait-or-error.sw.yaml
    ├── yamlgreet.sw.yaml
    ├── schemas/
    │   ├── ansible-job-template__main-schema.json
    │   ├── ansible-job-template__ref-schema__Ansible_Job_Definition.json
    │   ├── ansible-job-template__ref-schema__GitHub_Repository_Info.json
    │   ├── assessment__main-schema.json
    │   ├── azure-check-file__main-schema.json <-- NEW SCHEMA
    │   ├── go-backend__main-schema.json
    │   ├── ...
    │   ├── wait-or-error__main-schema.json
    │   └── yamlgreet__main-schema.json
    └── specs/
        └── actions-openapi.json
```

---

## 2. Create the **JSON Schema** (`azure-check-file__main-schema.json`)

1. In the `workflows/schemas/` folder, create a new file named **`azure-check-file__main-schema.json`**.  
2. Paste the **full** content below into it:

```json
{
  "$id": "classpath:/schemas/azure-check-file__main-schema.json",
  "title": "Data Input Schema for Azure Check File Workflow",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "repoUrl": {
      "type": "string",
      "title": "Azure DevOps Repo URL",
      "description": "The Azure DevOps repository URL to clone"
    },
    "fileName": {
      "type": "string",
      "title": "File Name",
      "description": "The file name to check within the cloned repo"
    }
  },
  "required": ["repoUrl", "fileName"]
}
```

### Explanation

- **`repoUrl`**: The input parameter that will store the Azure DevOps repository URL from which you want to clone.  
- **`fileName`**: The input parameter that will store the file name to be checked in that repo.

---

## 3. Create the **Workflow** (`azure-check-file.sw.yaml`)

1. In the `workflows/` folder, create a new file named **`azure-check-file.sw.yaml`**.  
2. Paste the **full** content below into it:

```yaml
id: azure-check-file
version: "1.0"
specVersion: "0.8"
name: Azure Check File Workflow
description: >
  Demonstrates how Janus IDP Orchestrator / SonataFlow can re-run from a failed step 
  rather than starting from the beginning, by cloning an Azure DevOps repo and checking for a file.

# Link to the JSON schema for validating the input data:
dataInputSchema: schemas/azure-check-file__main-schema.json

start: CloneRepo

# Define placeholder functions. You can reference actual endpoints or custom tasks
# in your SonataFlow environment. For example, you might define them in specs/actions-openapi.json.
functions:
  - name: cloneRepo
    type: custom
    operation: specs/actions-openapi.json#cloneRepo

  - name: checkFile
    type: custom
    operation: specs/actions-openapi.json#checkFile

states:
  #
  # 1) CloneRepo State
  #
  - name: CloneRepo
    type: operation
    actions:
      - name: cloneRepoAction
        functionRef:
          refName: cloneRepo
          arguments:
            repoUrl: "${ .repoUrl }"
    # If there's an error cloning the repo, we can either:
    # - Immediately transition to the same state (CloneRepo), or
    # - Use a built-in retry strategy.
    onErrors:
      - error: "*"
        # The wildcard means any error leads to a retry.
        # The next line simply transitions to the same state to reattempt.
        transition: CloneRepo
        # Or you could define a "retry" object with intervals, maxAttempts, etc.
        # For example:
        # retry:
        #   maxAttempts: 3
        #   interval: "PT5S"
    transition: CheckFile

  #
  # 2) CheckFile State
  #
  - name: CheckFile
    type: operation
    actions:
      - name: checkFileAction
        functionRef:
          refName: checkFile
          arguments:
            fileName: "${ .fileName }"
    # We assume the "checkFile" function throws an error if the file isn't found
    onErrors:
      - error: "*"
        # If file not found, we transition to WaitBeforeRetry
        transition: WaitBeforeRetry
    transition: FileExists

  #
  # 3) WaitBeforeRetry State
  #
  - name: WaitBeforeRetry
    type: sleep
    duration: "PT5S"  # Wait for 5 seconds before re-checking
    transition: CheckFile

  #
  # 4) FileExists State
  #
  - name: FileExists
    type: inject
    data:
      message: "File exists!"
    end: true
```

### Explanation

1. **`CloneRepo` State**  
   - Uses `cloneRepo` function to clone the Azure DevOps repository (`repoUrl`).  
   - If an error occurs (e.g., network issue, bad URL), the workflow stays in this state (via `transition: CloneRepo`), retrying without going back to the `start` of the workflow.

2. **`CheckFile` State**  
   - Uses `checkFile` function, passing `fileName`.  
   - If the file doesn’t exist, `checkFile` might throw an error (or return an error code). The wildcard `onErrors: - error: "*"` catches any error and transitions to **`WaitBeforeRetry`** instead of going all the way back to `CloneRepo`. This ensures we re-run from here.

3. **`WaitBeforeRetry` State**  
   - A **sleep** state that waits 5 seconds, then transitions back to **`CheckFile`**.  
   - This loop continues until the file eventually exists (or you decide to implement some max retry logic).

4. **`FileExists` State**  
   - If the file is found, the workflow transitions here.  
   - Simple `inject` state returns a message indicating success, and ends the workflow.

---

## 4. (Optional) Define the Functions in `actions-openapi.json`

In your `workflows/specs/` folder, you might have an **`actions-openapi.json`** file (or similarly named file) that defines how `cloneRepo` and `checkFile` work. This might look something like:

```jsonc
{
  "openapi": "3.0.0",
  "info": {
    "title": "Actions API",
    "version": "1.0"
  },
  "paths": {
    "/cloneRepo": {
      "post": {
        "operationId": "cloneRepo",
        "summary": "Clone an Azure DevOps repo",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "repoUrl": {
                    "type": "string"
                  }
                },
                "required": ["repoUrl"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Cloned successfully"
          },
          "400": {
            "description": "Error cloning the repository"
          }
        }
      }
    },
    "/checkFile": {
      "post": {
        "operationId": "checkFile",
        "summary": "Check file in cloned repo",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "fileName": {
                    "type": "string"
                  }
                },
                "required": ["fileName"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "File found"
          },
          "404": {
            "description": "File not found"
          }
        }
      }
    }
  }
}
```

Then in **`azure-check-file.sw.yaml`**, you have:

```yaml
functions:
  - name: cloneRepo
    type: rest
    operation: specs/actions-openapi.json#cloneRepo

  - name: checkFile
    type: rest
    operation: specs/actions-openapi.json#checkFile
```

---

## 5. How Re-run on Failure Actually Works

- **SonataFlow / Janus IDP Orchestrator** keeps track of which **state** the workflow is currently in, and whether that state completed successfully or failed.  
- If a state fails, the orchestrator uses the `onErrors` block (or the `retry` block) to decide the next state or the same state to re-enter.  
- Because you explicitly instruct the workflow to transition to the **same** or a **subsequent** state (rather than the initial `start`), it continues from the point of failure.  

**Hence, the workflow does not start from the beginning**; it re-runs only the **failed task** (or moves to a “wait” state, then returns to the failed task).

---

## 6. Summary of Steps

1. **In** `tiagodolphine-backstage-orchestrator-workflows/workflows/schemas/`:  
   - Create `azure-check-file__main-schema.json` with the required JSON schema for `repoUrl` and `fileName`.

2. **In** `tiagodolphine-backstage-orchestrator-workflows/workflows/`:  
   - Create `azure-check-file.sw.yaml`. This workflow will:  
     1. Clone the Azure DevOps repo.  
     2. Check for the file.  
     3. If the file is missing, wait and **retry** the same step—**not** restarting from the beginning.  

3. **(Optional)** Update or create your function definitions (OpenAPI or custom code tasks).  

4. **Deploy/Run** the workflow on your SonataFlow service.  
   - Provide input data, e.g.:
     ```json
     {
       "repoUrl": "https://dev.azure.com/YourOrg/YourProject/_git/YourRepo",
       "fileName": "README.md"
     }
     ```
   - Observe how the workflow only re-runs from the failed step if the file is missing or if repo cloning fails.

---

## 7. Final Answer

- **Yes**, Janus IDP Orchestrator + SonataFlow can **re-run** from the failed state rather than starting the entire workflow again.  
- The **full solution** is given above with file placements, complete YAML workflow, and complete JSON schema.  

mvn io.quarkus.platform:quarkus-maven-plugin:3.2.1.Final:create \
    -DprojectGroupId=com.example \
    -DprojectArtifactId=sonataflow-sample \
    -DclassName="com.example.WorkflowApplication" \
    -Dextensions="sonataflow-serverless-workflow"
# Dynamic Allocation of Resources in Cloud (DARC)

## Setup User
Create an IAM User in AWS and assign it the necessary policies. It's important to assign only the permissions needed for the operations that DARC will perform to adhere to the principle of least privilege.

**Note:** Temporarily, you may use the `AdministratorAccess` policy for convenience, but it's crucial to identify and apply more granular policies tailored to your requirements for security best practices.

## Cloud Provider Setup

Here follows the procedure to set up the necessary technologies for AWS provider, the provider available in this prototype. For other providers, please consult the relevant documentation.

### Setup AWS CLI Profile
1. Install the AWS CLI following the instructions from the official AWS documentation.
2. Configure the AWS CLI by running `aws configure` and inputting your new IAM user's access key ID and secret access key when prompted.

## Set Environment Variable
Before executing the Terraform code, set up the `KUBECONFIG` environment variable to point to your Kubernetes configuration file. This step is necessary for `kubectl` to interact with your cluster.

On Unix-like systems, you can set the variable by adding the following line to your shell profile:

```bash
export KUBECONFIG="~/.kube/config"
```

## Provision Terraform Code

To deploy the infrastructure with Terraform:

1. Initialize Terraform to download all necessary modules and files:

```bash
terraform init
```

2. Apply the Terraform code to provision the resources:

```bash
terraform apply
```

## Use kubectl with the New Cluster

To configure `kubectl` to interact with the new cluster:

```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

## Requirements to Run Argo Workflows

Specify the service account to run the workflow with by assigning `serviceAccountName` in the `spec`. For example, use "argo-workflow":

```yaml
...
spec:
  serviceAccountName: argo-workflow
...
```

## Run Argo Workflow and Observe Scaling

1. Submit the argo workflow:
```bash
argo submit -n argo --watch matrixmul.yaml
```

2. Observe the increase in pods:

```bash
kubectl get pods -n kube-system
```

3. Check for an increase in nodes:

```bash
kubectl get nodes
```

## Test Cluster Autoscaler (Without Argo Workflows)

1. Apply the cluster-autoscaler deployment (initially set to 0 replicas):

```bash
kubectl apply -f cluster-autoscaler-deployment.yaml
```

2. Increase the number of replicas to trigger autoscaling:

```bash
kubectl scale deployment inflate --replicas=5
```

3. Observe the increase in pods:

```bash
kubectl get pods -n kube-system
```

4. Check for an increase in nodes:

```bash
kubectl get nodes
```


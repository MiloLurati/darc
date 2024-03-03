# Dynamic Allocation of Resources in Cloud (DARC)

## Set up User
Create an IAM User of AWS and Assign it the correct policies (still have to figure out which ones).
Note: For now I just use the adminAccess policy because I haven't figured out the policies yet of the user.

## Set up AWS CLI Profile
Install AWS CLI and add the user keys.

## Potential issues
If provisioning everything from zero, you will probably have to first provision all modules and resources that are not the cluster-autoscaler, and with a second apply provision the cluster-autoscaler. Inbetween the applies run the following to add the provisioned cluster to kubectl `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`.

## Test cluster-autoscaler
First we need to apply the following deployment (currently at 0 replicas):
```
kubectl apply -f cluter-autoscaler-deployment.yaml
```
Increase the replicas:
```
kubectl scale deployment inflate --replicas 5
```
Check for the pod increase:
```
kubectl get pods -n kube-system
```
Observe the node increase:
```
kubectl get nodes
```

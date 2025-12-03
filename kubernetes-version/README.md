# Codemida Infrastructure - Kubernetes Version with Helm on AWS EKS

For a learning purpose, I built a Helm chart to easily deploy Codemida applications on a Kubernetes cluster. I use a AWS EKS managed cluster with EC2 instances for that.

## Prerequisites

- eksctl to create EKS clusters easily
- kubectl to interact with the Kubernetes cluster
- Helm to manage Kubernetes applications

## Usage

First, we need to create an EKS cluster using eksctl (ensure you have AWS CLI configured with the right permissions):

```bash
eksctl create cluster \
 --name codemida-cluster \
 --region eu-west-3 \
 --nodegroup-name codemida-workers \
 --node-type t3.small \
 --nodes 2 \
 --nodes-min 1 \
 --nodes-max 4 \
 --managed
```

Once the cluster is created (it may take a few minutes), we add a context to enable kubectl on our machine to interact with the cluster:

```bash
aws eks update-kubeconfig --name codemida-cluster --region eu-west-3
```

We can deploy the Codemida application using Helm. Let's package the Helm chart first:

```bash
cd kubernetes-version
helm package .
```

Then, we can install the chart on the Kubernetes cluster:

```bash
helm install codemida-release ./codemida-0.1.0.tgz
```

To verify that the application is running, let's check the status of the pods:

```bash
kubectl get pods
```

To access the application through the ingress, we first need to add an add-on for the NGINX ingress controller:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

We can get the external IP of the ingress controller:

```bash
kubectl get svc -n ingress-nginx
```

It's now possible to access the Codemida application using the external ALB DNS name of the ingress controller.

⚠️ If the ALB return a 404 error, you may need to change the hostName in values.yaml to match the external DNS name of the LoadBalancer, and upgrade the Helm release. In production, you would typically set up a proper DNS record and set a A or CNAME record to point to the LoadBalancer. You should also consider using TLS for secure communication.

To upgrade the Helm release:

```bash
helm upgrade codemida-release .
```

## Cleanup

To delete the EKS cluster, run:

```bash
eksctl delete cluster --name codemida-cluster --region eu-west-3
```

You can also have to delete the ressources created by eksctl such as the NAT Gateway, ENI, elastic IP, VPC... Ensure to check the successful deletion of those from the AWS Management Console to avoid unexpected costs.

---

This README provides a basic guide to deploy Codemida on a Kubernetes cluster using Helm and AWS EKS. For production deployments, consider additional configurations for security, scaling, and monitoring.
Also, I voluntarily ommited to provide the api-secrets.yaml's data for security reasons. You should create your own secrets as needed.

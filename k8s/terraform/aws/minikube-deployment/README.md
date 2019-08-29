# Minikube + Helm

This section assumes that Minikube has been deployed. As of this writing Helm bits are installed as part of the terraform deployment but aren't configure, below are manual steps to install and configure Helm.

Validate Kubernetes:

```
kubectl get nodes
kubectl get po -n kube-system
```

If nothing returns, ensure that minikube is running. Minikube NEEDS a root for the commands to work;

```
sudo minikube status
```

If status returns that minikube is not running;

```
sudo minikube start --vm-driver=none
```

Installing Helm from their script:

```
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

Now to link up tiller with kubernetes via a service account. The following commands will create a service account within the kube-system context, bind to a cluster role as a cluster-admin, and start tiller with the newly created service account

```
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

helm init --service-account tiller
```

Install socat, it's a dependency for helm for port forwarding to pods,

```
sudo apt install -y socat
```

Let's test it with a known mysql install! First create mysql.yml in your current working directory and copy below into it;

```
---
mysqlUser: localUsr
mysqlPassword: localUsrxPwd#
mysqlRootPassword: FUnIsntSOmethingOneConsiderWhenBalancingTheUniverse
persistence:
  enabled: true
  storageClass: local-path
```

Now to try the mysql install with the yml;

```
helm install --name local-database --namespace test -f mysql.yaml stable/mysql
```

Helm deployed applications can be checked with this command:

```
helm list
```


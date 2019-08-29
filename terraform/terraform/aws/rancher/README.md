# High Availability (HA) Install

------

For production environments, we recommend installing Rancher in a high-availability configuration so that your user base can always access Rancher Server. When installed in a Kubernetes cluster, Rancher will integrate with the cluster’s etcd database and take advantage of Kubernetes scheduling for high-availability.

This procedure walks you through setting up a 3-node cluster with RKE and installing the Rancher chart with the Helm package manager.

> **IMPORTANT:**It is not supported, nor generally a good idea, to run Rancher on top of hosted Kubernetes solutions such as Amazon’s EKS, or Google’s GKE. These hosted Kubernetes solutions do not expose etcd to a degree that is manageable for Rancher, and their customizations can interfere with Rancher operations. It is strongly recommended to use hosted infrastructure such as EC2 or GCE instead.
>
> **IMPORTANT:**For the best performance, we recommend this Kubernetes cluster to be dedicated only to run Rancher. After the Kubernetes cluster to run Rancher is setup, you can [create or import clusters](https://rancher.com/docs/rancher/v2.x/en/cluster-provisioning/#cluster-creation-in-rancher) for running your workloads.

## Recommended Architecture

- DNS for Rancher should resolve to a Layer 4 load balancer (TCP)
- The Load Balancer should forward port TCP/80 and TCP/443 to all 3 nodes in the Kubernetes cluster.
- The Ingress controller will redirect HTTP to HTTPS and terminate SSL/TLS on port TCP/443.
- The Ingress controller will forward traffic to port TCP/80 on the pod in the Rancher deployment.



HA Rancher install with layer 4 load balancer, depicting SSL termination at ingress controllers

![Rancher HA](https://rancher.com/docs/img/rancher/ha/rancher2ha.svg)



## Required Tools

The following CLI tools are required for this install. Please make sure these tools are installed and available in your `$PATH`

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) - Kubernetes command-line tool.
- [rke](https://rancher.com/docs/rke/latest/en/installation/) - Rancher Kubernetes Engine, cli for building Kubernetes clusters.
- [helm](https://docs.helm.sh/using_helm/#installing-helm) - Package management for Kubernetes.

> **IMPORTANT:**Due to an issue with Helm v2.12.0 and cert-manager, please use Helm v2.12.1 or higher.

## Installation Outline

- [Create Nodes and Load Balancer](https://rancher.com/docs/rancher/v2.x/en/installation/ha/create-nodes-lb/)
- [Install Kubernetes with RKE](https://rancher.com/docs/rancher/v2.x/en/installation/ha/kubernetes-rke/)
- [Initialize Helm (tiller)](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-init/)
- [Install Rancher](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/)

# 1. Create Nodes and Load Balancer

------

Use your provider of choice to provision 3 nodes and a Load Balancer endpoint for your RKE install.

> **NOTE:**These nodes must be in the same region/datacenter. You may place these servers in separate availability zones.

### Node Requirements

View the supported operating systems and hardware/software/networking requirements for nodes running Rancher at [Node Requirements](https://rancher.com/docs/rancher/v2.x/en/installation/requirements).

View the OS requirements for RKE at [RKE Requirements](https://rancher.com/docs/rke/latest/en/os/)

### Load Balancer

RKE will configure an Ingress controller pod, on each of your nodes. The Ingress controller pods are bound to ports TCP/80 and TCP/443 on the host network and are the entry point for HTTPS traffic to the Rancher server.

Configure a load balancer as a basic Layer 4 TCP forwarder. The exact configuration will vary depending on your environment.

> **IMPORTANT:**Do not use this load balancer (i.e, the `local` cluster Ingress) to load balance applications other than Rancher following installation. Sharing this Ingress with other applications may result in websocket errors to Rancher following Ingress configuration reloads for other apps. We recommend dedicating the `local` cluster to Rancher and no other applications.

#### Examples

- [Nginx](https://rancher.com/docs/rancher/v2.x/en/installation/ha/create-nodes-lb/nginx/)
- [Amazon NLB](https://rancher.com/docs/rancher/v2.x/en/installation/ha/create-nodes-lb/nlb/)

# 2. Install Kubernetes with RKE

------

Use RKE to install Kubernetes with a high availability etcd configuration.

> **NOTE:**For systems without direct internet access see [Air Gap: High Availability Install](https://rancher.com/docs/rancher/v2.x/en/installation/air-gap-high-availability/) for install details.

### Create the `rancher-cluster.yml` File

Using the sample below create the `rancher-cluster.yml` file. Replace the IP Addresses in the `nodes` list with the IP address or DNS names of the 3 nodes you created.

> **NOTE:**If your node has public and internal addresses, it is recommended to set the `internal_address:` so Kubernetes will use it for intra-cluster communication. Some services like AWS EC2 require setting the `internal_address:` if you want to use self-referencing security groups or firewalls.

```yaml
nodes:
  - address: 165.227.114.63
    internal_address: 172.16.22.12
    user: ubuntu
    role: [controlplane,worker,etcd]
  - address: 165.227.116.167
    internal_address: 172.16.32.37
    user: ubuntu
    role: [controlplane,worker,etcd]
  - address: 165.227.127.226
    internal_address: 172.16.42.73
    user: ubuntu
    role: [controlplane,worker,etcd]

services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24h
```

#### Common RKE Nodes Options

| OPTION             | REQUIRED | DESCRIPTION                                                  |
| :----------------- | :------- | :----------------------------------------------------------- |
| `address`          | yes      | The public DNS or IP address                                 |
| `user`             | yes      | A user that can run docker commands                          |
| `role`             | yes      | List of Kubernetes roles assigned to the node                |
| `internal_address` | no       | The private DNS or IP address for internal cluster traffic   |
| `ssh_key_path`     | no       | Path to SSH private key used to authenticate to the node (defaults to `~/.ssh/id_rsa`) |

#### Advanced Configurations

RKE has many configuration options for customizing the install to suit your specific environment.

Please see the [RKE Documentation](https://rancher.com/docs/rke/latest/en/config-options/) for the full list of options and capabilities.

For tuning your etcd cluster for larger Rancher installations see the [etcd settings guide](https://rancher.com/docs/rancher/v2.x/en/installation/options/etcd/).

### Run RKE

```
rke up --config ./rancher-cluster.yml
```

When finished, it should end with the line: `Finished building Kubernetes cluster successfully`.

### Testing Your Cluster

RKE should have created a file `kube_config_rancher-cluster.yml`. This file has the credentials for `kubectl` and `helm`.

> **NOTE:**If you have used a different file name from `rancher-cluster.yml`, then the kube config file will be named `kube_config_<FILE_NAME>.yml`.

You can copy this file to `$HOME/.kube/config` or if you are working with multiple Kubernetes clusters, set the `KUBECONFIG`environmental variable to the path of `kube_config_rancher-cluster.yml`.

```
export KUBECONFIG=$(pwd)/kube_config_rancher-cluster.yml
```

Test your connectivity with `kubectl` and see if all your nodes are in `Ready` state.

```
kubectl get nodes

NAME                          STATUS    ROLES                      AGE       VERSION
165.227.114.63                Ready     controlplane,etcd,worker   11m       v1.13.5
165.227.116.167               Ready     controlplane,etcd,worker   11m       v1.13.5
165.227.127.226               Ready     controlplane,etcd,worker   11m       v1.13.5
```

### Check the Health of Your Cluster Pods

Check that all the required pods and containers are healthy are ready to continue.

- Pods are in `Running` or `Completed` state.
- `READY` column shows all the containers are running (i.e. `3/3`) for pods with `STATUS` `Running`
- Pods with `STATUS` `Completed` are run-once Jobs. For these pods `READY` should be `0/1`.

```
kubectl get pods --all-namespaces

NAMESPACE       NAME                                      READY     STATUS      RESTARTS   AGE
ingress-nginx   nginx-ingress-controller-tnsn4            1/1       Running     0          30s
ingress-nginx   nginx-ingress-controller-tw2ht            1/1       Running     0          30s
ingress-nginx   nginx-ingress-controller-v874b            1/1       Running     0          30s
kube-system     canal-jp4hz                               3/3       Running     0          30s
kube-system     canal-z2hg8                               3/3       Running     0          30s
kube-system     canal-z6kpw                               3/3       Running     0          30s
kube-system     kube-dns-7588d5b5f5-sf4vh                 3/3       Running     0          30s
kube-system     kube-dns-autoscaler-5db9bbb766-jz2k6      1/1       Running     0          30s
kube-system     metrics-server-97bc649d5-4rl2q            1/1       Running     0          30s
kube-system     rke-ingress-controller-deploy-job-bhzgm   0/1       Completed   0          30s
kube-system     rke-kubedns-addon-deploy-job-gl7t4        0/1       Completed   0          30s
kube-system     rke-metrics-addon-deploy-job-7ljkc        0/1       Completed   0          30s
kube-system     rke-network-plugin-deploy-job-6pbgj       0/1       Completed   0          30s
```

### Save Your Files

> **IMPORTANT**The files mentioned below are needed to maintain, troubleshoot and upgrade your cluster.

Save a copy of the following files in a secure location:

- `rancher-cluster.yml`: The RKE cluster configuration file.

- `kube_config_rancher-cluster.yml`: The [Kubeconfig file](https://rancher.com/docs/rke/latest/en/kubeconfig/) for the cluster, this file contains credentials for full access to the cluster.

- `rancher-cluster.rkestate`: The [Kubernetes Cluster State file](https://rancher.com/docs/rke/latest/en/installation/#kubernetes-cluster-state), this file contains credentials for full access to the cluster.

  *The Kubernetes Cluster State file is only created when using RKE v0.2.0 or higher.*

# 3. Initialize Helm (Install Tiller)

------

Helm is the package management tool of choice for Kubernetes. Helm “charts” provide templating syntax for Kubernetes YAML manifest documents. With Helm we can create configurable deployments instead of just using static files. For more information about creating your own catalog of deployments, check out the docs at https://helm.sh/. To be able to use Helm, the server-side component `tiller`needs to be installed on your cluster.

> **NOTE:**For systems without direct internet access see [Helm - Air Gap](https://rancher.com/docs/rancher/v2.x/en/installation/air-gap-installation/install-rancher/#helm) for install details.

### Install Tiller on the Cluster

> **IMPORTANT:**Due to an issue with Helm v2.12.0 and cert-manager, please use Helm v2.12.1 or higher.

Helm installs the `tiller` service on your cluster to manage charts. Since RKE enables RBAC by default we will need to use `kubectl`to create a `serviceaccount` and `clusterrolebinding` so `tiller` has permission to deploy to the cluster.

- Create the `ServiceAccount` in the `kube-system` namespace.
- Create the `ClusterRoleBinding` to give the `tiller` account access to the cluster.
- Finally use `helm` to install the `tiller` service

```plain
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:tiller

helm init --service-account tiller
```

> **NOTE:**This`tiller`install has full cluster access, which should be acceptable if the cluster is dedicated to Rancher server. Check out the [helm docs](https://docs.helm.sh/using_helm/#role-based-access-control) for restricting `tiller` access to suit your security requirements.

### Test your Tiller installation

Run the following command to verify the installation of `tiller` on your cluster:

```
kubectl -n kube-system  rollout status deploy/tiller-deploy
Waiting for deployment "tiller-deploy" rollout to finish: 0 of 1 updated replicas are available...
deployment "tiller-deploy" successfully rolled out
```

And run the following command to validate Helm can talk to the `tiller` service:

```
helm version
Client: &version.Version{SemVer:"v2.12.1", GitCommit:"02a47c7249b1fc6d8fd3b94e6b4babf9d818144e", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.12.1", GitCommit:"02a47c7249b1fc6d8fd3b94e6b4babf9d818144e", GitTreeState:"clean"}
```

# 4. Install Rancher

------

Rancher installation is managed using the Helm package manager for Kubernetes. Use `helm` to install the prerequisite and charts to install Rancher.

> **NOTE:**For systems without direct internet access see [Air Gap: High Availability Install](https://rancher.com/docs/rancher/v2.x/en/installation/air-gap-installation/install-rancher/).

### Add the Helm Chart Repository

Use `helm repo add` command to add the Helm chart repository that contains charts to install Rancher. For more information about the repository choices and which is best for your use case, see [Choosing a Version of Rancher](https://rancher.com/docs/rancher/v2.x/en/installation/server-tags/#helm-chart-repositories).

 Latest: Recommended for trying out the newest features

 Stable: Recommended for production environments

 Alpha: Experimental preview of upcoming releases. 
Note: Upgrades are not supported to, from, or between Alphas.

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
```

### Choose your SSL Configuration

Rancher Server is designed to be secure by default and requires SSL/TLS configuration.

There are three recommended options for the source of the certificate.

> **NOTE:**If you want terminate SSL/TLS externally, see [TLS termination on an External Load Balancer](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/#external-tls-termination).

| CONFIGURATION                                                | CHART OPTION                     | DESCRIPTION                                                  | REQUIRES CERT-MANAGER                                        |
| :----------------------------------------------------------- | :------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| [Rancher Generated Certificates](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#rancher-generated-certificates) | `ingress.tls.source=rancher`     | Use certificates issued by Rancher’s generated CA (self signed) This is the **default** | [yes](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#optional-install-cert-manager) |
| [Let’s Encrypt](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#let-s-encrypt) | `ingress.tls.source=letsEncrypt` | Use [Let’s Encrypt](https://letsencrypt.org/) to issue a certificate | [yes](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#optional-install-cert-manager) |
| [Certificates from Files](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#certificates-from-files) | `ingress.tls.source=secret`      | Use your own certificate files by creating Kubernetes Secret(s) | no                                                           |

### Optional: Install cert-manager

> **NOTE:**cert-manager is only required for certificates issued by Rancher’s generated CA (`ingress.tls.source=rancher`) and Let’s Encrypt issued certificates (`ingress.tls.source=letsEncrypt`). You should skip this step if you are using your own certificate files (option `ingress.tls.source=secret`) or if you use [TLS termination on an External Load Balancer](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/#external-tls-termination).
>
> **IMPORTANT:**Due to an issue with Helm v2.12.0 and cert-manager, please use Helm v2.12.1 or higher.

Rancher relies on [cert-manager](https://github.com/kubernetes/charts/tree/master/stable/cert-manager) version v0.5.2 from the official Kubernetes Helm chart repository to issue certificates from Rancher’s own generated CA or to request Let’s Encrypt certificates.

Install `cert-manager` from Kubernetes Helm chart repository.

```
helm install stable/cert-manager \
  --name cert-manager \
  --namespace kube-system \
  --version v0.5.2
```

Wait for `cert-manager` to be rolled out:

```
kubectl -n kube-system rollout status deploy/cert-manager
Waiting for deployment "cert-manager" rollout to finish: 0 of 1 updated replicas are available...
deployment "cert-manager" successfully rolled out
```



#### Rancher Generated Certificates

> **NOTE:**You need to have [cert-manager](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#optional-install-cert-manager) installed before proceeding.

The default is for Rancher to generate a CA and uses `cert-manager` to issue the certificate for access to the Rancher server interface. Because `rancher` is the default option for `ingress.tls.source`, we are not specifying `ingress.tls.source` when running the `helm install` command.

- Set the `hostname` to the DNS name you pointed at your load balancer.

```
helm install rancher-latest/rancher \
  --name rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org
```

Wait for Rancher to be rolled out:

```
kubectl -n cattle-system rollout status deploy/rancher
Waiting for deployment "rancher" rollout to finish: 0 of 3 updated replicas are available...
deployment "rancher" successfully rolled out
```

#### Let’s Encrypt

> **NOTE:**You need to have [cert-manager](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#optional-install-cert-manager) installed before proceeding.

This option uses `cert-manager` to automatically request and renew [Let’s Encrypt](https://letsencrypt.org/) certificates. This is a free service that provides you with a valid certificate as Let’s Encrypt is a trusted CA. This configuration uses HTTP validation (`HTTP-01`) so the load balancer must have a public DNS record and be accessible from the internet.

- Set `hostname` to the public DNS record, set `ingress.tls.source` to `letsEncrypt` and `letsEncrypt.email` to the email address used for communication about your certificate (for example, expiry notices)

```
helm install rancher-latest/rancher \
  --name rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=me@example.org
```

Wait for Rancher to be rolled out:

```
kubectl -n cattle-system rollout status deploy/rancher
Waiting for deployment "rancher" rollout to finish: 0 of 3 updated replicas are available...
deployment "rancher" successfully rolled out
```

#### Certificates from Files

Create Kubernetes secrets from your own certificates for Rancher to use.

> **NOTE:**The `Common Name` or a `Subject Alternative Names` entry in the server certificate must match the `hostname`option, or the ingress controller will fail to configure correctly. Although an entry in the `Subject Alternative Names` is technically required, having a matching `Common Name` maximizes compatibility with older browsers/applications. If you want to check if your certificates are correct, see [How do I check Common Name and Subject Alternative Names in my server certificate?](https://rancher.com/docs/rancher/v2.x/en/faq/technical/#how-do-i-check-common-name-and-subject-alternative-names-in-my-server-certificate)

- Set `hostname` and set `ingress.tls.source` to `secret`.
- If you are using a Private CA signed certificate , add `--set privateCA=true` to the command shown below.

```
helm install rancher-latest/rancher \
  --name rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set ingress.tls.source=secret
```

Now that Rancher is deployed, see [Adding TLS Secrets](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/tls-secrets/) to publish the certificate files so Rancher and the ingress controller can use them.

After adding the secrets, check if Rancher was rolled out successfully:

```
kubectl -n cattle-system rollout status deploy/rancher
Waiting for deployment "rancher" rollout to finish: 0 of 3 updated replicas are available...
deployment "rancher" successfully rolled out
```

If you see the following error: `error: deployment "rancher" exceeded its progress deadline`, you can check the status of the deployment by running the following command:

```
kubectl -n cattle-system get deploy rancher
NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
rancher   3         3         3            3           3m
```

It should show the same count for `DESIRED` and `AVAILABLE`.

### Advanced Configurations

The Rancher chart configuration has many options for customizing the install to suit your specific environment. Here are some common advanced scenarios.

- [HTTP Proxy](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/#http-proxy)
- [Private Docker Image Registry](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/#private-registry-and-air-gap-installs)
- [TLS Termination on an External Load Balancer](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/#external-tls-termination)

See the [Chart Options](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/chart-options/) for the full list of options.

### Save your options

Make sure you save the `--set` options you used. You will need to use the same options when you upgrade Rancher to new versions with Helm.

### Finishing Up

That’s it you should have a functional Rancher server. Point a browser at the hostname you picked and you should be greeted by the colorful login page.


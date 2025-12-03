# Install a Prometheus Stack on Amazon EKS Using the Prometheus Operator

### Includes: PrometheusRule example + sample Grafana dashboard

This sample project provides everything you need to stand up an Amazon EKS cluster, install a full monitoring stack using the **kube-prometheus-stack** Helm chart (Prometheus Operator), deploy a sample alert, and load a Grafana dashboard.

It includes ready-to-use manifests, Helm values, utility scripts, and a packaging helper.
You can clone this repo or copy these files into your own GitHub project.

---

## What This Project Demonstrates

* Creating an Amazon EKS cluster using **eksctl**
* Installing the **Prometheus Operator** and the full monitoring suite:

  * Prometheus
  * Alertmanager
  * Grafana
  * Exporters and CRDs that power the operator
* Applying a sample **PrometheusRule** alert
* Importing a simple **Grafana dashboard**
* Cleaning up the environment safely

---

## Technologies Used

* **Prometheus / Prometheus Operator** (`kube-prometheus-stack`)
* **Kubernetes** on **Amazon EKS**
* **Helm 3**
* **eksctl**
* **Grafana**
* Bash (Linux/macOS)

---

## Repository Contents

| Path                                       | Description                                                                              |
| ------------------------------------------ | ---------------------------------------------------------------------------------------- |
| `eksctl/create-cluster.yaml`               | eksctl configuration describing the EKS cluster, nodegroup, region, instance types, etc. |
| `scripts/create-cluster.sh`                | Script that runs `eksctl create cluster ...` using the config file.                      |
| `scripts/delete-cluster.sh`                | Script to tear down the cluster.                                                         |
| `helm/values-prometheus.yaml`              | Opinionated example values for the kube-prometheus-stack Helm chart.                     |
| `manifests/prometheus-rules.yaml`          | Example PrometheusRule defining a basic alert.                                           |
| `grafana/dashboards/sample-dashboard.json` | Minimal example Grafana dashboard for import.                                            |
| `package.sh`                               | Zip/packaging helper.                                                                    |
| `.gitignore`, `LICENSE`                    | Project metadata.                                                                        |

**⚠️ Important:**
This repository is intended for demonstration.
Before using in production:

* Replace all default passwords and secrets.
* Update storage classes, IAM roles, and cluster configuration to match your environment.
* Apply proper security, RBAC, and network controls.

---

## Prerequisites

You must have the following installed and configured:

* AWS account + CLI credentials (`~/.aws/credentials`)
* **eksctl** — [https://eksctl.io/](https://eksctl.io/)
* **kubectl** — [https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)
* **Helm 3** — [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)
* AWS IAM permissions for EKS (ability to create VPC, EC2, IAM resources)

---

# Step-by-Step Guide

---

## 1. Review or Customise the Cluster Configuration

Open:

```
vim eksctl/create-cluster.yaml
```

Here you can adjust:

* **region**
* **clusterName**
* **nodeGroup instance type(s)**
* **scaling configuration**
* **SSH access** (optional)

This determines how large your cluster is and how expensive it will be.
For testing, small instance types like `t3.medium` are usually sufficient.

---

## 2. Create the EKS Cluster

Make scripts executable:

```bash
chmod +x scripts/create-cluster.sh scripts/delete-cluster.sh
```

Create the cluster:

```bash
./scripts/create-cluster.sh
```

which:

* Provision the EKS control plane
* Creates a managed nodegroup
* Sets up VPC networking for the cluster

This process usually takes **10–20 minutes**.

---

## 3. Add the Helm Repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### What this does:

* Adds the official Prometheus community charts repo
* Refreshes local chart information

---

## 4. Install the kube-prometheus-stack

Use the included values file:

```bash
export RELEASE_NAME=prometheus-stack

helm install $RELEASE_NAME \
  prometheus-community/kube-prometheus-stack \
  -f helm/values-prometheus.yaml \
  --namespace monitoring \
  --create-namespace
```

### What this installs:

* **Prometheus**
* **Alertmanager**
* **Grafana**
* **ServiceMonitor** CRDs and operator components
* Node exporter / kube-state-metrics
* Default dashboards and alerts

Everything is created inside the `monitoring` namespace.

---

## 5. Verify the Deployment

Check the pods:

```bash
kubectl get pods -n monitoring
```

Check services:

```bash
kubectl get svc -n monitoring
```

Wait for all pods to become **Running** or **Completed**.

---

## 6. Access Grafana

### Get the Grafana admin password:

If using the provided values file:

```bash
kubectl get secret \
  --namespace monitoring \
  prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

*(Update the secret name if your release name is different.)*

### Port-forward the Grafana service:

```bash
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
```

Now open:

```
http://localhost:3000
```

**Login:**

* Username: `admin`
* Password: retrieved above

---

## 7. Apply the Sample PrometheusRule

```bash
kubectl apply -n monitoring -f manifests/prometheus-rules.yaml
```

### What this does:

* Creates or updates a PrometheusRule CRD
* Defines a simple alert (e.g., based on API server metrics or a sample demo metric)
* Validates that the Prometheus Operator reconciles custom rules correctly

Modify thresholds or conditions to match real production requirements.

---

## 8. Import the Sample Grafana Dashboard

In the Grafana UI:

1. Go to **Dashboards → Import**
2. Paste the JSON from:

```
grafana/dashboards/sample-dashboard.json
```

3. Click **Import**

You should now see a minimal dashboard populated with sample panels.

---

## 9. Cleanup the Environment (Optional)

Remove the monitoring stack:

```bash
helm uninstall prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

Remove the EKS cluster:

```bash
./scripts/delete-cluster.sh
```

---

# Notes & Best Practices

* Use AWS-appropriate storage classes (e.g., `gp3` for production).
* For production:

  * Enable HA for Prometheus and Alertmanager
  * Integrate Grafana with OAuth/IAM
  * Use external persistent storage and backups
* Rotate all passwords and secrets; use:

  * Kubernetes Secrets
  * AWS Secrets Manager
  * HashiCorp Vault

---

## License

MIT

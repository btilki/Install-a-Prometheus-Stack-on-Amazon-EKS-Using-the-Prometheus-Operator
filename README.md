# Install Prometheus Stack in Kubernetes (EKS) using the Prometheus Operator and add a PrometheusRule and a Grafana dashboard 

This sample project contains files and scripts you can download and push to a GitHub repository. It demonstrates how to:

- Create an AWS EKS cluster with `eksctl`
- Install the Prometheus stack (Prometheus, Alertmanager, and Grafana) using the `kube-prometheus-stack` Helm chart (Prometheus Operator)
- Add a basic PrometheusRule (alert) and a sample Grafana dashboard
- Clean up the cluster

Technologies used:
- Prometheus (Prometheus Operator / kube-prometheus-stack)
- Kubernetes (Amazon EKS)
- Helm
- eksctl
- Grafana
- Linux / macOS (bash)

Contents of this repo:
- eksctl/create-cluster.yaml — sample EKS cluster configuration for `eksctl`
- scripts/create-cluster.sh — script to create the cluster (uses eksctl)
- scripts/delete-cluster.sh — delete the cluster
- helm/values-prometheus.yaml — opinionated values for the `kube-prometheus-stack` Helm chart (sample)
- manifests/prometheus-rules.yaml — example PrometheusRule (alert) resource
- grafana/dashboards/sample-dashboard.json — a minimal Grafana dashboard JSON you can import
- package.sh — create a downloadable zip of the repo
- .gitignore, LICENSE

Important: This is a sample/demo configuration. Do not use the default passwords in production. Replace storage class names and access policies to fit your AWS account and cluster configuration.

Prerequisites
- AWS account and AWS CLI configured (~/.aws/credentials)
- eksctl installed: https://eksctl.io/
- kubectl installed and configured: https://kubernetes.io/docs/tasks/tools/
- Helm 3: https://helm.sh/docs/intro/install/
- jq (optional, used in scripts)
- AWS IAM permissions to create EKS clusters and related resources (VPC, EC2, IAM)

Step-by-step guide
1) Inspect or adjust the cluster configuration
   - Open `eksctl/create-cluster.yaml`. Adjust region, clusterName, nodegroup instance types, and scaling to fit your needs and budget.

2) Create the EKS cluster
   - Make the scripts executable:
     ```
     chmod +x scripts/create-cluster.sh scripts/delete-cluster.sh
     ```
   - Run:
     ```
     ./scripts/create-cluster.sh
     ```
   - The script runs `eksctl create cluster -f eksctl/create-cluster.yaml`. It will create an EKS control plane and managed nodegroup. This can take ~10–20 minutes.

3) Install Helm chart repositories
   ```
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

4) Install kube-prometheus-stack with the sample values
   - Example install command:
     ```
     export RELEASE_NAME=prometheus-stack
     helm install $RELEASE_NAME prometheus-community/kube-prometheus-stack -f helm/values-prometheus.yaml --namespace monitoring --create-namespace
     ```
   - This installs Prometheus, Alertmanager, Grafana, and related components into the `monitoring` namespace.

5) Verify installation
   ```
   kubectl get pods -n monitoring
   kubectl get svc -n monitoring
   ```
   Wait until pods are in `Running` (or `Completed` for some jobs).

6) Get Grafana credentials and access the UI
   - If you used the sample `values-prometheus.yaml`, Grafana admin password is set there. Otherwise retrieve:
     ```
     kubectl get secret --namespace monitoring prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
     ```
     (Replace `prometheus-stack` with your release name if different.)
   - Port-forward to access Grafana locally:
     ```
     kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
     # then open http://localhost:3000
     ```
   - Login: user `admin` and the password from above (or what you set).

7) Create rule / alerts
   - Apply the sample `manifests/prometheus-rules.yaml`:
     ```
     kubectl apply -n monitoring -f manifests/prometheus-rules.yaml
     ```
   - The rule alerts when the kube-system `kube-apiserver` or a demo metric crosses the threshold (it's a simple example). Adjust it for production.

8) Import the sample Grafana dashboard
   - In Grafana UI -> Dashboards -> Import -> Paste the JSON from `grafana/dashboards/sample-dashboard.json`.

9) Cleanup
   - Delete Helm release and namespace (optional):
     ```
     helm uninstall prometheus-stack -n monitoring
     kubectl delete namespace monitoring
     ```
   - Delete the EKS cluster:
     ```
     ./scripts/delete-cluster.sh
     ```

Notes and recommendations
- Use an appropriate storageClass for PVs in AWS (gp2 or gp3). The values file uses `gp2` as an example.
- For production, use external storage and HA configurations for Alertmanager and Prometheus, and secure Grafana (OAuth, IAM auth).
- Rotate passwords and use Kubernetes secrets or external secret stores (AWS Secrets Manager, HashiCorp Vault).
- You can use `kubectl get prometheus` / `kubectl get servicemonitor`, etc. to explore the Prometheus Operator CRDs.

License
- MIT. See LICENSE file.

That's it — the repo is self-contained. Follow the steps above to create the EKS cluster, install the Prometheus stack, and try the sample alert + dashboard.

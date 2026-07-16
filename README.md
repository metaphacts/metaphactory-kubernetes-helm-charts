# metaphactory Helm Chart
Repository for maintaining Helm chart definitions for metaphactory

## Prerequisites

* `kubectl` and [Helm 3](https://helm.sh/docs/intro/install/) installed
* a Kubernetes cluster setup (client and server version >= 1.23 , check with `kubectl version`)
* outgoing HTTP/HTTPS traffic for the Kubernetes cluster, allowing to access external Docker registries (e.g. Docker Hub)

## metaphactory Deployment and Maintenance with Helm

### Preparation

To perform any deployments or updates, you will first need to log into the metaphacts' Docker Hub repository. If you do not yet have access, please register for a trial on [https://metaphacts.com/get-started](https://metaphacts.com/get-started) and follow the steps for a Docker-based deployment. After registration, you will receive an email containing a user name and token to access the container image from Docker Hub which can be used to log in using `docker login`.

**IMPORTANT:** This guide is using a `StatefulSet` for the deployment of metaphactory, which includes the pod and volume claim definitions in one file and allows easy update and scale-out configurations defined in `templates/statefulset.yaml`.

The configuration for an AWS Load Balancer with SSL termination is included in `templates/metaphactory-ingress-tls.yaml` and can be activated by setting the property `enabled` in the `ingress` section within `values.yaml` to `true`.

### Helm-specific configuration

This repository provides a Helm Repository that can be added by running the
following command:

```sh
helm repo add metaphactory https://metaphacts.github.io/metaphactory-kubernetes-helm-charts/
```

Define separate values files for your deployments, e.g.
`development-values.yaml` and `production-values.yaml`.

To deploy the Helm chart with the values defined in this file, the filename is
passed as a parameter to the `install` command like this:

```sh
helm install metaphactory metaphactory/metaphactory -f development-values.yaml
```

New Chart Versions are automatically pushed to the Helm Repository. You can list
available versions with.

```sh
helm search repo metaphactory --versions
```

When upgrading you need to reference the values file again, or provide the
flag `--reuse-values`:

```sh
helm upgrade metaphactory metaphactory/metaphactory -f development-values.yaml --version 6.3.6
```

#### metaphactory Configuration

The SSO configuration defined in file `values.yaml` provides an example
configuration using OIDC with Azure AD for Single-Sign On (SSO) and a database
configuration for an externally running GraphDB database.

##### Authentication and Single-Sign On (SSO)

This Helm chart supports SSO via OpenID Connect (OIDC), the OIDC configuration is defined in `shiro-sso-oidc-params.ini` (parameter `ssoOidcParams` in file `values.yaml`). The example shows how to use OIDC with Azure AD for Single-Sign On (SSO). When using Azure, the values for `discoveryURI.value` (replace `customer-tenant-id` with your organization's ID), `callbackUrl.value` (externally reachable URL of your metaphactory installation), `clientId.value` (ID of application registered for metaphactory in Azure AD), and `clientSecret.value` (corresponding client password) need to be adjusted.

Local users can be enabled by un-commenting the parameter `enableLocalUsers` in `environment.prop`. The users are defined in the `shiro.ini` file also provided in parameter `localDefaultUsers` in file `values.yaml`.

Also see the [Authentication and Authorization Providers](https://help.metaphacts.com/resource/Help:AuthenticationProviders#oidc) documentation for details on OIDC configuration.

**Please note:** as this file is projected into the container as a read-only file, users and passwords cannot be managed using metaphactory's User Administration page. Instead, they can be created using the [Shiro Command Line Hasher tool](https://shiro.apache.org/command-line-hasher.html) and stored in the parameter.

##### Database Configuration

The database configuration is provided with the `repository-config` key in the `ConfigMap`. See [Repository Manager](https://help.metaphacts.com/resource/Help:RepositoryManager) as well as [How to connect to GraphDB](https://help.metaphacts.com/resource/Help:HowToConnectToGraphDB) or [How to connect to Stardog](https://help.metaphacts.com/resource/Help:HowToConnectToStardog) for details on database configuration.

**Please note**: as this file is projected into the container as a read-only file, it cannot be changed using metaphactory's Repository Administration page.

**Note:** the `ConfigMap` contains two configuration files for the tests and assets repositories: `repository-assets-config` and `repository-tests-config` which will configure metaphactory to use GraphDB repositories for assets and tests.


#### Initial Deployment

To create a new deployment from scratch chose from these two options:

##### metaphactory for use with existing triple stores

1. Clone this GIT repository
2. Create a namespace (or use an existing one): `kubectl create ns metaphactory-dev`
3. Create a secret in your cluster to pull images from a private registry and note down the name of that secret (the secret name assumed in provided configuration files is `regcred`): `kubectl create secret docker-registry regcred --docker-username=metaphactscustomers --docker-password=<your-token-from-registration> --namespace metaphactory-dev`
4. Create a secret in your cluster to access the database (the secret name assumed in provided configuration files is `credentials`): `kubectl create secret generic credentials --from-literal=repository.username=admin --from-literal=repository.password=admin --namespace metaphactory-dev`
5. Ensure that the correct secret names from the previous steps are set in `values.yaml` for parameters `imagePullSecretName:` and `credentialsSecretName:`
6. Ensure that the intended storage class is set in `values.yaml` in the `storage` part for `className:`. Use the command `kubectl get storageclass` to list available storage classes in your cluster.
7. The default configuration creates a service of type `LoadBalancer`. This can be changed to `type: ClusterIP` or `type: NodePort` in the `service` section of `values.yaml`.
8. Adjust the SSO and database configuration in `values.yaml` to work with the target environment (see below)
9. Next start the metaphactory chart with `helm install -f values.yaml metaphactory ./charts/metaphactory/` and verify that the pod and service are running fine with `kubectl get pods` and `kubectl get service metaphactory` service should show an external IP, please note down this IP or hostname.
Please note, that Helm will create the deployment within the default namespace. To use a different namespace, rather execute `helm install metaphactory ./charts/metaphactory/ --namespace metaphactory-dev` instead.
10. Verify that the application is running by connecting to `http://<external IP>` with the external IP as retrieved during step 9.
11. Login with your SSO user. When local users are enabled (see `Configuration` below), user name and credentials can be provided in the login form available at the `/login` endpoint. The default credentials are user `admin` with password `admin`.



### Optional Setup: Activate the Ontopic Module for the Semantic Layer

The mapping and virtualization capabilities of the Semantic Layer are powered by [Ontopic](https://metaphacts.com), deployed alongside metaphactory. Ontopic provides the environment for AI-assisted creation, curation and review of the executable (R2RML) mappings, and serves these mappings as SPARQL endpoints over your relational databases - making the data queryable as a knowledge graph without physically moving it.

This is an optional module: disabled by default, enabled by setting `ontopic.enabled: true` in `values.yaml`. It deploys 6 additional Pods:

| Service | Purpose |
|---|---|
| `ontopic-angular-frontend` | Ontopic Studio web UI |
| `ontopic-process-server` | Query processing backend |
| `ontopic-store-server` | Project/policy store backend |
| `ontopic-store-server-db` | PostgreSQL for `ontopic-store-server` (community image) |
| `ontopic-server` | Semantic SQL / SPARQL endpoint server |
| `ontopic-ai-server` | LLM-backed AI assistant for Ontopic Studio (requires an OpenAI/Anthropic key) |

#### Network isolation

Ontopic is reached exclusively through metaphactory's reverse proxy - none of the 6 Pods above have an Ingress of their own, and their Services are `ClusterIP`-only.

**This alone does not fully isolate them.** Kubernetes namespaces are not a network boundary: any Pod anywhere in the cluster (even in a different namespace) can resolve and connect to a `ClusterIP` Service unless something actively blocks it. To actually restrict which Pods may reach Ontopic, this chart also renders `NetworkPolicy` resources (`ontopic.networkPolicy.enabled`, `true` by default) that default-deny ingress to each Ontopic Pod except from metaphactory and the specific other Ontopic Pods that legitimately talk to it.

**Important caveat:** `NetworkPolicy` is only enforced if your cluster's CNI plugin implements it. Calico, Cilium, and most managed-cloud CNIs (EKS, GKE, AKS) do. Plain Flannel does **not** - it silently accepts `NetworkPolicy` objects without ever enforcing them, with no error or warning. Verify your cluster's CNI supports `NetworkPolicy` before relying on this as your only isolation mechanism.

#### Enabling Ontopic

1. Create the required secret (`ontopic-store-secrets` by default, referenced by `ontopic.storeServer.secretName` / `ontopic.storeServerDb.secretName`) with a `db-password` key shared by `ontopic-store-server` and `ontopic-store-server-db`:
   ```sh
   kubectl create secret generic ontopic-store-secrets \
     --from-literal=db-password='<strong-password>' --namespace metaphactory-dev
   ```
2. Optionally, create secrets for blob-storage-backed materialization and for the AI assistant, and reference their names via `ontopic.ontopicServer.blobStorageSecretName` / `ontopic.aiServer.secretName` (left empty by default - Ontopic runs fine without them, just without those features):
   ```sh
   kubectl create secret generic ontopic-blob-secrets \
     --from-literal=s3-access-key-id='...' --from-literal=s3-access-key-secret='...' \
     --from-literal=azure-account-name='...' --from-literal=azure-account-key='...' \
     --from-literal=azure-sas-token='...' --namespace metaphactory-dev

   kubectl create secret generic ontopic-ai-secrets \
     --from-literal=openai-api-key='...' --from-literal=anthropic-api-key='...' \
     --from-literal=llm-additional-headers='...' --namespace metaphactory-dev
   ```
3. Configure JDBC drivers for `ontopic.processServer.jdbc` and `ontopic.ontopicServer.jdbc` (the **H2 driver is mandatory** for `ontopic-server` - it uses H2 as its internal metadata store and will not start without it; it's pre-configured as a default). Two options, configured per-service:
   - **`existingClaim`** (recommended for production/air-gapped clusters): reference a `PersistentVolumeClaim` you populate once yourself, e.g. via `kubectl cp` against a throwaway Pod mounting the same claim. No runtime network dependency.
   - **`urls`** (convenience default for quick evaluation): a list of `{name, url}` entries downloaded by an initContainer (reusing the metaphactory image, which already has `curl`) into an ephemeral volume on every Pod start. Append an entry per relational database you plan to map, e.g.:
     ```yaml
     ontopic:
       ontopicServer:
         jdbc:
           urls:
             - name: h2
               url: https://repo1.maven.org/maven2/com/h2database/h2/2.3.232/h2-2.3.232.jar
             - name: postgresql
               url: https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar
     ```
4. Set `ontopic.enabled: true` in your values file and run `helm upgrade`/`helm install` as usual.
5. Verify: `kubectl get pods --namespace metaphactory-dev` until all `ontopic-*` Pods and `metaphactory` reach `Running`/`Ready`, then browse to `https://<your-metaphactory-host>/`, open the 'Apps' menu and select 'Ontopic'  and confirm the Ontopic UI loads.

#### Redeploying Ontopic from scratch

To wipe Ontopic's persistent state and start over (this destroys all Ontopic projects, mappings, and materialized data):
```sh
kubectl delete pvc --namespace metaphactory-dev \
  ontopic-store-server-docs-ontopic-store-server-0 \
  ontopic-store-server-repos-ontopic-store-server-0 \
  ontopic-store-server-db-data-ontopic-store-server-db-0 \
  ontopic-server-endpoint-ontopic-server-0 \
  ontopic-server-endpoint-security-ontopic-server-0 \
  ontopic-server-materialization-db-ontopic-server-0 \
  ontopic-server-materialization-configuration-ontopic-server-0 \
  ontopic-server-materialization-result-ontopic-server-0
```



### Deleting the Deployment

To remove the complete setup run following commands (**Note: This will remove all persistent volumes and data as well!**)
1. Remove the metaphactory chart with `helm uninstall metaphactory` - **Note: This will destroy all metaphactory runtime data and configuration!**



### Troubleshooting

Please follow below steps before contacting our support on `support@metaphacts.com`
1. Run `kubectl describe service metaphactory` to verify the status of the service.
2. Run `kubectl describe pod metaphactory` to get details on the metaphactory pod status. The init container should be in state terminated and the actual container in state running.
3. Follow activity in the cluster with `kubectl events`
4. Pull logs on the metaphactory pod with `kubectl logs metaphactory-0`
5. You can access the container for advanced troubleshooting through `kubectl exec -it metaphactory-0 -- sh`

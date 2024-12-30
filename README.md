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

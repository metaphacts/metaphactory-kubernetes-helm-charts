# Changelog

All notable changes to the Kubernetes Helm Charts-based setup are documented in this file.

Note: when updating to a newer release of metaphactory, also regard the information from the respective [Changelog](https://help.metaphacts.com/resource/Help:Start?tab=Changelog). Updates to the application content may be required as specified in the upgrade notes.

If not mentioned otherwise, the Helm chart definitions are backwards compatible to the previous released version.

## 2026-09-30 (Release 6.1.0)

The docker tags have been updated to the 6.1.0 release of metaphactory.

The Knowledge Extractor module (document annotation extraction service) is now an optional part of the deployment.

**Breaking change:** the standalone Ontopic suite deployment added for metaphactory 6.0 (version 1.12 of the Helm chart ) has been removed - the Semantic Layer's mapping/virtualization capabilities are now fully integrated into metaphactory itself and require no separate deployment or configuration.
If your values file sets `ontopic.enabled: true` or any other `ontopic.*` key, remove that section before upgrading; it is no longer recognized and the corresponding Pods will no longer be deployed.

Additional changes

- Add support for configuring a `ServiceAccount` for the metaphactory pod (e.g. for EKS Pod Identity/IRSA-style cloud API authentication)
- Add ability to provision JDBC drivers for metaphactory itself via the bundled `jdbc-drivers` app (`container.jdbc`)
- Add ability to disable the database/repository configuration entirely (`database.enabled: false`) for deployments where it will be configured later


## 2026-08-03 (Release 6.0.1)

The docker tags have been updated to the 6.0.1 release of metaphactory.

The docker tags have been updated to the 6.0.1 release of Ontopic.

Additional changes

- Add a predefined jmxExporter and configuration which can be enabled via values.yml. The JMX Exporter agent is shipped as part of metaphactory and only needs to be referenced as shown in the commented example.


## 2026-07-13 (Release 6.0.0)

The docker tags have been updated to the 6.0.0 release of metaphactory.

Add optional deployment of the Semantic Layer, powered by Ontopic


## 2026-03-27 (Release 5.11.0)

The docker tags have been updated to the 5.11.0 release of metaphactory.


## 2026-03-26 (Release 5.10.4)

The docker tags have been updated to the 5.10.4 release of metaphactory.

Additional changes

- Add support for enabling jetty statistics module in the container
- Add support for enabling JMX monitoring metrics in the container


## 2026-03-04 (Release 5.10.3)

- Add ability to configure the plugin.properties file


## 2026-02-11 (Release 5.10.3)

The docker tags have been updated to the 5.10.3 release of metaphactory.

Additional changes

- Add support for enabling jetty request logs in the container


## 2026-02-05 (Release 5.10.2)

- Add ability to inject custom Jetty configuration into the container


## 2026-01-29 (Release 5.10.2)

The docker tags have been updated to the 5.10.2 release of metaphactory.

Additional changes

- Fix resource specification to make limit configurable and change variable names


## 2026-01-12 (Release 5.10.1)

The docker tags have been updated to the 5.10.1 release of metaphactory.

Additional changes

- fix for storageClass name
- updated liveness/readiness endpoints

## 2025-12-19 (Release 5.10.0)

The docker tags have been updated to the 5.10.0 release of metaphactory.


## 2025-10-08 (Release 5.9.0)

The docker tags have been updated to the 5.9.0 release of metaphactory.


## 2025-07-10 (Release 5.8.0)

The docker tags have been updated to the 5.8.0 release of metaphactory.

Additional changes

- improved configuration to support activating bundled apps like eia-physical-layer and ai-services


## 2025-03-28 (Release 5.7.0)

The docker tags have been updated to the 5.7.0 release of metaphactory.

Additional changes

- improved configuration for repositories
- improved options to define metaphactory system configuration via ConfigMap
- improved ability to mount apps from volumes


## 2024-12-20 (Release 5.6.0)

The docker tags have been updated to the 5.6.0 release of metaphactory.



## 2024-09-25 (Release 5.5.0)

The docker tags have been updated to the 5.5.0 release of metaphactory.



## 2024-07-05 (Release 5.4.0)

The docker tags have been updated to the 5.4.0 release of metaphactory.



## 2024-03-28 (Release 5.3.0)

The docker tags have been updated to the 5.3.0 release of metaphactory.



## 2024-01-12 (Release 5.2.0)

The docker tags have been updated to the 5.2.0 release of metaphactory.

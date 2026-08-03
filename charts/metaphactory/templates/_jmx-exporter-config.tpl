{{- define "metaphactory.jmxExporterConfig" -}}
lowercaseOutputName: true
rules:
  # JVM classes currently loaded.
  - pattern: 'java.lang<type=ClassLoading><LoadedClassCount>'
    name: jvm_classes_currently_loaded
    type: GAUGE

  - pattern: 'java.lang<type=Memory><HeapMemoryUsage>committed'
    name: metaphactory_jmx_memory_committed_bytes
    labels:
      area: heap
    type: GAUGE

  - pattern: 'java.lang<type=Memory><NonHeapMemoryUsage>committed'
    name: metaphactory_jmx_memory_committed_bytes
    labels:
      area: nonheap
    type: GAUGE

  # Heap and non-heap configured memory ceiling.
  - pattern: 'java.lang<type=Memory><HeapMemoryUsage>max'
    name: metaphactory_jmx_memory_max_bytes
    labels:
      area: heap
    type: GAUGE
    
  - pattern: 'java.lang<type=Memory><NonHeapMemoryUsage>max'
    name: metaphactory_jmx_memory_max_bytes
    labels:
      area: nonheap
    type: GAUGE

  # Current and peak JVM thread counts.
  - pattern: 'java.lang<type=Threading><ThreadCount>'
    name: jvm_threads_current
    type: GAUGE

  - pattern: 'java.lang<type=Threading><PeakThreadCount>'
    name: jvm_threads_peak
    type: GAUGE

  # File descriptor usage from the JVM process.
  - pattern: 'java.lang<type=OperatingSystem><OpenFileDescriptorCount>'
    name: process_open_fds
    type: GAUGE
  - pattern: 'java.lang<type=OperatingSystem><MaxFileDescriptorCount>'
    name: process_max_fds
    type: GAUGE

  # Process CPU time is exposed by the JVM in nanoseconds.
  - pattern: 'java.lang<type=OperatingSystem><ProcessCpuTime>'
    name: process_cpu_seconds_total
    valueFactor: 1.0e-9
    type: COUNTER

  # Virtual memory reserved by the JVM process.
  - pattern: 'java.lang<type=OperatingSystem><CommittedVirtualMemorySize>'
    name: process_virtual_memory_bytes
    type: GAUGE
{{- end -}}
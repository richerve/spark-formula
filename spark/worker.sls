{% from "spark/map.jinja" import spark with context %}

include:
  - spark

spark_worker_defaults:
  file.managed:
    - name: /etc/default/spark-worker
    - source: salt://spark/files/spark-worker.default.jinja
    - template: jinja
    - defaults:
        worker_args: {{ spark.worker.args }}
        master_uri: {{ spark.worker.master_uri }}

spark_worker_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/spark-worker.service
    - source: salt://spark/files/spark-worker.systemd.jinja
{%- endif %}
    - template: jinja
    - defaults:
        user: {{ spark.user }}
        group: {{ spark.group }}
        version_path: {{ spark.version_path }}
    - watch:
      - file: spark_worker_defaults

spark_worker_service:
  service.running:
    - name: spark-worker
    - enable: True
    - watch:
      - file: spark_worker_service_unit
      - file: spark_worker_defaults

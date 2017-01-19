{% from "spark/map.jinja" import spark with context %}

include:
  - spark

spark_master_defaults:
  file.managed:
    - name: /etc/default/spark-master
    - source: salt://spark/files/spark-master.default.jinja
    - template: jinja
    - defaults:
        master_args: {{ spark.master.args }}

spark_master_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/spark-master.service
    - source: salt://spark/files/spark-master.systemd.jinja
{%- endif %}
    - template: jinja
    - defaults:
        user: {{ spark.user }}
        group: {{ spark.group }}
        version_path: {{ spark.version_path }}
    - watch:
      - file: spark_master_defaults

spark_master_service:
  service.running:
    - name: spark-master
    - enable: True
    - watch:
      - file: spark_master_service_unit
      - file: spark_master_defaults

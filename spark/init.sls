{% from "spark/map.jinja" import spark with context %}
{%- set version_path = spark.install_dir ~ "/spark-" ~ spark.version %}

spark_tarball:
  archive.extracted:
    - name: {{ spark.install_dir }}
    - source: {{ spark.source }}
    - source_hash: {{ spark.source_hash }}
    - archive_format: tar
    - if_missing: {{ version_path }}

spark-symlink:
  file.symlink:
    - name: {{spark.install_dir}}/spark
    - target: {{ version_path }}
    - require:
      - archive: spark_tarball

spark-submit_bin_link:
  file.symlink:
    - name: /usr/bin/spark-submit
    - target: {{ version_path }}/bin/spark-submit
    - require:
      - archive: spark_tarball

spark_conf_link:
  file.symlink:
    - name: /etc/spark
    - target: {{ version_path }}/conf
    - require:
      - archive: spark_tarball

{%- if spark.env is defined %}
spark_env:
  file.managed:
    - name: /etc/spark/spark-env.sh
    - source: salt://spark/files/spark-env.jinja
    - template: jinja
    - defaults:
        spark_env: {{spark.env}}
    - require:
      - file: spark_conf_link
{%- endif %}

spark_profile:
  file.managed:
    - name: /etc/profile.d/spark.sh
    - contents:
      - export SPARK_HOME={{ version_path }}
    - require:
      - file: spark-submit_bin_link

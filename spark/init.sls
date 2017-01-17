{% from "spark/map.jinja" import spark with context %}

spark_tarball:
  archive.extracted:
    - name: {{ spark.install_dir }}
    - source: {{ spark.source }}
    - source_hash: {{ spark.source_hash }}
    - archive_format: tar
    - if_missing: {{ spark.version_path }}

spark-symlink:
  file.symlink:
    - name: {{spark.install_dir}}/spark
    - target: {{ spark.version_path }}
    - require:
      - archive: spark_tarball

spark-submit_bin_link:
  file.symlink:
    - name: /usr/bin/spark-submit
    - target: {{ spark.version_path }}/bin/spark-submit
    - require:
      - archive: spark_tarball

spark_conf_link:
  file.symlink:
    - name: /etc/spark
    - target: {{ spark.version_path }}/conf
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
      - SPARK_HOME={{ spark.version_path }}
      - export SPARK_HOME
    - require:
      - file: spark-submit_bin_link

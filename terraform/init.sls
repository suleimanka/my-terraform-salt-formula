{%- include "terraform/map.jinja" -%}

terraform-deps:
  pkg.installed:
    - pkgs:
      - unzip

{% for ver, info in terraform.artifacts.items() %}
terraform-{{ ver }}-dir:
  file.directory:
    - name: /usr/local/bin/terraform-{{ ver }}
    - user: root
    - group: root
    - mode: 755

terraform-{{ ver }}-archive:
  archive.extracted:
    - name: /usr/local/bin/terraform-{{ ver }}
    - source: {{ info.url }}
    {%- if info.sha256 %}
    - source_hash: sha256={{ info.sha256 }}
    {% endif %}
    - archive_format: zip
    - enforce_toplevel: False
    - user: root
    - group: root
    - require:
      - pkg: terraform-deps
      - file: terraform-{{ ver }}-dir

terraform-{{ ver }}-perm:
  file.file:
    - name: /usr/local/bin/terraform-{{ ver }}/terraform
    - mode: 755
    - user: root
    - group: root
    - require:
      - archive: terraform-{{ ver }}-archive
{% endfor %}

terraform-symlink:
  file.symlink:
    - name: /usr/local/bin/terraform
    - target: /usr/local/bin/terraform-{{ terraform.default_version }}/terraform
    - force: true
    - require:
      - archive: terraform-{{ terraform.default_version }}-archive

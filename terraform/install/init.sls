{% from 'terraform/settings.jinja' import terraform, get_download_url, get_skip_verify, get_source_hash_url with context %}

"Terraform :: Manage base dir":
  file.directory:
    - name: {{ terraform.dirs.root }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{%- for ver in terraform.versions %}

"Terraform :: Download archive for {{ ver }}":
  file.managed:
    - name: {{ terraform.dirs.root }}/terraform_{{ ver }}_{{ grains.kernel|lower }}_{{ terraform.arch }}.zip
    - source: "{{ get_download_url(ver) }}"
    - source_hash: "{{ get_source_hash_url(ver) }}"
    - user: root
    - group: root
    - mode: '0644'
    - unless: test -f {{ terraform.dirs.root }}/{{ ver }}/terraform
    - require:
      - file: "Terraform :: Manage base dir"

"Terraform :: Extract {{ ver }}":
  archive.extracted:
    - name: {{ terraform.dirs.root }}/{{ ver }}
    - source: {{ terraform.dirs.root }}/terraform_{{ ver }}_{{ grains.kernel|lower }}_{{ terraform.arch }}.zip
    - archive_format: zip
    - enforce_toplevel: False
    - if_missing: {{ terraform.dirs.root }}/{{ ver }}/terraform
    - user: root
    - group: root
    - require:
      - file: "Terraform :: Download archive for {{ ver }}"

"Terraform :: Alternatives for {{ ver }}":
  alternatives.install:
    - name: terraform
    - link: /usr/local/bin/terraform
    - path: {{ terraform.dirs.root }}/{{ ver }}/terraform
    - priority: {{ ver | replace('.', '') }}
    - require:
      - archive: "Terraform :: Extract {{ ver }}"
    - unless: salt['alternatives.check_exists']('terraform', '{{ terraform.dirs.root }}/{{ ver }}/terraform')

"Terraform :: Remove archive for {{ ver }}":
  file.absent:
    - name: {{ terraform.dirs.root }}/terraform_{{ ver }}_{{ grains.kernel|lower }}_{{ terraform.arch }}.zip
    - require:
      - archive: "Terraform :: Extract {{ ver }}"

{%- endfor %}

{%- from 'base/settings.jinja' import base with context %}

{%- if grains.os_family|lower in ['redhat'] %}
"Base host management :: Manage Epel repository installation for '{{ grains.os }}' platform":
  pkg.installed:
    - name: epel-release
    - order: first
{%- endif  %}

{%- for package in base.pkgs %}
"Base host management :: Manage '{{ package }}' installation":
  pkg.installed:
    - name: {{ package }}
  {%- if ['vim', 'vim-enhanced', 'mc'] in base.pkgs %}
  - require_in:
    {%- if ['vim', 'vim-enhanced'] in base.pkgs %}
    - file: "Base host management :: Manage VIM RC configuration"
    {%- endif  %}
    {%- if ['mc'] in base.pkgs %}
    - file: "Base host management :: Manage MC configuration"
    {%- endif  %}
  {%- endif  %}
{%- endfor %}

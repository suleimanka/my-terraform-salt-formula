{%- from 'base/settings.jinja' import base with context %}
{%- if (base.sysctl is defined) and (base.sysctl) %}
  {%- if ((grains.virtual == 'physical') or (grains.virtual_subtype is not defined) or
          (grains.virtual_subtype is defined and grains.virtual_subtype|lower != 'docker')) %}
    {%- for parameter, value in base.sysctl.items() %}
"Base host management :: Manage sysctl '{{ parameter }}' configuration with '{{ value }}' value":
  sysctl.present:
    - name: {{ parameter }}
    - value: {{ value }}
    {%- endfor %}
  {%- endif %}
{%- endif %}

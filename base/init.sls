{%- from 'base/settings.jinja' import base with context %}

include:
  - base.packages
  - base.utils
  - base.sysctl

{%- if (base.aliases.commands is iterable) and (base.aliases.commands is not string) %}
"Base host management :: Manage system-wide bash aliases":
  file.line:
    - name: {{ base.aliases.file }}
    - mode: ensure
    - after: '{{ base.aliases.placeholder }}'
    - show_changes: True
    - content: |
  {%- for name, alias in base.aliases.commands.items() %}
        {{ alias }}
  {%- endfor %}
{%- endif %}

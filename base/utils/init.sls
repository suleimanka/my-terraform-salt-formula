{%- from 'base/settings.jinja' import base with context %}

"Base host management :: Manage user auto-logout":
  file.managed:
    - name: /etc/profile.d/timeout-logout.sh
    - source: salt://{{ slspath }}/templates/timeout-logout.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root

{%- if ('vim' in base.pkgs) or ('vim-enhanced' in base.pkgs) %}
"Base host management :: Manage VIM RC configuration":
  file.managed:
    - name: {{ base.vim.vimrc }}
    - source: salt://{{ slspath }}/templates/vimrc
    - template: jinja
    - mode: 644
    - user: root
    - group: root

"Base host management :: Manage VIM RC to VI RC symbolic link":
  file.symlink:
    - name: {{ base.vim.virc }}
    - target: {{ base.vim.vimrc }}
    - force: true
    - require:
      - file: "Base host management :: Manage VIM RC configuration"
{%- endif %}

{%- if 'mc' in base.pkgs %}
"Base host management :: Manage MC configuration":
  file.managed:
    - name: {{ base.mc.conf }}/mc.ini
    - source: salt://{{ slspath }}/templates/mc.ini
    - template: jinja
    - mode: 644
    - user: root
    - group: root
{%- endif %}

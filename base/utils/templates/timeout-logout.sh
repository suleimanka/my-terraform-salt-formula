#!/bin/bash
{%- from 'base/settings.jinja' import base with context %}
# {{ salt['pillar.get']('salt_banner','Managed by salt') }}

TMOUT={{ base.shell.timeout }}
readonly TMOUT
export TMOUT

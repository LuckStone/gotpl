{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(24) -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}

{#
  CUSTOM TEMPLATES: This section contains templates that make up the different parts of the telegraf configuration file.
  - global_tags section
  - agent section
#}

{%- block global_tags -%}
{%- if Values.daemonset.config.global_tags -%}
[global_tags]
  {%- for key, val in Values.daemonset.config.global_tags.iteritems() %}
      {{ key }} = {{ val | quote() }}
  {%- endfor %}
{%- endif %}
{%- endblock -%}

{%- block agent -%}
[agent]
{%- for key, value in Values.daemonset.config.agent.iteritems() %}
  {%- set tp = typeOf(value) %}
  {%- if tp=="string" %}
      {{ key }} = {{ value | quote() }}
  {%- endif %}
  {%- if tp=="float64" %}
      {{ key }} = {{ value | int64() }}
  {%- endif %}
  {%- if tp=="int" %}
      {{ key }} = {{ value | int64() }}
  {%- endif %}
  {%- if tp=="bool" %}
      {{ key }} = {{ value }}
  {%- endif %}
{%- endfor %}
{%- endblock -%}

{%- block outputs -%}
{%- for output, config in Values.daemonset.config.outputs.iteritems() %}
    [[outputs.{{ output }}]]
  {%- if config %}
    {%- for key, value in config.iteritems() -%}
      {%- set tp = typeOf(value) %}
      {%- if tp=="string" %}
      {{ key }} = {{ value | quote() }}
      {%- endif %}
      {%- if tp=="float64" %}
      {{ key }} = {{ value | int64() }}
      {%- endif %}
      {%- if tp=="int" %}
      {{ key }} = {{ value | int64() }}
      {%- endif %}
      {%- if tp=="bool" %}
      {{ key }} = {{ value }}
      {%- endif %}
      {%- if tp == "[]interface {}" %}
      {{ key }} = [
          {%- set numOut = length(value) %}
          {%- set numOut = numOut | sub(1) %}
          {%- for b, val in value.iteritems() %}
            {%- set i = int64(b) %}
            {%- if i==numOut %}
        {{ val | quote() }}
            {%- else %}
        {{ val | quote() }},
            {%- endif %}
          {%- endfor %}
      ]
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
{%- endblock -%}

{%- block inputs -%}
{%- for input, config in Values.daemonset.config.inputs.iteritems() %}
    [[inputs.{{- input }}]]
      {%- if config -%}
        {%- for key, value in config.iteritems() -%}
          {%- set tp = typeOf(value) -%}
          {%- if tp=="string" %}
      {{ key }} = {{ value | quote() }}
          {%- endif %}
          {%- if tp=="float64" %}
      {{ key }} = {{ value | int64() }}
          {%- endif %}
          {%- if tp=="int" %}
      {{ key }} = {{ value | int64() }}
          {%- endif %}
          {%- if tp=="bool" %}
      {{ key }} = {{ value }}
          {%- endif %}
          {%- if tp == "[]interface {}" %}
      {{ key }} = [
              {%- set numOut = length(value) %}
              {%- set numOut = numOut | sub(1) %}
              {%- for b, val in value.iteritems() %}
                {%- set i = b |  int64() %}
                {%- set vtp = typeOf(val) %}
                {%- if i==numOut %}
                  {%- if vtp=="string" %}
        {{ val | quote() }}
                  {%- endif %}
                  {%- if vtp=="float64" %}
        {{ val | int64() }}
                  {%- endif %}
                {%- else %}
                  {%- if vtp=="string" %}
        {{ val | quote() }},
                  {%- endif %}
                  {%- if vtp=="float64" %}
        {{ val | int64() }},
                  {%- endif %}
                {%- endif %}
              {%- endfor %}
      ]
          {%- endif %}
          {%- if tp == "map[string]interface {}" %}
      [[inputs.{{ input }}.{{ key }}]]
            {%- for k, v in value.iteritems() %}
              {%- set tps = typeOf(v) %}
              {%- if tps=="string" %}
        {{ k }} = {{ v }}
              {%- endif %}
              {%- if tps == "[]interface {}" %}
        {{ k }} = [
                {%- set numOut = length(value) %}
                {%- set numOut = numOut | sub(1) %}
                {%- for b, val in v.iteritems() %}
                  {%- set i = b | int64() %}
                  {%- if i==numOut %}
            {{ val | quote() }}
                  {%- else %}
            {{ val | quote() }},
                  {%- endif %}
                {%- endfor %}
        ]
              {%- endif %}
              {%- if tps == "map[string]interface {}" %}
        [[inputs.{{ input }}.{{ key }}.{{ k }}]]
                {%- for foo, bar in v.iteritems() %}
            {{ foo }} = {{ bar | quote() }}
                {%- endfor %}
              {%- endif %}
            {%- endfor %}
          {%- endif %}
        {%- endfor %}
      {%- endif %}
    {%- endfor %}
{%- endblock -%}
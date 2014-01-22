rabbitmq-server:
  pkg.installed: []

{{ pillar['rabbitmq-user'] }}:
  rabbitmq_user.present:
    - password: {{ pillar['rabbitmq-pw'] }}
    - force: true
    - permissions:
      - '/':
        - '.*'
        - '.*'
        - '.*'
    - runas: root
    - require:
      - file: /etc/rabbitmq/rabbitmq.config

{{ pillar['rabbitmq-vhost'] }}:
  rabbitmq_vhost.present:
    - user: {{ pillar['rabbitmq-user'] }}
    - runas: root
    - require:
      - rabbitmq_user: {{ pillar['rabbitmq-user'] }}

{% if pillar['rabbitmq-ssl'] %}
# create certificates
{% set rabbitmq_ca_name = salt['pillar.get']('rabbitmq-ca-name', 'rabbitmq-ca') %}
{% set cert_path = '/etc/pki/'~rabbitmq_ca_name~'/'~rabbitmq_ca_name~'_ca_cert' %}
rabbitmq-create-ca:
  module.run:
    - name: tls.create_ca
    - ca_name: '{{ rabbitmq_ca_name }}'
    - CN: ca-{{ grains['fqdn'] }}
    - C: 'AU'
    - ST: 'Victoria'
    - L: 'Melbourne'
    - O: 'MyTardis'
    - emailAddress: '{{ salt['pillar.get']('admin_email_address', 'admin@localhost') }}'

rabbitmq-create-csr:
  module.run:
    - name: tls.create_csr
    - ca_name: '{{rabbitmq_ca_name}}'
    - CN: {{ grains['fqdn'] }}
    - C: 'AU'
    - ST: 'Victoria'
    - L: 'Melbourne'
    - O: 'MyTardis'
    - emailAddress: '{{ salt['pillar.get']('admin_email_address', 'admin@localhost') }}'
    - require:
        - module: rabbitmq-create-ca

rabbitmq-create-ca-signed-cert:
  module.run:
    - name: tls.create_ca_signed_cert
    - ca_name: '{{ rabbitmq_ca_name }}'
    - CN: {{ grains['fqdn'] }}
    - require:
        - module: rabbitmq-create-csr
# end create certs
{% endif %}

/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - template: jinja
    - source: salt://templates/rabbitmq.config
    - require:
      - pkg: rabbitmq-server
{% if pillar['rabbitmq-ssl'] %}
      - module: rabbitmq-create-ca-signed-cert
    - context:
      ca_name: {{ rabbitmq_ca_name }}
      cert_path: {{ cert_path }}
{% endif %}

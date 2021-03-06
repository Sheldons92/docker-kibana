#!/usr/bin/bash

export HOME=/kibana

: ${ELASTICSEARCH_URL:=http://localhost:9200}
: ${ELASTICSEARCH_CERTIFICATE_VERIFICATION:=full}
: ${ELASTICSEARCH_SSL_CA_CERT_PATH:=}
: ${ELASTICSEARCH_USERNAME:=}
: ${ELASTICSEARCH_PASSWORD:=}
: ${ENABLE_KIBANA_RUNAS_HEADER:=false}
: ${XPACK_SECURITY_ENABLE:=false}
: ${XPACK_SECURITY_ENCRYPTION_KEY:=$(uuidgen)}
: ${XPACK_SECURITY_SECURE_COOKIES_ENABLE:=false}
: ${XPACK_MONITORING_ENABLE:=false}
: ${XPACK_MONITORING_REPORT_STATS:=false}
: ${XPACK_GRAPH_ENABLE:=false}
: ${XPACK_ML_ENABLE:=false}
: ${XPACK_REPORTING_ENABLE:=false}

sed -e "s/%ELASTICSEARCH_CERTIFICATE_VERIFICATION%/${ELASTICSEARCH_CERTIFICATE_VERIFICATION}/" \
    -e "s/%XPACK_SECURITY_ENABLE%/${XPACK_SECURITY_ENABLE}/" \
    -e "s#%XPACK_SECURITY_ENCRYPTION_KEY%#${XPACK_SECURITY_ENCRYPTION_KEY}#" \
    -e "s/%XPACK_SECURITY_SECURE_COOKIES_ENABLE%/${XPACK_SECURITY_SECURE_COOKIES_ENABLE}/" \
    -e "s/%XPACK_MONITORING_ENABLE%/${XPACK_MONITORING_ENABLE}/" \
    -e "s/%XPACK_MONITORING_REPORT_STATS%/${XPACK_MONITORING_REPORT_STATS}/" \
    -e "s/%XPACK_GRAPH_ENABLE%/${XPACK_GRAPH_ENABLE}/" \
    -e "s/%XPACK_ML_ENABLE%/${XPACK_ML_ENABLE}/" \
    -e "s/%XPACK_REPORTING_ENABLE%/${XPACK_REPORTING_ENABLE}/" \
    -i /kibana/config/kibana.yml

if [[ -n "${ELASTICSEARCH_SSL_CA_CERT_PATH}" ]]; then
  sed -e "s#%ELASTICSEARCH_SSL_CA_CERT_PATH_CONFIG_ENTRY%#elasticsearch.ssl.certificateAuthorities: ${ELASTICSEARCH_SSL_CA_CERT_PATH}#" \
      -i /kibana/config/kibana.yml
else
  sed -e "s/%ELASTICSEARCH_SSL_CA_CERT_PATH_CONFIG_ENTRY%//" \
      -i /kibana/config/kibana.yml
fi

if [[ ${ENABLE_KIBANA_RUNAS_HEADER} == true ]]; then
  sed -e "s#%ELASTICSEARCH_REQUEST_HEADERS_WHITELIST_ENTRY%#elasticsearch.requestHeadersWhitelist: [ es-security-runas-user, authorization ]#" \
      -e "s#%XPACK_MONITORING_ELASTICSEARCH_REQUEST_HEADERS_WHITELIST_ENTRY%#xpack.monitoring.elasticsearch.requestHeadersWhitelist: [ es-security-runas-user, authorization ]#" \
      -i /kibana/config/kibana.yml

else
  sed -e "s/%ELASTICSEARCH_REQUEST_HEADERS_WHITELIST_ENTRY%//" \
      -e "s/%XPACK_MONITORING_ELASTICSEARCH_REQUEST_HEADERS_WHITELIST_ENTRY%//" \
      -i /kibana/config/kibana.yml
fi

if [[ -n "${ELASTICSEARCH_USERNAME}" && -n "${ELASTICSEARCH_PASSWORD}" ]]; then 
  sed -e "s#%ELASTICSEARCH_USERNAME_CONFIG_ENTRY%#elasticsearch.username: ${ELASTICSEARCH_USERNAME}#" \
      -e "s#%ELASTICSEARCH_PASSWORD_CONFIG_ENTRY%#elasticsearch.password: ${ELASTICSEARCH_PASSWORD}#" \
      -i /kibana/config/kibana.yml
else
  sed -e "s/%ELASTICSEARCH_USERNAME_CONFIG_ENTRY%//" \
      -e "s/%ELASTICSEARCH_PASSWORD_CONFIG_ENTRY%//" \
      -i /kibana/config/kibana.yml
fi

exec /kibana/node/bin/node src/cli -e "${ELASTICSEARCH_URL}"

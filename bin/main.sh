#!/bin/bash



peano(){
  source bin/main.sh;
  echo "Peano environment loaded";
}


peano_env() {
  local SOURCE_CD="${1:-main.local}";
  local SOURCE_ENV_PATH=".env.${SOURCE_CD}";
  
  set -a
  source "${SOURCE_ENV_PATH}";
  set +a

  echo "Environment variables loaded from ${SOURCE_ENV_PATH}";
}

peano_url() {
  echo "${FUSEKI_HOST}/${DATASET_CD}";
}

peano_sparql() {
  clear;
  curl \
    -s \
    "$(peano_url)/sparql" \
    -H "Accept: ${OUT_FORMAT}" \
    --data-urlencode "query${1}";
}


peano_post() {
  clear;
  local GRAPH_CD="${1}";
  local FILE_PATH="${2}";
  curl \
    -s \
    -X POST "$(peano_url)/data?graph=${GRAPH_CD}" \
    -H "Content-Type: text/turtle" \
    --data-binary "@${FILE_PATH}";
  echo "Data posted to graph ${GRAPH_CD} from ${FILE_PATH}";
}

peano_put() {
  clear;
  local GRAPH_CD="${1}";
  local FILE_PATH="${2}";
  echo "Putting data from ${FILE_PATH} to graph ${GRAPH_CD}";  
  curl \
    -s \
    -X PUT "$(peano_url)/data?graph=${GRAPH_CD}" \
    -H "Content-Type: text/turtle" \
    --data-binary "@${FILE_PATH}";
  echo "Data put to graph ${GRAPH_CD} from ${FILE_PATH}";
}

peano_export() {
  clear;
  local GRAPH_CD="${1}";
  local FILE_PATH="${2}";
  curl \
    -s \
    "$(peano_url)/get?graph=${GRAPH_CD}" \
    -H "Accept: text/turtle" \
    -o "${FILE_PATH}";
  echo "Data exported from graph ${GRAPH_CD} to ${FILE_PATH}";
}

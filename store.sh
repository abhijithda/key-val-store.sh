#!/bin/bash

# set -x
STORE_PATH=${STORE_PATH:-/tmp}
readonly STORE_FILE=${STORE_PATH}/store

##### OPERATIONS
readonly OPERATION_INIT_STORE="INIT_STORE"
readonly OPERATION_DESTORY_STORE="DESTORY_STORE"
readonly OPERATION_GET="GET"
readonly OPERATION_PUT="PUT"
readonly OPERATION_DELETE="DELETE"

usage() {
    cat <<EOF
Usage:
1. $(basename $0) -h
2. $(basename $0) -I
2. $(basename $0) -C
3. $(basename $0) -G -k <key>
4. $(basename $0) -P -k <key> -v <value>
5. $(basename $0) -D -k <key>

where,
    h   Display this help usage.
    I   Initialize store.
    C   Clear / destory store.
    G   Get key value from store.
    P   Put key and its value into store. Any existing value of key would be overwritten.
    D   Delete key and its value from store.
    k   Key name in store.
    v   Value of they key.
EOF
}

init_store() {
    touch ${STORE_FILE}
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to initialize store."
        exit 1
    fi
    chmod a+rwx ${STORE_FILE}
}

destory_store() {
    rm -f ${STORE_FILE}
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to clear store and its contents."
        exit 1
    fi
}

# del_key_value_from_store()
#   Deletes specified key and its value from store.
del_key_value_from_store() {
    key=${1:?}
    sed -i /^${key}/d ${STORE_FILE}
}

# get_key_value_from_store()
#   Gets specified key's value from store.
get_key_value_from_store() {
    key=${1:?}
    echo $(grep -P ${key}'=' ${STORE_FILE} | cut -d "=" -f 2)
}

# put_key_value_to_store()
#   Saves key and value into store.
#   If key already exists in store, it'll be overwritten with new value.
put_key_value_to_store() {
    key=${1:?}
    value=${2:?}
    # Delete
    sed -i /^${key}/d ${STORE_FILE}
    cat >>${STORE_FILE} <<EOF
${key}=${value}
EOF
}

prepare_key() {
    name=${1:?}
    key=${2:?}
    echo "${name}_${key}"
}

#################### Commonly used functions ####################

get_auth_token() {
    name=${1:?}
    key="AUTH_TOKEN"
    named_key=$(prepare_key ${name} ${key})
    echo $(get_key_value_from_store ${named_key})
}

save_auth_token() {
    name=${1:?}
    value=${2:?}

    key="AUTH_TOKEN"
    named_key=$(prepare_key ${name} ${key})
    put_key_value_to_store ${named_key} ${value}
}

get_cookie_file_path() {
    name=${1:?}
    key="COOKIE_FILE"
    named_key=$(prepare_key ${name} ${key})
    echo $(get_key_value_from_store ${named_key})
}

save_cookie_file_path() {
    name=${1:?}
    value=${2:?}

    key="COOKIE_FILE"
    named_key=$(prepare_key ${name} ${key})
    put_key_value_to_store ${named_key} ${value}
}

##### main #####

operation=""

while getopts 'hCDGIPk:v:' OPTION; do
    case "$OPTION" in
    h)
        usage
        exit 0
        ;;
    C)
        operation=${OPERATION_DESTORY_STORE}
        ;;
    I)
        operation=${OPERATION_INIT_STORE}
        ;;
    D)
        operation=${OPERATION_DELETE}
        ;;
    G)
        operation=${OPERATION_GET}
        ;;
    P)
        operation=${OPERATION_PUT}
        ;;
    k)
        key=${OPTARG}
        ;;
    v)
        val=${OPTARG}
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [ ${operation} == ${OPERATION_INIT_STORE} ]; then
    $(init_store)
elif [ ${operation} == ${OPERATION_DESTORY_STORE} ]; then
    $(destory_store)
elif [ ${operation} == ${OPERATION_GET} ]; then
    echo $(get_key_value_from_store $key $val)
elif [ ${operation} == ${OPERATION_PUT} ]; then
    $(put_key_value_to_store $key $val)
elif [ ${operation} == ${OPERATION_DELETE} ]; then
    $(del_key_value_from_store $key)
fi



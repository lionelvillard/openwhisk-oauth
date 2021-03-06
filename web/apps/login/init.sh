#!/usr/bin/env bash

#wsk api-experimental delete /objectstore /getAuthToken
#GET_TOKEN_ENDPOINT=`wsk api-experimental create /objectstore /getAuthToken get objectstore/getAuthToken | grep https`

#wsk api-experimental delete /objectstore /createObjectAsReq
#UPLOAD_ENDPOINT=`wsk api-experimental create /objectstore /createObjectAsReq post objectstore-${CONTAINER}/createObjectAsReq | grep https`

. ../../../conf/config.sh
. ~/.wskprops

# take the page name from the name of the current directory
PAGE=${PWD##*/}

# holy cow, we need to replace "&" with "\\&", so that awk doesn't treat & as "replace with matching text"
PROVIDERS="`cat ../../../conf/providers-client.json | tr -d '\n' | sed 's/&/\\\\\\&/g'`"
echo -n "."

if [ -f ../../../conf/endpoints.sh ]; then
    . ../../../conf/endpoints.sh
fi

if [ -z "${LOGIN_ENDPOINT}" ]; then
    WSK_NAMESPACE=`node -e '{C=require(process.argv[1]); console.log(C.OrganizationFields.Name + "_" + C.SpaceFields.Name) }' ~/.cf/config.json`
    LOGIN_ENDPOINT="https://openwhisk.ng.bluemix.net/api/v1/experimental/web/${WSK_NAMESPACE}/oauth/web-login.http"
    echo -n "."
fi

if [ ! -d build ]; then
    mkdir build 
fi

# cheapskate templating
sed -e "s#{PROVIDERS}#${PROVIDERS}#g" \
    -e "s#{LOGIN_ENDPOINT}#${LOGIN_ENDPOINT}#g" \
    templates/${PAGE}.js > build/${PAGE}.js
echo -n "."

sed -e '/{CSS}/ {' -e 'r ../../common/common.css' -e 'd' -e '}' \
    -e '/{JS/ {' -e "r build/${PAGE}.js" -e 'd' -e '}' \
    -e "s/{COMPANY}/${1-MyCompany}/g" \
    -e "s/{PRODUCT}/${2-MyApplication}/g" \
    templates/${PAGE}.html > build/${PAGE}.html
echo "."

# deploy the assets to objectstore
npm install
(cd build && ../../../common/deploy.sh ${PAGE}.html)

echo "ok"

#!/bin/sh

#Copyright [2017] Christian Galsterer

#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

REG_PASS='admin:admin123'
HEADER='Accept: application/vnd.docker.distribution.manifest.v2+json'
SNAPSHOT_REG_URI='https://mbp.fritz.box:8083/v2'
RELEASE_REG_URI='https://mbp.fritz.box:8084/v2'
CURL_COMMAND="curl -s --insecure --user $REG_PASS -H \"$HEADER\""

# fetch all repositories from release registry
release_images=`eval $CURL_COMMAND ${RELEASE_REG_URI}/_catalog | jq -r '.repositories[]'`

# iterate over each repository to fetch tags and delete corresponding image in snapshot registry
for image in ${release_images[*]};
do
	# fetch all tags for a given image
    release_tags=`eval $CURL_COMMAND ${RELEASE_REG_URI}/$image/tags/list | jq -r '.tags[]'`
    echo "Available tags for image [$image]:"
    echo "$release_tags"
    echo 

    # iterate over all fetched tags, get digest for corresponding snapshot image and finally delete image:tag combination
    for release_tag in ${release_tags[*]};
    do
    	digest=`eval $CURL_COMMAND -i ${SNAPSHOT_REG_URI}/$image/manifests/$release_tag-SNAPSHOT | grep -Fi Docker-Content-Digest |  sed -e "s/^Docker-Content-Digest: //" | tr -d '\r'`
    	if [ "$digest" ]; then
    	    echo "Deleting tag [$release_tag] for image [$image] from registry [$SNAPSHOT_REG_URI]"
		    result=`eval $CURL_COMMAND -w "%{http_code}" -X DELETE ${SNAPSHOT_REG_URI}/$image/manifests/$digest`
		fi
    done
    echo
done
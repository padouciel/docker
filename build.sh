#!/bin/bash

set -e

# on attend en argument :
# - $1: path d'un répertoire conteant un Dockerfile et sous la forme tag_racine_tag_enfant
# - $2 : une version (tag)

run=0

while getopts "r:" option
do
	case "$option" in
	r)
		run=1
		run_args="$OPTARG"
		;;
	\?)
		exit 1
	esac
done

shift $((OPTIND-1))

if [[ -z "${1}" || ! -f "$(basename ${1})/Dockerfile" ]] 
then
	echo 'No argument or no "Dockerfile" is present in ' "${1}"
	cat <<EOF

Usage :
  ${0} [-r [run args]] directory version

Where :
  -r : run the container after a successfull build (docker run)
    * run args : argument(s) for the "docker run" command enclosed in "" (the "name==..." arg is automaticaly set whith the image name
  directory : a directoty thant contains a "Dockerfile" (docker context)
    if the directory name contains a "_", then the image name is parsed into "first part/last part", eg :
    "mydocker_testimage" => mydocker/testimage
  
  version : is the version use for tagging iamge (1 by default)
    "latest" tag is alsways set for the generated image

Examaple :
${0} -r "--rm" /mydocker/test 5

==> generate an image like "mydocker/test:5" and add a "latest" tag
	
EOF
	exit 1
fi

image="$(basename ${1})"

repo="${image%%_*}"

if [[ "${repo}" != "${image}" ]] 
then
	# Add slash
	repo="${repo}/"
	imagename=${image#*_}
fi

version=${2:-1}


docker build -t "${repo}${imagename}:latest" "${image}/" && docker tag -f "${repo}${imagename}:latest" "${repo}${imagename}:${version}"

# run the container with no
[[ "${?}" -eq 0 && "${run}" -eq 1 ]] && echo "running docker container ${imagename}" &&  docker run ${run_args} --name="${imagename}" "${repo}${imagename}:${version}"


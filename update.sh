#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


for version in "${versions[@]}"; do	
  if [ "${version}" == "1.8" ]; then
    fullGems="rubygems1.8"
    fullPackage="ruby1.8"
    fullVersion="$(curl -fsSL "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu/dists/trusty/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname=$fullPackage -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | sort -rV | head -n1 )"
  elif [ "${version}" == "1.9" ]; then
    fullGems=""
  	fullPackage="ruby1.9.1"
    fullVersion="$(curl -fsSL "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu/dists/trusty/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname=$fullPackage -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | sort -rV | head -n1 )"
  else
    fullGems=""
  	fullPackage="ruby${version}"
    fullVersion="$(curl -fsSL "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu/dists/trusty/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname=$fullPackage -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | sort -rV | head -n1 )"
	fi
	(
		set -x
		sed '
			s/%%RUBY_MAJOR%%/'"$version"'/g;
			s/%%RUBY_VERSION%%/'"$fullVersion"'/g;
			s!%%RUBY_PACKAGE%%!'"$fullPackage"'!g;
      s!%%RUBY_GEMS%%!'"$fullGems"'!g;
		' Dockerfile.template > "$version/Dockerfile"
	)
done


# docker-semantic-clean-registry

## Introduction
Unlike [Maven](https://maven.apache.org), Docker doesn't support the concept of "SNAPSHOT" versions which are very useful in combination with continuous integration.
One common approach with (private) registries, e.g. [Sonatype Nexus](https://www.sonatype.com) is, to setup two repositories, one containing the SNAPSHOT versions, one of containing the release versions.

Caveats of this approach are that the "SNAPSHOT" repository constantly grows consuming a lot of disk space (incl. backups) and that SNAPSHOTS get never cleaned up and are still available after a release is made.
In order to mimic the behaviour of Maven and Maven repositories to delete SNAPSHOTS after a release is made (sometimes after a short grace period) this shell script was created.

It assumes the following setup
* One "SNAPSHOT" repository for the "SNAPSHOT" Docker images
* One "RELEASE" repository for the release Docker images, i.e. containing everything else than the "SNAPSHOT" versions
* [Semantic Versioning](http://semver.org) using "SNAPSHOT" postfix for the tag version, e.g. 1.0.0-SNAPSHOT

## Supported Registries
As the scripts uses only [Docker Registry HTTP API V2](https://docs.docker.com/registry/spec/api/) features it should work with all registries supporting this protocol version.

It was tested with
* Sonatype Nexus 3.5.1-02

## Prerequisites
* [jq](https://stedolan.github.io/jq/) installed


## How The Script Works
For the given "RELEASE" repository all images are retrieved. For each image, all tags are retrieved. For each image:tag combination it is checked if a corresponding image:tag combination exists in the given "SNAPSHOT" repository, appending "-SNAPSHOT" to the version tag.
If the corresponding image:tag combination exits in the "SNAPSHOT" repository, the image:tag combination is deleted from the "SNAPSHOT" repository.


## Usage
In order to use the script please run the following command

```sh
remove_snapshots.sh -
```


## Releases

1.0.0 (2017-)

## License

```
   Copyright 2017 Christian Galsterer

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```


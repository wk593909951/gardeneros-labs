$ErrorActionPreference = 'Stop'
$containerName = 'gardeneros-exp0-20261109'
docker info --format '{{.ServerVersion}}' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Please start Docker Desktop with the Linux engine first.'
}
$owner = docker inspect --format '{{index .Config.Labels "local.owner"}}' $containerName
if ($LASTEXITCODE -ne 0 -or $owner -ne 'osexperiment-experiment0') {
    throw 'Dedicated GardenerOS container not found. No other container will be changed.'
}
docker start $containerName | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Failed to start the GardenerOS container.' }
docker exec -it --workdir /mnt $containerName bash
exit $LASTEXITCODE

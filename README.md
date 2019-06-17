# MPI Environment in Docker

## Deploy
```bash
docker stack deploy -c docker-compose.yml myapp
```

## Login into `master` container
```bash
docker exec -it (docker stack ps myapp | grep master | awk 'NR==1{print $1}') /bin/bash
# or
ssh -p 4000 -i ssh/id_rsa mpi@127.0.0.1
# run test
mpirun -hosts mpi_master,mpi_worker /home/mpi/test/test
```

## TODO
- [ ] Get all workers

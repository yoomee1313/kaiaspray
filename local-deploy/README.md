# Local-deploy

This tool is especially designed for development of kaia network. That's why this tool requires the kaia source code which has been compiled. Otherwise(monitoring tool), it will be deployed through docker. 

It deploys the private network. Given an option, you can also deploy the monitoring tool.

## Prerequisite
If you opt to deploy the monitoring tool, you should install the docker at your local computer.
* docker
* docker-compose

Otherwise, kaia repository should be downloaded at the designated paths.

## Get started

### Download the kaia repository at the designated paths
```
```

### Configuration
The configuration file is located at `local-deploy/properties.sh`. If not exists, copy from sample_properties.sh.
```shell
cp sample_properties.sh properties.sh
```

#### Setup Directories
It's mandatory field to set.
```
KAIACODE=$HOME/workdir/kaia
HOMEDIR=$HOME/workdir/kaiaspray/local-deploy
```

#### setup some options
You can setup custom network_id and number of nodes. If you need, you can increase the number of test accounts as well.
```
NETWORK_ID=949494 # put random NETWORK_ID
NUMOFCN=1
NUMOFPN=1
NUMOFEN=1
NUMOFTESTACCSPERNODE=1
```

#### remix option
Default value is true. If you don't want to use remix, you can set it to false.
```
REMIX=true # if this is true, set the cors field of the EN to use remix. If EN not available, CN will be used for remix.
```

#### homi - nodekey dir options
Default value is false. It means the homi will generate new keys. If you're already using existing nodekeys, locate the nodekeys under nodekey
```
HOMI_CNKEYS=false
HOMI_PNKEYS=false
HOMI_ENKEYS=false
```

### Setup & run & stop Kaia nodes
To setup kaia directories, run the next script.
```shell
./0_kaia_setup.sh
```
To copy kaia binaries, run the `./1_copy_binary.sh` script like below.
```shell
./1_copy_binary.sh # it copies the binaries to all nodes
./1_copy_binary.sh cn 1 # it copies the binary to the first cn node
./1_copy_binary.sh en 3 # it copies the binary to the third en node
```
To delete and initialize the data directory, run the `2_initialize_nodes.sh` script like below.
```shell
./2_initialize_nodes.sh # it deletes and initializes the all nodes
./2_initialize_nodes.sh cn 1 # it deletes and initializes the first cn node
./2_initialize_nodes.sh en 3 # it deletes and initializes the third en node
````
To start the kaia nodes, run the `3_ccstart.sh` script like below.
```shell
./3_ccstart.sh # it starts all nodes
./3_ccstart.sh cn 1 # it starts the first cn node
./3_ccstart.sh en 3 # it starts the third en node
```

To attach the kaia node, run the `5_ccattach.sh` script like below.
```shell
./5_ccattach.sh cn 1 # it attaches the first cn node
./5_ccattach.sh en 3 # it attaches the third en node
```

To tail the log, run the `6_logs.sh` script like below.
```shell
./6_logs.sh cn 1 # it tails the log of the first cn node
./6_logs.sh en 3 # it tails the log of the third en node
```

To stop the kaia nodes, run the `4_ccstop.sh` script like below.
```shell
./4_ccstop.sh # it stops all nodes
./4_ccstop.sh cn 1 # it stops the first cn node
./4_ccstop.sh en 3 # it stops the third en node 
```

### Start & stop monitoring tool
To start the monitoring tool, run the next script.
```shell
./7_monitoring.sh start
```

To stop the monitoring tool, run the next script.
```shell
./7_monitoring.sh stop
```
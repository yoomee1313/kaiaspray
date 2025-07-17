# setup directories
KAIACODE=$HOME/workdir/kaia
HOMEDIR=$HOME/workdir/kaiaspray/local-deploy

# setup some options
NETWORK_ID=949494 # put random NETWORK_ID
NUMOFCN=1
NUMOFPN=1
NUMOFEN=1
NUMOFTESTACCSPERNODE=1

# remix option
REMIX=true # if this is true, set the cors field of the EN to use remix. If EN not available, CN will be used for remix.

# homi - nodekey dir options. If you already using existing nodekeys, locate the nodekeys under nodekey
HOMI_CNKEYS=false
HOMI_PNKEYS=false
HOMI_ENKEYS=false

# homi - compatibility options
# HOMI_ISTANBUL_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_LONDON_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_MAGMA_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_SHANGHAI_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_PRAGUE_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_KORE_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_KAIA_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_KIP103_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_KIP160_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_RANDAO_COMPATIBLE_BLOCKNUMBER=999999999
# HOMI_CUNCUN_COMPATIBLE_BLOCKNUMBER=999999999

# homi - some useful options
HOMI_PATCH_ADDRESSBOOK=false # if you set true, the addressbook admin will be the cn1 nodekey.
HOMI_REGISTRY=false # if you set true, the bls-registry mock will be registered automatically.
HOMI_NUMOF_INITIAL_CN_NUM=0 # amount NUMOFCN, HOMI_NUMOF_INITIAL_CN_NUM will be addvalidate later.
HOMI_BAOBAB_TEST=false # if you set true, the homi will be setup for baobab testnet.
# HOMI_PATCH_ADDRESSBOOK_ADDR=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
# HOMI_FUNDING_ADDR=0xaB36568200B0f2B262107e4E74C68d6E8729Da39

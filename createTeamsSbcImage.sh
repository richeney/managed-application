#!/bin/bash

## This script will upload the SBC image to Azure
## Will attempt to find the extracted .vhd image,
## or can be specified as the first parameter

# Functions for errors and coloured outputs

error()
{
  if [ -n "$@" ]
  then
    tput setaf 1
    echo "ERROR: $@" >&2
    tput sgr0
  fi

  exit 1
}

yellow() { tput setaf 3; cat - ; tput sgr0; return; }
cyan()   { tput setaf 6; cat - ; tput sgr0; return; }

# Set default values

rg=teamsSbcImage
loc=westeurope

# If the user has not specified the .vhd then search obvious directories

if [ -n "$1" ]
then
  vhd=$1
  echo "vhd" | grep -q ".vhd$" || error "Specified image file does not have .vhd suffix as expected"
  [ ! -f "$vhd" ] && error "Specified image file, $vhd, cannot be found"
else
  vhd=$(ls /mnt/c/Users/${LOGNAME}/Downloads/sbc-*-azure/sbc-*.vhd $HOME/sbc-*-azure/sbc-*.vhd /tmp/sbc-*-azure/sbc-*.vhd 2>/dev/null)
  [ -z "$vhd" ] && error "No image files specified or found"
  [ $(echo "$vhd" | wc -w) -gt 1 ] && error 'More than one image file found: $vhd'
fi

echo "Using image file $vhd" | cyan

# Grab the Azure subscription ID
subId=$(az account show --output tsv --query id)
[[ -z "$subId" ]] && error "Not logged into Azure as expected."

# Create the resource group for the image

echo "az group create --name $rg --location $loc" | yellow
/usr/bin/az group create --name "$rg" --location $loc --output jsonc
[[ $? -ne 0 ]] && error "Failed to create resource group $rg"

# Create the storage account

saName=$(echo $rg | tr '[:upper:]' '[:lower:]')$(/usr/bin/md5sum <<< $subId | cut -c1-10)
echo "az storage account create --name $saName --kind BlobStorage --access-tier hot --sku Standard_LRS --resource-group $rg --location $loc" | yellow
/usr/bin/az storage account create --name $saName --kind StorageV2 --access-tier hot --sku Standard_LRS --resource-group $rg --location $loc --output jsonc
[[ $? -ne 0 ]] && error "Failed to create storage account $saName"

# Grab the storage account key

saKey=$(/usr/bin/az storage account keys list --account-name $saName --resource-group $rg --query "[1].value" --output tsv)
[[ $? -ne 0 ]] && error "Do not have sufficient privileges to read the storage account access key"

# Create the containers

for container in images disks
do
  echo "az storage container create --name $container --account-name $saName --account-key $saKey" | yellow
  /usr/bin/az storage container create --name $container --account-name $saName --account-key $saKey --output jsonc
  [[ $? -ne 0 ]] && error "Failed to create the container $container"
done

[[ ! -f $vhd ]] && error "$vhd not found"

# Upload the image
vhdBlob="https://$saName.blob.core.windows.net/images/$(basename $vhd)"
echo "azcopy --source $vhd --destination $vhdBlob --dest-key $saKey --blob-type page" | yellow
/usr/bin/azcopy --source $vhd --destination $vhdBlob --dest-key $saKey --blob-type page

sleep 10

# Create image from the VHD image
echo "az image create --resource-group $rg --name ${vhdBlob##*/} --soux" | yellowrce $vhdBlob --os-type linu
/usr/bin/az image create --resource-group $rg --name ${vhdBlob##*/} --source $vhdBlob --os-type linux
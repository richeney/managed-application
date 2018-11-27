# Mediant Session Border Controller for Microsoft Teams as a Managed Application

## Introduction

This lab is designed to demonstrate how to create a [managed application](https://docs.microsoft.com/en-us/azure/managed-applications/overview). Managed applications enable services to be deployed into a customer's subscription via a custom service catalog and user interface screens, as per the example below.  The managed application contains a UI definition that determines the format of these screens.

INSERT UI SCREEN

The resulting resources will be split into two resource groups.  The simply named resource group will contain a single resource representing the managed application and this will be present as a single line in the billing statement for the customer. Therefore the customer sees a price that reflects the business value of the managed application rather than a simple aggregation of the underlying Azure service costs.

SHOW RESOURCE GROUP WITH MANAGED APPLICATION LISTED

The second resource group contains the underlying resources that form the managed application.  The actual resources are described using declarative ARM templates.

SHOW SECOND RESOURCE GROUP WITH THE UNDERLYING RESOURCES

The customer will have limited visibility into this resource group as they are not managing these resources. The managed application definition will include an RBAC assignment for the required roles at this resource group scope level.  The managed application definition includes lists of specific Azure Active Directory GUIDs for specific users or groups, and the GUID representing the required role definition.  This is often a single group assigned with Contributor access to the resource group.

SCREEN SHOW OF THE RBAC ASSIGNMENT

For the lab we wil be using the session border controller (SBC) from Mediant.  The SBC enables a wide number of voice communication types for Microsoft Teams.  The reason it has been chosen for this lab is that it is available as an image in the Azure Marketplace, but it has also been made available as a vhd download from Mediant. Therefore the guide can include the steps for using inbuilt images as well as custom images uploaded into the system.

## Requirements

You will need an Azure subscription.

The repository includes common linux commands and example Bash scripting. Windows 10 users are recommended to use the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

You will need the [Azure CLI (az)](https://aka.ms/GetTheAzureCLI) and [azcopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux#download-and-install-azcopy).

For the record, this guide has been created using:

* LTRT-10825 Mediant Virtual Edition SBC for Microsoft Azure Installation Manual Ver 7.2.pdf
* sbc-F7.20A.204.015-azure.zip
* Windows 10 Enterprise 1809
* Windows Subsystem for Linux running Ubuntu 18.04 (Bionic Beaver)
* azure-cli 2.0.49
* azcopy 7.3.0-netcore

## Mediant Documentation and VE Image

The <http://www.audiocodes.com> site is the source of:

* [Installation documentation](https://www.audiocodes.com/library/technical-documents?query=azure&productFamilyGroup=1637&productGroup=1638)
* [Mediant VE images](https://services.audiocodes.com/app/answers/list/st/5/kw/azure/p/148/page/1)
  * _NB. The Azure image is not in the list at the time of writing._
* [Mediant VE for Azure images](https://audiocodes.sharefile.com/share/view/sbaf874077d143bfa/fo4282bf-0f2b-4341-bee3-836b1d74cdca)

Refer to the installation instructions in the pdf file it you want to see how the SBC is installed manually.

If you are following the custom image steps then download and unzip the image.  To check the md5sum of the downloaded image:

```bash

/mnt/c/Users/richeney/Downloads/sbc-F7.20A.204.015-azure $ ls -l
total 10486788
-rwxrwxrwx 1 richeney richeney 10738467328 Nov  8 14:19 sbc-F7.20A.204.015.vhd
-rwxrwxrwx 1 richeney richeney          57 Nov  8 14:19 sbc-F7.20A.204.015.vhd.md5

/mnt/c/Users/richeney/Downloads/sbc-F7.20A.204.015-azure $ md5sum --check sbc-F7.20A.204.015.vhd.md5
sbc-F7.20A.204.015.vhd: OK

```

## Automate the image upload

This lab does not cover the creation of images.  There is plenty of documentation around regarding the creation of custom image vhd files, from sysprepping [Windows](https://docs.microsoft.com/en-gb/azure/virtual-machines/windows/capture-image-resource) and [Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu) machines or using Packer as the basis of scripted image creation for  [Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer) and [Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer).

Section 3 in the Mediant documentation refers to the creation of the Azure storage account and the image upload. I have written a [Linux script](https://github.com/richeney/managed-application/blob/master/createTeamsSbcImage.sh), that will do all of this for you if you pass the image as the argument.  (If you don't specify an argument then it will try to find the Mediant SBC image.)

```bash
curl --output createTeamsSbcImage.sh https://raw.githubusercontent.com/richeney/managed-application/master/createTeamsSbcImage.sh && chmod 744 createTeamsSbcImage.sh
```

Feel free to examine the script to see what it is doing.  The usage for the script is `./createTeamsSbcImage.sh /path/to/sbc-*.vhd`.

The upload will take

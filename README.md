# <<WORK IN PROGRESS!!>> - Mediant Session Border Controller for Microsoft Teams

Create a session border controller (SBC) for Microsoft Teams voice.

## Introduction

This repository serves multiple purposes:

1. Information for manually installing the Mediant Virtual Edition SBC for Microsoft Azure
1. Scripted automation for the image creation within Azure Storage
1. Idempotent deployment of the Azure resources using ARM templates
1. Steps to configure the solution as a Managed Application for Service Integrators (SIs) and Managed Service Providers (MSPs)

## Requirements

You will need an Azure subscription.

The repository includes common linux commands and example Bash scripting. Windows 10 users are recommended to use the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

You will need the [Azure CLI (az)](https://aka.ms/GetTheAzureCLI
) and [azcopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux#download-and-install-azcopy).

For the record, this guide has been created using:

* LTRT-10825 Mediant Virtual Edition SBC for Microsoft Azure Installation Manual Ver 7.2.pdf
* sbc-F7.20A.204.015-azure.zip
* Windows 10 Enterprise 1809
* Windows Subsystem for Linux running Ubuntu 18.04 (Bionic Beaver)
* azure-cli 2.0.49
* azcopy 7.3.0-netcore

## Mediant Documentation and VE Image

The <http://www.audiocodes.com> site is the source of the

* [Installation documentation](https://www.audiocodes.com/library/technical-documents?query=azure&productFamilyGroup=1637&productGroup=1638)
* [Mediant VE images](https://services.audiocodes.com/app/answers/list/st/5/kw/azure/p/148/page/1)
  * _NB. The Azure image is not in the list at the time of writing._
* [Mediant VE for Azure images](https://audiocodes.sharefile.com/share/view/sbaf874077d143bfa/fo4282bf-0f2b-4341-bee3-836b1d74cdca)

Download the documentation. Download and unzip the image.

Check the md5sum of the downloaded image:

```bash

/mnt/c/Users/richeney/Downloads/sbc-F7.20A.204.015-azure $ ls -l
total 10486788
-rwxrwxrwx 1 richeney richeney 10738467328 Nov  8 14:19 sbc-F7.20A.204.015.vhd
-rwxrwxrwx 1 richeney richeney          57 Nov  8 14:19 sbc-F7.20A.204.015.vhd.md5

/mnt/c/Users/richeney/Downloads/sbc-F7.20A.204.015-azure $ md5sum --check sbc-F7.20A.204.015.vhd.md5
sbc-F7.20A.204.015.vhd: OK

```

Follow the installation instructions in the pdf file it you want to install the SBC manually.

## Automate the image creation

Section 3 of the installation document covers the creation of the image, plus a resource group and virtual network for the SBC to deployed into.

The

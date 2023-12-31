# AdministrationR-seauAutomatisation

## Directories

- __Modules__ : put your modules in (like your classes). Core is for modules with abstract classes
- __Resources__ : put your resources (json files for configuration and csv files for things like a list of users)
- __src__ : put your files with actual functionality you want to implement. You can use your modules in there.
- __Tests__ : if you want to implement some tests


## Exec

Don't touch init-project.ps1. It is the entry point for the project.

If you want to execute a file, go to the file and press __CRT+MAJ+B__. There is some tasks configured. Choose the tasks "Ask Current Script".  
Also, you can just do __CRT+MAJ+B__ and select "Launch A Script". Then, you can give the path in the src directory. (don't touch ${workspaceFolder}/src, just change after that the path).


## Create a Class

You create a file in the Modules directory (in one of the existing directories in it or in a new). The extension for a module is __.psm1__.    
You create your class.  

And, to import your module, you need to use :
```
using Module <path_from_root_dir_to_file>
```

## Modules files

- __GenerateConfig.psm1__ : file to put function permitting the generation of a config file. Actually, there is 1 function to generate a forest config file (with 1 domain controller only)
- __ADDS.psm1, ADLDS.psm1, DC.psm1__ : files with class representing exactly what their names imply. Just the beginning, can be strenghten later on.
- __Service.psm1__ : file with an abstract class for all service-oriented classes we create to inherit
- __NetworkAdapter.psm1__ : file with a class representing a network adapter

## SRC files 

- __generate-ad.ps1 and generate-config.ps1__ : you need to launch first __generate-config.ps1__ to create a json with the configuration for your forest (and 1 domain controller). Then, you can execute __generate-ad.ps1__ and when asked, give the name of the json file with the config you generated
- __promote-dc.ps1__ : you also need to have a json config file for a forest generated and give his name when asked. This one is for promoting a domain controller in an existing forest / domain

## Global Variables
There is some variable usable in all the project (even module). You call them like that : __$global:variable_name__

Actually, there is :
- __$global:RootPath__ : the root path of the project
- __$global:restart__ : use to indicate if you want to restart the device at the end of the script's execution
- __$global:LogFilePath__ : the path to the log file of the script which is executed

## Write-HostAndLog
Function permitting to write something in the console and in the file log of the executed script. You can use it in all your script, even module, because it is import directly in the entry point of the project.


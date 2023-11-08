# AdministrationR-seauAutomatisation

## Directories

- __Modules__ : put your modules in (like your classes). Core is for modules with abstract classes
- __Resources__ : put your resources (json files for configuration and csv files for things like a list of users)
- __src__ : put your files with actual functionality you want to implement. You can use your modules in there.
- __Tests__ : if you want to implement some tests

Don't touch Modules/psd1. It is generated automatically.


## Exec

Don't touch init-project.ps1. It is the entry point for the project.

If you want to execute a file, go to the file and press __CRT+MAJ+B__. There is some tasks configured. Choose the tasks "Ask Current Script".  
Also, you can just do __CRT+MAJ+B__ and select "Launch A Script". Then, you can give the path in the src directory. (don't touch ${workspaceFolder}/src, just change after that the path).


## Create a Class

You create a file in the Modules directory (in one of the existing directories in it or in a new). The extension for a module is __.psm1__.    
You create your class.  
In the __"Resources/Config/config.json"__, you need to indicate your class in __'ModulePaths'__ :
- In __Path__, you give the path from the root to the directory of you module with the class.
- In __Classes__, you add an object with the name of the file (without the extension).

If you add a class in an existing repository, you can just add an object in the Path corresponding.

And, to import your project, you need to use :
```
using Module <path_from_root_dir_to_file>
```

## Global Variables
There is some variable usable in all the project (even module). You call them like that : __$global:variable_name__

Actually, there is :
- __$global:RootPath__ : the root path of the project
- __$global:restart__ : use to indicate if you want to restart the device at the end of the script's execution
- __$global:LogFilePath__ : the path to the log file of the script which is executed

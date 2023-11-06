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

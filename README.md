# ASM Samples
The repository consists of 9 assembler programs for DOS. They can be assembled using FASM assembler. Running "fasm program_name.ASM" outputs a program_name.COM executable. Code comments are in Polish as this is an old project.

## Overview
There are 6 different types of programs in the repository:

1. **calculator.ASM** - a 32b calculator;  
2. **psp.ASM** - prints a PSP (Program Segment Prefix);  
3. sorting programs:
  1. **sort3.ASM** - ASCII characters sorting (bubble sort algorithm);  
  2. **sort4.ASM** - ASCII characters sorting (insertion sort algorithm);  
  3. **sort5.ASM** - 16b, 32b numbers and ASCII as numbers sorting (bubble sort algorithm);  
4. **copy.ASM** - copies content of one file to another;  
5. directory listing:  
  1. **directory.ASM** - lists files in a given directory, only basic regex supported;  
  2. **directory2.ASM** - like above, supported file attributes:  
    - ``-aATTRIBUTES`` where ATTRIBUTES is a combination of the following parameters:  
        &nbsp;&nbsp;&nbsp;&nbsp; ``D`` - directory,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``H`` - hidden,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``R`` - read only,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``S`` - system,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``D`` - archive;  
    - ``-fDISPLAY_OPTIONS`` where DISPLAY_OPTIONS is a combination of the following parameters:  
        &nbsp;&nbsp;&nbsp;&nbsp; ``N`` - name,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``D`` - last modification date,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``C`` - last modification time,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``R`` - size,  
        &nbsp;&nbsp;&nbsp;&nbsp; ``A`` - type;  
    - ``-p`` - waits for key press after printing whole terminal screen;  
    - ``-s`` - recursive listing;  
6. **clock.ASM** - displays current time, updated every second, closable by pressing "e" key.  

## License
Copyright 2015 Damian Terlecki

Unless explicitly stated otherwise all files in this repository are licensed under the Apache License, Version 2.0 (the "License");
you may not use this files except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

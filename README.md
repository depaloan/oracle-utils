- *listener.hunter.py*. Estrae l'elenco di host univoci dal log di un listener
- *asm-du.sh*. Visualizza informazioni sui diskgroup ASM e l'occupazione di ciascun database
- *datapump-command-generator.py*. Genera comandi di import/export Datapump

## db-patching-command-generator.py
Generate the required commands to move a DB to a new OH in order to apply BP/PSU. Instances are bounced in transactional mode, with services relocated to the other node. Supports both 11g and 12c command syntax.

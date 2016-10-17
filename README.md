# niosII
A final project for the course of Microprocessors II - 2016
This project is based on Altera's DE2 Board - powered by NIOS II processor.  
Many thanks for our great **Prof Joao Paulo L Carvalho** :neckbeard:
## Authors  
 * Dalton Lima @daltonbr    
 * Giovanna Cazelato @giovannaC  
 * Lucas Pinheiro @lucaspin 
 
## This final project  
This project consists of a console application that accept user commands, using the DE2 Altera’s board and a host computer.
This console must be implemented through **UART**, using the terminal Window from Altera Monitor.
Upon starting the program, the terminal should print:  

`“Enter the command: `  

And wait for user input. The commands will have at maximum two integers, as showed in the table below:

| Command | Action |
|---------|--------|
| 00 xx | Blink the xx-nth – red led in intervals of 500 ms |
|01 xx  | Cancel the blinking of the xx-nth red led |
|10	    | Read the content of first 8 bits of the switch keys (SW7-0) and calculate the respective triangular number. The result must be show in the 7-segment display in decimal |
|20	| Show the phrase “Hello 2016” in the 7-segment display and rotate them to the right in intervals of 200ms. If KEY1 was pressed them the direction of the rotation must be inverted. If KEY2 was pressed, them the rotation must be paused. Pressing KEY2 again must resume the rotation |
|21	| Stop rotation of the phrase |

Some things are left unsaid in this description. Problems must be solved by the team and the solution must be explained in the final report.
As a bonus, the team must develop additional commands.

## TODO
- [X] method to calculate a triangular number (triangular.s)  
- [ ] method to convert a given 16bit unsigned integer to its correspond in 7-display-segment     
- [ ] decide which option is best: convert all digits at once OR one by one  
- [ ] method or way to move and rotate the HexDisplay  
- [ ] discuss a way to read and decide which command was assigned  

For more project like this one, see our another repo https://github.com/daltonbr/micro2

/*
This program sounds the bell when driver is on seat AND haven't closed the doors. 
Use the general framework and the function shells, replace the code inside  the control_action() function with your own code.

Note: This code is designed to run in an infinite loop to mimic a real control system. 
If you prefer to read the inputs from a file, modify the code appropriately to terminate the loop when all the inputs have been processed.

run this file as : gcc filename.c -o executableName

*/


#include <stdio.h> //This is useful to do i/o to test the code 

unsigned int driver_on_seat;
unsigned int doors_closed;
unsigned int bell;
unsigned int key_in_car;
unsigned int door_lock;
unsigned int driver_seat_belt_fastened;
unsigned int engine_running;
unsigned int door_lock_lever;
unsigned int car_moving;
unsigned int brake_pedal;
unsigned int brake;

*/
void read_inputs_from_ip_if(){

	//place your input code here
	//to read the current state of the available sensors
	printf("The DOS value is %d", argv[0]);
	printf("The DSBF value is %d", argv[1]);
	printf("The ER value is %d", argv[2]);
	printf("The DC value is %d", argv[3]);
	printf("The KIC value is %d", argv[4]);
	printf("The DLC value is %d", argv[5]);
	printf("The BP value is %d", argv[6]);
	printf("The CM value is %d", argv[7]);
}

void write_output_to_op_if(){

	//place your output code here
      //to display/print the state of the 3 actuators (DLA/BELL/BA)

}


//The code segment which implements the decision logic
void control_action(){

	/*
	The code given here sounds the bell when driver is on seat 
	AND hasn't closed the doors. (Requirement-2)
 	Replace this code segment with your own code.
	*/

	if (driver_on_seat && !doors_closed)
		bell = 1;
	else if (!driver_seat_belt_fastened && engine_running)
		bell = 1;
	else
		bell = 0;

	if(door_lock_lever && !door_lock){
	if (key_in_car && !driver_on_seat)
		door_lock = 0;
	else
		door_lock = 1;
	}

	if(car_moving && brake_pedal)
		brake = 1;
	//else if (car_moving && !brake_pedal)
		//brake = 0;
	else
		brake = 0;
}

/* ---     You should not have to modify anything below this line ---------*/

int main(int argc, char *argv[])
{
	
	/*The main control loop which keeps the system alive and responsive for ever, 
	until the system is powered off */
	for (; ; )
	{
		read_inputs_from_ip_if();
		control_action();
		write_output_to_op_if();

	}
	
	return 0;
}

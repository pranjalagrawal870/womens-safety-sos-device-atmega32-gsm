# womens-safety-sos-device-atmega32-gsm
A real-time embedded system that sends an SOS SMS alert at the press of a button using an ATmega32 microcontroller and SIM800L GSM module. Designed for personal safety with fast, interrupt-driven response.
*Hardware Components
ATmega32
SIM800L GSM module
16 MHz crystal oscillator
Capacitors (0.22µF + bulk)
Buck converter (~4V for GSM)
Push button
Buzzer
Breadboard & jumper wires
*Working
Button press triggers interrupt (INT0)
ISR sends AT commands via UART
GSM module sends SOS SMS
Buzzer indicates activation

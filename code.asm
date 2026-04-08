; ATmega32 SOS SMS Device
; Button -> PD2 (INT0)
; Buzzer -> PD3
; GSM UART -> PD0 (RX), PD1 (TX)

.include "m32def.inc"

.def temp = r16

.org 0x00
    rjmp RESET
.org INT0addr
    rjmp BUTTON_ISR

; ---------------- RESET ----------------
RESET:
    ; Initialize stack
    ldi temp, HIGH(RAMEND)
    out SPH, temp
    ldi temp, LOW(RAMEND)
    out SPL, temp

    ; Buzzer -> PD3 as output
    sbi DDRD, PD3
    cbi PORTD, PD3          ; buzzer OFF

    ; Button -> PD2 as input (with pull-up)
    cbi DDRD, PD2
    sbi PORTD, PD2

    ; UART Init (9600 baud @ 16 MHz)
    ldi temp, 103
    out UBRRL, temp
    clr temp
    out UBRRH, temp
    ldi temp, (1<<TXEN)
    out UCSRB, temp
    ldi temp, (1<<URSEL)|(1<<UCSZ1)|(1<<UCSZ0)
    out UCSRC, temp

    ; Enable INT0 (falling edge trigger)
    ldi temp, (1<<ISC01)
    out MCUCR, temp
    ldi temp, (1<<INT0)
    out GICR, temp

    sei                       ; enable global interrupts

MAIN: rjmp MAIN

; ---------------- INTERRUPT ----------------
BUTTON_ISR:
    sbi PORTD, PD3            ; buzzer ON
    rcall SEND_SOS             ; send AT commands
    cbi PORTD, PD3            ; buzzer OFF
    reti

; ---------------- SEND SOS ----------------
SEND_SOS:
    ; AT+CMGF=1  (set text mode)
    ldi ZL, low(MSG1*2)
    ldi ZH, high(MSG1*2)
    rcall SEND_STRING
    rcall DELAY

    ; AT+CMGS="phone"
    ldi ZL, low(MSG2*2)
    ldi ZH, high(MSG2*2)
    rcall SEND_STRING
    rcall DELAY

    ; Message body: SOS
    ldi ZL, low(MSG3*2)
    ldi ZH, high(MSG3*2)
    rcall SEND_STRING
    rcall DELAY

    ; Ctrl+Z (end of SMS)
    ldi temp, 26              ; ASCII SUB
    rcall UART_TX
    rcall DELAY
    ret

; ---------------- SUBROUTINES ----------------
SEND_STRING:
L1: lpm temp, Z+
    cpi temp, 0
    breq L2
    rcall UART_TX
    rjmp L1
L2: ret

UART_TX:
    sbis UCSRA, UDRE
    rjmp UART_TX
    out UDR, temp
    ret

DELAY:
    ldi temp, 255
DL1: ldi r17, 255
DL2: dec r17
    brne DL2
    dec temp
    brne DL1
    ret

; ---------------- STRINGS ----------------
MSG1: .db "AT+CMGF=1",13,0
MSG2: .db "AT+CMGS=""+919424928547""",13,0 ;replace with your number
MSG3: .db "SOS! HELP ME",0


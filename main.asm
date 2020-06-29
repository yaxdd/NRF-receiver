    #include <p18f4550.inc>
    #include "fuses.inc"
    #include "SPI.inc"
    #include "NRF24L01.inc"
    #include "TIMER0.inc"
    #include "PWM.inc"
variables UDATA_ACS 0x00
W_TEMP	    res 1
STATUS_TEMP res 1
BSR_TEMP    res 1
TXDATA	  res 1
RXDATA	  res 1
TMR0_COUNT  res 2
DATA_TO_SEND     res 1
COMMAND	  res 1
BUFFER_DATA res 5

RES_VECT  CODE    0x0000	;declaramos el vector de reset
    GOTO    START

ISRHV     CODE    0x0008
    GOTO    HIGH_ISR
ISRLV     CODE    0x0018
    GOTO    LOW_ISR

ISRH      CODE
HIGH_ISR
			      ;guardamos el contexto al entrar  a la interrupcion
    movwf W_TEMP
    movff STATUS, STATUS_TEMP
    movff BSR, BSR_TEMP
    btfss INTCON,TMR0IF	      ;reviso la bandera de interrupcion del timer0
    bra EXIT_ISR		      ; si no se cumplió, salgo de la interrupcion
    BCF INTCON,TMR0IF	      ; Limpiamos la bandera
    bcf T0CON,TMR0ON	      ;desactivo el timer
    EXIT_ISR
			      ;Recuperamos el contexto
    movf W_TEMP,W
    movff STATUS_TEMP,STATUS
    movff BSR_TEMP,BSR
    retfie
ISRL      CODE
LOW_ISR
    retfie



MAIN_PROG CODE			;generamos la seccion de codigo de nuestro programa
; 1.- Configurar Timer 0
; 2.- Configurar SPI
; 3.- Configurar NRF como receptor
; 4.- Esperar bytes del transmisor
; 5.- Convertir 10 bits a señal pwm
; 6.- Repetir desde el paso 4
START
    ;seleccionamos el oscilador interno y lo configuramos a 8 mhz
    movlw 0x72
    movwf OSCCON
    clrf    TRISC
    clrf    PORTC
    ;configuro las interrupciones
    clrf PIR1	    ;limpiamos bandera de interrupciones
    clrf INTCON	    ;limpiamos el registro
    clrf PIE1	    ;desactivamos todas las interrupciones de perifericos
    bsf INTCON,GIE	    ;activamos las interrupciones globales
    bsf INTCON,TMR0IE  ; y la interrupcion del timer0
    call PWM_INIT
    call TMR0_INIT
    call SPI_INIT
    call NRF_INIT_RX
    loop
    call NRF_DATA_READY ; esperamos a que el NRF reciba algun dato
    call NRF_READ_BUFFER
    ; procesar bytes recibidos en BUFFER_DATA y BUFFER_DATA+1
    call CONFIGURE_PWM
    call DELAY_100MS
    goto loop
    END


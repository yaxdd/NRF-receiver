CONFIGURE_PWM
    movlw   0Xff
    movwf   PR2	    ;Se introduce 0xFF al registro PR2 (Dato calculado previamente)
    movf    BUFFER_DATA+1
    movwf   CCPR1L	    ;Pasamos el resultado de la conversion al registro CCP1RL
    rrncf   BUFFER_DATA,F		    ;Se rota hacia la derecha el registro W sin acarreo
    rrncf   BUFFER_DATA,F		    ;Se rota hacia la derecha el registro W sin acarreo
    movf    BUFFER_DATA,W
    movwf   CCP1CON	    ;Se pasa la parte baja del resultado de la conversion al registro CCP1CON (5:4 bits)

    bsf	    CCP1CON,2    ;Seleccionamos modo PWM
    bsf     CCP1CON,3

    bsf    T2CON,2	    ;Encendemos el Timer 2, prescaler 1,postescaler 1

    return
PWM_ROUTINE CODE
    CONFIGURE_PWM
    bcf T2CON,TMR2ON
    clrf TMR2
    movlw   0Xff
    movwf   PR2	    ;Se introduce 0xFF al registro PR2 (Dato calculado previamente)
    movf    BUFFER_DATA+1,W
    movwf   CCPR1L	    ;Pasamos el resultado de la conversion al registro CCP1RL
    rrncf   BUFFER_DATA,F		    ;Se rota hacia la derecha el registro W sin acarreo
    rrncf   BUFFER_DATA,F		    ;Se rota hacia la derecha el registro W sin acarreo
    movf    BUFFER_DATA,W
    movwf   CCP1CON	    ;Se pasa la parte baja del resultado de la conversion al registro CCP1CON (5:4 bits)

    bsf	    CCP1CON,2    ;Seleccionamos modo PWM
    bsf     CCP1CON,3

    bsf    T2CON,TMR2ON	    ;Encendemos el Timer 2, prescaler 1,postescaler 1

    return
    PWM_INIT
    movlw 0xC0
    movwf BUFFER_DATA
    movwf BUFFER_DATA+1
    call CONFIGURE_PWM
    return
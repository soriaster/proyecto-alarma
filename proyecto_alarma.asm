
	LIST		p=16F887		;Tipo de microcontrolador
	INCLUDE 	P16F887.INC		;Define los SFRs y bits del 
						;P16F887

	__CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_XT_OSC	
						;Setea parámetros de 
					;	configuración

	errorlevel	 -302	;Deshabilita mensajes de 
						;advertencia por cambio 
						;bancos			
	CBLOCK 0X20	
	;PRIMER DISPLAY MULTIPIXELADO
	contador			;Cuenta 100 interrupciones
	unidades			
	uni_cod	
	decenas	
	dec_cod	
	sel
	contadora			;Cuenta 100 interrupciones
	unidadesa
	uni_coda	
	decenasa	
	dec_coda	
	sela
	;SEGUNDO DISPLAY MULTIPIXELADO
	contadorb			;Cuenta 100 interrupciones
	unidadesb
	uni_codb	
	decenasb	
	dec_codb	
	selb
	contadorc			;Cuenta 100 interrupciones
	unidadesc
	uni_codc	
	decenasc	
	dec_codc	
	selc
	;COMPARADORES DE VALORES
	com
	com1
	com2
	com3
	com4
	com5
	com6
	;VALORES DE ESPERA
	N1	
	N2
	N3
	
	ENDC
;*********************************************************************
;*********************************************************************
;PROGRAMA
	ORG		0x00		;Vector de RESET
	GOTO	MAIN
	ORG		0x04		;Vector de interrupción
	GOTO	Interrupcion	;Va a rutina de interrupción

	
Interrupcion  


abc
		BTFSc PORTA,6	 ;SI PRESIONO RA6  INICIO CONTEO , SINO MUESTRO INTRO
		GOTO CONTEO      
		call entrada	; SE MUESTRA EN CONJUNTO P7, RC Y AB
		goto abc
;INICIO EL CONTEO DE UNIDADES QUE REQUIERO

CONTEO	movf	sel,w		;Se mueve a si mismo para afectar bandera
		movlw	0x00 
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,0	
		
		btfsc	STATUS,2	;sel=0 refresca dig1; sel=1 refresca dig2
		goto	dig2

dig1	movf	unidades,w 
		call	tabla
		movwf	com1
		movwf	uni_cod
		movf 	uni_cod,w
		bsf		PORTA,0
		bsf		PORTA,1	
		movwf	PORTB    
		bcf		PORTA,0
		comf	sel,f
		goto 	dec
	
dig2	btfsc	PORTA,3		;SI PRESIONO RA3  MUESTRO VALORES DE UNIDADES EN DISPLAY
		retfie
		movf	decenas,w  
		call	tabla
		movwf	com2
		movwf	dec_cod
		movf 	dec_cod,w
		bsf		PORTA,0
		bsf		PORTA,1
		movwf	PORTB
		btfss	PORTA,2		;SI PRESIONO RA2  MUESTRO VALORES DE CAJAS EN DISPLAY , INICIO CONTEO DE CAJAS.
		goto	ALARMA
		btfsc STATUS,Z
	    retfie
		bcf		PORTA,1
		comf	sel,f	

dec		decfsz 	contador,f	;cuenta espacios de 10ms
		goto	Seguir			;Aún, no son 100 interrupciones
		INCF 	unidades,f		;Ahora sí 10x100=1000ms=1seg
		movlw	.10
		subwf	unidades,w
		btfss	STATUS,2
		goto	cont
		clrf	unidades
		incf	decenas
		movlw	.10
		subwf	decenas,w
		btfss	STATUS,2
		goto	cont
		clrf	decenas

cont 	movlw 	.100		
 	    movwf 	contador   		;Carga contador con 100

Seguir 	bcf	INTCON,T0IF		;Repone flag del TMR0 
		movlw 	~.39
	    movwf 	TMR0      		;Repone el TMR0 con ~.39
	    retfie				;Retorno de interrupción

;;;;;;;;;**********;;;;;;;;;;;;;;;;
;;;;;;;;;**********;;;;;;;;;;;;;;;;
;INICIO LA CANTIDAD DE CAJAS QUE REQUIERO CONTEO DE CAJAS

ALARMA	movf	sela,w
		btfss	STATUS,2
		goto	dig2a

dig1a	movf	unidadesa,w 
		call	tabla
		movwf	com3
		movwf	uni_coda 
		movf 	uni_coda,w 
		bsf		PORTA,4
		bsf		PORTA,5
		movwf	PORTC	; MUESTRA EL CONTEO DE CAJAS
		bcf		PORTA,4
		comf	sela,f
		goto 	deca

dig2a	btfsc	PORTA,2			; SI PRESIONO RA2 INICIO CONTEO DE CAJAS
		retfie
		movf	decenasa,w  
		call	tabla
		movwf	com5
		movwf	dec_coda
		movf 	dec_coda,w
		bsf		PORTA,4
		bsf		PORTA,5
		movwf	PORTC	; 
		btfss	PORTA,7
		goto    CAJAS
		btfsc STATUS,Z
	    retfie
		bcf		PORTA,5
		comf	sela,f
	

deca	decfsz 	contadora,f		;cuenta espacios de 10ms
		goto	Seguira			;Aún, no son 100 interrupciones
		INCF 	unidadesa,f		;Ahora sí 10x100=1000ms=1seg
		movlw	.10
		subwf	unidadesa,w
		btfss	STATUS,2
		goto	conta
		clrf	unidadesa
		incf	decenasa
		movlw	.10
		subwf	decenasa,w
		btfss	STATUS,2
		goto	conta
		clrf	decenasa

conta	movlw 	.100		
    	movwf 	contadora   		;Carga contador con 100

Seguira	bcf	INTCON,T0IF		;Repone flag del TMR0 
		movlw 	~.39
	    movwf 	TMR0      		;Repone el TMR0 con ~.39
	    retfie				;Retorno de interrupción

;;;;;;;;*************;;;;;;;;;;;;;;;;
;;;;;;;;*************;;;;;;;;;;;;;;;;
;INICIO EL CONTEO AUTOMATICO DE UNIDADES 

CAJAS	movf	selb,w
		btfss	STATUS,2
		goto	dig2b

dig1b	movf	unidadesb,w 
		call	tabla
		movwf	uni_codb 
		movf 	uni_codb,w 
		bsf		PORTA,0
		bsf		PORTA,1
		movwf	PORTB	
		bcf		PORTA,0
		comf	selb,f
		subwf	com1,w
		movwf 	com4
		subwf	com3,w
		movwf 	com6
		goto 	decb

dig2b	btfsc	PORTA,7			;SI PRESIONO RA7 INICIO EL CONTEO
		retfie
		movf	decenasb,w  
		call	tabla
		movwf	dec_codb
		movf 	dec_codb,w
		bsf		PORTA,0
		bsf		PORTA,1
		movwf	PORTB
		btfsc   STATUS,Z
	    retfie
		bcf		PORTA,1
		comf	selb,f	
		subwf	com2,w
		subwf 	com4,w
		btfsc 	STATUS,Z
		call    UNIDADCAJA

decb	decfsz 	contadorb,f		;cuenta espacios de 10ms
		goto	Seguirb			;Aún, no son 100 interrupciones
		INCF 	unidadesb,f		;Ahora sí 10x100=1000ms=1seg
		movlw	.10
		subwf	unidadesb,w
		btfss	STATUS,2
		goto	contb
		clrf	unidadesb
		incf	decenasb
		movlw   .10
		subwf	decenasb,w
		btfss	STATUS,2
		goto	contb
		clrf	decenasb

contb	movlw 	.100		
   	    movwf 	contadorb   		;Carga contador con 100

Seguirb bcf	INTCON,T0IF		;Repone flag del TMR0 
		movlw 	~.39
	    movwf 	TMR0      		;Repone el TMR0 con ~.39
	    retfie				;Retorno de interrupción

;;;;;;;;*************;;;;;;;;;;;
;;;;;;;;;***********;;;;;;;;;;;;

MAIN
;SETEO DE PUERTOS 
	BANKSEL		ANSEL		;Selecciona el Bank3
	CLRF		ANSEL
	CLRF		ANSELH
	BANKSEL 	TRISA		;Selecciona el Bank1
	CLRF		TRISA		;PORTA configurado como salida
	CLRF		TRISB		;PORTB configurado como salida
	CLRF		TRISC		;PORTC configurado como salida
	CLRF		TRISE		;PORTC configurado como salida
	movlw	    b'00001100'		;CONFIGURO COMO ENTRADAS ANALOGICAS	
	movwf		TRISA		;CARGO EL VALOR AL TRISA

;INICIALIZACION	      
	BANKSEL 	PORTA		;Selecciona el Bank0		
	CLRF		PORTA		;Borra latch de salida de PORTB
	CLRF		PORTB		;Borra latch de salida de PORTC
	CLRF		PORTC		;PORTC configurado como salida
	CLRF		PORTE		;PORTC configurado como salida
	clrf		unidades
	clrf		decenas
	clrf		sel		
	clrf		unidadesa
	clrf		decenasa
	clrf		sela
	clrf		unidadesb
	clrf		decenasb
	clrf		selb
	clrf		unidadesc
	clrf		decenasc
	clrf		selc
	clrf	    com     
	clrf	    com1	
	clrf 		com2	   
	clrf 		com3                                                                
	clrf 		com4 
	clrf 		com5 
	clrf 		com6 
;PROGRAMACION DEL TMR0
	banksel		OPTION_REG  	;Selecciona el Bank1
	movlw		b'00000111'	;TMR0 como temporizador
	movwf		OPTION_REG  	;con preescaler de 256 
	BANKSEL		TMR0		;Selecciona el Bank0
	movlw		.217		;Valor decimal 217	
	movwf		TMR0		;Carga el TMR0 con 217
	
;PROGRAMACION DE INTERRUPCION
	movlw	b'10100000'
	movwf	INTCON			;Activa la interrupción del TMR0
	movlw	.100			;Cantidad de interrupciones a contar
	movwf	contador		;Nº de veces a repetir la interrupción
	movlw	.100
	movwf	contadora
	movlw	.100
	movwf	contadorb
	movlw	.100
	movwf	contadorc

	loop	
		nop  
		goto loop



; TABLA DE CONVERSION---------------------------------------------------------

tabla
    ADDWF   PCL,F       	; PCL + W -> W
					; El PCL se incrementa con el 
					; valor de W proporcionando un 
					; salto
    RETLW   0x3F     	; Retorna con el código del 0
	RETLW	0x06		; Retorna con el código del 1
	RETLW	0x5B		; Retorna con el código del 2
	RETLW	0x4F		; Retorna con el código del 3
	RETLW	0x66		; Retorna con el código del 4
	RETLW	0x6D		; Retorna con el código del 5
	RETLW	0x7D		; Retorna con el código del 6
	RETLW	0x07		; Retorna con el código del 7
	RETLW	0x7F		; Retorna con el código del 8
	RETLW	0x67		; Retorna con el código del 9

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;	

;MUESTRO EN EL DISPLAY P7
	P7		MOVLW	.55
			MOVWF	N1
	LAZO1	MOVLW	.30
			MOVWF	N2
			NOP
	LAZO2	MOVLW	.255
			MOVWF	N3
	LAZO3	NOP
				NOP
				NOP
				DECFSZ	N3,F
				GOTO	LAZO3
				movlw	0x73 
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,1
				DECFSZ	N2,F
				GOTO	LAZO2
				movlw	0x67  
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,0
				DECFSZ	N1,F
				GOTO	LAZO1
	return

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;

;MUESTRO EN EL DISPLAY RC

	RC		MOVLW	.55
			MOVWF	N1
	LAZO1a	MOVLW	.30
			MOVWF	N2
			NOP
	LAZO2a	MOVLW	.255
			MOVWF	N3
	LAZO3a	NOP
				NOP
				NOP
				DECFSZ	N3,F
				GOTO	LAZO3a
				movlw	0x39 
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,1
				DECFSZ	N2,F
				GOTO	LAZO2a
				movlw	0xF7 
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,0
				DECFSZ	N1,F
				GOTO	LAZO1a
	return

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;

;MUESTRO EN EL DISPLAY APRETAR BOTONERA

	ON_AB       MOVLW	.55
				MOVWF	N1
	LAZO1b		MOVLW	.30
				MOVWF	N2
				NOP
	LAZO2b		MOVLW	.255
				MOVWF	N3
	LAZO3b		NOP
				NOP
				NOP
				DECFSZ	N3,F
				GOTO	LAZO3b
				movlw	0xF7 
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,1
				DECFSZ	N2,F
				GOTO	LAZO2b
				movlw	0xFF 
				bsf	PORTA,0
				bsf	PORTA,1
				movwf	PORTB
				bcf	PORTA,0
				DECFSZ	N1,F
				GOTO	LAZO1b
	return

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;
; RETARDOS DE TIEMPO

	DELAY		MOVLW	.30
				MOVWF	N1
	LAZO1c		MOVLW	.30
				MOVWF	N2
				NOP
	LAZO2c		MOVLW	.128
				MOVWF	N3
	LAZO3c		NOP
				NOP
				NOP
				DECFSZ	N3,F
				GOTO	LAZO3c
				DECFSZ	N2,F
				GOTO	LAZO2c
				DECFSZ	N1,F
				GOTO	LAZO1c
	RETURN

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;
;FUNCION PARA MOSTRAR LA INTRO
	entrada CALL P7
			CALL P7
			CALL RC
			CALL RC
			CALL ON_AB
			CALL ON_AB
	return

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;

; FUNCION QUE ME MUESTRA EL CONTEO AUTOMATICO DE CAJAS SELECCIONAS
;Y CUANDO LLEGA AL NUMERO ELEGIDO DE UNIDADES Y CAJAS SUENA ALARMA

	UNIDADCAJA		clrf	unidadesb
					clrf	decenasb
					movf	decenasc,w
					call	tabla
					bsf		PORTA,4
					bsf		PORTA,5
					movwf	PORTC   
					bcf		PORTA,5
					movlw	0x00 
					bsf		PORTA,0
					bsf		PORTA,1
					movwf 	PORTB
					bcf		PORTA,1
					CALL 	DELAY
					incf 	unidadesc,w
					movwf 	unidadesc
					call	tabla					
					bsf		PORTA,4
					bsf		PORTA,5
					movwf	PORTC   
					movwf	uni_codc
					subwf	com3,w			
					movwf 	com6
					bcf		PORTA,4
					CALL 	DELAY
					movlw   0x67
					subwf 	uni_codc,w
					btfsc 	STATUS,Z
					call 	disp2					
					movf 	com,w
					subwf	com6,w
					btfsc 	STATUS,Z
					call    RING
					return
					
		disp2		clrf	unidadesc
					incf 	decenasc,w
					movwf 	decenasc
					call	tabla
					subwf	com5,w
					movwf   com
					CALL	DELAY
		return

;;;;;;;;**************;;;;;;;;;;;;;;;
;;;;;;;;**************;;;;;;;;;;;;;;;
;FUNCION DE LA ALARMA
	
		RING	
		regreso		movlw	0x00 
					bsf		PORTA,0
					bsf		PORTA,1
					movwf 	PORTB
					bcf		PORTA,1
					BSF		PORTE,0
					CALL 	DELAY
					BCF		PORTE,0
					CALL 	DELAY
					BSF		PORTE,0
					CALL 	DELAY 
					BCF		PORTE,0
					CALL 	DELAY
					BSF		PORTE,0
					CALL 	DELAY 
					goto regreso
					return 
		
		END			;Fin del  programa fuente
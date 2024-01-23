.device atmega8

.equ SPL = 0x3D
.equ SPH = 0x3E

.equ PINB = 0x16
.equ DDRB = 0x17
.equ PORTB = 0x18
.equ PINC = 0x13
.equ PORTC = 0x15
.equ PORTD = 0x12

.equ ADCL = 0x04
.equ ADCH = 0x05
.equ ADCSRA = 0x06
.equ ADMUX = 0x07

.equ SPMCR = 0x37

.equ RAMEND = 0x045F

.org 0
USERCODE:

.org 0xC00

START:
    ldi r16, high(RAMEND)
    out SPH, r16
    ldi r16, low(RAMEND)
    out SPL, r16

    sbi PORTC, 4
    ldi r16, 1
    rcall delay
    clr r30
    clr r31
    sbic PINC, 4
    ijmp
    cbi PORTC, 4

    ldi r16, 0x65
    out ADMUX, r16
    ldi r16, 0xE2
    out ADCSRA, r16

loop:

    clr r20       ; avg8
    clr r14       ; avglo
    clr r15       ; avghi
    ldi r26, 0xFD
    ldi r27, 0    ; X = buf_start - 3

    clr r24       ; bit count

    ldi r16, 20
    rcall delay
    ldi r16, 2
    rcall blink_err

wait_nosignal:
    rcall upd_avg
    rcall sample
    cpi r20, 6
    brlo wait_nosignal

    ldi r19, 100
wait_rampup:
    rcall sample
    rcall upd_avg
    dec r19
    brne wait_rampup

wait_next:
    ldi r19, 100
wait_longlow:
    dec r19
    breq do_signal
    rcall sample
    brlo wait_longlow

    sbi PORTB, 0
wait_high:
    rcall sample
    brsh wait_high
    cbi PORTB, 0

    clr r19     ; counter for low periods
count_low:
    inc r19
    cpi r19, 6
    brlo not_byte_yet
    rcall append_byte
    rjmp wait_next
not_byte_yet:
    rcall sample
    brlo count_low
    inc r24
    lsr r18     ; accumulator for result
    cpi r19, 3
    brlo wait_next
    ori r18, 0x80
    rjmp wait_next

do_signal:

    cpi r27, 0    ; compare if X still at start
    breq loop
    
    cp  r25, r30
    breq chksum_ok
    ldi r16, 30
    rcall delay
    ldi r16, 5
    rcall blink_err
    rjmp loop

chksum_ok:
    rcall write_program

signal_done:
    ldi r16, 50
    rcall delay
    ldi r16, 3
    rcall blink_err
    rjmp signal_done

SAMPLE:
    push r18
    push r19
    ldi r18, 0xFF  ; cur min
    ldi r17, 0x00  ; cur max
    ldi r16, 10     ; samples count
adc_wait:
    sbis ADCSRA, 4
    rjmp adc_wait
    sbi ADCSRA, 4
    in r19, ADCH
    cp r18, r19
    brlo not_min
    mov r18, r19
not_min:
    cp r19, r17
    brlo not_max
    mov r17, r19
not_max:
    dec r16
    brne adc_wait
    sub r17, r18   ; return sweep in r17
    pop r19
    pop r18
    mov r16, r20
    lsr r16
    cp r17, r16
    ret

APPEND_BYTE:
    cpi r24, 8
    brlo append_end
    clr r24
    lsl r25
    adc r25, r24
    eor r25, r18
    st X+, r18
    cpi r27, 1
    brne append_end
    cpi r26, 0
    brne append_end
    sbiw r26, 3
    ld r30, X+
    ld r28, X+
    ld r29, X+
    ldi r25, 0x5A ; checksum
append_end:
    ret


UPD_AVG:
    clr r16
    add r14, r17
    adc r15, r16
    sub r14, r20
    sbc r15, r16
    mov r16, r14   ; update avg8
    andi r16, 0xF0
    swap r16
    mov r20, r15
    andi r20, 0x0F
    swap r20
    or r20, r16
    ret

BLINK_BITS:    ; from r19, high first
    push r16
    push r20
    ldi r20, 8
nextbit:
    ldi r16, 25
    rol r19
    brcs long
    ldi r16, 5
long:
    sbi PORTB, 0
    rcall delay
    ldi r16, 15
    cbi PORTB, 0
    rcall delay
    dec r20
    brne nextbit
    ldi r16, 70
    rcall delay
    pop r20
    pop r16
    ret

BLINK_ERR:
    sbi PORTB, 0
    push r16
    ldi r16, 5
    rcall delay
    cbi PORTB, 0
    ldi r16, 10
    rcall delay
    pop r16
    dec r16
    brne blink_err
    ret

WRITE_PROGRAM:
    clr r2        ; page pointer
    clr r3
    ldi r28, 0
    ldi r29, 1
write_next_page:
    rcall write_page
    ldi r16, 0x40
    add r2, r16
    clr r16
    adc r3, r16
    cp r29, r27
    brlo write_next_page
    brne writing_done
    cp r28, r26
    brlo write_next_page
writing_done:
    ret

WRITE_PAGE:
    mov r30, r2   ; erase page
    mov r31, r3
    ldi r16, 0b011
    rcall do_spm

    clr r30
    clr r31

next_byte:
    ld r0, Y+
    ld r1, Y+
    ldi r16, 0b001
    rcall do_spm
    adiw r30, 2

    cpi r30, 64
    brlo next_byte

    mov r30, r2
    mov r31, r3
    ldi r16, 0b101
    rcall do_spm

    ret

DO_SPM:
    out SPMCR, r16
    spm
spm_wait:
    in r16, SPMCR
    sbrc r16, 0
    rjmp spm_wait
    ret

DELAY:         ; load delay value to r16
    push r17
    push r18
lbl1:
    ldi r17, 100
lbl2:
    ldi r18, 100
lbl3:
    dec r18
    brne lbl3
    dec r17
    brne lbl2
    dec r16
    brne lbl1
    pop r18
    pop r17
    ret

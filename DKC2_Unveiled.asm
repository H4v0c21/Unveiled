;written with asar in mind


hirom


{ ;rom modifications
	;hijack original code to run custom code
	; org $F3A0FA : jsl Bonus_barrel_1
	; org $F3A15C : jsl Bonus_barrel_2
	; org $F3A14F : jsl Bonus_barrel_3

	org $F5CDE1 : jsl Start_select

	org $C090B7 : jsl Palette_1
	org $FB8B9F : jsl Palette_2 : rts
	org $FB8BCA : jsl Palette_3 : rts
	org $C0AA41 : jsl Palette_4 : nop #2

	org $FB9214 : jsl Single_kong

	org $FEBA31 : jsl Extra_DKCoin_1
	org $FEB88F : jsl Extra_DKCoin_2

	org $FBB8FF : jsl Secret_objects

	org $B8C764 : ret_C764: : org $B8C774 : jsl Team_throw_check : beq ret_C764

	org $B4AE40 : jsl Klubba_hide_option : nop
	org $B49B41 : jsl Klubba_default_option : nop #2
	org $B49A73 : jsl Klubba_prevent_option : nop #2

	org $BBBB93 : jsl Preserve_krool_zinger : beq ret_BBA4 : org $BBBBA4 : ret_BBA4:

	org $B8B8F3 : jsl Block_Y : nop #2

	org $B3D75B : jsl Reverse_controls

	;other rom modifications
	org $B39DA2 : ldx #$0006         ;drop TNT instead of banana bunch from chests if KONG letters already in possession
	org $B9EEC2 : lda #$9272 : nop   ;override animal type from box. always purple dk coin
	org $F4BE8F : db $2E             ;mario DK coins
	org $F6F46E : nop #2             ;no fake eggs from crow
	; org $FFC53C : db $3C, $FF, $00 ;bonus barrel roulette

	org $FFC4AD : db $0A ;3up instead of 1up in this goal rotation list
	org $FFC53C : db $00 ;this goal rotation list is blank
}


org $FDFC00 ;custom code location


{ ;bonus barrel on goal post
	; detect FF in goal rotation and use another sprite (bugged! can corrupt other sprites)
	; Bonus_barrel_1:
		; jsl $BB8C40
		; lda $48,X
		; cmp #$00FF
		; beq spec
		; rtl
	; spec:
		; lda #$3170
		; sta $1A,X
		; lda $12,X
		; and #$F0FF
		; sta $12,X
		; rtl

	; -----

	;preserve barrel speed on barrels dropped from goal post
	; Bonus_barrel_2:
		; pha
		; lda $00,X
		; cmp #$0140
		; beq is_barrel
		; stz $2C,X
	; is_barrel:
		; stz $56,X
		; pla
		; rtl

	; -----

	;detect FF being dropped from goal post and replace
	; Bonus_barrel_3:
		; cmp #$01FE ;FF has been shifted left once
		; beq replace_ff
		; lda $FF1A8A,X
		; rtl
	; replace_ff:
		; lda #$373A ;bonus barrel to room 2
		; rtl
}


{ ;always enable start+select for certain levels
	Start_select:
		lda $7E59F2 : ora #$8004 : sta $7E59F2
		lda $7E59F6 : ora #$1020 : sta $7E59F6
		jsl $BB91D9 ;the replaced jsl goes here instead
		rtl

	; 59F6 0020 = 2-2
	; 59F6 1000 = 4-5
	; 59F2 0004 = 4-6
	; 59F2 8000 = ?-?
}


{ ;palette code
	Palette_1:
		jsl $B58006
		lda #$6484 : sta $7EFEF0
		lda #$6574 : sta $7EFEF2	
		rtl

	; -----

	Palette_2:
		lda $7E08A4
		beq .palette_dixie

		lda $7EFEF0
		rtl
	.palette_dixie:
		lda $7EFEF2
		rtl

	; -----

	Palette_3:
		lda $7E08A4
		bne .palette_dixie

		lda $7EFEF0
		rtl
	.palette_dixie:
		lda $7EFEF2
		rtl

	; -----

	Palette_4:
		lda #$0000 ;to clear B
		sep #$20
		lda $0502
		and #$30
		lsr A
		sta $04F0
		lda $0503
		and #$20
		ora $04F0
		lsr A
		rep #$20
		phx
		tax
		lda.l .palettes,X   : sta $7EFEF0
		lda.l .palettes+2,X : sta $7EFEF2
		plx
		lda $0512
		cmp #$000F
		rtl

	.palettes:
		dw $6484,$6574, $64C0,$65B0, $6C9A,$6CB8, $6D30,$6D4E
		dw $6242,$705A, $6862,$6808, $77E2,$6CF4, $6D6C,$6D8A
}


{ ;single kong code
	Single_kong:
		sep #$30
		ldx $D3                 ;level ID

;-----
		cpx #$22 ;rattle battle room
		bne .skip_force_kong_transform

		lda #$00 : sta $6E : sta $6F ;set character select to kongs
	.skip_force_kong_transform:
;-----
		;exception for fiery furnace to get dixie at midway
		cpx #$16
		bne .skip

		ldx $08AC ;stored level ID for midway
		cpx #$16
		bne .skip

		ldx $08AA ;stored midway
		cpx #$01
		bne .skip

		lda #$01 : sta $08A4
		bra +

	.skip:
		ldx $D3
;-----

		lda.l .single_kong_flags,X
		beq .ret ;do nothing if byte is 0

		pha
		ldx $08A6     ;level starting point
	.next_entry:
		lsr A         ;set carry to current entry bit
		dex
		bpl .next_entry

		pla           ;restore flags for bits 6-7
		bcc .ret      ;branch if entry bit is clear

		asl A
		bcc .specific_kong

		lda $08A4 : eor #$01 : sta $08A4 ;opposite kong
		bra +

	.specific_kong:
		asl A : lda #$00 : rol A ;transfer bit 7 to bit 0 in A
		sta $08A4                ;active kong bit
	+:
		lda #$02 : sta $08C3 ;2? not set in jp ver0 in any case. could possibly just be stz $08C3
	.ret:
		rep #$30
		jsl $808E3B ;the replaced jsl goes here instead
		rtl

	.single_kong_flags: ;length = 256b
		db $00, $00, $00, $00, $03, $00, $00, $00, $00, $00, $00, $00, $89, $01, $00, $41
		db $00, $00, $00, $00, $43, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $81, $00, $00, $87, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

		; singleKongFlags layout
		; bit 0-5: entries
		; bit 6:   kong selector (0: diddy 1:dixie ?)
		; bit 7:   opposite kong mode
}


{ ;additional DK coin in levels
	; dk coin 2 has this extra:
	; 0030 0001

	Extra_DKCoin_1:
		lda $08A8
		jsr _FB8169
		lda $0030,Y
		bne .specialDKCoin

		lda $7E59D2,X ;regular DK coin
		bra .resume

	.specialDKCoin:
		lda $7E59FE
		and #$0002
		bne .krool_beaten

		lda #$0000 : sta $0000,Y
		rtl
	.krool_beaten:
		lda $7E5952,X ;2nd DK coin

	.resume:
		and $60
		bne .already_collected

		clc
		rtl
	.already_collected:
		sec
		rtl

	; -----

	Extra_DKCoin_2: ;store coin in bitfield
		lda $0030,X
		bne .special_DK_coin

		lda $08A8
		jsr _FB8169
		lda $7E59D2,X : ora $60 : sta $7E59D2,X
		rtl
	.special_DK_coin:
		lda $08A8
		jsr _FB8169
		lda $7E5952,X : ora $60 : sta $7E5952,X ;save within range that gets copied to saveRAM
		rtl

	; -----

	_FB8169: ;cloned code due to jsl/rts mismatch
		sta $5E
		and #$000F
		asl A
		tax
		lda $BB817F,X : sta $60
		lda $5E
		lsr #4
		asl
		tax
		rts
}


{ ;extra object spawns after k.rool defeated
	Secret_objects:
		lda $7E59FE
		and #$0002
		bne .ret   ;skip if k.rool beaten

		lda $00,X  ;load ID
		cmp #$01A8 ;DK barrel
		bne +      ;if not, check next type

		lda $32,X
		cmp #$0001
		bne .ret   ;if signature word isn't right, don't hide

		bra .hide

	+:
		cmp #$0150 ;invincibility barrel
		bne +

		lda $42,X
		cmp #$0FF0
		bne .ret

		bra .hide

	+:
		cmp #$0138 ;bonus timer
		bne +

		lda $46,X
		cmp #$0041
		bne .ret

		bra .hide

	+:
		cmp #$013C ;bonus cannon
		bne +

		lda $32,X
		cmp #$0001
		bne .ret

		bra .hide

	+:
		cmp #$0140 ;barrel cannon
		bne +

		lda $5A,X
		cmp #$ABCD
		bne .ret

		; bra .hide

	.hide:
		stz $00,X
	+:
	.ret:
		lda $0000FB
		rtl
}


{ ;disable team throw for certain levels
	Team_throw_check:
		lda $D3
		cmp #$008F ;clapper's cavern
		beq .ret

		cmp #$0091 ;clapper's cavern, bonus 1
		beq .ret

		cmp #$0092 ;clapper's cavern, bonus 1
		beq .ret

		ldy $0597
		lda $002E,Y
	.ret:
		rtl
}


{ ;hide pay option if insufficient DK coins
	Klubba_hide_option:
		rep #$20 ;replaced op

		lda $08CE
		cmp #$0029 ;check if player has the required DK coins
		bcs .ret

		;detect klubba's dialog options
		lda $7E3E12
		cmp #$2035 ;'U'
		bne .ret

		lda $7E3E14
		cmp #$2050 ;'p'
		bne .ret

		lda #$0000 ;zero out ram to be transferred to vram
		ldx #$0032
	-:
		sta $7E3E00,X
		dex #2
		bpl -

	.ret:
		dec $0681 ;replaced op
		rtl
}


{ ;default to option #2 if insufficient DK coins
	Klubba_default_option:
		lda $08CE
		cmp #$0029 ;check if player has the required DK coins
		bcs .ret

		lda $06
		cmp #$93BF ;some random check to see if this is at klubba's
		bne .ret

		lda #$0002 : sta $0654
		lda #$B314
		bra .ret2

	.ret:
		lda #$A314
	.ret2:
		sta $06B5
		rtl
}


{ ;prevent selecting option 1 if insufficient DK coins
	Klubba_prevent_option:
		lda $08CE
		cmp #$0029 ;check if player has the required DK coins
		bcs .ret

		lda $06
		cmp #$93BF ;some random check to see if this is at klubba's
		bne .ret

		lda $0654
		cmp #$0002
		rtl

	.ret:
		lda $0654
		cmp #$0001
		rtl
}


{ ;prevent zinger in krool from despawning
	Preserve_krool_zinger:
		lda $D3
		cmp #$0061
		bne .normal ;resume if not k.rool duel

		lda $00,X
		cmp #$01FC
		beq .ret    ;quit early if zinger

	.normal:
		php
		lda $58,X
		and #$000F
		asl
		plp
	.ret:
		rtl
}


{ ;block Y inputs
	Block_Y:
		lda $D3
		cmp #$0080 ;klobber karnage
		beq .disable

		cmp #$0097 ;klobber karnage bonus
		beq .disable

		bra .ret

	.disable:
		lda $050E : and #$BFFF : sta $050E
	.ret:
		ldy #$0000
		lda $0510
		rtl
}


{ ;reverse controls from crochead barrel
	Reverse_controls:
		lda $42,X : sta $44,X ;timer
		lda $0B02 : eor #$0010 : sta $0B02
		rtl
}

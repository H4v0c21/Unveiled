;---------- HOW TO USE


;get asar: https://github.com/RPGHacker/asar/releases/download/v1.71/asar171.zip

;create a new text file and copy-paste the following in it: asar.exe dkc2_krool.asm DKC2_Unveiled.sfc
;save with the extension .bat in the asar folder

;put a rom in the asar folder and run the .bat file to patch


;---------- asar / rom setup


math pri on : math round off : hirom


;---------- k rool script macros


macro goto(offset)
	;jumps to specified offset/label
	;goto 0 is a special case and jumps to the current pattern's starting point
	dw $0002, <offset>
endmacro


macro wait(timer)
	;wait x amount of frames
	dw $0028, <timer>
endmacro


macro dash(speed, acceleration)
	;dash. speed is specified as a decimal number, with a decimal sign if desired
	;acceleration should be within 1-6
	dw $0029, <speed>*256, <acceleration>
endmacro


macro shoot()
	dw $002A
endmacro


macro vacuum()
	dw $002B
endmacro


macro retract_spikes()
	dw $002C
endmacro


macro goto_if(offset)
	;goto offset if 0x0735 in RAM is clear. not sure what the purpose of this is yet
	dw $002D, <offset>
endmacro


macro spawn_item(item, x, y, sub, gas_x, gas_y)
	;spawn item. item is an offset to an item definition in bank FF.
	;x,y is the position
	;sub is a subroutine to call. should probably leave this as is
	;gas_x,gas_y is where the puff of smoke appears relative to the item
	dw $002E, <item>, <x>, <y>, <sub>, <gas_x>, <gas_y>
endmacro


macro visibility(state) ;todo
	;$0000 = invisible
	;$1000 = transparent
	;$2000 = fully visible
	dw $0033, <state>
endmacro


macro vacuum2(timer)
	dw $0035, <timer>
endmacro


macro wait_if_gas_hit(timer)
	;wait x amount of frames if the player is affected by any of the 3 gas types
	dw $0036, <timer>
endmacro


macro fade(a, b, timer)
	;no idea what a and b are supposed to be. timer is how long each fade step takes
	dw $0037, <a>, <b>, <timer>
endmacro


macro todo48(a, b)
	dw $0048, <a>, <b>
endmacro


macro shoot_fish()
	dw $0049
endmacro


;---------- object defines


!DK_barrel = $2212


;---------- k rool 1 script


namespace krool1


org $B6908D : script_1_entry: ;0x36908D
	%wait(100)
	%goto(pattern1)

	;leftover data? can possibly remove this to make space for new script events. investigate
	dw $90DB, $0045, $0003, $0000, $0000, $0000, $0000, $0000
	dw $0028, $003C, $0046, $0028, $0028, $0046, $0028, $0028
	dw $0046, $0028, $005F, $0047, $0028, $0014, $0047, $0028
	dw $001E, $0047, $0028, $0082, $0045, $0002, $0000, $0000
	dw $0000, $0000, $0000


pattern1:
	%shoot()
	%wait(240)
	%dash(5.0, 3)
	%wait(50)
	%vacuum()
.loop:
	%wait(50)
	%shoot()
	%wait(80)
	%dash(5.0, 4)
	%wait(50)
	%vacuum()
	%goto(.loop)

	dw $90ED ;leftover data?


pattern2:
	%wait(50)
	%shoot()
	%wait(120)
	%dash(5.0, 6)
	%wait(10)
	%dash(5.0, 6)
	%retract_spikes()
	%wait(50)
	%vacuum()
	%goto(0) ;pattern2


pattern3:
	%wait(60)
	%shoot()
	%wait(80)
	%dash(5.25, 6)
	%wait(10)
	%dash(5.25, 6)
	%wait(10)
	%dash(5.25, 6)
	%wait(40)
	%retract_spikes()
	%wait(80)
	%vacuum()
	%goto(0) ;pattern3


pattern4:
	%spawn_item(!DK_barrel, 456, 368, $ADB7, 0, -22)
.loop:
	%wait(80)
	%shoot()
	%wait(90)
	%goto_if(.loop)
	%vacuum()
	%goto(.loop)

	dw $9171 ;leftover data?


pattern5:
	%wait(80)
	%dash(5.5, 6)
.loop:
	%wait(40)
	%shoot()
	%wait(140)
	%goto_if(.loop)
	%vacuum()
	%goto(.loop)

	dw $9191 ;leftover data?

pattern6:
	%wait(40)
	%dash(5.75, 6)
.loop:
	%wait(40)
	%shoot()
	%wait(180)
	%goto_if(.loop)
	%vacuum()
	%goto(.loop)

	dw $91B1 ;leftover data?


pattern7:
	%spawn_item(!DK_barrel, 456, 368, $ADB7, 0, -22)
	%wait(50)
	%dash(6.0, 6)
.loop:
	%wait(40)
	%shoot()
	%wait(90)
	%wait_if_gas_hit(120)
	%dash(1.5, 6)
	%wait(34)
	%visibility($1000) ;3691F7
	%dash(5.0, 6)
	%wait(34)
	%fade($AE5F, $AE6B, 7)
	%visibility($0000)
	%dash(5.0, 6)
	%spawn_item($1F86, 456, 449, $ADA8, 0, -14)
	%visibility($1000)
	%fade($AE6B, $AE7B, 7)
	%wait(40)
	%visibility($2000)
	%vacuum()
	%goto(.loop)

	dw $91DF ;leftover data?


namespace off


;---------- k rool 2 script


namespace krool2


org $B69355 : script_2_entry: ;0x369355
	%wait(500)
	%wait(30)
	%shoot_fish()
	%wait(120)
.loop:
	%wait(120)
	%todo48($003A, $C3D0)
	%wait(150)
	%goto_if(.loop)
	%wait(75)
	%vacuum2(360)
	%goto(.loop)


namespace off


;---------- k rool speed definitions


macro krool_speeds(a, b, c, d, e, f, g, h, i)
	dw <i>*256, <h>*256, <g>*256, <f>*256, <e>*256, <d>*256, <c>*256, <b>*256, <a>*256
endmacro

org $B69385 : %krool_speeds(2.5, 3.5, 3.8125, 4.125, 4.4375, 4.75, 5.0625, 5.375, 5.6875)


;----------

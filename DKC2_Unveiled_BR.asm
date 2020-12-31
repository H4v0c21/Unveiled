;---------- HOW TO USE


;get asar: https://github.com/RPGHacker/asar/releases/download/v1.71/asar171.zip

;create a new text file and copy-paste the following in it: asar.exe DKC2_Unveiled_BR.asm DKC2_Unveiled_BR.sfc
;save with the extension .bat in the asar folder

;put a rom in the asar folder and run the .bat file to patch


;---------- Format for replacement string


;each character is 2 bytes, with the high byte being $20. The low byte is an ASCII value - $20.
;as an example, "G" ($47 in ASCII) would be stored as $2027.


;---------- rom setup


hirom


;----------


org $B4963C
	db $0B   ;string length (character count * 2 - 1)
	dw $FF00 ;offset

org $B4FF00
	dw $2027, $2032, $2021, $2034, $2029, $2033 ;"GRATIS"


;----------


org $B49670
	db $0F
	dw $FF10

org $B4FF10
	dw $2012, $2000, $202D, $202F, $2025, $2024, $2021, $2033 ;"2 MOEDAS"

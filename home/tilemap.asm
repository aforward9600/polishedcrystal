SetPalettes::
; Inits the Palettes
; depending on the system the monochromes palettes or color palettes
	push de
	ld a, %11100100
	call DmgToCgbBGPals
	lb de, %11100100, %11100100
	call DmgToCgbObjPals
	pop de
	ret

ClearPalettes::
; Make all palettes white
	ldh a, [rSVBK]
	push af

	ld a, BANK(wBGPals)
	ldh [rSVBK], a

; Fill wBGPals and wOBPals with $ffff (white)
	ld hl, wBGPals
if !DEF(MONOCHROME)
	ld bc, 16 palettes
	ld a, $ff
	rst ByteFill
else
	ld b, (16 palettes) / 2
.mono_loop
	ld a, PAL_MONOCHROME_WHITE % $100
	ld [hli], a
	ld a, PAL_MONOCHROME_WHITE / $100
	ld [hli], a
	dec b
	jr nz, .mono_loop
endc

	pop af
	ldh [rSVBK], a

; Request palette update
	ld a, 1
	ldh [hCGBPalUpdate], a
	ret

SetHPPal::
; Set palette for hp bar pixel length e at hl.
	call GetHPPal
	ld [hl], d
	ret

GetHPPal::
; Get palette for hp bar pixel length e in d.
	ld d, HP_GREEN
	ld a, e
	cp 25
	ret nc
	inc d ; HP_YELLOW
	cp 10
	ret nc
	inc d ; HP_RED
	ret

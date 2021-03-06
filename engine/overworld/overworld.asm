_ReplaceKrisSprite::
	call GetPlayerSprite
	ld a, [wPlayerSprite]
	ldh [hUsedSpriteIndex], a
	xor a
	ldh [hUsedSpriteTile], a
	ld hl, wSpriteFlags
	res 5, [hl]
	jp GetUsedSprite

GetPlayerSprite:
; Get Chris or Kris's sprite.
	ld hl, .Chris
	ld a, [wPlayerSpriteSetupFlags]
	bit 2, a
	jr nz, .go
	ld a, [wPlayerGender]
	bit 0, a
	jr z, .go
	ld hl, .Kris

.go
	ld a, [wPlayerState]
	ld c, a
.loop
	ld a, [hli]
	cp c
	jr z, .good
	inc hl
	cp $ff
	jr nz, .loop

; Any player state not in the array defaults to Chris's sprite.
	xor a ; ld a, PLAYER_NORMAL
	ld [wPlayerState], a
	ld a, SPRITE_CHRIS
	jr .finish

.good
	ld a, [hl]

.finish
	ld [wPlayerSprite], a
	ld [wPlayerObjectSprite], a
	ret

.Chris:
	db PLAYER_NORMAL,    SPRITE_CHRIS
	db PLAYER_BIKE,      SPRITE_CHRIS_BIKE
	db PLAYER_SURF,      SPRITE_CHRIS_SURF
	db PLAYER_SURF_PIKA, SPRITE_SURFING_PIKACHU
	db $ff

.Kris:
	db PLAYER_NORMAL,    SPRITE_KRIS
	db PLAYER_BIKE,      SPRITE_KRIS_BIKE
	db PLAYER_SURF,      SPRITE_KRIS_SURF
	db PLAYER_SURF_PIKA, SPRITE_SURFING_PIKACHU
	db $ff

MapCallbackSprites_LoadUsedSpritesGFX:
	ld a, MAPCALLBACK_SPRITES
	call RunMapCallback
ReloadVisibleSprites::
	push hl
	push de
	push bc
	call GetPlayerSprite
	xor a
	ldh [hUsedSpriteIndex], a
	call ReloadSpriteIndex
	call LoadEmoteGFX
	jp PopBCDEHL

ReloadSpriteIndex::
; Reloads sprites using hUsedSpriteIndex.
; Used to reload variable sprites
	ld hl, wObjectStructs
	ld de, OBJECT_STRUCT_LENGTH
	ldh a, [hUsedSpriteIndex]
	ld b, a
	xor a
.loop
	ldh [hObjectStructIndexBuffer], a
	ld a, [hl]
	and a
	jr z, .done
	bit 7, b
	jr z, .continue
	cp b
	jr nz, .done
.continue
	push hl
	; hl points to an object_struct; we want bc to point to a map_object,
	; to get the radius (actually the SPRITE_MON_ICON species).
	push bc
	ld bc, OBJECT_RADIUS - MAPOBJECT_RADIUS
	add hl, bc
	ld b, h
	ld c, l
	call GetSpriteVTile
	pop bc
	pop hl
	push hl
	inc hl ; skip OBJECT_SPRITE
	inc hl ; skip OBJECT_MAP_OBJECT_INDEX
	ld [hl], a ; OBJECT_SPRITE_TILE
	pop hl
.done
	add hl, de
	ldh a, [hObjectStructIndexBuffer]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

LoadEmoteGFX::
	ld a, [wSpriteFlags]
	bit 6, a
	ret nz

	ld c, EMOTE_SHADOW
	call LoadEmote
	call GetMapPermission
	call CheckOutdoorMapOrPerm5
	jr z, .outdoor
	ld c, EMOTE_BOULDER_DUST
	jp LoadEmote

.outdoor
	ld c, EMOTE_SHAKING_GRASS
	call LoadEmote
	ld c, EMOTE_PUDDLE_SPLASH
	jp LoadEmote

SafeGetSprite:
	push hl
	call GetSprite
	pop hl
	ret

GetSprite::
	call GetMonSprite
	ret c

	ld hl, SpriteHeaders ; address
	dec a
	ld c, a
	ld b, 0
	ld a, NUM_SPRITEHEADER_FIELDS
	rst AddNTimes
	; load the address into de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	; load the sprite bank into both b and h
	ld a, [hli]
	ld b, a
	; load the sprite type into l
	ld l, [hl]
	ld h, a
	; load the length into c
	ld c, 15
	ld a, l
	cp BIG_GYARADOS_SPRITE
	ret z
	ld c, 12
	ret

GetMonSprite:
; Return carry if a monster sprite was loaded.
	cp SPRITE_MON_ICON
	jr z, .MonIcon
	cp SPRITE_MON_DOLL_1
	jr z, .MonDoll1
	cp SPRITE_MON_DOLL_2
	jr z, .MonDoll2
	cp SPRITE_DAYCARE_MON_1
	jr z, .BreedMon1
	cp SPRITE_DAYCARE_MON_2
	jr z, .BreedMon2
	cp SPRITE_GROTTO_MON
	jr z, .GrottoMon

	cp SPRITE_VARS
	jr c, .Normal
	sub SPRITE_VARS
	ld e, a
	ld d, 0
	ld hl, wVariableSprites
	add hl, de
	ld a, [hl]
	and a
	jr nz, GetMonSprite
	; fallthrough

.NoSprite:
	ld a, 1
	lb hl, 0, MON_SPRITE
.Normal:
	and a
	ret

.MonIcon:
; Everything that calls GetMonSprite either points to a map_object struct in bc,
; or will not be used for Pokémon icons, so this SPRITE_MON_ICON can assume
; that bc takes MAPOBJECT_* offsets.
; (That means the player, Battle Tower trainers, and variable sprites cannot
;  use Pokémon icons.)
	ld hl, MAPOBJECT_RADIUS
	add hl, bc
	ld a, [hl]
	jr .Mon

.BreedMon1:
	ld a, [wBreedMon1Species]
	jr .Mon

.BreedMon2:
	ld a, [wBreedMon2Species]
	jr .Mon

.GrottoMon:
	farcall GetHiddenGrottoContents
	ld a, [hl]
	jr .Mon

.MonDoll1:
	ld a, [wLeftOrnament]
	jr .MonDoll

.MonDoll2:
	ld a, [wRightOrnament]
.MonDoll:
	farcall GetDecorationSpecies
	; fallthrough

.Mon:
	and a
	jr z, .NoSprite
	farcall LoadOverworldMonIcon
	lb hl, 0, MON_SPRITE
	scf
	ret

_DoesSpriteHaveFacings::
; Checks to see whether we can apply a facing to a sprite.
; Returns zero for Pokémon sprites, carry for the rest.
	cp SPRITE_POKEMON
	jr c, .facings
	cp SPRITE_VARS
	jr nc, .facings
	scf
	ret

.facings
	and a
	ret

_GetSpritePalette::
	call GetMonSprite
	jr c, .is_pokemon

	ld hl, SpriteHeaders + SPRITEHEADER_PALETTE
	dec a
	ld c, a
	ld b, 0
	ld a, NUM_SPRITEHEADER_FIELDS
	rst AddNTimes
	ld a, [hl]
	ret

.is_pokemon
	ld a, [wMapGroup]
	cp GROUP_KRISS_HOUSE_2F
	jr nz, .not_doll
	ld a, [wMapNumber]
	cp MAP_KRISS_HOUSE_2F
	jr nz, .not_doll
	farjp GetMonIconPalette

.not_doll
	cp GROUP_ROUTE_34
	jr nz, .not_daycare
	ld a, [wMapNumber]
	cp MAP_ROUTE_34
	jr nz, .not_daycare
	farcall GetMonIconPalette

	; gray, pink, and teal exist in the party menu and the player's room,
	; but not on Route 34 for the Daycare
	cp PAL_OW_GRAY
	jr z, .use_rock
	cp PAL_OW_TEAL
	jr z, .use_green
	cp PAL_OW_PINK
	ret nz
.not_daycare
	xor a ; PAL_OW_RED
	ret

.use_rock
	ld a, PAL_OW_ROCK
	ret

.use_green
	ld a, PAL_OW_GREEN
	ret

GetUsedSprite::
	ldh a, [hUsedSpriteIndex]
	call SafeGetSprite
	ldh a, [hUsedSpriteTile]
	call .GetTileAddr
	push bc
	push hl
	call SwapHLDE
	call FarDecompressWRA6InB
	pop hl
	pop bc
	ld de, wDecompressScratch
	push hl
	push de
	push bc
	ld a, [wSpriteFlags]
	bit 7, a
	call z, .CopyToVram
	pop bc
	ld l, c
	ld h, 0
rept 4
	add hl, hl
endr
	pop de
	add hl, de
	ld d, h
	ld e, l
	pop hl

	ld a, [wSpriteFlags]
	bit 6, a
	ret nz

	ldh a, [hUsedSpriteIndex]
	call _DoesSpriteHaveFacings
	ret c

	ld a, [wSpriteFlags]
	bit 5, a
	ld a, h
	jr nz, .vram1
	add 4
.vram1
	add 4
	ld h, a

.CopyToVram:
	ldh a, [rVBK]
	push af
	ld a, [wSpriteFlags]
	bit 5, a
	ld a, $0
	jr z, .bankswitch
	inc a
.bankswitch
	ldh [rVBK], a
	call Request2bppInWRA6
	pop af
	ldh [rVBK], a
	ret

.GetTileAddr:
; Return the address of tile (a) in (hl).
	and $7f
	ld l, a
	ld h, 0
rept 4
	add hl, hl
endr
	ld a, l
	add vTiles0 % $100
	ld l, a
	ld a, h
	adc vTiles0 / $100
	ld h, a
	ret

LoadEmote::
; Get the address of the pointer to emote c.
	ld a, c
	ld bc, 6
	ld hl, EmotesPointers
	rst AddNTimes
; Load the emote address into de
	ld e, [hl]
	inc hl
	ld d, [hl]
; load the length of the emote (in tiles) into c
	inc hl
	ld c, [hl]
	swap c
; load the emote pointer bank into b
	inc hl
	ld b, [hl]
; load the VRAM destination into hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
; swap the source into hl and the destination into de
	call SwapHLDE
; load into vram0
	jp DecompressRequest2bpp

INCLUDE "data/sprites/emotes.asm"

INCLUDE "data/sprites/sprites.asm"

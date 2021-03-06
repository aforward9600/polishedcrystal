KIRK_SHUCKIE_ID EQU 00518

SpecialGiveShuckie:
; Adding to the party.
	xor a
	ld [wMonType], a

; Level 20 Shuckle.
	ld a, SHUCKLE
	ld [wCurPartySpecies], a
	ld a, 20
	ld [wCurPartyLevel], a

	predef TryAddMonToParty
	jr nc, .NotGiven

; Caught data.
	lb bc, MALE, NET_BALL
	farcall SetGiftPartyMonCaughtData

; Holding a Berry Juice.
	ld hl, wPartyMon1Item
	call _GetLastPartyMonAttribute
	ld [hl], BERRY_JUICE

; OT ID.
	ld hl, wPartyMon1ID
	call _GetLastPartyMonAttribute
	ld a, KIRK_SHUCKIE_ID / $100
	ld [hli], a
	ld [hl], KIRK_SHUCKIE_ID % $100

; Nickname.
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonNicknames
	call SkipNames
	ld de, SpecialShuckieNick
	call CopyName2

; OT.
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonOT
	call SkipNames
	ld de, SpecialShuckieOT
	call CopyName2

; Engine flag for this event.
	ld hl, wDailyFlags
	set 5, [hl] ; ENGINE_SHUCKIE_GIVEN
	ld a, TRUE
	ldh [hScriptVar], a
	ret

.NotGiven:
	xor a ; ld a, FALSE
	ldh [hScriptVar], a
	ret

_GetLastPartyMonAttribute:
	ld a, [wPartyCount]
	dec a
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ret

SpecialReturnShuckie:
	farcall SelectMonFromParty
	jr c, .refused

	ld a, [wCurPartySpecies]
	cp SHUCKLE
	jr nz, .DontReturn

	ld a, [wCurPartyMon]
	ld hl, wPartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes

; OT ID
	ld a, [hli]
	cp KIRK_SHUCKIE_ID / $100
	jr nz, .DontReturn
	ld a, [hl]
	cp KIRK_SHUCKIE_ID % $100
	jr nz, .DontReturn

; OT
	ld a, [wCurPartyMon]
	ld hl, wPartyMonOT
	call SkipNames
	ld de, SpecialShuckieOT
.CheckOT:
	ld a, [de]
	cp [hl]
	jr nz, .DontReturn
	cp "@"
	jr z, .done
	inc de
	inc hl
	jr .CheckOT

.done
	farcall CheckCurPartyMonFainted
	jr c, .fainted
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Happiness
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ld a, [hl]
	cp 150
	ld a, $3
	jr nc, .HappyToStayWithYou
	xor a ; take from pc
	ld [wPokemonWithdrawDepositParameter], a
	farcall RemoveMonFromPartyOrBox
	ld a, $2
.HappyToStayWithYou:
	ldh [hScriptVar], a
	ret

.refused
	ld a, $1
	ldh [hScriptVar], a
	ret

.DontReturn:
	xor a
	ldh [hScriptVar], a
	ret

.fainted
	ld a, $4
	ldh [hScriptVar], a
	ret

SpecialShuckieOT:
	db "Kirk@"
SpecialShuckieNick:
	db "Shuckie@"

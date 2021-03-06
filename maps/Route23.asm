Route23_MapScriptHeader:
	db 0 ; scene scripts

	db 0 ; callbacks

	db 4 ; warp events
	warp_event  7, 135, POKEMON_LEAGUE_GATE, 5
	warp_event  8, 135, POKEMON_LEAGUE_GATE, 6
	warp_event  4, 31, VICTORY_ROAD_1F, 1
	warp_event 14, 31, VICTORY_ROAD_2F, 1

	db 23 ; coord events
	coord_event 14, 131, 0, Route23ZephyrBadgeTriggerScript
	coord_event  9, 123, 1, Route23HiveBadgeTriggerScript
	coord_event 10, 107, 2, Route23PlainBadgeTriggerScript
	coord_event 12, 107, 2, Route23PlainBadgeTriggerScript
	coord_event 13, 107, 2, Route23PlainBadgeTriggerScript
	coord_event 14, 107, 2, Route23PlainBadgeTriggerScript
	coord_event 15, 107, 2, Route23PlainBadgeTriggerScript
	coord_event  8, 98, 3, Route23FogBadgeTriggerScript
	coord_event  9, 98, 3, Route23FogBadgeTriggerScript
	coord_event 11, 98, 3, Route23FogBadgeTriggerScript
	coord_event 12, 98, 3, Route23FogBadgeTriggerScript
	coord_event 13, 98, 3, Route23FogBadgeTriggerScript
	coord_event  4, 83, 4, Route23StormBadgeTriggerScript
	coord_event  6, 83, 4, Route23StormBadgeTriggerScript
	coord_event  7, 83, 4, Route23StormBadgeTriggerScript
	coord_event  8, 70, 5, Route23MineralBadgeTriggerScript
	coord_event  9, 70, 5, Route23MineralBadgeTriggerScript
	coord_event 10, 70, 5, Route23MineralBadgeTriggerScript
	coord_event 12, 70, 5, Route23MineralBadgeTriggerScript
	coord_event 13, 70, 5, Route23MineralBadgeTriggerScript
	coord_event 12, 55, 6, Route23GlacierBadgeTriggerScript
	coord_event  6, 47, 7, Route23RisingBadgeTriggerScript
	coord_event  7, 47, 7, Route23RisingBadgeTriggerScript

	db 1 ; bg events
	bg_event  3, 32, SIGNPOST_JUMPTEXT, VictoryRoadSignText

	db 8 ; object events
	object_event 15, 131, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23ZephyrBadgeOfficerScript, -1
	object_event  8, 123, SPRITE_OFFICER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23HiveBadgeOfficerScript, -1
	object_event 11, 107, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23PlainBadgeOfficerScript, -1
	object_event 10, 98, SPRITE_SWIMMING_OFFICER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23FogBadgeOfficerScript, -1
	object_event  5, 83, SPRITE_SWIMMING_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23StormBadgeOfficerScript, -1
	object_event 11, 70, SPRITE_OFFICER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23MineralBadgeOfficerScript, -1
	object_event 13, 55, SPRITE_OFFICER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23GlacierBadgeOfficerScript, -1
	object_event  8, 47, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, Route23RisingBadgeOfficerScript, -1

	const_def 1 ; object constants
	const ROUTE23_OFFICER1
	const ROUTE23_OFFICER2
	const ROUTE23_OFFICER3
	const ROUTE23_OFFICER4
	const ROUTE23_OFFICER5
	const ROUTE23_OFFICER6
	const ROUTE23_OFFICER7
	const ROUTE23_OFFICER8

VictoryRoadSignText:
	text "Victory Road"
	done

Route23ZephyrBadgeOfficerScript:
Route23ZephyrBadgeTriggerScript:
	faceobject ROUTE23_OFFICER1, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER1
	stringtotext .ZephyrBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_ZEPHYRBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $0, Route23OfficerHaveBadgeScript
	setscene $1
	jump Route23OfficerHaveBadgeScript

.ZephyrBadgeText:
	db "Zephyr Badge@"

Route23HiveBadgeOfficerScript:
Route23HiveBadgeTriggerScript:
	faceobject ROUTE23_OFFICER2, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER2
	stringtotext .HiveBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_HIVEBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $1, Route23OfficerHaveBadgeScript
	setscene $2
	jump Route23OfficerHaveBadgeScript

.HiveBadgeText:
	db "Hive Badge@"

Route23PlainBadgeOfficerScript:
Route23PlainBadgeTriggerScript:
	faceobject ROUTE23_OFFICER3, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER3
	stringtotext .PlainBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_PLAINBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $2, Route23OfficerHaveBadgeScript
	setscene $3
	jump Route23OfficerHaveBadgeScript

.PlainBadgeText:
	db "Plain Badge@"

Route23FogBadgeOfficerScript:
Route23FogBadgeTriggerScript:
	faceobject ROUTE23_OFFICER4, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER4
	stringtotext .FogBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_FOGBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $3, Route23OfficerHaveBadgeScript
	setscene $4
	jump Route23OfficerHaveBadgeScript

.FogBadgeText:
	db "Fog Badge@"

Route23StormBadgeOfficerScript:
Route23StormBadgeTriggerScript:
	faceobject ROUTE23_OFFICER5, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER5
	stringtotext .StormBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_STORMBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $4, Route23OfficerHaveBadgeScript
	setscene $5
	jump Route23OfficerHaveBadgeScript

.StormBadgeText:
	db "Storm Badge@"

Route23MineralBadgeOfficerScript:
Route23MineralBadgeTriggerScript:
	faceobject ROUTE23_OFFICER6, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER6
	stringtotext .MineralBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_MINERALBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $5, Route23OfficerHaveBadgeScript
	setscene $6
	jump Route23OfficerHaveBadgeScript

.MineralBadgeText:
	db "Mineral Badge@"

Route23GlacierBadgeOfficerScript:
Route23GlacierBadgeTriggerScript:
	faceobject ROUTE23_OFFICER7, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER7
	stringtotext .GlacierBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_GLACIERBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $6, Route23OfficerHaveBadgeScript
	setscene $7
	jump Route23OfficerHaveBadgeScript

.GlacierBadgeText:
	db "Glacier Badge@"

Route23RisingBadgeOfficerScript:
Route23RisingBadgeTriggerScript:
	faceobject ROUTE23_OFFICER8, PLAYER
	faceobject PLAYER, ROUTE23_OFFICER8
	stringtotext .RisingBadgeText, 0
	opentext
	writetext Route23OfficerNeedBadgeText
	waitbutton
	checkflag ENGINE_RISINGBADGE
	iffalse_jumpopenedtext Route23OfficerNoBadgeText
	checkscene
	ifgreater $7, Route23OfficerHaveBadgeScript
	setscene $8
	jump Route23OfficerHaveBadgeScript

.RisingBadgeText:
	db "Rising Badge@"

Route23OfficerNoBadgeText:
	text "You don't have the"
	line "@"
	text_from_ram wStringBuffer3
	text " yet!"

	para "You have to have"
	line "it to get to the"
	cont "#mon League!@"
	done

Route23OfficerHaveBadgeScript:
	writetext .SeeBadgeText
	waitbutton
	thisopenedtext

	text "OK then! Please,"
	line "go right ahead!"
	done

.SeeBadgeText:
	text "Oh! That is the"
	line "@"
	text_from_ram wStringBuffer3
	text "!@"
	sound_dex_fanfare_50_79
	db "@@"

Route23OfficerNeedBadgeText:
	text "You can pass here"
	line "only if you have"
	cont "the @"
	text_from_ram wStringBuffer3
	text "."
	done

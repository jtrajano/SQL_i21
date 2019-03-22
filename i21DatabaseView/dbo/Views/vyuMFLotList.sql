CREATE VIEW vyuMFLotList
AS
SELECT L.intLotId
	,L.strLotNumber
	,L.intItemId
	,L.intLocationId
FROM tblICLot L
JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN tblICRestriction R1 ON R1.intRestrictionId = IsNULL(SL.intRestrictionId,R1.intRestrictionId)
	AND R1.strInternalCode = 'STOCK'
WHERE L.intLotStatusId = 1 -- Active
	AND L.dtmExpiryDate >= GetDate()
	AND L.dblQty > 0
	AND NOT EXISTS (
		SELECT *
		FROM tblMFWorkOrderProducedLot WP
		WHERE WP.intSpecialPalletLotId = L.intLotId
			AND WP.ysnProductionReversed = 0
		)
	AND SL.intStorageLocationId IN (
		SELECT PA.strAttributeValue
		FROM dbo.tblMFManufacturingProcessAttribute PA
		WHERE PA.intAttributeId = 90
			AND PA.strAttributeValue <> ''
		)

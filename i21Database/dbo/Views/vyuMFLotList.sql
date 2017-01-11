CREATE VIEW vyuMFLotList
AS
SELECT L.intLotId
	,L.strLotNumber
	,L.intItemId
	,L.intLocationId
FROM tblICLot L
JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN tblICRestriction R1 ON R1.intRestrictionId = SL.intRestrictionId
	AND R1.strInternalCode = 'STOCK'
WHERE L.intLotStatusId = 1 -- Active
	AND L.dtmExpiryDate >= GetDate()
	AND L.dblQty > 0

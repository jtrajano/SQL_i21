CREATE VIEW vyuMFParentLot
AS
SELECT DISTINCT PL.intParentLotId
	,PL.strParentLotNumber
	,I.intItemId
FROM tblICParentLot PL
JOIN tblICItem I ON I.intItemId = PL.intItemId
JOIN tblICLot L ON L.intParentLotId = PL.intParentLotId
	AND L.dblQty > 0

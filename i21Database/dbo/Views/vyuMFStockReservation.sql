CREATE VIEW vyuMFStockReservation
AS
SELECT S.intLotId
	,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, ISNULL(L.intWeightUOMId, L.intItemUOMId), ISNULL(S.dblQty, 0))) AS dblQty
FROM dbo.tblICStockReservation S
JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
	AND S.ysnPosted = 0
GROUP BY S.intLotId


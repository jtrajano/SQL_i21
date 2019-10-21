CREATE VIEW vyuMFStockReservation
AS
SELECT S.intLotId
	,SUM(CASE 
			WHEN S.intItemUOMId = L.intItemUOMId
				THEN ISNULL(S.dblQty, 0)
			ELSE dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, L.intItemUOMId, ISNULL(S.dblQty, 0))
			END) AS dblQty
	,SUM(CASE 
			WHEN S.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
				THEN ISNULL(S.dblQty, 0)
			ELSE dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, ISNULL(L.intWeightUOMId, L.intItemUOMId), ISNULL(S.dblQty, 0))
			END) AS dblWeight
FROM dbo.tblICStockReservation S
JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
	AND S.ysnPosted = 0 
GROUP BY S.intLotId

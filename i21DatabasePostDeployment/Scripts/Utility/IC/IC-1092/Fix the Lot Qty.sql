UPDATE Lot
SET dblQty = CASE WHEN ISNULL(Lot.dblWeightPerQty, 0) <> 0 THEN InvTrans.dblQty / Lot.dblWeightPerQty ELSE InvTrans.dblQty END 
FROM	dbo.tblICLot Lot LEFT JOIN (
			SELECT	dblQty = SUM(dblQty * dblUOMQty)
					,intLotId
			FROM	dbo.tblICInventoryTransaction
			WHERE	ISNULL(ysnIsUnposted, 0) = 0 
			GROUP BY intLotId
			
		) InvTrans
			ON Lot.intLotId = InvTrans.intLotId
WHERE	ROUND((InvTrans.dblQty - CASE WHEN ISNULL(Lot.dblWeightPerQty, 0) <> 0 THEN Lot.dblQty * Lot.dblWeightPerQty ELSE Lot.dblQty END), 6)
		<> 0
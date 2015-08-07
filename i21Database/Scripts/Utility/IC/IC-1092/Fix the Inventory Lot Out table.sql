UPDATE	CostBucketLot
SET		dblStockOut = LotOutQty.dblQty
FROM	dbo.tblICInventoryLot CostBucketLot LEFT JOIN (
			SELECT	dblQty = SUM(LotOut.dblQty)
					,intInventoryLotId
			FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN dbo.tblICInventoryTransaction InvTrans
						ON LotOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
			WHERE	ISNULL(InvTrans.dblValue, 0) = 0
					AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0 
			GROUP BY LotOut.intInventoryLotId
		) AS LotOutQty
			ON CostBucketLot.intInventoryLotId = LotOutQty.intInventoryLotId
WHERE	dblStockOut <> LotOutQty.dblQty
		AND dblStockIn >= LotOutQty.dblQty
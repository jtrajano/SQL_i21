PRINT N'BEGIN - IC Data Fix for 18.1. #13'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 
	UPDATE	UpdateLot
	SET		dblQtyInTransit = (
				SELECT	ISNULL(
							SUM (
								dbo.fnCalculateQtyBetweenUOM(
									InvTrans.intItemUOMId
									, Lot.intItemUOMId
									, InvTrans.dblQty
								)
							)
						, 0) 
				FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN tblICItemLocation il
								ON InvTrans.intItemLocationId = il.intItemLocationId 
						INNER JOIN dbo.tblICLot Lot
							ON InvTrans.intLotId = Lot.intLotId 
				WHERE	Lot.intLotId = UpdateLot.intLotId			
						AND il.intLocationId IS NULL 
			)
	FROM	dbo.tblICLot UpdateLot 
	WHERE	UpdateLot.dblQtyInTransit IS NULL 	

	UPDATE	dbo.tblICLot
	SET		dblWeightInTransit = dbo.fnMultiply(ISNULL(dblQtyInTransit, 0), ISNULL(dblWeightPerQty, 0)) 	
	FROM	dbo.tblICLot UpdateLot 
	WHERE	UpdateLot.dblQtyInTransit IS NULL 	

    UPDATE	dbo.tblICLot
    SET     dblQtyInTransit = ISNULL(dblQtyInTransit, 0)
            ,dblWeightInTransit = ISNULL(dblWeightInTransit, 0) 
    FROM    dbo.tblICLot UpdateLot 
END 

GO

PRINT N'END - IC Data Fix for 18.1. #13'
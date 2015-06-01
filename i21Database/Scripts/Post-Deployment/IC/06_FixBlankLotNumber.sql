-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the lot status 
-- --------------------------------------------------

print('/*******************  BEGIN Fix blank lot numbers *******************/')
GO

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryReceiptItemLot'))
BEGIN
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICInventoryReceiptItemLot') AND name = 'strLotNumber')
	BEGIN
		-- Repopulate the missing strLotNumber value
		EXEC('
			UPDATE	ItemLot
			SET		strLotNumber = Lot.strLotNumber
			FROM	dbo.tblICInventoryReceiptItemLot ItemLot INNER JOIN tblICLot Lot
						ON ItemLot.intLotId = Lot.intLotId
			WHERE	ItemLot.intLotId IS NOT NULL 
					AND ISNULL(ItemLot.strLotNumber, '''') = ''''
		')
	END
END

GO
print('/*******************  END Fix blank lot numbers *******************/')
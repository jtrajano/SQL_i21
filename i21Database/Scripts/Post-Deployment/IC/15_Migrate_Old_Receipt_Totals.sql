IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICInventoryReceiptCalculateTotals]') AND type in (N'P', N'PC'))
	EXEC dbo.uspICInventoryReceiptCalculateTotals 
GO 
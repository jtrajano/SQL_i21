PRINT N'START- IC Refresh IR Details'
GO

-- Temporarily comment this out to resolve IC-7927 but will temporarily remove optimizations in IC-7893
--EXEC dbo.uspICUpdateInventoryReceiptDetail

GO

PRINT N'END - IC Refresh IR Details'
GO
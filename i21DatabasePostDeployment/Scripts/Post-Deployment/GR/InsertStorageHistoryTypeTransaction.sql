GO 
    PRINT 'Start inserting fixed data in tblGRStorageHistoryTransaction'

    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'Scale')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('Scale', 1)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'CustomerStorage')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('CustomerStorage', 2)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'Transfer')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('Transfer', 3)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'Settlement')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('Settlement', 4)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'DeliverySheet')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('DeliverySheet', 5)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'Invoice')
    BEGIN    
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('Invoice', 6)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'InventoryReceipt')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('InventoryReceipt', 7)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'InventoryShipment')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('InventoryShipment', 8)
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGRStorageHistoryTypeTransaction WHERE strType = 'InventoryAdjustment')
    BEGIN
        INSERT INTO [dbo].[tblGRStorageHistoryTypeTransaction] (strType, intTypeId) VALUES ('InventoryAdjustment', 9)
    END

    PRINT 'End inserting fixed data in tblGRStorageHistoryTransaction'
GO
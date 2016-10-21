
-- Rename tblICInventoryShipmentItem.intCustomerStorageId to intStorageScheduleTypeId
IF NOT EXISTS (
	SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intStorageScheduleTypeId' 
	AND OBJECT_ID = OBJECT_ID(N'tblICInventoryShipmentItem')
) 
AND EXISTS (
	SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCustomerStorageId' 
	AND OBJECT_ID = OBJECT_ID(N'tblICInventoryShipmentItem')
)
BEGIN
	--  - [intCustomerStorageId] INT NULL
	--  + [intStorageScheduleTypeId] INT NULL
    EXEC sp_rename 'tblICInventoryShipmentItem.intCustomerStorageId', 'intStorageScheduleTypeId' , 'COLUMN'
END
GO
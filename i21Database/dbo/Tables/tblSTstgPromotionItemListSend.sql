CREATE TABLE [dbo].[tblSTstgPromotionItemListSend]
(
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListMaintenanceRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ILTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListID] INT NULL, 
    [ItemListDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeFormat] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [POSCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [PosCodeModifierName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

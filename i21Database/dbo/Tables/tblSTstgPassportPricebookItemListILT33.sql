CREATE TABLE [dbo].[tblSTstgPassportPricebookItemListILT33]
(
	[intPromotionItemListSend] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListMaintenanceRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListID] INT NULL, 
    [ItemListDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeFormatFormat] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [POSCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[strUniqueGuid]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblSTstgPassportPricebookItemListILT33] PRIMARY KEY ([intPromotionItemListSend])
)
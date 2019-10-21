CREATE TABLE [dbo].[tblSTstgPassportPricebookComboCBT33]
(
	[intComboSalesFile] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [CBTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PromotionID] INT NULL, 
	[PromotionReason] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ComboDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ComboPrice] NUMERIC(18, 2) NULL,
	[ItemListID] INT NULL,
	[ComboItemQuantity] INT NULL,
	[ComboItemUnitPrice] NUMERIC(18, 2) NULL,
	[StartDate] DATE NULL,
	[StartTime] TIME(0) NULL,
	[StopDate] DATE NULL,
	[StopTime] TIME(0) NULL,
	[strUniqueGuid]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblSTstgPassportPricebookComboCBT33] PRIMARY KEY ([intComboSalesFile])  
)

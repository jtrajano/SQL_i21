CREATE TABLE [dbo].[tblSTstgComboSalesFile]
(
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ComboMaintenanceRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [CBTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PromotionID] INT NULL, 
    [SalesRestrictCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [LinkCodeType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[ComboDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListID] INT NULL, 
    [ComboItemQuantity] INT NULL, 
    [ComboItemUnitPrice] NUMERIC(18, 6) NULL, 
    [StartDate] DATETIME NULL, 
    [StopDate] DATETIME NULL  
)

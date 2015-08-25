CREATE TABLE [dbo].[tblSTstgMixMatchFile]
(
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [MixMatchMaintenanceRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [CBTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PromotionID] INT NULL, 
    [PromotionReason] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[MixMatchDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [SalesRestrictCode] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListID] INT NULL, 
    [MixMatchUnits] INT NULL, 
    [MixMatchPrice] NUMERIC(18, 6) NULL, 
    [MixMatchPriceCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

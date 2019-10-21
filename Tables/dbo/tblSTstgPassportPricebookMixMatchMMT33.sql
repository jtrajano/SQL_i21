CREATE TABLE [dbo].[tblSTstgPassportPricebookMixMatchMMT33]
(
	[intMixMatchId] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [MMTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PromotionID] INT NULL, 
	[PromotionReason] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [MixMatchDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[TransactionLimit] INT NULL,
	[ItemListID] INT NULL,
	[StartDate] DATE NULL,
	[StartTime] TIME(0) NULL,
	[StopDate] DATE NULL,
	[StopTime] TIME(0) NULL,
	[MixMatchUnits] INT NULL,
	[MixMatchPrice] NUMERIC(18, 2) NULL,
	[strUniqueGuid]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblSTstgPassportPricebookMixMatchMMT33] PRIMARY KEY ([intMixMatchId])  
)
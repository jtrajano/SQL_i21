CREATE TABLE [dbo].[tblSTstgDepartmentSendFile]
(
	[intDepartmentSendFile] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [MCTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [MerchandiseCode] INT NULL, 
    [ActiveFlagValue] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[MerchandiseCodeDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [SalesRestrictCode] INT NULL, 
    [TaxStrategyID] INT NULL, 
    CONSTRAINT [PK_tblSTstgDepartmentSendFile] PRIMARY KEY ([intDepartmentSendFile])  
)

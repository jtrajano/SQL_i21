CREATE TABLE [dbo].[tblCFImportNetworkCostResult] (
    [intResultId]         INT            IDENTITY (1, 1) NOT NULL,
	[intEntityId] INT NOT NULL, 
    [strNote] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strSiteNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strProductNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intRecordNo] INT NULL, 
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFImportNetworkCostResult_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportNetworkCostResult] PRIMARY KEY CLUSTERED ([intResultId] ASC)
);


CREATE TABLE [dbo].[tblCFImportNetworkTaxRefResult] (
    [intResultId]         INT            IDENTITY (1, 1) NOT NULL,
	[intEntityId] INT NOT NULL, 
    [strNote] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strItemCategory] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strNetworkTaxCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intRecordNo] INT NULL, 
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFImportNetworkTaxRefResult_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportNetworkTaxRefResult] PRIMARY KEY CLUSTERED ([intResultId] ASC)
);
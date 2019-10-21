CREATE TABLE [dbo].[tblCFImportDriverPinResult] (
    [intResultId]         INT            IDENTITY (1, 1) NOT NULL,
	[intEntityId] INT NOT NULL, 
    [strNote] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDriverPinNumber]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strAccountNumber]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intRecordNo] INT NULL, 
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFImportDriverPinResult_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportDriverPinResult] PRIMARY KEY CLUSTERED ([intResultId] ASC)
);


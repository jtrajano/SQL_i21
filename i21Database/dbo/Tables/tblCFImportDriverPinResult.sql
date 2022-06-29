CREATE TABLE [dbo].[tblCFImportDriverPinResult] (
    [intResultId]         INT            IDENTITY (1, 1) NOT NULL,
	[intEntityId] INT NOT NULL, 
    [strNote] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDriverPinNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strAccountNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intRecordNo] INT NULL, 
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFImportDriverPinResult_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportDriverPinResult] PRIMARY KEY CLUSTERED ([intResultId] ASC)
);


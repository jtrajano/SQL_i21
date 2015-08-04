CREATE TABLE [dbo].[tblCFAccountFailedImport] (
    [intAccountFailedImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strAccountNumber]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReason]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFAccountFailedImport] PRIMARY KEY CLUSTERED ([intAccountFailedImportId] ASC)
);




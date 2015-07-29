CREATE TABLE [dbo].[tblCFAccountFailedImport] (
    [intAccountFailedImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strAccountNumber]         NVARCHAR (MAX) NOT NULL,
    [strReason]                NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_tblCFAccountFailedImport] PRIMARY KEY CLUSTERED ([intAccountFailedImportId] ASC)
);


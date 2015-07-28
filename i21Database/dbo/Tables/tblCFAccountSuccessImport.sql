CREATE TABLE [dbo].[tblCFAccountSuccessImport] (
    [intAccountSuccessImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strAccountNumber]          NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_tblCFAccountSuccessImport] PRIMARY KEY CLUSTERED ([intAccountSuccessImportId] ASC)
);


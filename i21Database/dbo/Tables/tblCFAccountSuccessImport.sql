CREATE TABLE [dbo].[tblCFAccountSuccessImport] (
    [intAccountSuccessImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strAccountNumber]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFAccountSuccessImport] PRIMARY KEY CLUSTERED ([intAccountSuccessImportId] ASC)
);




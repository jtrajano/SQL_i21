CREATE TABLE [dbo].[tblCFExportValidURL] (
    [intExportValidURLId] INT            IDENTITY (1, 1) NOT NULL,
    [strExportValidURL]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFValidURL_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFValidURL] PRIMARY KEY CLUSTERED ([intExportValidURLId] ASC)
);




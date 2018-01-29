CREATE TABLE [dbo].[tblCFExportValidURL] (
    [intExportValidURLId]      INT            IDENTITY (1, 1) NOT NULL,
    [strExportValidURL]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFExportValidURL_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFExportValidURL] PRIMARY KEY CLUSTERED ([intExportValidURLId] ASC)
);


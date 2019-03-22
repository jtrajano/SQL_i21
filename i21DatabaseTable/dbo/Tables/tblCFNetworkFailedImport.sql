CREATE TABLE [dbo].[tblCFNetworkFailedImport] (
    [intNetworkFailedImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strNetworkId]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReason]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFNetworkFailedImport] PRIMARY KEY CLUSTERED ([intNetworkFailedImportId] ASC)
);


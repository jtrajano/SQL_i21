CREATE TABLE [dbo].[tblCFNetworkSuccessImport] (
    [intNetworkSuccessImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strNetworkId]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFNetworkSuccessImport] PRIMARY KEY CLUSTERED ([intNetworkSuccessImportId] ASC)
);


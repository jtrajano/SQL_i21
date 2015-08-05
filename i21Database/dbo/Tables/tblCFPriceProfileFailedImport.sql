CREATE TABLE [dbo].[tblCFPriceProfileFailedImport] (
    [intPriceProfileFailedImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strPriceProfileId]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReason]                     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFPriceProfileFailedImport] PRIMARY KEY CLUSTERED ([intPriceProfileFailedImportId] ASC)
);


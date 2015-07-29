CREATE TABLE [dbo].[tblCFPriceProfileSuccessImport] (
    [intPriceProfileSuccessImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strPriceProfileId]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFPriceProfileSuccessImport] PRIMARY KEY CLUSTERED ([intPriceProfileSuccessImportId] ASC)
);


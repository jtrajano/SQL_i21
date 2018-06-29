CREATE TABLE [dbo].[tblCFExportTaxMappingDetail] (
    [intExportTaxMappingDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intExportTaxMappingId]       INT            NOT NULL,
    [intTaxClassId]               INT            NOT NULL,
    [strRecordMaker]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPosition]                 INT            NOT NULL,
    [strFormat]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]            INT            CONSTRAINT [DF_tblCFExportTaxMappingDetail_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFExportTaxMappingDetail] PRIMARY KEY CLUSTERED ([intExportTaxMappingDetailId] ASC),
    CONSTRAINT [FK_tblCFExportTaxMappingDetail_tblCFExportTaxMapping] FOREIGN KEY ([intExportTaxMappingId]) REFERENCES [dbo].[tblCFExportTaxMapping] ([intExportTaxMappingId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFExportTaxMappingDetail_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId])
);




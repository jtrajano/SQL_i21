CREATE TABLE [dbo].[tblTFValidLocalTax] (
    [intValidLocalTaxId]            INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentDetailId] INT           NOT NULL,
    [intLocalTaxId]                 INT           NULL,
    [strLocalTax]                   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFValidLocalTax_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFValidLocalTax] PRIMARY KEY CLUSTERED ([intValidLocalTaxId] ASC),
    CONSTRAINT [FK_tblTFValidLocalTax_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
);


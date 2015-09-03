CREATE TABLE [dbo].[tblTFValidProductCode] (
    [intValidProductCodeId]         INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentDetailId] INT           NOT NULL,
    [intProductCode]                INT           NULL,
    [strProductCode]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFValidProductCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFValidProductCode] PRIMARY KEY CLUSTERED ([intValidProductCodeId] ASC),
    CONSTRAINT [FK_tblTFValidProductCode_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
);


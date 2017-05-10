CREATE TABLE [dbo].[tblSMDocumentReport] (
    [intDocumentReportId]	INT             IDENTITY (1, 1) NOT NULL,
    [strReportName]			NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]		INT				NOT NULL,
    CONSTRAINT [PK_dbo.tblSMDocumentReport] PRIMARY KEY CLUSTERED ([intDocumentReportId] ASC)
);
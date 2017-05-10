CREATE TABLE [dbo].[tblSMScreenReport] (
    [intScreenReportId]		INT             IDENTITY (1, 1) NOT NULL,
    [strReportName]			NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intScreenId]			INT				NOT NULL,
    [intConcurrencyId]		INT				NOT NULL,
    CONSTRAINT [PK_dbo.tblSMScreenReport] PRIMARY KEY CLUSTERED ([intScreenReportId] ASC),
	CONSTRAINT [FK_tblSMScreenReport_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId])
);

CREATE TABLE [dbo].[tblSCHReportDistributionDetailContact]
(
	[intReportDistributionDetailContactId]	INT				IDENTITY (1, 1) NOT NULL,
	[intReportDistributionId]				INT				NOT NULL,
	[intEntityId]							INT				NOT NULL,
	[strEmail]								[nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[intFilterId]							INT				NULL,
	[intConcurrencyId]						INT				NOT NULL,

    CONSTRAINT [PK_tblSCHReportDistributionDetailContact] PRIMARY KEY CLUSTERED ([intReportDistributionDetailContactId] ASC),
    CONSTRAINT [FK_tblSCHReportDistributionDetailContact_tblSCHReportDistribution] FOREIGN KEY (intReportDistributionId) REFERENCES [dbo].[tblSCHReportDistribution] ([intReportDistributionId]) ON DELETE CASCADE
)

CREATE TABLE [dbo].[tblSCHReportDistributionDetailGroup]
(
	[intReportDistributionDetailGroupId]	INT				IDENTITY (1, 1) NOT NULL,
	[intReportDistributionId]				INT				NOT NULL,
	[intReportDistributionGroupId]			INT				NOT NULL,
	[intConcurrencyId]						INT				NOT NULL,

    CONSTRAINT [PK_tblSCHReportDistributionDetailGroup] PRIMARY KEY CLUSTERED ([intReportDistributionDetailGroupId] ASC),
    CONSTRAINT [FK_tblSCHReportDistributionDetailGroup_tblSCHReportDistribution] FOREIGN KEY (intReportDistributionId) REFERENCES [dbo].[tblSCHReportDistribution] ([intReportDistributionId]) ON DELETE CASCADE
)









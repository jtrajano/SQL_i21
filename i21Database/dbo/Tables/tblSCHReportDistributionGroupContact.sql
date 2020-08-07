CREATE TABLE [dbo].[tblSCHReportDistributionGroupContact]
(
	[intReportDistributionGroupContactId]				INT IDENTITY (1, 1) NOT NULL,
	[intReportDistributionGroupId]						[int] NOT NULL,
	[intEntityId]										[int] NOT NULL,
	[intFilterId]										[int] NULL,
	[intConcurrencyId]									[int] DEFAULT 1,

	CONSTRAINT [PK_tblSCHReportDistributionGroupContact] PRIMARY KEY CLUSTERED ([intReportDistributionGroupContactId] ASC),
    CONSTRAINT [FK_tblSCHReportDistributionGroupContact_tblSCHReportDistributionGroup] FOREIGN KEY ([intReportDistributionGroupId]) REFERENCES [dbo].[tblSCHReportDistributionGroup] ([intReportDistributionGroupId]) ON DELETE CASCADE
)

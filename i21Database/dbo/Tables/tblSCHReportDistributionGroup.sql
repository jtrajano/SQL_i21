CREATE TABLE [dbo].[tblSCHReportDistributionGroup]
(
	[intReportDistributionGroupId]				INT IDENTITY (1, 1) NOT NULL,
	[strDescription]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]							[int] DEFAULT 1,

	CONSTRAINT [PK_tblSCHReportDistributionGroup] PRIMARY KEY CLUSTERED ([intReportDistributionGroupId] ASC),
	CONSTRAINT [UC_tblSCHReportDistributionGroup] UNIQUE (strDescription)
)
GO

CREATE INDEX [IX_tblSCHReportDistributiontGroup_intReportDistributionGroupId] ON [dbo].[tblSCHReportDistributionGroup] ([intReportDistributionGroupId])
GO

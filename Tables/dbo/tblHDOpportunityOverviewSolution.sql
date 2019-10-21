CREATE TABLE [dbo].[tblHDOpportunityOverviewSolution]
(
		[intOpportunityOverviewSolutionId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] [int] NULL,
	[strOverviewType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunityOverviewSolution] PRIMARY KEY CLUSTERED ([intOpportunityOverviewSolutionId] ASC),
    CONSTRAINT [FK_tblHDOpportunityOverviewSolution_tblHDProject] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]),
    CONSTRAINT [FK_tblHDOpportunityOverviewSolution_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)

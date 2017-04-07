CREATE TABLE [dbo].[tblCRMOpportunityOverviewProblem]
(
	[intOpportunityOverviewId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] [int] NULL,
	[strOverviewType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityOverview] PRIMARY KEY CLUSTERED ([intOpportunityOverviewId] ASC),
    CONSTRAINT [FK_tblCRMOpportunityOverview_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCRMOpportunityOverview_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE
)

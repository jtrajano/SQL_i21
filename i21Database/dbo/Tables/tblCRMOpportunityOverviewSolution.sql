﻿CREATE TABLE [dbo].[tblCRMOpportunityOverviewSolution]
(
	[intOpportunityOverviewSolutionId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] [int] NULL,
	[strOverviewType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityOverviewSolution_intOpportunityOverviewSolutionId] PRIMARY KEY CLUSTERED ([intOpportunityOverviewSolutionId] ASC)
    --CONSTRAINT [FK_tblCRMOpportunityOverviewSolution_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]),
    --CONSTRAINT [FK_tblCRMOpportunityOverviewSolution_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)

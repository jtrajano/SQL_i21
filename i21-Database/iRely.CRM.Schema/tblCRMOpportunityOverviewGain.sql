CREATE TABLE [dbo].[tblCRMOpportunityOverviewGain]
(
	[intOpportunityOverviewGainId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] [int] NULL,
	[strOverviewType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityOverviewGain_intOpportunityOverviewGainId] PRIMARY KEY CLUSTERED ([intOpportunityOverviewGainId] ASC),
    CONSTRAINT [FK_tblCRMOpportunityOverviewGain_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCRMOpportunityOverviewGain_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE
)
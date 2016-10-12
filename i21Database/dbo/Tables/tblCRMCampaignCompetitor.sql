CREATE TABLE [dbo].[tblCRMCampaignCompetitor]
(
	[intCampaignCompetitorId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityCampaignId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMCampaignCompetitor_intCampaignCompetitorId] PRIMARY KEY CLUSTERED ([intCampaignCompetitorId] ASC)
	--CONSTRAINT [UQ_tblHDCampaignCompetitor_intOpportunityCampaignId_intEntityId] UNIQUE ([intOpportunityCampaignId],[intEntityId]),
    --CONSTRAINT [FK_tblHDCampaignCompetitor_tblHDOpportunityCampaign] FOREIGN KEY ([intOpportunityCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
    --CONSTRAINT [FK_tblHDCampaignCompetitor_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignCompetitor',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignCompetitorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Opportunity Campaign Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignCompetitor',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignCompetitor',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignCompetitor',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
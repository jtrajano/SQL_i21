CREATE TABLE [dbo].[tblHDCampaignEntity]
(
	[intCampaignEntityId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityCampaignId] [int] NOT NULL,
	[intEntityCustomerId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCampaignEntity] PRIMARY KEY CLUSTERED ([intCampaignEntityId] ASC),
	CONSTRAINT [UQ_tblHDCampaignEntity_intOpportunityCampaignId_intEntityCustomerId] UNIQUE ([intOpportunityCampaignId],[intEntityCustomerId]),
    CONSTRAINT [FK_tblHDCampaignEntity_tblHDProject] FOREIGN KEY ([intOpportunityCampaignId]) REFERENCES [dbo].[tblHDOpportunityCampaign] ([intOpportunityCampaignId]),
    CONSTRAINT [FK_tblHDCampaignEntity_tblCTContractHeader] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Opportunity Campaign',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for AR Customer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intEntityCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
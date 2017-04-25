CREATE TABLE [dbo].[tblCRMLostRevenueConfig]
(
	[intLostRevenueConfigId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[dtmRevenueFrom] [datetime] NOT NULL,
	[dtmRevenueTo] [datetime] NOT NULL,
	[dtmCompareToRevenueFrom] [datetime] NOT NULL,
	[dtmCompareToRevenueTo] [datetime] NOT NULL,
	[dtmOpportunityDate] [datetime] NULL,
	[intCampaignId] [int] NULL,
	[dtmCreatedDate] [datetime] NULL,
	[dtmLastUpdatedDate] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMLostRevenueConfig_intLostRevenueConfigId] PRIMARY KEY CLUSTERED ([intLostRevenueConfigId] ASC),
	CONSTRAINT [FK_tblCRMLostRevenueConfig_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) on delete cascade,
	CONSTRAINT [FK_tblCRMLostRevenueConfig_tblCRMCampaign_intCampaignId] FOREIGN KEY ([intCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]) on delete cascade,
	CONSTRAINT [UQ_tblCRMLostRevenueConfig_intEntityId] UNIQUE ([intEntityId])
)

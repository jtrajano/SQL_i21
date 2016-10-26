﻿CREATE TABLE [dbo].[tblCRMCampaignEntity]
(
	[intCampaignEntityId] [int] IDENTITY(1,1) NOT NULL,
	[intCampaignId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strResponse] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMCampaignEntity_intCampaignEntityId] PRIMARY KEY CLUSTERED ([intCampaignEntityId] ASC),
	CONSTRAINT [UQ_tblCRMCampaignEntity_intCampaignId_intEntityCustomerId] UNIQUE ([intCampaignId],[intEntityId]),
    CONSTRAINT [FK_tblCRMCampaignEntity_tblCRMCampaign_intCampaignId] FOREIGN KEY ([intCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
    CONSTRAINT [FK_tblCRMCampaignEntity_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Opportunity Campaign',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Customer Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Response',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'strResponse'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaignEntity',
    @level2type = N'COLUMN',
    @level2name = N'strComment'
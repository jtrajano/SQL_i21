﻿CREATE TABLE [dbo].[tblHDOpportunityCampaign]
(
	[intOpportunityCampaignId] [int] IDENTITY(1,1) NOT NULL,
	[strCampaignName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intLineOfBusinessId] [int] NULL,
	[dtmStartDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[dblOpenRate] [numeric](18, 6) NULL,
	[dtmCreateDate] [datetime] NULL,
	[strStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[ysnHold] [bit] null,
	[ysnActive] [bit] null,
	[intEntityId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunityCampaign] PRIMARY KEY CLUSTERED ([intOpportunityCampaignId] ASC),
	CONSTRAINT [UQ_tblHDOpportunityCampaign] UNIQUE ([strCampaignName]),
	CONSTRAINT [FK_tblHDOpportunityCampaign_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'strCampaignName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Line Of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intLineOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dtmStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Open Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dblOpenRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Create Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreateDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hold (true or false)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'ysnHold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active (true or false)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Salesperson',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
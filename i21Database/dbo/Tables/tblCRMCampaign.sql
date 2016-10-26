CREATE TABLE [dbo].[tblCRMCampaign]
(
	[intCampaignId] [int] IDENTITY(1,1) NOT NULL,
	[strCampaignName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intTypeId] [int] NULL,
	[intLineOfBusinessId] [int] NULL,
	[dtmStartDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[dblOpenRate] [numeric](18, 6) NULL,
	[dblBaseCost] [numeric](18, 6) NULL,
	[dblTotalCost] [numeric](18, 6) NULL,
	[dblExpectedRevenue] [numeric](18, 6) NULL,
	[dtmCreateDate] [datetime] NULL,
	intStatusId [int] NULL,
	[ysnHold] [bit] null,
	[ysnActive] [bit] null,
	[intEntityId] [int] NULL,
	[strRetrospective] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strImageId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMCampaign_intCampaignId] PRIMARY KEY CLUSTERED ([intCampaignId] ASC),
	CONSTRAINT [UQ_tblCRMCampaign_strCampaignName] UNIQUE ([strCampaignName]),
	CONSTRAINT [FK_tblCRMCampaign_tblCRMType_intTypeId] FOREIGN KEY ([intTypeId]) REFERENCES [dbo].[tblCRMType] ([intTypeId]),
	CONSTRAINT [FK_tblCRMCampaign_tblCRMStatus_intStatusId] FOREIGN KEY (intStatusId) REFERENCES [dbo].[tblCRMStatus] (intStatusId),
	CONSTRAINT [FK_tblCRMCampaign_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])

)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'strCampaignName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Line Of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intLineOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dtmStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Open Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dblOpenRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Create Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreateDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hold (true or false)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'ysnHold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active (true or false)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Id for Salesperson',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampaign',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
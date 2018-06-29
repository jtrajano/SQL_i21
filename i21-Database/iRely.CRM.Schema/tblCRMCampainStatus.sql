CREATE TABLE [dbo].[tblCRMCampainStatus]
(
	[intCampaignStatusId] [int] IDENTITY(1,1) NOT NULL,
	[strStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMCampainStatus] PRIMARY KEY CLUSTERED ([intCampaignStatusId] ASC),
	CONSTRAINT [UQ_tblCRMCampainStatus_strStatus] UNIQUE ([strStatus])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampainStatus',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampainStatus',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampainStatus',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMCampainStatus',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
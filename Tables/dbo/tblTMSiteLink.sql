CREATE TABLE [dbo].[tblTMSiteLink] (
    [intConcurrencyId] INT DEFAULT 1 NOT NULL,
    [intSiteLinkID]    INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]        INT DEFAULT 0 NULL,
    [intContractID]    INT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMSiteLink] PRIMARY KEY CLUSTERED ([intSiteLinkID] ASC),
    CONSTRAINT [FK_tblTMSiteLink_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'intSiteLinkID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'intContractID'
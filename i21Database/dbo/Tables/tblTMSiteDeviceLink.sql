CREATE TABLE [dbo].[tblTMSiteDeviceLink] (
    [intConcurrencyId]    INT DEFAULT 1 NOT NULL,
    [intSiteDeviceLinkID] INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]           INT DEFAULT 0 NULL,
    [intSiteDeviceID]     INT DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMSiteDeviceLink] PRIMARY KEY CLUSTERED ([intSiteDeviceLinkID] ASC),
    CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSiteDevice] FOREIGN KEY ([intSiteDeviceID]) REFERENCES [dbo].[tblTMSiteDevice] ([intSiteDeviceID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDeviceLink',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDeviceLink',
    @level2type = N'COLUMN',
    @level2name = N'intSiteDeviceLinkID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDeviceLink',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDeviceLink',
    @level2type = N'COLUMN',
    @level2name = N'intSiteDeviceID'
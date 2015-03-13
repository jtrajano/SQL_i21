CREATE TABLE [dbo].[tblTMSiteDevice] (
    [intConcurrencyId]             INT DEFAULT 1 NOT NULL,
    [intSiteDeviceID]              INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]                    INT DEFAULT 0 NULL,
    [intDeviceId]                  INT DEFAULT 0 NULL,
    [ysnAtCustomerToBeTransferred] BIT DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMSiteDevice] PRIMARY KEY CLUSTERED ([intSiteDeviceID] ASC),
    CONSTRAINT [FK_tblTMSiteDevice_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteDevice_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDevice',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDevice',
    @level2type = N'COLUMN',
    @level2name = N'intSiteDeviceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDevice',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Idicates if the device is to be transferred back to bulk location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnAtCustomerToBeTransferred'
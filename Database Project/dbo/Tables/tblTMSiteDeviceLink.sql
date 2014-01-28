CREATE TABLE [dbo].[tblTMSiteDeviceLink] (
    [intConcurrencyId]    INT DEFAULT 1 NOT NULL,
    [intSiteDeviceLinkID] INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]           INT DEFAULT 0 NULL,
    [intSiteDeviceID]     INT DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMSiteDeviceLink] PRIMARY KEY CLUSTERED ([intSiteDeviceLinkID] ASC),
    CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSiteDevice] FOREIGN KEY ([intSiteDeviceID]) REFERENCES [dbo].[tblTMSiteDevice] ([intSiteDeviceID])
);


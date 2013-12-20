CREATE TABLE [dbo].[tblTMSiteDeviceLink] (
    [intConcurrencyID]    INT CONSTRAINT [DEF_tblTMSiteDeviceLink_intConcurrencyID] DEFAULT ((0)) NULL,
    [intSiteDeviceLinkID] INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]           INT CONSTRAINT [DEF_tblTMSiteDeviceLink_intSiteID] DEFAULT ((0)) NULL,
    [intSiteDeviceID]     INT CONSTRAINT [DEF_tblTMSiteDeviceLink_intSiteDeviceID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMSiteDeviceLink] PRIMARY KEY CLUSTERED ([intSiteDeviceLinkID] ASC),
    CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSiteDevice] FOREIGN KEY ([intSiteDeviceID]) REFERENCES [dbo].[tblTMSiteDevice] ([intSiteDeviceID])
);


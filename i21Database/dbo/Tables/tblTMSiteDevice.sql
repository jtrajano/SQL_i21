CREATE TABLE [dbo].[tblTMSiteDevice] (
    [intConcurrencyId]             INT DEFAULT 1 NOT NULL,
    [intSiteDeviceID]              INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]                    INT DEFAULT 0 NULL,
    [intDeviceID]                  INT DEFAULT 0 NULL,
    [ysnAtCustomerToBeTransferred] BIT DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMSiteDevice] PRIMARY KEY CLUSTERED ([intSiteDeviceID] ASC),
    CONSTRAINT [FK_tblTMSiteDevice_tblTMDevice] FOREIGN KEY ([intDeviceID]) REFERENCES [dbo].[tblTMDevice] ([intDeviceID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteDevice_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);


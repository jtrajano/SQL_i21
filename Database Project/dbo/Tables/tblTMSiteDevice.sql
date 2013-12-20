CREATE TABLE [dbo].[tblTMSiteDevice] (
    [intConcurrencyID]             INT CONSTRAINT [DEF_tblTMSiteDevice_intConcurrencyID] DEFAULT ((1)) NULL,
    [intSiteDeviceID]              INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]                    INT CONSTRAINT [DEF_tblTMSiteDevice_intSiteID] DEFAULT ((0)) NULL,
    [intDeviceID]                  INT CONSTRAINT [DEF_tblTMSiteDevice_intDeviceID] DEFAULT ((0)) NULL,
    [ysnAtCustomerToBeTransferred] BIT CONSTRAINT [DEF_tblTMSiteDevice_ysnAtCustomerToBeTransferred] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMSiteDevice] PRIMARY KEY CLUSTERED ([intSiteDeviceID] ASC),
    CONSTRAINT [FK_tblTMSiteDevice_tblTMDevice] FOREIGN KEY ([intDeviceID]) REFERENCES [dbo].[tblTMDevice] ([intDeviceID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteDevice_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);


CREATE TABLE [dbo].[tblTMCompanySiteDevice] (
    [intCompanySiteDeviceId] INT IDENTITY (1, 1) NOT NULL,
    [intCompanyConsumptionSiteId] INT NULL,
    [intDeviceId] INT NULL,
    [intRowNumber] INT NULL,
    [intConcurrencyId] INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMCompanySiteDevice] PRIMARY KEY ([intCompanySiteDeviceId] ASC),
    CONSTRAINT [FK_tblTMCompanySiteDevice_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]), --ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMCompanySiteDevice_tblTMCompanyConsumptionSite] FOREIGN KEY ([intCompanyConsumptionSiteId]) REFERENCES [dbo].[tblTMCompanyConsumptionSite] ([intCompanyConsumptionSiteId]) ON DELETE CASCADE
)


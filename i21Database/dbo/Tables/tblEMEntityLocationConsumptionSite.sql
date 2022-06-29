CREATE TABLE [dbo].[tblEMEntityLocationConsumptionSite] (
    [intEntityLocationConsumptionSiteId]    INT IDENTITY (1, 1) NOT NULL,
    [intEntityLocationId]                   INT DEFAULT 0 NULL,
    [intSiteID]                             INT DEFAULT 0 NULL,
    [intConcurrencyId]                      INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblEMEntityLocationConsumptionSite] PRIMARY KEY CLUSTERED ([intEntityLocationConsumptionSiteId] ASC),
    CONSTRAINT [FK_tblEMEntityLocationConsumptionSite_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
    CONSTRAINT [FK_tblEMEntityLocationConsumptionSite_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId])
);
GO
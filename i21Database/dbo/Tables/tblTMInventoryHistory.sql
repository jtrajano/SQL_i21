CREATE TABLE [dbo].[tblTMInventoryHistory]
(
    [intConcurrencyId] INT DEFAULT 1 NOT NULL,
    [intInventoryId] INT IDENTITY(1,1) NOT NULL,
    [intSiteID]      INT DEFAULT 0 NULL,
    [dblLastInventoryReading] NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmLastInventoryTime] DATETIME NULL, 
    [dblCurrentInventoryReading] NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmInventoryTime]  DATETIME NULL
   
    CONSTRAINT [PK_tblTMInventoryHistory] PRIMARY KEY CLUSTERED ([intInventoryId] ASC),
    CONSTRAINT [FK_tblTMInventoryHistory_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
)







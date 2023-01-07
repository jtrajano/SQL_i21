CREATE TABLE [dbo].[tblTMInventoryHistory]
(
    [intConcurrencyId] INT DEFAULT 1 NOT NULL,
    [intInventoryHistoryId] INT IDENTITY(1,1) NOT NULL,
    [intSiteId]      INT DEFAULT 0 NULL,
    [dblLastInventoryReading] NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmLastInventoryTime] DATETIME NULL, 
    [dblCurrentInventoryReading] NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmInventoryTime]  DATETIME NULL
   
    CONSTRAINT [PK_tblTMInventoryHistory] PRIMARY KEY CLUSTERED ([intInventoryHistoryId] ASC),
    CONSTRAINT [FK_tblTMInventoryHistory_tblTMSite_intSiteId] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
)







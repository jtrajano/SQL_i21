CREATE TABLE [dbo].[tblTMSiteSeasonResetArchive] (
    [intSiteSeasonResetArchiveID] INT             IDENTITY (1, 1) NOT NULL,
    [intSeasonResetArchiveID]     INT             NOT NULL,
    [intSiteID]                   INT             NOT NULL,
    [dblLastDeliveryDegreeDay]    NUMERIC (18, 6) NOT NULL,
    [dblYTDGallonsThisSeason]     NUMERIC (18, 6) NOT NULL,
    [dblYTDGalsLastSeason]        NUMERIC (18, 6) NOT NULL,
    [dblYTDGals2SeasonsAgo]       NUMERIC (18, 6) NOT NULL,
    [dblYTDSalesThisSeason]       NUMERIC (18, 6) NOT NULL,
    [dblYTDSalesLastSeason]       NUMERIC (18, 6) NOT NULL,
    [dblYTDSales2SeasonsAgo]      NUMERIC (18, 6) NOT NULL,
    [intConcurrencyId]            INT             DEFAULT 1 NOT NULL, 
    CONSTRAINT [PK_tblTMSiteSeasonResetArchive] PRIMARY KEY ([intSiteSeasonResetArchiveID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intSiteSeasonResetArchiveID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season Reset Archive ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intSeasonResetArchiveID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Delivery Degree Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblLastDeliveryDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Gallons This Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDGallonsThisSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Gallons Last Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDGalsLastSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Gallons Last 2 Seasons',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDGals2SeasonsAgo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Sales This Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDSalesThisSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Sales Last Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDSalesLastSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Sales Last 2 Seasons',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDSales2SeasonsAgo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
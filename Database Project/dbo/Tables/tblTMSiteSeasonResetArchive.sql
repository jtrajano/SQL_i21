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
    [intConcurrencyID]            INT             NULL
);


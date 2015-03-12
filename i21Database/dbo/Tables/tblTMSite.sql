CREATE TABLE [dbo].[tblTMSite] (
    [intConcurrencyId]            INT             DEFAULT 1 NOT NULL,
    [intSiteID]                   INT             IDENTITY (1, 1) NOT NULL,
    [strSiteAddress]              NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intProduct]                  INT             DEFAULT 0 NULL,
    [intCustomerID]               INT             DEFAULT 0 NOT NULL,
    [dblTotalCapacity]            NUMERIC (18, 6) DEFAULT 0 NULL,
    [ysnOnHold]                   BIT             DEFAULT 0 NULL,
    [ysnActive]                   BIT             DEFAULT 1 NULL,
    [strDescription]              NVARCHAR (200)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strAcctStatus]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblPriceAdjustment]          NUMERIC (18, 6) DEFAULT 0 NULL,
    [intClockID]                  INT             DEFAULT 0 NULL,
    [dblDegreeDayBetweenDelivery] NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblSummerDailyUse]           NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblWinterDailyUse]           NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [ysnTaxable]                  BIT             DEFAULT 0 NULL,
    [intTaxStateID]               INT             DEFAULT 0 NULL,
    [ysnPrintDeliveryTicket]      BIT             DEFAULT 0 NOT NULL,
    [ysnAdjustBurnRate]           BIT             DEFAULT 0 NULL,
    [intDriverID]                 INT             DEFAULT 0 NULL,
    [strRouteId]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strSequenceID]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblYTDGalsThisSeason]        NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblYTDGalsLastSeason]        NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmRunOutDate]               DATETIME        DEFAULT 0 NULL,
    [dblEstimatedPercentLeft]     NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblConfidenceFactor]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [strZipCode]                  NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strCity]                     NVARCHAR (70)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strState]                    NVARCHAR (70)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblLatitude]                 NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblLongitude]                NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [intSiteNumber]               INT             DEFAULT 0 NOT NULL,
    [dtmOnHoldStartDate]          DATETIME        DEFAULT 0 NULL,
    [dtmOnHoldEndDate]            DATETIME        DEFAULT 0 NULL,
    [ysnHoldDDCalculations]       BIT             DEFAULT 0 NULL,
    [dblYTDSales]                 NUMERIC (18, 6) DEFAULT 0 NULL,
    [intUserID]                   INT             DEFAULT 0 NULL,
    [strBillingBy]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblPreviousBurnRate]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblTotalReserve]             NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblLastGalsInTank]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblLastDeliveredGal]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [intDeliveryTicketNumber]     INT             DEFAULT 0 NULL,
    [dblEstimatedGallonsLeft]     NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmLastDeliveryDate]         DATETIME        DEFAULT 0 NULL,
    [dtmNextDeliveryDate]         DATETIME        DEFAULT 0 NULL,
    [strCountry]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intFillMethodId]             INT             DEFAULT 0 NULL,
    [intHoldReasonID]             INT             DEFAULT 0 NULL,
    [dblYTDGals2SeasonsAgo]       NUMERIC (18, 6) DEFAULT 0 NULL,
    [intTaxLocale1]               INT             DEFAULT 0 NULL,
    [intTaxLocale2]               INT             DEFAULT 0 NULL,
    [ysnAllowPriceChange]         BIT             DEFAULT 0 NULL,
    [intRecurringPONumber]        INT             DEFAULT 0 NULL,
    [ysnPrintARBalance]           BIT             DEFAULT 0 NOT NULL,
    [ysnPromptForPercentFull]     BIT             DEFAULT 0 NULL,
    [strFillGroup]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblBurnRate]                 NUMERIC (18, 6) DEFAULT 0 NULL,
    [strTankTownship]             NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmLastUpdated]              DATETIME        DEFAULT 0 NULL,
    [intLastDeliveryDegreeDay]    INT             DEFAULT 0 NULL,
    [intNextDeliveryDegreeDay]    INT             DEFAULT 0 NULL,
    [ysnDeliveryTicketPrinted]    BIT             DEFAULT 0 NOT NULL,
    [strComment]                  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strInstruction]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strClassFillOption]          NVARCHAR (20)   COLLATE Latin1_General_CI_AS DEFAULT (N'No') NULL,
    [dblLastMeterReading]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [strLocation]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ((0)) NULL,
    [intRoute]                    INT             NULL,
    [dtmLastReadingUpdate]        DATETIME        NULL,
    [intFillGroupId]              INT             NULL,
    [intRouteId]                  INT             NULL,
    [intTankTownshipId]           INT             NULL,
    [dtmForecastedDelivery]       DATETIME        NULL,
    [intParentSiteID]             INT             NULL,
    [intDeliveryTermID]           INT             NULL,
    [dblYTDSalesLastSeason]       NUMERIC (18, 6) NULL,
    [dblYTDSales2SeasonsAgo]      NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblTMSite] PRIMARY KEY CLUSTERED ([intSiteID] ASC),
    CONSTRAINT [FK_tblTMSite_tblTMClock] FOREIGN KEY ([intClockID]) REFERENCES [dbo].[tblTMClock] ([intClockID]),
    CONSTRAINT [FK_tblTMSite_tblTMCustomer] FOREIGN KEY ([intCustomerID]) REFERENCES [dbo].[tblTMCustomer] ([intCustomerID]),
    CONSTRAINT [FK_tblTMSite_tblTMFillMethod] FOREIGN KEY ([intFillMethodId]) REFERENCES [dbo].[tblTMFillMethod] ([intFillMethodId]),
    CONSTRAINT [FK_tblTMSite_tblTMHoldReason] FOREIGN KEY ([intHoldReasonID]) REFERENCES [dbo].[tblTMHoldReason] ([intHoldReasonID]),
    CONSTRAINT [FK_tblTMSite_tblTMSite] FOREIGN KEY ([intParentSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblTMSite_tblTMRoute] FOREIGN KEY (intRouteId) REFERENCES [dbo].[tblTMRoute] (intRouteId),
	CONSTRAINT [FK_tblTMSite_tblTMFillGroup] FOREIGN KEY (intFillGroupId) REFERENCES [dbo].[tblTMFillGroup] (intFillGroupId),
	CONSTRAINT [FK_tblTMSite_tblTMTankTownship] FOREIGN KEY (intTankTownshipId) REFERENCES [dbo].[tblTMTankTownship] (intTankTownshipId)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strSiteAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intProduct'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblTotalCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if delivery in site is on hold',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnOnHold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if site is active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strAcctStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Adjustment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblPriceAdjustment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intClockID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Degree Day Between Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblDegreeDayBetweenDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Summary Daily Use',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblSummerDailyUse'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Winter Daily Use',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblWinterDailyUse'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax State ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intTaxStateID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Delivery Ticket Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintDeliveryTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Adjust Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnAdjustBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intDriverID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Route ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strRouteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sequence ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strSequenceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Gallons This Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDGalsThisSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Gallons Last Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDGalsLastSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Runout date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmRunOutDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated Percent Left',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblEstimatedPercentLeft'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblConfidenceFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strZipCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitude',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblLatitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitude',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblLongitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intSiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'On Hold Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmOnHoldStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'On Hold End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmOnHoldEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hold Degree Day Calculations',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnHoldDDCalculations'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Sales',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDSales'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BIlling By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strBillingBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Previous Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblPreviousBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Total Reserve',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblTotalReserve'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Gallons in Tank',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblLastGalsInTank'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Delivered Gallons',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblLastDeliveredGal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Ticket Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated Gallons Left',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblEstimatedGallonsLeft'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmNextDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fill Method ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intFillMethodId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hold Reason ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intHoldReasonID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Gallons Two Seasons Ago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDGals2SeasonsAgo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Locale 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intTaxLocale1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Locale 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intTaxLocale2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Price Change Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowPriceChange'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recurring PO Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intRecurringPONumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print AR Balance Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintARBalance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prompt For Percent Full Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnPromptForPercentFull'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strFillGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Township',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strTankTownship'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Updated Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Delivery Degree Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intLastDeliveryDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Delivery Degree Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intNextDeliveryDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Ticket Printed Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'ysnDeliveryTicketPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Instruction',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strInstruction'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Class Fill Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strClassFillOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Meter Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblLastMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'strLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intRoute'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date to indicate when was the site estimated gallons left was updated',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastReadingUpdate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fill Group ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intFillGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Route ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intRouteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Township ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intTankTownshipId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Forecasted Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dtmForecastedDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Parent Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intParentSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Term ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryTermID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Sales Last Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDSalesLastSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'YTD Sales Last two Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSite',
    @level2type = N'COLUMN',
    @level2name = N'dblYTDSales2SeasonsAgo'
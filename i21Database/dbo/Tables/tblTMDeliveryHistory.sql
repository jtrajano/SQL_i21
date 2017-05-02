CREATE TABLE [dbo].[tblTMDeliveryHistory] (
    [intConcurrencyId]                      INT             DEFAULT 1 NOT NULL,
    [intDeliveryHistoryID]                  INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strBulkPlantNumber]                    NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmInvoiceDate]                        DATETIME        DEFAULT 0 NULL,
    [strProductDelivered]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblQuantityDelivered]                  NUMERIC (18, 6) DEFAULT 0 NULL,
    [intDegreeDayOnDeliveryDate]            INT             DEFAULT 0 NULL,
    [intDegreeDayOnLastDeliveryDate]        INT             DEFAULT 0 NULL,
    [dblBurnRateAfterDelivery]              NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblCalculatedBurnRate]                 NUMERIC (18, 6) DEFAULT 0 NULL,
    [ysnAdjustBurnRate]                     BIT             DEFAULT 0 NULL,
    [intElapsedDegreeDaysBetweenDeliveries] INT             DEFAULT 0 NULL,
    [intElapsedDaysBetweenDeliveries]       INT             DEFAULT 0 NULL,
    [strSeason]                             NVARCHAR (15)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblWinterDailyUsageBetweenDeliveries]  NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblSummerDailyUsageBetweenDeliveries]  NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblGallonsInTankbeforeDelivery]        NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblGallonsInTankAfterDelivery]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblEstimatedPercentBeforeDelivery]     NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblActualPercentAfterDelivery]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblMeterReading]                       NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblLastMeterReading]                   NUMERIC (18, 6) DEFAULT 0 NULL,
    [intUserID]                             INT             DEFAULT 0 NULL,
    [dtmLastUpdated]                        DATETIME        DEFAULT 0 NULL,
    [intSiteID]                             INT             DEFAULT 0 NULL,
    [strSalesPersonID]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT 0 NULL,
    [dblExtendedAmount]                  NUMERIC (18, 6) NOT NULL DEFAULT 0,
    [ysnForReview] BIT NOT NULL DEFAULT 0, 
    [dtmMarkForReviewDate] DATETIME NULL, 
    [dblWillCallPercentLeft] NUMERIC(18, 6) NULL, 
    [dblWillCallCalculatedQuantity] NUMERIC(18, 6) NULL, 
    [dblWillCallDesiredQuantity] NUMERIC(18, 6) NULL, 
    [intWillCallDriverId] INT NULL, 
    [intWillCallProductId] INT NULL, 
    [intWillCallSubstituteProductId] INT NULL, 
    [dblWillCallPrice] NUMERIC(18, 6) NULL, 
    [intWillCallDeliveryTermId] INT NULL, 
    [dtmWillCallRequestedDate] DATETIME NULL, 
    [intWillCallPriority] INT NULL, 
    [dblWillCallTotal] NUMERIC(18, 6) NULL, 
    [strWillCallComments] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [dtmWillCallCallInDate] DATETIME NULL, 
    [intWillCallUserId] INT NULL, 
    [ysnWillCallPrinted] BIT NULL, 
    [dtmWillCallDispatch] DATETIME NULL, 
    [strWillCallOrderNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intInvoiceId] INT NULL, 
    [intWillCallContractId] INT NULL, 
    [dtmWillCallDeliveryDate] DATETIME NULL, 
    [dblWillCallDeliveryQuantity] NUMERIC(18, 6) NULL, 
    [dblWillCallDeliveryPrice] NUMERIC(18, 6) NULL, 
    [dblWillCallDeliveryTotal] NUMERIC(18, 6) NULL, 
    [intInvoiceDetailId] INT NULL, 
    [dtmSiteLastDelivery] DATETIME NULL, 
    [dblSitePreviousBurnRate] NUMERIC(18, 6) NULL, 
    [dblSiteBurnRate] NUMERIC(18, 6) NULL, 
    [dtmSiteOnHoldStartDate] DATETIME NULL, 
    [dtmSiteOnHoldEndDate] DATETIME NULL, 
    [ysnSiteHoldDDCalculations] BIT NULL, 
    [ysnSiteOnHold] BIT NULL, 
    [dblSiteLastDeliveredGal] NUMERIC(18, 6) NULL, 
    [ysnSiteDeliveryTicketPrinted] BIT NULL, 
    [dblSiteDegreeDayBetweenDelivery] NUMERIC(18, 6) NULL, 
    [intSiteNextDeliveryDegreeDay] INT NULL, 
    [dblSiteLastGalsInTank] NUMERIC(18, 6) NULL, 
    [dblSiteEstimatedPercentLeft] NUMERIC(18, 6) NULL, 
    [dtmSiteLastReadingUpdate] DATETIME NULL, 
    [ysnMeterReading] BIT NOT NULL DEFAULT ((0)), 
    [intWillCallRouteId] INT NULL, 
    [intWillCallDispatchId] INT NULL, 
    [dtmCreatedDate] DATETIME NULL DEFAULT (GETDATE()), 
    [ysnWillCallLeakCheckRequired] BIT NOT NULL DEFAULT 0, 
    [dblWillCallOriginalPercentLeft] NUMERIC(18, 6) NULL, 
    CONSTRAINT [PK_tblTMDeliveryHistory] PRIMARY KEY CLUSTERED ([intDeliveryHistoryID] ASC),
    CONSTRAINT [FK_tblTMDeliveryHistory_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblTMDeliveryHistory_tblLGRoute] FOREIGN KEY ([intWillCallRouteId]) REFERENCES [dbo].[tblLGRoute] ([intRouteId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryHistoryID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bulk Plant No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strBulkPlantNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmInvoiceDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Delivered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strProductDelivered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity Delivered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantityDelivered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DD on Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intDegreeDayOnDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DD on Last Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intDegreeDayOnLastDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Burn Rate After Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblBurnRateAfterDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculated Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblCalculatedBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Adjust Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnAdjustBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Elapsed DD Between last Deliveries',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intElapsedDegreeDaysBetweenDeliveries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Elapsed Days Between last Deliveries',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intElapsedDaysBetweenDeliveries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Winter Daily Usage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWinterDailyUsageBetweenDeliveries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Summer Daily Usage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSummerDailyUsageBetweenDeliveries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gallons in Tank Before Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblGallonsInTankbeforeDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gallons in Tank After Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblGallonsInTankAfterDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated % Before Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblEstimatedPercentBeforeDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Actual % After Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblActualPercentAfterDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblLastMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Updated Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Person',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strSalesPersonID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extended Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblExtendedAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'For Review tag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnForReview'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date marked for review',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmMarkForReviewDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call percent left',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dblWillCallPercentLeft'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call calculated quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWillCallCalculatedQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call desired quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWillCallDesiredQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call driver Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'intWillCallDriverId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call product Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call substitute product Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallSubstituteProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWillCallPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call delivery term Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallDeliveryTermId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call requested date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmWillCallRequestedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call priority',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallPriority'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWillCallTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call comments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strWillCallComments'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call call-in date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dtmWillCallCallInDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call entered by Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'intWillCallUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call Printed Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnWillCallPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call dispatch date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmWillCallDispatch'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call order number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'strWillCallOrderNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intInvoiceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Id used in Will Call',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallContractId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmWillCallDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call Delivery Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dblWillCallDeliveryQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call Delivery Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWillCallDeliveryPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will call Delivery Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblWillCallDeliveryTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Detail Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intInvoiceDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Delivery date  of the site during delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dtmSiteLastDelivery'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Previous Burn rate during delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dblSitePreviousBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Burn rate during delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dblSiteBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site On Hold Start Date during Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dtmSiteOnHoldStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site On Hold End Date during Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmSiteOnHoldEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Hold DD Calculation during Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnSiteHoldDDCalculations'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site On Hold during delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnSiteOnHold'
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Last Delivered Gallons',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSiteLastDeliveredGal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Delivery Ticket Printed Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnSiteDeliveryTicketPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Degree Day Between Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSiteDegreeDayBetweenDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Next Delivery Degree Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intSiteNextDeliveryDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Last Gallons in Tank',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSiteLastGalsInTank'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Estimated Percent Left during delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSiteEstimatedPercentLeft'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Last Reding Update during delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmSiteLastReadingUpdate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicator if record is a Delivery or Virtual Meter Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'ysnMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will Call Route Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallRouteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will Call Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'intWillCallDispatchId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = 'dtmCreatedDate'
GO

CREATE INDEX [IX_tblTMDeliveryHistory_intSiteID] ON [dbo].[tblTMDeliveryHistory] ([intSiteID])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_dtmInvoiceDate] ON [dbo].[tblTMDeliveryHistory] ([dtmInvoiceDate])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_dtmCreatedDate] ON [dbo].[tblTMDeliveryHistory] ([dtmCreatedDate] DESC)

GO

CREATE INDEX [IX_tblTMDeliveryHistory_intWillCallRouteId] ON [dbo].[tblTMDeliveryHistory] ([intWillCallRouteId])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_intInvoiceId] ON [dbo].[tblTMDeliveryHistory] ([intInvoiceId])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_strInvoiceNumber] ON [dbo].[tblTMDeliveryHistory] ([strInvoiceNumber])
    
GO


CREATE INDEX [IX_tblTMDeliveryHistory_intWillCallDispatchId] ON [dbo].[tblTMDeliveryHistory] ([intWillCallDispatchId])


GO

CREATE INDEX [IX_tblTMDeliveryHistory_intWillCallSubstituteProductId] ON [dbo].[tblTMDeliveryHistory] ([intWillCallSubstituteProductId])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_intWillCallDriverId] ON [dbo].[tblTMDeliveryHistory] ([intWillCallDriverId])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_intWillCallUserId] ON [dbo].[tblTMDeliveryHistory] ([intWillCallUserId])

GO

CREATE INDEX [IX_tblTMDeliveryHistory_strWillCallOrderNumber] ON [dbo].[tblTMDeliveryHistory] ([strWillCallOrderNumber])


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Will Call Leak Check Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistory',
    @level2type = N'COLUMN',
    @level2name = N'ysnWillCallLeakCheckRequired'
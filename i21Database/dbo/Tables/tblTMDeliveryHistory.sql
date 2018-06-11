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
	[ysnManualAdjustment] BIT NOT NULL DEFAULT 0
    CONSTRAINT [PK_tblTMDeliveryHistory] PRIMARY KEY CLUSTERED ([intDeliveryHistoryID] ASC),
    CONSTRAINT [FK_tblTMDeliveryHistory_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblTMDeliveryHistory_tblLGRoute] FOREIGN KEY ([intWillCallRouteId]) REFERENCES [dbo].[tblLGRoute] ([intRouteId])
);


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

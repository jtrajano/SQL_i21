﻿CREATE TABLE [dbo].[tblTMSite] (
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
    [dblSummerDailyUse]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblWinterDailyUse]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [ysnTaxable]                  BIT             DEFAULT 0 NULL,
    [intTaxStateID]               INT             DEFAULT 0 NULL,
    [ysnPrintDeliveryTicket]      BIT             DEFAULT 0 NULL,
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
    [ysnPrintARBalance]           BIT             DEFAULT 0 NULL,
    [ysnPromptForPercentFull]     BIT             DEFAULT 0 NULL,
    [strFillGroup]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblBurnRate]                 NUMERIC (18, 6) DEFAULT 0 NULL,
    [strTankTownship]             NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmLastUpdated]              DATETIME        DEFAULT 0 NULL,
    [intLastDeliveryDegreeDay]    INT             DEFAULT 0 NULL,
    [intNextDeliveryDegreeDay]    INT             DEFAULT 0 NULL,
    [ysnDeliveryTicketPrinted]    BIT             DEFAULT 0 NULL,
    [strComment]                  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strInstruction]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strClassFillOption]          NVARCHAR (20)   COLLATE Latin1_General_CI_AS DEFAULT (N'No') NULL,
    [dblLastMeterReading]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [strLocation]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ((0)) NULL,
    [intRoute]                    INT             NULL,
    [dtmLastReadingUpdate]        DATETIME        NULL,
    [intFillGroupID]              INT             NULL,
    [intRouteId]                  INT             NULL,
    [intTankTownshipID]           INT             NULL,
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
    CONSTRAINT [FK_tblTMSite_tblTMSite] FOREIGN KEY ([intParentSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
);


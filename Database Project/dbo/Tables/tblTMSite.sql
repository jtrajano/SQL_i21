﻿CREATE TABLE [dbo].[tblTMSite] (
    [intConcurrencyID]            INT             CONSTRAINT [DEF_tblTMSite_intConcurrencyID] DEFAULT ((0)) NULL,
    [intSiteID]                   INT             IDENTITY (1, 1) NOT NULL,
    [strSiteAddress]              NVARCHAR (1000) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strSiteAddress] DEFAULT ('') NULL,
    [intProduct]                  INT             CONSTRAINT [DEF_tblTMSite_intProduct] DEFAULT ((0)) NULL,
    [intCustomerID]               INT             CONSTRAINT [DEF_tblTMSite_intCustomerID] DEFAULT ((0)) NOT NULL,
    [dblTotalCapacity]            NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblTotalCapacity] DEFAULT ((0)) NULL,
    [ysnOnHold]                   BIT             CONSTRAINT [DEF_tblTMSite_ysnOnHold] DEFAULT ((0)) NULL,
    [ysnActive]                   BIT             CONSTRAINT [DEF_tblTMSite_ysnActive] DEFAULT ((1)) NULL,
    [strDescription]              NVARCHAR (200)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strDescription] DEFAULT ('') NULL,
    [strAcctStatus]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strAcctStatus] DEFAULT ('') NULL,
    [dblPriceAdjustment]          NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblPriceAdjustment] DEFAULT ((0)) NULL,
    [intClockID]                  INT             CONSTRAINT [DEF_tblTMSite_intClockLocno] DEFAULT ((0)) NULL,
    [dblDegreeDayBetweenDelivery] NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblDDBetweenDlvry] DEFAULT ((0)) NULL,
    [dblSummerDailyUse]           NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblSummerDailyUse] DEFAULT ((0)) NULL,
    [dblWinterDailyUse]           NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblWinterDailyUse] DEFAULT ((0)) NULL,
    [ysnTaxable]                  BIT             CONSTRAINT [DEF_tblTMSite_ysnTaxable] DEFAULT ((0)) NULL,
    [intTaxStateID]               INT             CONSTRAINT [DEF_tblTMSite_intTaxStateID] DEFAULT ((0)) NULL,
    [ysnPrintDeliveryTicket]      BIT             CONSTRAINT [DEF_tblTMSite_ysnPrintDlvryTicket] DEFAULT ((0)) NULL,
    [ysnAdjustBurnRate]           BIT             CONSTRAINT [DEF_tblTMSite_ysnAdjustBurnRate] DEFAULT ((0)) NULL,
    [intDriverID]                 INT             CONSTRAINT [DEF_tblTMSite_intDriverID] DEFAULT ((0)) NULL,
    [strRouteID]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strRouteID] DEFAULT ('') NOT NULL,
    [strSequenceID]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strSequenceID] DEFAULT ('') NULL,
    [dblYTDGalsThisSeason]        NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblYTDGalsThisSeason] DEFAULT ((0)) NULL,
    [dblYTDGalsLastSeason]        NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblYTDGalsLastSeason] DEFAULT ((0)) NULL,
    [dtmRunOutDate]               DATETIME        CONSTRAINT [DEF_tblTMSite_dtmRunOutDate] DEFAULT ((0)) NULL,
    [dblEstimatedPercentLeft]     NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblEstimatedPercentLeft] DEFAULT ((0)) NULL,
    [dblConfidenceFactor]         NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblConfidenceFactor] DEFAULT ((0)) NULL,
    [strZipCode]                  NVARCHAR (10)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strZipCode] DEFAULT ('') NULL,
    [strCity]                     NVARCHAR (70)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strCity] DEFAULT ('') NULL,
    [strState]                    NVARCHAR (70)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strState] DEFAULT ('') NULL,
    [dblLatitude]                 NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblLatitude] DEFAULT ((0)) NOT NULL,
    [dblLongitude]                NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblLongitude] DEFAULT ((0)) NOT NULL,
    [intSiteNumber]               INT             CONSTRAINT [DEF_tblTMSite_intSiteNumber] DEFAULT ((0)) NOT NULL,
    [dtmOnHoldStartDate]          DATETIME        CONSTRAINT [DEF_tblTMSite_dtmOnHoldStartDate] DEFAULT ((0)) NULL,
    [dtmOnHoldEndDate]            DATETIME        CONSTRAINT [DEF_tblTMSite_dtmOnHoldEndDate] DEFAULT ((0)) NULL,
    [ysnHoldDDCalculations]       BIT             CONSTRAINT [DEF_tblTMSite_ysnHoldDDCalculations] DEFAULT ((0)) NULL,
    [dblYTDSales]                 NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblYTDSales] DEFAULT ((0)) NULL,
    [intUserID]                   INT             CONSTRAINT [DEF_tblTMSite_intUserID] DEFAULT ((0)) NULL,
    [strBillingBy]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strBillingBy] DEFAULT ('') NULL,
    [dblPreviousBurnRate]         NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblPreviousBurnRate] DEFAULT ((0)) NULL,
    [dblTotalReserve]             NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblTotalReserve] DEFAULT ((0)) NULL,
    [dblLastGalsInTank]           NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblLastGalsInTank] DEFAULT ((0)) NULL,
    [dblLastDeliveredGal]         NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblLastDeliveredGal] DEFAULT ((0)) NULL,
    [intDeliveryTicketNumber]     INT             CONSTRAINT [DEF_tblTMSite_intDeliveryTicketNumber] DEFAULT ((0)) NULL,
    [dblEstimatedGallonsLeft]     NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblEstimatedGallonsLeft] DEFAULT ((0)) NULL,
    [dtmLastDeliveryDate]         DATETIME        CONSTRAINT [DEF_tblTMSite_dtmLastDeliveryDate] DEFAULT ((0)) NULL,
    [dtmNextDeliveryDate]         DATETIME        CONSTRAINT [DEF_tblTMSite_dtmNextDeliveryDate] DEFAULT ((0)) NULL,
    [strCountry]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strCountry] DEFAULT ('') NULL,
    [intFillMethodID]             INT             CONSTRAINT [DEF_tblTMSite_intFillMethodID] DEFAULT ((0)) NULL,
    [intHoldReasonID]             INT             CONSTRAINT [DEF_tblTMSite_intHoldReasonID] DEFAULT ((0)) NULL,
    [dblYTDGals2SeasonsAgo]       NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblYTDGals2SeasonsAgo] DEFAULT ((0)) NULL,
    [intTaxLocale1]               INT             CONSTRAINT [DEF_tblTMSite_intTaxLocale1] DEFAULT ((0)) NULL,
    [intTaxLocale2]               INT             CONSTRAINT [DEF_tblTMSite_intTaxLocale2] DEFAULT ((0)) NULL,
    [ysnAllowPriceChange]         BIT             CONSTRAINT [DEF_tblTMSite_ysnAllowPriceChange] DEFAULT ((0)) NULL,
    [intRecurringPONumber]        INT             CONSTRAINT [DEF_tblTMSite_intRecurringPONumber] DEFAULT ((0)) NULL,
    [ysnPrintARBalance]           BIT             CONSTRAINT [DEF_tblTMSite_ysnPrintARBalance] DEFAULT ((0)) NULL,
    [ysnPromptForPercentFull]     BIT             CONSTRAINT [DEF_tblTMSite_ysnPromptForPercentFull] DEFAULT ((0)) NULL,
    [strFillGroup]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strFillGroup] DEFAULT ('') NULL,
    [dblBurnRate]                 NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblBurnRate] DEFAULT ((0)) NULL,
    [strTankTownship]             NVARCHAR (10)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strTankTownship] DEFAULT ('') NULL,
    [dtmLastUpdated]              DATETIME        CONSTRAINT [DEF_tblTMSite_dtmLastUpdated] DEFAULT ((0)) NULL,
    [intLastDeliveryDegreeDay]    INT             CONSTRAINT [DEF_tblTMSite_intLastDeliveryDegreeDay] DEFAULT ((0)) NULL,
    [intNextDeliveryDegreeDay]    INT             CONSTRAINT [DEF_tblTMSite_intNextDeliveryDegreeDay] DEFAULT ((0)) NULL,
    [ysnDeliveryTicketPrinted]    BIT             CONSTRAINT [DEF_tblTMSite_ysnDeliveryTicketPrinted] DEFAULT ((0)) NULL,
    [strComment]                  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strComment] DEFAULT ('') NULL,
    [strInstruction]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strInstruction] DEFAULT ('') NULL,
    [strClassFillOption]          NVARCHAR (20)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strClassFillOption] DEFAULT (N'No') NULL,
    [dblLastMeterReading]         NUMERIC (18, 6) CONSTRAINT [DEF_tblTMSite_dblLastMeterReading] DEFAULT ((0)) NULL,
    [strLocation]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSite_strLocation] DEFAULT ((0)) NULL,
    [intRoute]                    INT             NULL,
    [dtmLastReadingUpdate]        DATETIME        NULL,
    [intFillGroupID]              INT             NULL,
    [intRouteID]                  INT             NULL,
    [intTankTownshipID]           INT             NULL,
    [dtmForecastedDelivery]       DATETIME        NULL,
    [intParentSiteID]             INT             NULL,
    [intDeliveryTermID]           INT             NULL,
    [dblYTDSalesLastSeason]       NUMERIC (18, 6) NULL,
    [dblYTDSales2SeasonsAgo]      NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblTMSite] PRIMARY KEY CLUSTERED ([intSiteID] ASC),
    CONSTRAINT [FK_tblTMSite_tblTMClock] FOREIGN KEY ([intClockID]) REFERENCES [dbo].[tblTMClock] ([intClockID]),
    CONSTRAINT [FK_tblTMSite_tblTMCustomer] FOREIGN KEY ([intCustomerID]) REFERENCES [dbo].[tblTMCustomer] ([intCustomerID]),
    CONSTRAINT [FK_tblTMSite_tblTMFillMethod] FOREIGN KEY ([intFillMethodID]) REFERENCES [dbo].[tblTMFillMethod] ([intFillMethodID]),
    CONSTRAINT [FK_tblTMSite_tblTMHoldReason] FOREIGN KEY ([intHoldReasonID]) REFERENCES [dbo].[tblTMHoldReason] ([intHoldReasonID]),
    CONSTRAINT [FK_tblTMSite_tblTMSite] FOREIGN KEY ([intParentSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
);


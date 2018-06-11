﻿CREATE TABLE [dbo].[tblTMCOBOLREADSite] (
    [CustomerNumber]       CHAR (10)       CONSTRAINT [DEF_tblTMCOBOLREADSite_CustomerNumber] DEFAULT ((0)) NOT NULL,
    [SiteNumber]           CHAR (4)        CONSTRAINT [DEF_tblTMCOBOLREADSite_SiteNumber] DEFAULT ((0)) NOT NULL,
    [ClockNumber]          CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLREADSite_ClockNumber] DEFAULT ((0)) NULL,
    [SiteAddress]          CHAR (200)      CONSTRAINT [DEF_tblTMCOBOLREADSite_SiteAddress] DEFAULT ((0)) NULL,
    [BillingBy]            CHAR (50)       CONSTRAINT [DEF_tblTMCOBOLREADSite_BillingBy] DEFAULT ((0)) NULL,
    [TotalCapacity]        DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLREADSite_TotalCapacity] DEFAULT ((0)) NULL,
    [ClassFillOption]      CHAR (20)       CONSTRAINT [DEF_tblTMCOBOLREADSite_ClassFillOption] DEFAULT ((0)) NULL,
    [ItemNumber]           CHAR (13)       CONSTRAINT [DEF_tblTMCOBOLREADSite_ItemNumber] DEFAULT ((0)) NULL,
    [Taxable]              CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLREADSite_Taxable] DEFAULT ((0)) NULL,
    [TaxState]             CHAR (2)        CONSTRAINT [DEF_tblTMCOBOLREADSite_TaxState] DEFAULT ((0)) NULL,
    [TaxLocale1]           CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLREADSite_TaxLocale1] DEFAULT ((0)) NULL,
    [TaxLocale2]           CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLREADSite_TaxLocale2] DEFAULT ((0)) NULL,
    [AllowPriceChange]     CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLREADSite_AllowPriceChange] DEFAULT ((0)) NULL,
    [PriceAdjustment]      DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLREADSite_PriceAdjustment] DEFAULT ((0)) NULL,
    [AcctStatus]           CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLREADSite_AcctStatus] DEFAULT ((0)) NULL,
    [PromptForPercentFull] CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLREADSite_PromptForPercentFull] DEFAULT ((0)) NULL,
    [AdjustBurnRate]       CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLREADSite_AdjustBurnRate] DEFAULT ((0)) NULL,
    [RecurringPONumber]    CHAR (15)       CONSTRAINT [DEF_tblTMCOBOLREADSite_RecurringPONumber] DEFAULT ((0)) NULL,
    [LastDeliveryDate]     CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLREADSite_LastDeliveryDate] DEFAULT ((0)) NULL,
    [LastMeterReading]     DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLREADSite_LastMeterReading] DEFAULT ((0)) NULL,
    [MeterType]            CHAR (50)       CONSTRAINT [DEF_tblTMCOBOLREADSite_MeterType] DEFAULT ((0)) NULL,
    [ConversionFactor]     DECIMAL (18, 8) CONSTRAINT [DEF_tblTMCOBOLREADSite_ConversionFactor] DEFAULT ((0)) NULL,
    [Description]          CHAR (200)      CONSTRAINT [DEF_tblTMCOBOLREADSite_Description] DEFAULT ((0)) NULL,
    [SerialNumber]         CHAR (50)       NULL,
    CONSTRAINT [PK_tblTMCOBOLREADSite] PRIMARY KEY CLUSTERED ([CustomerNumber] ASC, [SiteNumber] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_tblTMCOBOLREADSite_CustomerNumber] ON [dbo].[tblTMCOBOLREADSite]([CustomerNumber] ASC)
GO





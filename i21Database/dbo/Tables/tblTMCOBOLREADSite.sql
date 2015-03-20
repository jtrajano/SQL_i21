CREATE TABLE [dbo].[tblTMCOBOLREADSite] (
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
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'CustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'SiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'ClockNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'SiteAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billing By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'BillingBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Total Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'TotalCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Class Fill Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'ClassFillOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'ItemNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'Taxable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'TaxState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Locale 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'TaxLocale1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Locale 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'TaxLocale2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Price Change (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'AllowPriceChange'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Adjustment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'PriceAdjustment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'AcctStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prompt for percent full Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'PromptForPercentFull'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Adjust Burn Rate Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'AdjustBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recurring PO Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'RecurringPONumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'LastDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Meter Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'LastMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'MeterType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Type Conversion Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'ConversionFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serial Number of first tank device attach to site',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSite',
    @level2type = N'COLUMN',
    @level2name = N'SerialNumber'
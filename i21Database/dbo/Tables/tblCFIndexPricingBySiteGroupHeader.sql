CREATE TABLE [dbo].[tblCFIndexPricingBySiteGroupHeader] (
    [intIndexPricingBySiteGroupHeaderId] INT      IDENTITY (1, 1) NOT NULL,
    [intPriceIndexId]                    INT      NULL,
    [dtmDate]                            DATETIME NULL,
    [intSiteGroupId]                     INT      NULL,
    [intConcurrencyId]                   INT      CONSTRAINT [DF_tblCFIndexPricingBySiteGroupHeader_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFIndexPricingBySiteGroupHeader] PRIMARY KEY CLUSTERED ([intIndexPricingBySiteGroupHeaderId] ASC)
);


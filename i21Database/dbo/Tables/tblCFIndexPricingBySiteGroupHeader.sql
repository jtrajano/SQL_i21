CREATE TABLE [dbo].[tblCFIndexPricingBySiteGroupHeader] (
    [intIndexPricingBySiteGroupHeaderId] INT      IDENTITY (1, 1) NOT NULL,
    [intPriceIndexId]                    INT      NULL,
    [dtmDate]                            DATETIME NULL,
    [intSiteGroupId]                     INT      NULL,
    [intConcurrencyId]                   INT      CONSTRAINT [DF_tblCFIndexPricingBySiteGroupHeader_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFIndexPricingBySiteGroupHeader] PRIMARY KEY CLUSTERED ([intIndexPricingBySiteGroupHeaderId] ASC),
    CONSTRAINT [FK_tblCFIndexPricingBySiteGroupHeader_tblCFPriceIndex] FOREIGN KEY ([intPriceIndexId]) REFERENCES [dbo].[tblCFPriceIndex] ([intPriceIndexId]),
    CONSTRAINT [FK_tblCFIndexPricingBySiteGroupHeader_tblCFSiteGroup] FOREIGN KEY ([intSiteGroupId]) REFERENCES [dbo].[tblCFSiteGroup] ([intSiteGroupId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblCFIndexPricingBySiteGroupHeader_dtmDate]
ON [dbo].[tblCFIndexPricingBySiteGroupHeader]([dtmDate] ASC)
GO






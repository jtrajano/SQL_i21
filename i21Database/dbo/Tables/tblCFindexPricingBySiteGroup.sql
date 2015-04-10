CREATE TABLE [dbo].[tblCFindexPricingBySiteGroup] (
    [intIndexPricingBySiteGroupId] INT             NULL,
    [intPriceIndexId]              INT             NULL,
    [intSiteGroupId]               INT             NULL,
    [intARItemID]                  INT             NULL,
    [dtmDate]                      DATETIME        NULL,
    [intTime]                      INT             NULL,
    [dblIndexPrice]                NUMERIC (18, 6) NULL,
    [intConcurrencyId]             INT             CONSTRAINT [DF_tblCFindexPricingBySiteGroup_intConcurrencyId] DEFAULT ((1)) NULL
);


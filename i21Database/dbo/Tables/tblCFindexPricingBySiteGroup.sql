CREATE TABLE [dbo].[tblCFIndexPricingBySiteGroup] (
    [intIndexPricingBySiteGroupId]       INT             IDENTITY (1, 1) NOT NULL,
    [intIndexPricingBySiteGroupHeaderId] INT             NULL,
    [intARItemID]                        INT             NULL,
    [intTime]                            INT             NULL,
    [dblIndexPrice]                      NUMERIC (18, 6) NULL,
    [intConcurrencyId]                   INT             CONSTRAINT [DF_tblCFindexPricingBySiteGroup_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFIndexPricingBySiteGroup] PRIMARY KEY CLUSTERED ([intIndexPricingBySiteGroupId] ASC),
    CONSTRAINT [FK_tblCFIndexPricingBySiteGroup_tblCFIndexPricingBySiteGroupHeader] FOREIGN KEY ([intIndexPricingBySiteGroupHeaderId]) REFERENCES [dbo].[tblCFIndexPricingBySiteGroupHeader] ([intIndexPricingBySiteGroupHeaderId]) ON DELETE CASCADE
);


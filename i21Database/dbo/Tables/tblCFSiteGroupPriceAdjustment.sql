CREATE TABLE [dbo].[tblCFSiteGroupPriceAdjustment] (
    [intSiteGroupPriceAdjustmentId] INT             IDENTITY (1, 1) NOT NULL,
    [intSiteGroupId]                INT             NULL,
    [intARItemId]                   INT             NULL,
    [intPriceGroupId]               INT             NULL,
    [dtmStartEffectiveDate]         DATETIME        NULL,
    [dtmEndEffectiveDate]           DATETIME        NULL,
    [dblRate]                       NUMERIC (18, 6) NULL,
    [intConcurrencyId]              INT             CONSTRAINT [DF_tblCFSiteGroupPriceAdjustment_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSiteGroupPriceAdjustment] PRIMARY KEY CLUSTERED ([intSiteGroupPriceAdjustmentId] ASC),
    CONSTRAINT [FK_tblCFSiteGroupPriceAdjustment_tblCFSiteGroup] FOREIGN KEY ([intSiteGroupId]) REFERENCES [dbo].[tblCFSiteGroup] ([intSiteGroupId])
);




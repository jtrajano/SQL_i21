CREATE TABLE [dbo].[tblCFSiteGroupPriceAdjustment] (
    [intSiteGroupPriceAdjusmentId] INT             NULL,
    [intSiteGroupId]               INT             NULL,
    [intARItemID]                  INT             NULL,
    [intPriceGroupId]              INT             NULL,
    [dtmStartEffectiveDate]        DATETIME        NULL,
    [dtmEndEffectiveDate]          DATETIME        NULL,
    [dblRate]                      NUMERIC (18, 6) NULL,
    [intConcurrencyId]             INT             CONSTRAINT [DF_tblCFSiteGroupPriceAdjustment_intConcurrencyId] DEFAULT ((1)) NULL
);


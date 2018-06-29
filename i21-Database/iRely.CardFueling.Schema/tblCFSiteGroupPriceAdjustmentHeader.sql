CREATE TABLE [dbo].[tblCFSiteGroupPriceAdjustmentHeader] (
    [intSiteGroupPriceAdjustmentHeaderId] INT             IDENTITY (1, 1) NOT NULL,
    [intSiteGroupId]               INT             NOT NULL,
    [dtmEffectiveDate]         DATETIME        NULL,
    [intConcurrencyId]              INT             CONSTRAINT [DF_tblCFSiteGroupPriceAdjustmentHeader_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSiteGroupPriceAdjustmentHeader] PRIMARY KEY CLUSTERED ([intSiteGroupPriceAdjustmentHeaderId] ASC),
    CONSTRAINT [FK_tblCFSiteGroupPriceAdjustmentHeader_tblCFSiteGroup] FOREIGN KEY ([intSiteGroupId]) REFERENCES [dbo].[tblCFSiteGroup] ([intSiteGroupId]),
	CONSTRAINT [UQ_tblCFSiteGroupPriceAdjustmentHeader] UNIQUE ([intSiteGroupId],[dtmEffectiveDate]),
);






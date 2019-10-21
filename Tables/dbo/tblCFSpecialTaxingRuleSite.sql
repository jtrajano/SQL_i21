CREATE TABLE [dbo].[tblCFSpecialTaxingRuleSite] (
    [intSpecialTaxingRuleSiteId] INT IDENTITY (1, 1) NOT NULL,
    [intSpecialTaxingRuleId]     INT NULL,
    [intSiteId]                  INT NULL,
    [intSiteGroupId]             INT NULL,
    [intConcurrencyId]           INT CONSTRAINT [DF_tblCFSpecialTaxingRuleSite_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSpecialTaxingRuleSite] PRIMARY KEY CLUSTERED ([intSpecialTaxingRuleSiteId] ASC),
    CONSTRAINT [FK_tblCFSpecialTaxingRuleSite_tblCFSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblCFSite] ([intSiteId]),
    CONSTRAINT [FK_tblCFSpecialTaxingRuleSite_tblCFSiteGroup] FOREIGN KEY ([intSiteGroupId]) REFERENCES [dbo].[tblCFSiteGroup] ([intSiteGroupId]),
    CONSTRAINT [FK_tblCFSpecialTaxingRuleSite_tblCFSpecialTaxingRuleHeader] FOREIGN KEY ([intSpecialTaxingRuleId]) REFERENCES [dbo].[tblCFSpecialTaxingRuleHeader] ([intSpecialTaxingRuleId]) ON DELETE CASCADE
);


CREATE TABLE [dbo].[tblCFSpecialTaxingRuleTax] (
    [intSpecialTaxingRuleTaxId] INT IDENTITY (1, 1) NOT NULL,
    [intSpecialTaxingRuleId]    INT NULL,
    [intTaxCodeId]              INT NULL,
    [intConcurrencyId]          INT CONSTRAINT [DF_tblCFSpecialTaxingRuleTax_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSpecialTaxingRuleTax] PRIMARY KEY CLUSTERED ([intSpecialTaxingRuleTaxId] ASC),
    CONSTRAINT [FK_tblCFSpecialTaxingRuleTax_tblCFSpecialTaxingRuleHeader] FOREIGN KEY ([intSpecialTaxingRuleId]) REFERENCES [dbo].[tblCFSpecialTaxingRuleHeader] ([intSpecialTaxingRuleId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFSpecialTaxingRuleTax_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId])
);


CREATE TABLE [dbo].[tblCFSpecialTaxingRuleHeader] (
    [intSpecialTaxingRuleId] INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strType]                NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblCFSpecialTaxingRuleHeader_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSpecialTaxingRuleHeader] PRIMARY KEY CLUSTERED ([intSpecialTaxingRuleId] ASC)
);


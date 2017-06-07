CREATE TABLE [dbo].[tblCFPriceRuleGroup] (
    [intPriceRuleGroupId]      INT            IDENTITY (1, 1) NOT NULL,
    [strPriceGroup]            NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strPriceGroupDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]         INT            CONSTRAINT [DF_tblCFPriceRuleGroup_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFPriceRuleGroup] PRIMARY KEY CLUSTERED ([intPriceRuleGroupId] ASC)
);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFPriceRuleGroup_UniquePriceGroup
	ON tblCFPriceRuleGroup (strPriceGroup);

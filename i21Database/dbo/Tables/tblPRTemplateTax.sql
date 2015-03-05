CREATE TABLE [dbo].[tblPRTemplateTax] (
    [intTemplateTaxId]    INT             IDENTITY (1, 1) NOT NULL,
    [intTemplateId]       INT             NOT NULL,
    [intTypeTaxId]        INT             NOT NULL,
    [strCalculationType]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFilingStatus]     NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intTypeTaxStateId]   INT             NULL,
    [intTypeTaxLocalId]   INT             NULL,
    [dblAmount]           NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblExtraWithholding] NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblLimit]            NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [intAccountId]        INT             NULL,
    [intExpenseAccountId] INT             NULL,
    [intAllowance]        INT             DEFAULT ((0)) NULL,
    [strPaidBy]           NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [strVal1]             NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [strVal2]             NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [strVal3]             NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [strVal4]             NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [strVal5]             NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [strVal6]             NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [ysnDefault]          BIT             DEFAULT ((1)) NULL,
    [intSort]             INT             NULL,
    [intConcurrencyId]    INT             DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPRTemplateTax] PRIMARY KEY CLUSTERED ([intTemplateTaxId] ASC),
    CONSTRAINT [FK_tblPRTemplateTax_tblPREmployee] FOREIGN KEY ([intTemplateId]) REFERENCES [dbo].[tblPRTemplate] ([intTemplateId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPRTemplateTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [dbo].[tblPRTypeTax] ([intTypeTaxId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Filing Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strFilingStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type State Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Locality Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxLocalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extra Withholding',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'dblExtraWithholding'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Liability Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intExpenseAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Federal Allowances',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intAllowance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 5',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal5'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 6',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal6'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
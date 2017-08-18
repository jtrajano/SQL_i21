﻿CREATE TABLE [dbo].[tblPRTemplateEarning](
	[intTemplateEarningId] [int] IDENTITY(1,1) NOT NULL,
	[intTemplateId] INT NOT NULL, 
	[intTypeEarningId] INT NOT NULL,
	[strCalculationType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblDefaultHours] [numeric](18, 6) NULL DEFAULT ((0)),
	[intAccountId] INT NULL,
	[intTaxCalculationType] INT NULL DEFAULT ((0)),
	[strW2Code] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTemplateTimeOffId] [int] NULL,
	[intTemplateAccrueTimeOffId] [int] NULL,
	[intTemplateEarningLinkId] [int] NULL,
	[intPayGroupId] INT NULL,
	[ysnDefault] [bit] NOT NULL DEFAULT ((1)),
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTemplateEarning] PRIMARY KEY ([intTemplateEarningId]), 
    CONSTRAINT [FK_tblPRTemplateEarning_tblPRTypeEarning] FOREIGN KEY ([intTypeEarningId]) REFERENCES [tblPRTypeEarning]([intTypeEarningId]), 
	CONSTRAINT [FK_tblPRTemplateEarning_tblPRTemplate] FOREIGN KEY ([intTemplateId]) REFERENCES [tblPRTemplate]([intTemplateId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPRTemplateEarning_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
) ON [PRIMARY]
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = 'intTypeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'W2 Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'strW2Code'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = 'intTemplateTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = 'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTemplateEarning] ON [dbo].[tblPRTemplateEarning] ([intTemplateEarningId], [intTypeEarningId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = 'intTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = 'intTemplateEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Linked Template Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateEarningLinkId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accrue Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateAccrueTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intPayGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTaxCalculationType'
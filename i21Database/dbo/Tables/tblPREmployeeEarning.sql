CREATE TABLE [dbo].[tblPREmployeeEarning](
	[intEmployeeEarningId] [int] NOT NULL IDENTITY,
	[intEmployeeId] [int] NOT NULL,
	[intEarningTypeId] [int] NOT NULL,
	[strCalculationType] [nvarchar](50) NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblDefaultHours] [numeric](18, 6) NULL DEFAULT ((0)),
	[strW2Code] [nvarchar](50) NULL,
	[intAccountId] INT NULL,
	[ysnTimeOff] [bit] NULL DEFAULT ((0)),
	[intTimeOffTypeId] [int] NULL,
	[ysnActive] [bit] NULL DEFAULT ((1)),
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployeeEarning] PRIMARY KEY ([intEmployeeEarningId]), 
    CONSTRAINT [FK_tblPREmployeeEarning_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [tblPREmployee]([intEmployeeId]), 
    CONSTRAINT [FK_tblPREmployeeEarning_tblPREarningType] FOREIGN KEY ([intEarningTypeId]) REFERENCES [tblPREarningType]([intEarningTypeId]),
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeEarning] ON [dbo].[tblPREmployeeEarning] ([intEmployeeId], [intEarningTypeId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intEarningTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'W2 Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strW2Code'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning is a Time Off',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'ysnTimeOff'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTimeOffTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
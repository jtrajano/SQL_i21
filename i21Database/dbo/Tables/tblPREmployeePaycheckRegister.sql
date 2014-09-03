CREATE TABLE [dbo].[tblPREmployeePaycheckRegister](
	[intEmployeePaycheckRegisterId] [int] NOT NULL IDENTITY,
	[strCheckNumber] [nvarchar](50) NOT NULL,
	[intPaycheckId] INT NOT NULL,
	[strDescription] [nvarchar](255) NULL DEFAULT ((0)),
	[dblTotal] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblGross] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblNet] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblTax] [numeric](18, 6) NULL DEFAULT ((0)),
	[dtmPayDate] [datetime] NOT NULL,
	[ysnVoid] [bit] NULL DEFAULT ((0)),
	[strCustomerType] [nvarchar](50) NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployeePaycheckRegister] PRIMARY KEY ([intEmployeePaycheckRegisterId]), 
    CONSTRAINT [FK_tblPREmployeePaycheckRegister_tblPRPaycheck] FOREIGN KEY ([intPaycheckId]) REFERENCES [tblPRPaycheck]([intPaycheckId]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeePaycheckRegisterId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'strCheckNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'dblTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'dblGross'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'dblNet'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'dblTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'dtmPayDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Void',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'ysnVoid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeePaycheckRegister',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
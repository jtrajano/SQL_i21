CREATE TABLE [dbo].[tblPRPaycheckEarning](
	[intPaycheckEarningId] [int] IdENTITY(1,1) NOT NULL,
	[intPaycheckId] INT NOT NULL,
	[intEmployeeEarningId] INT NULL,
	[intTypeEarningId] INT NULL,
	[strCalculationType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblHours] [numeric](18, 6) NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[dblTotal] [numeric](18, 6) NULL,
	[strW2Code] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[intEmployeeDepartmentId] INT NULL,
	[intWorkersCompensationId] INT NULL,
	[intEmployeeTimeOffId] INT NULL,
	[intEmployeeEarningLinkId] INT NULL,
	[intAccountId] INT NOT NULL,
	[intTaxCalculationType] INT NULL DEFAULT ((0)),
	[intSort] [int] NULL,
	[intTimeOffRequestId] [int] NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblPRPaycheckEarning] PRIMARY KEY ([intPaycheckEarningId]),
	CONSTRAINT [FK_tblPRPaycheckEarning_tblPRPaycheck] FOREIGN KEY ([intPaycheckId]) REFERENCES [tblPRPaycheck]([intPaycheckId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPRPaycheckEarning_tblPRTypeEarning] FOREIGN KEY ([intTypeEarningId]) REFERENCES [dbo].[tblPRTypeEarning] ([intTypeEarningId]),
	CONSTRAINT [FK_tblPRPaycheckEarning_tblPRDepartment] FOREIGN KEY ([intEmployeeDepartmentId]) REFERENCES [dbo].[tblPRDepartment] ([intDepartmentId]),
	CONSTRAINT [FK_tblPRPaycheckEarning_tblPRWorkersCompensation] FOREIGN KEY ([intWorkersCompensationId]) REFERENCES [dbo].[tblPRWorkersCompensation] ([intWorkersCompensationId])
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__dblHo__244DAE7E]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [dblHours]
GO
/****** Object:  Default [DF__tblPRPayc__dblAm__2541D2B7]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [dblAmount]
GO
/****** Object:  Default [DF__tblPRPayc__dblTo__2635F6F0]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [dblTotal]
GO
/****** Object:  Default [DF__tblPRPayc__ysnTi__272A1B29]    Script Date: 08/14/2014 10:50:11 ******/

GO
/****** Object:  Default [DF__tblPRPayc__intCo__281E3F62]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = 'intEmployeeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount/Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'W2 Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'strW2Code'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Time Off Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Linked Employee Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeEarningLinkId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Department',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Workers Compensation Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intWorkersCompensationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTaxCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Request Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTimeOffRequestId'
CREATE TABLE [dbo].[tblPRPaycheckDeduction](
	[intPaycheckDeductionId] [int] IDENTITY(1,1) NOT NULL,
	[intPaycheckId] [int] NOT NULL,
	[intEmployeeDeductionId] INT NOT NULL,
	[strDeductFrom] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strCalculationType] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[dblLimit] [numeric](18, 6) NULL,
	[dblTotal] [numeric](18, 6) NULL,
	[dtmBeginDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[intAccountId] INT NULL,
	[strPaidBy] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[ysnSet] [bit] NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblPRPaycheckDeduction] PRIMARY KEY ([intPaycheckDeductionId]),
	CONSTRAINT [FK_tblPRPaycheckDeduction_tblPRPaycheck] FOREIGN KEY ([intPaycheckId]) REFERENCES [tblPRPaycheck]([intPaycheckId]) ON DELETE CASCADE, 
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__dblAm__2FBF612A]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblAmount]
GO
/****** Object:  Default [DF__tblPRPayc__dblPe__30B38563]    Script Date: 08/14/2014 10:50:11 ******/

GO
/****** Object:  Default [DF__tblPRPayc__dblLi__31A7A99C]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblLimit]
GO
/****** Object:  Default [DF__tblPRPayc__dblTo__329BCDD5]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblTotal]
GO
/****** Object:  Default [DF__tblPRPayc__ysnSe__338FF20E]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [ysnSet]
GO
/****** Object:  Default [DF__tblPRPayc__strPa__34841647]    Script Date: 08/14/2014 10:50:11 ******/

GO
/****** Object:  Default [DF__tblPRPayc__intCo__35783A80]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Deduction Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strDeductFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount/Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Begin Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeginDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Liability Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Manually Set',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'ysnSet'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
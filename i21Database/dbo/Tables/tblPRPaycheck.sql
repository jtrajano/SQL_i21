CREATE TABLE [dbo].[tblPRPaycheck](
	[intPaycheckId] [int] NOT NULL IDENTITY,
	[strPaycheckId] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEmployeeId] INT NOT NULL,
	[dtmPayDate] [datetime] NOT NULL,
	[strPayPeriod] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateFrom] [datetime] NOT NULL,
	[dtmDateTo] [datetime] NOT NULL,
	[intBankAccountId] INT NULL,
	[strReferenceNo] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] [numeric](18, 6) NULL,
	[dblAdjustedGross] [numeric](18, 6) NULL,
	[dblTaxTotal] [numeric](18, 6) NULL,
	[dblDeductionTotal] [numeric](18, 6) NULL,
	[dblNetPayTotal] [numeric](18, 6) NULL,
	[dblCompanyTaxTotal] [numeric](18, 6) NULL,
	[dtmPosted] [datetime] NULL,
	[ysnPosted] [bit] NOT NULL,
	[ysnPrinted] [bit] NOT NULL,
	[ysnVoid] [bit] NOT NULL,
	[ysnDirectDeposit] [bit] NOT NULL,
	[dtmCreated] [datetime] NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblPRPaycheck] PRIMARY KEY CLUSTERED ([intPaycheckId]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [FK_tblPRPaycheck_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [tblPREmployee]([intEmployeeId]),
 CONSTRAINT [FK_tblPRPaycheck_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId])
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__ysnGL__3D195C48]    Script Date: 08/14/2014 10:50:11 ******/

GO
/****** Object:  Default [DF__tblPRPayc__dtmDa__3E0D8081]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmDateFrom]
GO
/****** Object:  Default [DF__tblPRPayc__dtmDa__3F01A4BA]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmDateTo]
GO
/****** Object:  Default [DF__tblPRPayc__dtmPa__3FF5C8F3]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmPayDate]
GO
/****** Object:  Default [DF__tblPRPayc__dblGr__40E9ED2C]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblGross]
GO
/****** Object:  Default [DF__tblPRPayc__dblAd__41DE1165]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblAdjustedGross]
GO
/****** Object:  Default [DF__tblPRPayc__dblTa__42D2359E]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblTaxTotal]
GO
/****** Object:  Default [DF__tblPRPayc__dblDe__43C659D7]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblDeductionTotal]
GO
/****** Object:  Default [DF__tblPRPayc__dblLi__44BA7E10]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblCompanyTaxTotal]
GO
/****** Object:  Default [DF__tblPRPayc__dblNe__45AEA249]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblNetPayTotal]
GO
/****** Object:  Default [DF__tblPRPayc__ysnVo__46A2C682]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnVoid]
GO
/****** Object:  Default [DF__tblPRPayc__ysnPo__4796EABB]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnPosted]
GO
/****** Object:  Default [DF__tblPRPayc__ysnPr__488B0EF4]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnPrinted]
GO
/****** Object:  Default [DF__tblPRPayc__ysnDi__497F332D]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnDirectDeposit]
GO
/****** Object:  Default [DF__tblPRPayc__dtmCr__4A735766]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmCreated]
GO
/****** Object:  Default [DF__tblPRPayc__intCo__4B677B9F]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO
/****** Object:  Default [DF__tblPRPayc__ysnTo__4C5B9FD8]    Script Date: 08/14/2014 10:50:11 ******/

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'strPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dtmPayDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'strPayPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bank Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'intBankAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'strReferenceNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Pay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dblGross'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Adjusted Gross',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dblAdjustedGross'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deductions',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dblDeductionTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net Pay/Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dblNetPayTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Taxes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dblCompanyTaxTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Posted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dtmPosted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Posted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'ysnPosted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Check Printed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Void',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'ysnVoid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Direct Deposit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'ysnDirectDeposit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheck',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
CREATE TABLE [dbo].[tblPRForm941]
(
	[intForm941Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intYear] INT NULL, 
    [intQuarter] INT NULL, 
    [intEmployees] INT NULL DEFAULT ((0)), 
    [dblAdjustedGross] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFIT] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnNoTaxable] BIT NULL DEFAULT ((0)), 
    [dblTaxableSS] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTaxableSSTips] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTaxableMed] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblTaxableAddMed] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTaxDueUnreported] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblAdjustFractionCents] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblAdjustSickPay] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblAdjustTips] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTotalDeposit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[ysnRefundOverpayment] BIT NULL DEFAULT ((0)),
    [intScheduleType] INT NULL DEFAULT ((0)), 
	[dblMonth1] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblMonth2] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblMonth3] NUMERIC(18, 6) NULL DEFAULT ((0)),
    [ysnStoppedWages] BIT NULL DEFAULT ((0)), 
    [dtmStoppedWages] DATETIME NULL, 
    [ysnSeasonalEmployer] BIT NULL DEFAULT ((0)), 
    [ysnAllowContactDesignee] BIT NULL DEFAULT ((0)), 
    [strDesigneeName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strDesigneePhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDesigneePIN] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strTitle] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [dtmSignDate] DATETIME NULL, 
    [strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnSelfEmployed] BIT NULL DEFAULT ((0)), 
    [strPreparerName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerPTIN] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerFirmName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerEIN] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [dtmPreparerSignDate] DATETIME NULL, 
    [strPreparerAddress] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerState] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerZip] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strPreparerPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblPaymentDollars] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblPaymentCents] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1))
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'intForm941Id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Year',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'intYear'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quarter',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'intQuarter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employees',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'intEmployees'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Adjusted Gross',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblAdjustedGross'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Withheld',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblFIT'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'No taxable wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'ysnNoTaxable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable SS Wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableSS'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable SS Tips',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableSSTips'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable Medicare',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableMed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Due on unreported Tips',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxDueUnreported'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fraction of Cents',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblAdjustFractionCents'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sick Pay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblAdjustSickPay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tips and Life Insurance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblAdjustTips'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total Deposits',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblTotalDeposit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deposit Schedule Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'intScheduleType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Send a Refund',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'ysnRefundOverpayment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stopped paying wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'ysnStoppedWages'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Stopped paying wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dtmStoppedWages'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Seasonal Employer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'ysnSeasonalEmployer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Third Party Designee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowContactDesignee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Designee Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strDesigneeName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Designee Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strDesigneePhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'5-Digit PIN',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strDesigneePIN'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Title',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strTitle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Signature Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dtmSignDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Best Day Time Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Self Employed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'ysnSelfEmployed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preparers Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'PTIN',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerPTIN'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Firms Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerFirmName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EIN',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerEIN'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preparers Signature Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dtmPreparerSignDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerZip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'strPreparerPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Payment Dollar',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblPaymentDollars'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Payment Cents',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblPaymentCents'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Month 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblMonth1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Month 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblMonth2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Month 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblMonth3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable Additional Medicare',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRForm941',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableAddMed'
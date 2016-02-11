CREATE TABLE [dbo].[tblPRPaycheckDirectDeposit]
(
	[intPaycheckDirectDepositId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPaycheckId] INT NOT NULL, 
    [dtmDate] DATETIME NULL, 
    [intBankId] INT NULL, 
    [strAccountNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDistributionType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [dblAmount] NUMERIC(18, 6) NULL, 
    [dblAllocation] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPRPaycheckDirectDeposit_tblPRPaycheck] FOREIGN KEY ([intPaycheckId]) REFERENCES [tblPRPaycheck]([intPaycheckId]) ON DELETE CASCADE,
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckDirectDepositId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bank Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intBankId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'strAccountNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Distribution Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'strDistributionType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allocation',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'dblAllocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
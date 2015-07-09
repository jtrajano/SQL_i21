CREATE TABLE [dbo].[tblPREmployeeDirectDeposit]
(
	[intEmployeeDirectDepositId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEmployeeId] INT NOT NULL, 
    [intBankId] INT NULL, 
    [strBankAccountNumber] NVARCHAR(50) NULL, 
    [strABARoutingNumber] NVARCHAR(50) NULL, 
    [strAccountType] NVARCHAR(20) NULL, 
    [strPreNote] NVARCHAR(20) NULL, 
    [dblAmount] NUMERIC(18, 6) NULL, 
    [intSort] INT NULL DEFAULT ((1)), 
    [ysnActive] BIT NULL DEFAULT ((1)), 
    [intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPREmployeeDirectDeposit_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEmployeeId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDirectDepositId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bank Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = 'intBankId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bank Account Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'strBankAccountNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ABA Routing Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'strABARoutingNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'strAccountType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pre Note',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'strPreNote'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount or Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDirectDeposit',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
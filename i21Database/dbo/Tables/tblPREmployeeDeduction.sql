﻿CREATE TABLE [dbo].[tblPREmployeeDeduction] (
    [intEmployeeDeductionId] INT             IDENTITY (1, 1) NOT NULL,
    [intEntityEmployeeId]    INT             NOT NULL,
    [intTypeDeductionId]     INT             NOT NULL,
    [strDeductFrom]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCalculationType]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]              NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLimit]               NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
	[dblPaycheckMax]		 NUMERIC (18, 6) NULL DEFAULT ((0)),
	[strPaycheckMaxType]	 NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Fixed'),
    [dtmBeginDate]           DATETIME        NULL,
    [dtmEndDate]             DATETIME        NULL,
    [intAccountId]           INT             NULL,
	[intExpenseAccountId]	 INT			 NULL,
    [strPaidBy]              NVARCHAR (15)   COLLATE Latin1_General_CI_AS DEFAULT ('Employee') NOT NULL,
    [ysnDefault]             BIT             DEFAULT ((1)) NOT NULL,
    [intSort]                INT             NULL,
    [intConcurrencyId]       INT             DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPREmployeeDeduction] PRIMARY KEY CLUSTERED ([intEmployeeDeductionId] ASC),
    CONSTRAINT [FK_tblPREmployeeDeduction_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblPREmployeeDeduction_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPREmployeeDeduction_tblPRTypeDeduction] FOREIGN KEY ([intTypeDeductionId]) REFERENCES [dbo].[tblPRTypeDeduction] ([intTypeDeductionId])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeDeduction] ON [dbo].[tblPREmployeeDeduction] ([intEntityEmployeeId], [intTypeDeductionId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intEntityEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intTypeDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strDeductFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Begin Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeginDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intExpenseAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = 'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
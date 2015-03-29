CREATE TABLE [dbo].[tblPREmployeeEarning] (
    [intEmployeeEarningId] INT             IDENTITY (1, 1) NOT NULL,
    [intEmployeeId]        INT             NOT NULL,
    [intTypeEarningId]     INT             NOT NULL,
    [strCalculationType]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]            NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblDefaultHours]      NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [intAccountId]         INT             NULL,
    [strW2Code]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intEmployeeTimeOffId] INT             NULL,
    [ysnDefault]           BIT             DEFAULT ((1)) NOT NULL,
    [intSort]              INT             NULL,
    [intConcurrencyId]     INT             DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPREmployeeEarning] PRIMARY KEY CLUSTERED ([intEmployeeEarningId] ASC),
    CONSTRAINT [FK_tblPREmployeeEarning_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblPREmployeeEarning_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEmployeeId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPREmployeeEarning_tblPRTypeEarning] FOREIGN KEY ([intTypeEarningId]) REFERENCES [dbo].[tblPRTypeEarning] ([intTypeEarningId])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeEarning] ON [dbo].[tblPREmployeeEarning] ([intEmployeeId], [intTypeEarningId]) WITH (IGNORE_DUP_KEY = OFF)

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
    @level2name = N'intTypeEarningId'
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
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = 'intEmployeeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarning',
    @level2type = N'COLUMN',
    @level2name = 'ysnDefault'
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
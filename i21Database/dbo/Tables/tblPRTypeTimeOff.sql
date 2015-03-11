CREATE TABLE [dbo].[tblPRTypeTimeOff] (
    [intTypeTimeOffId] INT             IDENTITY (1, 1) NOT NULL,
    [strTimeOff]       NVARCHAR (30)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intTypeEarningId] INT             NULL,
    [dtmEligible]      DATETIME        NULL,
    [dblRate]          NUMERIC (18, 6) CONSTRAINT [DF__tblPRType__dblRa__4814B122] DEFAULT ((0)) NULL,
    [dblPerPeriod]     NUMERIC (18, 6) CONSTRAINT [DF__tblPRType__dblPe__4908D55B] DEFAULT ((0)) NULL,
    [strPeriod]        NVARCHAR (30)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tblPRType__strPe__49FCF994] DEFAULT ((0)) NULL,
    [strAwardPeriod]   NVARCHAR (30)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tblPRType__strAw__4AF11DCD] DEFAULT ((0)) NULL,
    [dblMaxEarned]     NUMERIC (18, 6) CONSTRAINT [DF__tblPRType__dblMa__4BE54206] DEFAULT ((0)) NULL,
    [dblMaxCarryover]  NUMERIC (18, 6) CONSTRAINT [DF__tblPRType__dblMa__4CD9663F] DEFAULT ((0)) NULL,
    [intAccountId]     INT             NULL,
    [intSort]          INT             NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF__tblPRType__intCo__4DCD8A78] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPRTypeTimeOff] PRIMARY KEY CLUSTERED ([intTypeTimeOffId] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTypeTimeOff] ON [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId], [strTimeOff]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strTimeOff'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Award Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strAwardPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblMaxCarryover'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxEarned'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Liability Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Eligible Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningId'
CREATE TABLE [dbo].[tblPRTemplateTimeOff] (
    [intTemplateTimeOffId] INT             IDENTITY (1, 1) NOT NULL,
    [intTemplateId]        INT             NOT NULL,
    [intTypeTimeOffId]     INT             NOT NULL,
    [dblRate]              NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblPerPeriod]         NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [strPeriod]            NVARCHAR (30)   COLLATE Latin1_General_CI_AS DEFAULT ((0)) NULL,
    [strAwardPeriod]       NVARCHAR (30)   COLLATE Latin1_General_CI_AS DEFAULT ((0)) NULL,
    [dblMaxCarryover]      NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblMaxEarned]         NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dtmEligible]          DATETIME        DEFAULT (getdate()) NULL,
    [intSort]              INT             NULL,
    [intConcurrencyId]     INT             DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPRTemplateTimeOff] PRIMARY KEY CLUSTERED ([intTemplateTimeOffId] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTemplateTimeOff] ON [dbo].[tblPRTemplateTimeOff] ([intTemplateTimeOffId], [intTypeTimeOffId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateTimeOffId'
GO

GO

GO

GO

GO

GO

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time-Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Award Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strAwardPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxCarryover'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Eligible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxEarned'
CREATE TABLE [dbo].[tblPREmployeeTimeOff] (
    [intEmployeeTimeOffId] INT             IDENTITY (1, 1) NOT NULL,
    [intEmployeeId]        INT             NOT NULL,
    [intTypeTimeOffId]     INT             NOT NULL,
    [dblRate]              NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblRa__73341951] DEFAULT ((0)) NULL,
    [dblPerPeriod]         NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblPe__74283D8A] DEFAULT ((0)) NULL,
    [strPeriod]            NVARCHAR (30)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tblPREmpl__strPe__751C61C3] DEFAULT ((0)) NULL,
    [strAwardPeriod]       NVARCHAR (30)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tblPREmpl__strAw__761085FC] DEFAULT ((0)) NULL,
    [dblMaxCarryover]      NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblMa__7704AA35] DEFAULT ((0)) NULL,
    [dblMaxEarned]         NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblMa__77F8CE6E] DEFAULT ((0)) NULL,
    [dtmLastAward]         DATETIME        NULL,
    [dblHoursAccrued]      NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblHo__78ECF2A7] DEFAULT ((0)) NULL,
    [dblHoursEarned]       NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblHo__79E116E0] DEFAULT ((0)) NULL,
    [dblHoursUsed]         NUMERIC (18, 6) CONSTRAINT [DF__tblPREmpl__dblHo__7AD53B19] DEFAULT ((0)) NULL,
    [dtmEligible]          DATETIME        CONSTRAINT [DF__tblPREmpl__dtmEl__7BC95F52] DEFAULT (getdate()) NULL,
    [intSort]              INT             NULL,
    [intConcurrencyId]     INT             CONSTRAINT [DF__tblPREmpl__intCo__7CBD838B] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPREmployeeTimeOff] PRIMARY KEY CLUSTERED ([intEmployeeTimeOffId] ASC),
    CONSTRAINT [FK_tblPREmployeeTimeOff_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEmployeeId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblPREmployeeTimeOff_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId])
);




GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeTimeOff] ON [dbo].[tblPREmployeeTimeOff] ([intEmployeeId], [intTypeTimeOffId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Eligible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Award Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strAwardPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxCarryover'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Award Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastAward'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Accrued',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursAccrued'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursEarned'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursUsed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxEarned'
CREATE TABLE [dbo].[tblPRTypeTimeOff] (
    [intTypeTimeOffId] INT             IDENTITY (1, 1) NOT NULL,
    [strTimeOff]       NVARCHAR (30)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strAwardPeriod]   NVARCHAR (30)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tblPRType__strAw__4AF11DCD] DEFAULT ((0)) NULL,
    [intSort]          INT             NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF__tblPRType__intCo__4DCD8A78] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPRTypeTimeOff] PRIMARY KEY CLUSTERED ([intTypeTimeOffId] ASC),
	CONSTRAINT [AK_tblPRTypeTimeOff_strTimeOff] UNIQUE ([strTimeOff])
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

GO

GO

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

GO

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

GO

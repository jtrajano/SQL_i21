CREATE TABLE [dbo].[tblPRDepartment] (
    [intDepartmentId]  INT           IDENTITY (1, 1) NOT NULL,
    [strDepartment]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intProfitCenter]  INT           NULL,
    [intLOB]		   INT           NULL,
	[strDifferentialPay] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL DEFAULT (('Actual')), 
    [intSort]          INT           NULL,
    [intConcurrencyId] INT           DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblPRDepartment] PRIMARY KEY CLUSTERED ([intDepartmentId] ASC),
    UNIQUE NONCLUSTERED ([strDepartment] ASC)
);



GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'strDepartment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Profit Center',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intProfitCenter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intLOB'
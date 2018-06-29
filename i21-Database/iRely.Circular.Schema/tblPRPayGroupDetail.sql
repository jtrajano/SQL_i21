CREATE TABLE [dbo].[tblPRPayGroupDetail]
(
	[intPayGroupDetailId]		INT				NOT NULL IDENTITY,
	[intPayGroupId]				INT				NOT NULL,
    [intEntityEmployeeId]		INT             NOT NULL,
	[intEmployeeEarningId]		INT             NOT NULL,
    [intTypeEarningId]			INT             NOT NULL,
	[intDepartmentId]			INT             NULL,
	[intWorkersCompensationId]	INT             NULL,
    [strCalculationType]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[dblDefaultHours]			NUMERIC (18, 6) DEFAULT ((0)) NULL,
	[dblHoursToProcess]			NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblAmount]					NUMERIC (18, 6) DEFAULT ((0)) NULL,
	[dblTotal]					NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dtmDateFrom]				DATETIME        NULL,
	[dtmDateTo]					DATETIME        NULL,
	[intSource]					INT             NULL DEFAULT ((0)),
	[intSort]					INT             NULL DEFAULT ((1)),
    [intConcurrencyId]			INT             DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblPRPayGroupDetail] PRIMARY KEY CLUSTERED ([intPayGroupDetailId] ASC),
	CONSTRAINT [FK_tblPRPayGroupDetail_tblPRPayGroup] FOREIGN KEY ([intPayGroupId]) REFERENCES [dbo].[tblPRPayGroup] ([intPayGroupId]),
	CONSTRAINT [FK_tblPRPayGroupDetail_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEntityId]),
	CONSTRAINT [FK_tblPRPayGroupDetail_tblPREmployeeEarning] FOREIGN KEY ([intEmployeeEarningId]) REFERENCES [dbo].[tblPREmployeeEarning] ([intEmployeeEarningId]),
	CONSTRAINT [FK_tblPRPayGroupDetail_tblPRTypeEarning] FOREIGN KEY ([intTypeEarningId]) REFERENCES [dbo].[tblPRTypeEarning] ([intTypeEarningId]),
	CONSTRAINT [FK_tblPRPayGroupDetail_tblPRDepartment] FOREIGN KEY ([intDepartmentId]) REFERENCES [dbo].[tblPRDepartment] ([intDepartmentId]),
	CONSTRAINT [FK_tblPRPayGroupDetail_tblPRWorkersCompensation] FOREIGN KEY ([intWorkersCompensationId]) REFERENCES [dbo].[tblPRWorkersCompensation] ([intWorkersCompensationId])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intPayGroupDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intPayGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intEntityEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours To Process',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursToProcess'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Workers Compensation Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intWorkersCompensationId'
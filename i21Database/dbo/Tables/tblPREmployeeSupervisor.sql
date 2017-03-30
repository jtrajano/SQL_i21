CREATE TABLE [dbo].[tblPREmployeeSupervisor]
(
	[intEmployeeSupervisorId] INT NOT NULL IDENTITY, 
    [intEntityEmployeeId] INT NOT NULL, 
    [intSupervisorId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblPREmployeeSupervisor] PRIMARY KEY ([intEmployeeSupervisorId]),
	CONSTRAINT [FK_tblPREmployeeSupervisor_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [tblPREmployee]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPREmployeeSupervisor_tblPREmployee_Supervisor] FOREIGN KEY ([intSupervisorId]) REFERENCES [tblPREmployee]([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeSupervisor',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeSupervisorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeSupervisor',
    @level2type = N'COLUMN',
    @level2name = N'intEntityEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Supervisor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeSupervisor',
    @level2type = N'COLUMN',
    @level2name = N'intSupervisorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeSupervisor',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeSupervisor',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
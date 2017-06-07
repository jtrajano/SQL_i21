CREATE TABLE [dbo].[tblPREmployeeDepartment]
(
	[intEmployeeDepartmentId] INT NOT NULL IDENTITY, 
    [intEntityEmployeeId] INT NOT NULL, 
    [intDepartmentId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblPREmployeeDepartment] PRIMARY KEY ([intEmployeeDepartmentId]),
	CONSTRAINT [FK_tblPREmployeeDepartment_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [tblPREmployee]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPREmployeeDepartment_tblPRDepartment] FOREIGN KEY ([intDepartmentId]) REFERENCES [dbo].[tblPRDepartment] ([intDepartmentId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intEntityEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeDepartment',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
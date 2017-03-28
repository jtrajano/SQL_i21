CREATE TABLE [dbo].[tblPRDepartmentShift]
(
	[intDepartmentShiftId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intDepartmentId] INT NOT NULL, 
    [intShiftNo] INT NOT NULL DEFAULT ((0)), 
    [dtmStart] DATETIME NULL, 
    [dtmEnd] DATETIME NULL, 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblRateType] NVARCHAR(30) NULL DEFAULT (('Per Hour')), 
    [dblPayType] NVARCHAR(30) NULL DEFAULT (('Actual')), 
    [intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPRDepartmentShift_tblPRDepartment] FOREIGN KEY ([intDepartmentId]) REFERENCES [dbo].[tblPRDepartment] ([intDepartmentId]) ON DELETE CASCADE
)

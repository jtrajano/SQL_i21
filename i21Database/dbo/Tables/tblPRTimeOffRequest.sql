CREATE TABLE [dbo].[tblPRTimeOffRequest]
(
	[intTimeOffRequestId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strRequestId] NVARCHAR(20) NOT NULL, 
    [intEntityEmployeeId] INT NOT NULL, 
    [dtmRequestDate] DATETIME NOT NULL, 
    [intDepartmentId] INT NULL, 
    [dtmDateFrom] DATETIME NOT NULL, 
    [dtmDateTo] DATETIME NOT NULL, 
    [intTypeTimeOffId] INT NOT NULL, 
    [dblRequest] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[dblEarned] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[dblUsed] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[dblBalance] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [strReason] NVARCHAR(MAX) NULL, 
    [strAddress] NVARCHAR(MAX) NULL, 
    [strStatus] NVARCHAR(20) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEntityEmployeeId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPRDepartment] FOREIGN KEY ([intDepartmentId]) REFERENCES [dbo].[tblPRDepartment] ([intDepartmentId])
)

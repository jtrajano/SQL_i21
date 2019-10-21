﻿CREATE TABLE [dbo].[tblPRTimeOffRequest]
(
	[intTimeOffRequestId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strRequestId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
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
    [strReason] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[ysnPostedToCalendar] BIT NULL DEFAULT ((0)),
	[intEventId] INT NULL,
	[intPayGroupDetailId] INT NULL,
	[intPaycheckId] INT NULL,
	[intCreatedUserId] INT NOT NULL,
	[dtmCreated] DATETIME NOT NULL,
	[intLastModifiedUserId] INT NOT NULL,
	[dtmLastModified] DATETIME NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEntityId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPREmployeeTimeOff] FOREIGN KEY ([intEntityEmployeeId],[intTypeTimeOffId]) REFERENCES [dbo].[tblPREmployeeTimeOff] ([intEntityEmployeeId],[intTypeTimeOffId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPRDepartment] FOREIGN KEY ([intDepartmentId]) REFERENCES [dbo].[tblPRDepartment] ([intDepartmentId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblSMEvents] FOREIGN KEY ([intEventId]) REFERENCES [dbo].[tblSMEvents] ([intEventId]),
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPRPayGroupDetail] FOREIGN KEY ([intPayGroupDetailId]) REFERENCES [tblPRPayGroupDetail]([intPayGroupDetailId]) ON DELETE SET NULL,
	CONSTRAINT [FK_tblPRTimeOffRequest_tblPRPaycheck] FOREIGN KEY ([intPaycheckId]) REFERENCES [dbo].[tblPRPaycheck] ([intPaycheckId])
)

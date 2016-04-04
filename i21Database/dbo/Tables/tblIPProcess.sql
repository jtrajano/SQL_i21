CREATE TABLE [dbo].[tblIPProcess]
(
	[intProcessId] INT NOT NULL IDENTITY, 
    [strProcessName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [intScheduleId] INT NULL,
	[ysnAutoExecution] bit DEFAULT 0,
	[dtmLastExecution] [datetime],
	[ysnBusy] BIT DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL DEFAULT 0, 	 
	CONSTRAINT [PK_tblIPProcess_intProcessId] PRIMARY KEY ([intProcessId]),
	CONSTRAINT [UQ_tblIPProcess_strProcessName] UNIQUE ([strProcessName]),
	CONSTRAINT [FK_tblIPProcess_tblIPSchedule_intScheduleId] FOREIGN KEY ([intScheduleId]) REFERENCES [tblIPSchedule]([intScheduleId]), 
)

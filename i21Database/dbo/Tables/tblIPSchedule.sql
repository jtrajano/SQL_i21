CREATE TABLE [dbo].[tblIPSchedule]
(
	[intScheduleId] INT NOT NULL, 
    [strScheduleName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intScheduleTypeId] INT NULL, 
    [dtmStartDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [intInterval] INT NULL DEFAULT 0, 
    [intActiveDayMask] INT NULL DEFAULT 0, 
    [intDate] INT NULL DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] DEFAULT GetDate(),	
	[intConcurrencyId] INT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblIPSchedule_intScheduleId] PRIMARY KEY ([intScheduleId]), 
    CONSTRAINT [UQ_tblIPSchedule_strScheduleName] UNIQUE ([strScheduleName]),
	CONSTRAINT [FK_tblIPSchedule_tblIPScheduleType_intScheduleTypeId] FOREIGN KEY ([intScheduleTypeId]) REFERENCES [tblIPScheduleType]([intScheduleTypeId]), 
)

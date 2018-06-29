CREATE TABLE [dbo].[tblSMActivityAttendee]
(
	[intActivityAttendeeId]		INT		NOT NULL PRIMARY KEY IDENTITY,
	[intActivityId]				[int]	NOT NULL,
	[intEntityId]				[int]	NOT NULL,
	[ysnAddCalendarEvent]		[bit]	NULL,
	[intConcurrencyId]			[int]	NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMActivityAttendee_tblSMActivity] FOREIGN KEY ([intActivityId]) REFERENCES [tblSMActivity]([intActivityId]) ON DELETE CASCADE
)

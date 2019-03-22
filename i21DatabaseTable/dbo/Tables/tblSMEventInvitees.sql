CREATE TABLE [dbo].[tblSMEventInvitees](
	[intEventInviteeId] [int] IDENTITY(1,1) NOT NULL,
	[intEventId] [int] NULL,
	[intEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.tblSMEventInvitees] PRIMARY KEY CLUSTERED ([intEventInviteeId] ASC),
 CONSTRAINT [FK_tblSMEventInvitees_tblSMEvents] FOREIGN KEY ([intEventId]) REFERENCES [dbo].[tblSMEvents] ([intEventId]) ON DELETE CASCADE
);
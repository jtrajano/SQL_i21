CREATE TABLE [dbo].[tblHDTimeEntryTimeOffNotification]
(
	[intTimeEntryTimeOffNotificationId] [int] IDENTITY(1,1) NOT NULL,
	[intTimeOffRequestId] [int] NOT NULL,
	[intTypeTimeOffId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intEntityRecipientId] [int] NULL,
	[dtmDateCreated] [datetime] NULL,
	[dtmDateSent] [datetime] NULL,
	[ysnSent] [bit] NULL default convert(bit,0),
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryTimeOffNotification_intTimeEntryTimeOffNotificationId] PRIMARY KEY CLUSTERED ([intTimeEntryTimeOffNotificationId] ASC),
    CONSTRAINT [FK_tblHDTimeEntryTimeOffNotification_tblPRTimeOffRequest_intTimeOffRequestId] FOREIGN KEY ([intTimeOffRequestId]) REFERENCES [dbo].[tblPRTimeOffRequest] ([intTimeOffRequestId]),
    CONSTRAINT [FK_tblHDTimeEntryTimeOffNotification_tblPRTypeTimeOff_intTypeTimeOffId] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId]),
    CONSTRAINT [FK_tblHDTimeEntryTimeOffNotification_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblHDTimeEntryTimeOffNotification_tblEMEntity_intEntityRecipientId] FOREIGN KEY ([intEntityRecipientId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)

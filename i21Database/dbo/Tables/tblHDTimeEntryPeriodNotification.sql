CREATE TABLE [dbo].[tblHDTimeEntryPeriodNotification]
(
	[intTimeEntryPeriodNotificationId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId]					   [int] NOT NULL,
	[intEntityRecipientId]			   [int] NULL,
	[dtmDateCreated]				   [datetime] NULL,
	[dtmDateSent]					   [datetime] NULL,
	[ysnSent]						   [bit] NULL DEFAULT CONVERT(BIT,0),
	[strWarning]					   NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTimeEntryPeriodDetailId]	   [int] NULL,
	[intConcurrencyId]				   [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryPeriodNotification_intTimeEntryPeriodNotificationId] PRIMARY KEY CLUSTERED ([intTimeEntryPeriodNotificationId] ASC),
    CONSTRAINT [FK_tblHDTimeEntryPeriodNotification_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblHDTimeEntryPeriodNotification_tblEMEntity_intEntityRecipientId] FOREIGN KEY ([intEntityRecipientId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblHDTimeEntryPeriodNotification_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] FOREIGN KEY ([intTimeEntryPeriodDetailId]) REFERENCES [dbo].[tblHDTimeEntryPeriodDetail] ([intTimeEntryPeriodDetailId]) ON DELETE CASCADE
)

GO
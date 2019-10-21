CREATE TABLE [dbo].[tblSMActivityFollowUp]
(
	[intActivityFollowUpId]			INT													NOT NULL IDENTITY,
	[intActivityFollowUpTemplateId]	[int]												NOT NULL,
	[strType]						[nvarchar](50)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[strSubject]					[nvarchar](100)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[dtmDueDate]					[datetime]											NULL, 
	[dtmTime]						[datetime]											NULL, 
	[intAssignedTo]					[int]												NOT NULL,
	[strCategory]					[nvarchar](50)		COLLATE Latin1_General_CI_AS	NULL,
	[strPriority]					[nvarchar](50)		COLLATE Latin1_General_CI_AS	NULL,
	[strStatus]						[nvarchar](50)		COLLATE Latin1_General_CI_AS	NULL,
	[strDetails]					[nvarchar](MAX)		COLLATE Latin1_General_CI_AS	NULL,
	[intSort]						[int]												NOT NULL DEFAULT ((1)),
	[intEntityContactId]			[int]												NULL,
	[intConcurrencyId]				[int]												NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblSMActivityFollowUp] PRIMARY KEY CLUSTERED ([intActivityFollowUpId] ASC),
    CONSTRAINT [FK_tblSMActivityFollowUp_tblSMActivityFollowUpTemplate] FOREIGN KEY ([intActivityFollowUpTemplateId]) REFERENCES [dbo].[tblSMActivityFollowUpTemplate] ([intActivityFollowUpTemplateId]) ON DELETE CASCADE
)

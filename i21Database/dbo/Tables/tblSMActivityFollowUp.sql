CREATE TABLE [dbo].[tblSMActivityFollowUp]
(
	[intActivityFollowUpId]			INT													NOT NULL PRIMARY KEY IDENTITY,
	[intActivityFollowUpTemplateId]	[int]												NOT NULL,
	[strType]						[nvarchar](50)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[strSubject]					[nvarchar](100)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[dtmDueDate]					[datetime]											NULL, 
	[dtmTime]						[datetime]											NULL, 
	[intAssignedTo]					[int]												NULL,
	[strCategory]					[nvarchar](50)		COLLATE Latin1_General_CI_AS	NULL,
	[strPriority]					[nvarchar](50)		COLLATE Latin1_General_CI_AS	NULL,
	[strStatus]						[nvarchar](50)		COLLATE Latin1_General_CI_AS	NULL,
	[strDetails]					[nvarchar](MAX)		COLLATE Latin1_General_CI_AS	NULL,
	[intConcurrencyId]				[int]												NOT NULL DEFAULT ((1))
)

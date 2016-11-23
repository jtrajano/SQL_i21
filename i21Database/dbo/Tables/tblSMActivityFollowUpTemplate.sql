CREATE TABLE [dbo].[tblSMActivityFollowUpTemplate]
(
	[intActivityFollowUpTemplateId]	INT													NOT NULL PRIMARY KEY IDENTITY,
	[strTemplateName]				[nvarchar](250)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[intConcurrencyId]				[int]												NOT NULL DEFAULT ((1))
)

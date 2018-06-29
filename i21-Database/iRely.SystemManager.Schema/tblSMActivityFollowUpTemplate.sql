CREATE TABLE [dbo].[tblSMActivityFollowUpTemplate]
(
	[intActivityFollowUpTemplateId]	INT													NOT NULL IDENTITY,
	[strTemplateName]				[nvarchar](250)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[intEntityId]					[int]												NOT NULL,
	[intConcurrencyId]				[int]												NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblSMActivityFollowUpTemplate] PRIMARY KEY CLUSTERED ([intActivityFollowUpTemplateId] ASC),
	CONSTRAINT [UQ_tblSMActivityFollowUpTemplate_strTemplateName] UNIQUE (strTemplateName)
)

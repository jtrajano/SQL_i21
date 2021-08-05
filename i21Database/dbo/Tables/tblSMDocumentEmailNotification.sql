CREATE TABLE [dbo].[tblSMDocumentEmailNotification]
(
	[intDocumentEmailNotificationId]		[int] IDENTITY(1,1) NOT NULL,
	[strName]							[nvarchar](250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strEmailAddress]					[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]					[int] NOT NULL DEFAULT (1),

    CONSTRAINT [PK_tblSMDocumentEmailNotification] PRIMARY KEY CLUSTERED ([intDocumentEmailNotificationId] ASC)
)

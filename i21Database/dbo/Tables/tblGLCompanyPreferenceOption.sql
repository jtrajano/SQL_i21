CREATE TABLE [dbo].[tblGLCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] [int] NOT NULL IDENTITY,
	[strNotificationMessage] [nvarchar](100) NULL,
	[intDaysBeforeEvent] [int] NULL,
	[intDaysAfterEvent] [int] NULL,
	[intConcurrencyId] [int] NULL,
	[strRemindUsers] [nvarchar](500) NULL,
	[strEventDescription] [nvarchar](50) NULL, 
    CONSTRAINT [PK_tblGLCompanyPreferenceOption] PRIMARY KEY ([intCompanyPreferenceOptionId])

)

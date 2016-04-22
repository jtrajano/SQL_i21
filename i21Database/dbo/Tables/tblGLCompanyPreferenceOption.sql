CREATE TABLE [dbo].[tblGLCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] [int] NOT NULL IDENTITY,
	[PostRemind_strNotificationMessage] [nvarchar](100) NULL,
	[PostRemind_intDaysBeforeEvent] [int] NULL,
	[PostRemind_intDaysAfterEvent] [int] NULL,
	[intConcurrencyId] [int] NULL,
	[PostRemind_strRemindUsers] [nvarchar](500) NULL,
	[PostRemind_strEventDescription] [nvarchar](50) NULL, 
    CONSTRAINT [PK_tblGLCompanyPreferenceOption] PRIMARY KEY ([intCompanyPreferenceOptionId])

)

CREATE TABLE [dbo].[tblHDSetting]
(
	[intSettingId] [int] IDENTITY(1,1) NOT NULL,
	[strHelpDeskName] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strHelpDeskURL] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strJIRAURL] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strTimeZone] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblHDSettings] PRIMARY KEY CLUSTERED 
(
	[intSettingId] ASC
)
)

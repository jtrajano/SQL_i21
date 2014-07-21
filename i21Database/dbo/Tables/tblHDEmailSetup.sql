CREATE TABLE [dbo].[tblHDEmailSetup]
(
	[intEmailSetupId] [int] IDENTITY(1,1) NOT NULL,
	[strFromEmail] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFromName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubjectPrefix] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strSMTPServer] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intSMTPPort] [int] NULL,
	[strEncryptedConnection] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnRequiresAuthentication] [bit] NULL,
	[strUserName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDEmailSetup] PRIMARY KEY CLUSTERED 
(
	[intEmailSetupId] ASC
)
)

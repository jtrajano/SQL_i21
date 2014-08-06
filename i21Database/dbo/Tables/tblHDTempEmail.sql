CREATE TABLE [dbo].[tblHDTempEmail]
(
	[intTempEmailId] [int] IDENTITY(1,1) NOT NULL,
	[strSMTPServer] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intSMTPPort] [int] NULL,
	[strUserName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[ysnRequiresAuthentication] [bit] NULL,
	[strFromEmail] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strSubject] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strBodyMessage] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strBodyMessageType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTicketId] [int] NULL,	
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTempEmail] PRIMARY KEY CLUSTERED 
(
	[intTempEmailId] ASC
)
)

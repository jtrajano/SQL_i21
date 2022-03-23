CREATE TABLE [dbo].[tblApiSchemaEMEntity](
	[guiApiUniqueId] [uniqueidentifier] NOT NULL,
	[intRowNumber] [int] NULL,
	[intKey] [int] IDENTITY(1,1) NOT NULL,
	[strEntityNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strName] [nvarchar](100) NOT NULL,
	[strMobile] [nvarchar](20) NULL,
	[strLocationName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strPhone] [nvarchar](100) NULL,
	[strEmail] [nvarchar](75) NULL,
	[strSuffix] [nvarchar](50) NULL,
	[strTitle] [nvarchar](255) NULL,
	[strNickName] [nvarchar](100) NULL,
	[strDepartment] [nvarchar](30) NULL,
	[strNotes] [nvarchar](max) NULL,
	[intEntityRank] [int] NULL,
	[ysnActive] [bit] NULL,
	[strContactMethod] [nvarchar](20) NULL,
	[strEmailDistributionOption] [nvarchar](max) NULL,
	[strPortalUserRole] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strPortalPassword] [nvarchar](100) NULL,
CONSTRAINT [PK_tblApiSchemaEMEntity] PRIMARY KEY CLUSTERED 
(
	[intKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]
GO

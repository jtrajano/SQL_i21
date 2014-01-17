/****** Object:  Table [dbo].[tblCPUserConfiguration]    Script Date: 01/15/2014 17:25:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblCPUserConfiguration]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tblCPUserConfiguration](
	[intUserConfigId] [int] IDENTITY(1,1) NOT NULL,
	[intUserSecurityId] [int] NOT NULL,
	[strCustomerNo] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_UserConfig] PRIMARY KEY CLUSTERED 
(
	[intUserConfigId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  ForeignKey [FK_UserConfig_UserSecurity]    Script Date: 01/15/2014 17:25:04 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserConfig_UserSecurity]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblCPUserConfiguration]'))
ALTER TABLE [dbo].[tblCPUserConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_UserConfig_UserSecurity] FOREIGN KEY([intUserSecurityId])
REFERENCES [dbo].[tblSMUserSecurity] ([intUserSecurityID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserConfig_UserSecurity]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblCPUserConfiguration]'))
ALTER TABLE [dbo].[tblCPUserConfiguration] CHECK CONSTRAINT [FK_UserConfig_UserSecurity]
GO

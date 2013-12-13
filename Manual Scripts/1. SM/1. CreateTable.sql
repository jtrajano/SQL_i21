/****** Object:  Table [dbo].[tblSMZipCode]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSMZipCode](
	[intZipCodeID] [int] IDENTITY(1,1) NOT NULL,
	[strZipCode] [nvarchar](12) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[strState] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[strCity] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[strCountry] [nvarchar](25) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[dblLatitude] [numeric] (18,6) NOT NULL DEFAULT (0),
	[dblLongitude] [numeric] (18,6) NOT NULL DEFAULT (0),
	[intSort] [int] NOT NULL DEFAULT(1),
	[intConcurrencyID] [int] NOT NULL DEFAULT(0),
 CONSTRAINT [PK_tblSMZipCode] PRIMARY KEY CLUSTERED 
(
	[strZipCode] ASC,
	[strCity] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]



GO
/****** Object:  Table [dbo].[tblSMUserRole]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMUserRole](
	[intUserRoleID] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strMenu] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strMenuPermission] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strForm] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[ysnAdmin] [bit] NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[intUserRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMStartingNumber]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMStartingNumber](
	[cntID] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionType] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intNumber] [int] NULL,
	[intTransactionTypeID] [int] NULL,
	[strModule] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[ysnEnable] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblSMStartingNumber] PRIMARY KEY CLUSTERED 
(
	[strTransactionType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMPreferences]    Script Date: 12/04/2013 11:26:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMPreferences](
	[intPreferenceID] [int] IDENTITY(1,1) NOT NULL,
	[intUserID] [int] NOT NULL,
	[strPreference] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strValue] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_SMPreferences_PreferenceID] PRIMARY KEY CLUSTERED 
(
	[intUserID] ASC, [strPreference]
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMMenu]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMMenu](
	[intMenuID] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strTemplate] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED 
(
	[intMenuID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMCurrency]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMCurrency](
	[intCurrencyID] [int] IDENTITY(1,1) NOT NULL,
	[strCurrency] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strCheckDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[dblDailyRate] [numeric](18, 6) NULL,
	[dblMinRate] [numeric](18, 6) NULL,
	[dblMaxRate] [numeric](18, 6) NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_SMCurrency_CurrencyID] PRIMARY KEY CLUSTERED 
(
	[intCurrencyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMCountry]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMCountry](
	[intCountryID] [int] IDENTITY(1,1) NOT NULL,
	[strCountry] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strPhoneNumber] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strCountryCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_SMCountry_CoutryID] PRIMARY KEY CLUSTERED 
(
	[intCountryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMCompany]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMCompany](
	[intCompanyID] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strAddress] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strCity] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strState] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strCountry] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strPhone] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strFax] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strEmail] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strWebsite] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[intCompanyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMActiveScreen]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMActiveScreen](
	[intActiveScreenID] [int] IDENTITY(1,1) NOT NULL,
	[strProcessName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strMenuName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strMacAddress] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strMachineName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strUserName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intProcessID] [int] NULL,
 CONSTRAINT [PK_ActiveScreen] PRIMARY KEY CLUSTERED 
(
	[intActiveScreenID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSMUserSecurity]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMUserSecurity](
	[intUserSecurityID] [int] IDENTITY(1,1) NOT NULL,
	[intUserRoleID] [int] NULL,
	[strUserName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strFullName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strPassword] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strFirstName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strMiddleName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL ,
	[strLastName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strPhone] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDepartment] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strLocation] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strEmail] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strMenuPermission] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strMenu] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strForm] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strFavorite] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[ysnDisabled] [bit] NOT NULL DEFAULT 0,
	[ysnAdmin] [bit] NOT NULL DEFAULT 0,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[intUserSecurityID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblSMUser__ysnAd__0CE5D100]    Script Date: 10/07/2013 16:40:48 ******/
ALTER TABLE [dbo].[tblSMUserRole] ADD  DEFAULT ((0)) FOR [ysnAdmin]
GO
/****** Object:  ForeignKey [FK_UserSecurity_UserRole]    Script Date: 10/07/2013 16:40:48 ******/
ALTER TABLE [dbo].[tblSMUserSecurity]  WITH CHECK ADD  CONSTRAINT [FK_UserSecurity_UserRole] FOREIGN KEY([intUserRoleID])
REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID])
GO
ALTER TABLE [dbo].[tblSMUserSecurity] CHECK CONSTRAINT [FK_UserSecurity_UserRole]
GO

GO

/****** Object:  Table [dbo].[tblSMCompanySetup]    Script Date: 11/05/2013 17:24:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSMCompanySetup](
	[intCompanySetupID] [int] IDENTITY(1,1) NOT NULL,
	[strCompanyName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL ,
	[strContactName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[strAddress] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL ,
	[strCounty] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL ,
	[strCity] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL ,
	[strState] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[strZip] [nvarchar](12) COLLATE Latin1_General_CI_AS NULL ,
	[strCountry] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL ,
	[strPhone] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[strFax] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL ,
	[strWebSite] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL ,
	[strEmail] [nvarchar](75) COLLATE Latin1_General_CI_AS NULL ,
	[strFederalTaxID] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[strStateTaxID] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[strBusinessType] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL ,
	[intConcurrencyID] [int] NULL DEFAULT (1),
 CONSTRAINT [PK_tblSMCompanySetup] PRIMARY KEY CLUSTERED 
(
	[strCompanyName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[tblSMDefaultMenu]    Script Date: 11/19/2013 15:32:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSMDefaultMenu](
	[intMenuID] [int] IDENTITY NOT NULL,
	[strMenuName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intParentMenuID] [int] NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCommand] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnVisible] [bit] DEFAULT(0) NOT NULL,
	[ysnExpanded] [bit] DEFAULT(0) NOT NULL,
	[ysnIsLegacy] [bit] DEFAULT(0) NOT NULL,
	[ysnLeaf] [bit] DEFAULT(1) NOT NULL,
	[intSort] [int] NULL,
 CONSTRAINT [PK_tblSMDefaultMenu] PRIMARY KEY CLUSTERED 
(
	[intMenuID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[tblSMMasterMenu]    Script Date: 11/19/2013 15:32:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSMMasterMenu](
	[intMenuID] [int] IDENTITY NOT NULL,
	[strMenuName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intParentMenuID] [int] NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCommand] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnVisible] [bit] DEFAULT(0) NOT NULL,
	[ysnExpanded] [bit] DEFAULT(0) NOT NULL,
	[ysnIsLegacy] [bit] DEFAULT(0) NOT NULL,
	[ysnLeaf] [bit] DEFAULT(1) NOT NULL,
	[intSort] [int] NULL,
 CONSTRAINT [PK_tblSMMasterMenu] PRIMARY KEY CLUSTERED 
(
	[intMenuID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[tblSMUserRoleMenu]    Script Date: 11/25/2013 11:01:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSMUserRoleMenu](
	[intUserRoleMenuID] [int] IDENTITY(1,1) NOT NULL,
	[intUserRoleID] [int] NOT NULL,
	[intMenuID] [int] NOT NULL,
	[intParentMenuID] [int] NULL,
	[ysnVisible] [bit] NOT NULL,
	[intSort] [int] NULL,
 CONSTRAINT [PK_tblSMUserRoleMenu] PRIMARY KEY CLUSTERED 
(
	[intUserRoleMenuID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblSMUserRoleMenu]  WITH CHECK ADD  CONSTRAINT [FK_tblSMUserRoleMenu_tblSMMasterMenu] FOREIGN KEY([intMenuID])
REFERENCES [dbo].[tblSMMasterMenu] ([intMenuID])
GO

ALTER TABLE [dbo].[tblSMUserRoleMenu]  WITH CHECK ADD  CONSTRAINT [FK_tblSMUserRoleMenu_tblSMUserRole] FOREIGN KEY([intUserRoleID])
REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID])
GO

ALTER TABLE [dbo].[tblSMUserRoleMenu] CHECK CONSTRAINT [FK_tblSMUserRoleMenu_tblSMMasterMenu]
GO

ALTER TABLE [dbo].[tblSMUserRoleMenu] ADD  CONSTRAINT [DF_tblSMUserRoleMenu_ysnVisible]  DEFAULT ((1)) FOR [ysnVisible]
GO

/****** Object:  Table [dbo].[tblSMUserMenu]    Script Date: 11/25/2013 10:55:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSMUserMenu](
	[intUserMenuID] [int] IDENTITY(1,1) NOT NULL,
	[intUserID] [int] NOT NULL,
	[intUserRoleMenuID] [int] NOT NULL,
	[ysnVisible] [bit] NOT NULL,
	[intSort] [int] NULL,
 CONSTRAINT [PK_tblSMUserMenu] PRIMARY KEY CLUSTERED 
(
	[intUserMenuID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblSMUserMenu]  WITH CHECK ADD  CONSTRAINT [FK_tblSMUserMenu_tblSMUserRoleMenu] FOREIGN KEY([intUserRoleMenuID])
REFERENCES [dbo].[tblSMUserRoleMenu] ([intUserRoleMenuID])
GO

ALTER TABLE [dbo].[tblSMUserMenu]  WITH CHECK ADD  CONSTRAINT [FK_tblSMUserMenu_tblSMUserSecurity] FOREIGN KEY([intUserID])
REFERENCES [dbo].[tblSMUserSecurity] ([intUserSecurityID])
GO

ALTER TABLE [dbo].[tblSMUserMenu] CHECK CONSTRAINT [FK_tblSMUserMenu_tblSMUserRoleMenu]
GO

ALTER TABLE [dbo].[tblSMUserMenu] ADD  CONSTRAINT [DF_tblSMUserMenu_ysnVisible]  DEFAULT ((1)) FOR [ysnVisible]
GO




-- update 13.3 to 13.4

PRINT N'Altering [dbo].[tblSMUserRole]...';

GO

ALTER TABLE [dbo].[tblSMUserRole]
    ADD [ysnAdmin] BIT DEFAULT ((0)) NOT NULL;


GO
PRINT N'Creating DF__tblSMUser__strUs__4A23E96A...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strUserName];


GO
PRINT N'Creating DF__tblSMUser__strFu__4B180DA3...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strFullName];


GO
PRINT N'Creating DF__tblSMUser__strPa__4C0C31DC...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strPassword];


GO
PRINT N'Creating DF__tblSMUser__strFi__4D005615...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strFirstName];


GO
PRINT N'Creating DF__tblSMUser__strLa__4DF47A4E...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strLastName];


GO
PRINT N'Creating DF__tblSMUser__strMe__4EE89E87...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strMenu];


GO
PRINT N'Creating DF__tblSMUser__strFa__4FDCC2C0...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ('') FOR [strFavorite];


GO
PRINT N'Creating DF__tblSMUser__ysnDi__50D0E6F9...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ((0)) FOR [ysnDisabled];


GO
PRINT N'Creating DF__tblSMUser__ysnAd__51C50B32...';


GO
ALTER TABLE [dbo].[tblSMUserSecurity]
    ADD DEFAULT ((0)) FOR [ysnAdmin];

GO


PRINT N'creating [dbo].[tblSMCompany]...';

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



PRINT N'creating [dbo].[tblSMCountry]...';

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



PRINT N'creating [dbo].[tblSMCurrency]...';

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




PRINT N'creating [dbo].[tblSMPreferences]...';

GO

/****** Object:  Table [dbo].[tblSMPreferences]    Script Date: 10/07/2013 16:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSMPreferences](
	[intPreferenceID] [int] IDENTITY(1,1) NOT NULL,
	[intUserID] [int] NULL,
	[strPreference] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strValue] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_SMPreferences_PreferenceID] PRIMARY KEY CLUSTERED 
(
	[intPreferenceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


PRINT N'creating [dbo].[tblSMStartingNumber]...';

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


PRINT N'creating [dbo].[tblSMZipCode]...';

GO
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
	[intSort] [int] NOT NULL DEFAULT(1),
	[intConcurrencyID] [int] NOT NULL DEFAULT(0),
 CONSTRAINT [PK_tblSMZipCode] PRIMARY KEY CLUSTERED 
(
	[strZipCode] ASC,
	[strCity] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

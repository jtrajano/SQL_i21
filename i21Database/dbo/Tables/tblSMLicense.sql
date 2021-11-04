CREATE TABLE [dbo].[tblSMLicense]
(
	[intLicenseId]			INT NOT NULL IDENTITY(1,1),
	[dtmDateRegistered]			DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmDateExpiration]		DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmSupportExpiration]	DATETIME NOT NULL DEFAULT(GETDATE()),
	[intNumberOfAdmin]		INT NOT NULL DEFAULT(1),
	[intNumberOfUser]		INT NOT NULL,
	[strCompanyId]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomer]			NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription]		NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strUniqueId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]		INT CONSTRAINT [DF_tblSMLicense_intConcurrencyId] DEFAULT ((0)) NOT NULL,

    CONSTRAINT [PK_tblSMLicense] PRIMARY KEY CLUSTERED ([intLicenseId] ASC)
)
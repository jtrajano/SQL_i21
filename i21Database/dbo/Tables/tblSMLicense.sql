CREATE TABLE [dbo].[tblSMLicense]
(
	[intLicenseId]			INT NOT NULL IDENTITY(1,1),
	[intEntityCustomerId]	INT NOT NULL,
	[dtmDateRegistered]			DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmDateExpiration]		DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmSupportExpiration]	DATETIME NOT NULL DEFAULT(GETDATE()),
	[intNumberOfAdmin]		INT NOT NULL DEFAULT(1),
	[intNumberOfUser]		INT NOT NULL,
	[strCompanyId]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription]		NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strUniqueId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]		INT CONSTRAINT [DF_tblSMLicense_intConcurrencyId] DEFAULT ((0)) NOT NULL,

    CONSTRAINT [PK_tblSMLicense] PRIMARY KEY CLUSTERED ([intLicenseId] ASC),
	CONSTRAINT [FK_tblSMLicense_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE
)
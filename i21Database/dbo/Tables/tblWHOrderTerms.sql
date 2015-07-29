CREATE TABLE [dbo].[tblWHOrderTerms]
(
	[intOrderTermsId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strInternalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[strOrderTerms] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[ysnDefault] BIT NULL,
	[ysnLocked] BIT NULL,
	[intLastUpdateId] INT NOT NULL,
	[dtmLastUpdateOn] DATETIME NOT NULL,

	CONSTRAINT [PK_tblWHOrderTerms_intOrderTermsId]  PRIMARY KEY ([intOrderTermsId]),	

)

CREATE TABLE [dbo].[tblSMLicenseRegisteredFeature]
(
	[intLicenseRegisteredFeatureId]		INT NOT NULL IDENTITY(1,1),
	[strKey]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL,
	[strValue]							NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,

	[intConcurrencyId]					INT DEFAULT ((1)) NOT NULL

	CONSTRAINT [PK_tblSMLicenseRegisteredFeature] PRIMARY KEY CLUSTERED ([intLicenseRegisteredFeatureId] ASC),
	CONSTRAINT [UC_tblSMLicenseRegisteredFeature] UNIQUE (strKey)
)

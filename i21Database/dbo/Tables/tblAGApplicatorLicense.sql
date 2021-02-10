CREATE TABLE [dbo].[tblAGApplicatorLicense]
(
	[intApplicatorLicenseId]		INT				NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityId]					INT				NOT NULL,
	[intStateId]					INT				NOT NULL,
    [strState]						NVARCHAR (100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strLicenseNumber]				NVARCHAR (100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmLicenseExpirationDate]		DATETIME		NULL,
    [intConcurrencyId]				INT				NOT NULL DEFAULT (1), 

	CONSTRAINT [FK_dbo_tblAGApplicatorLicense_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
);
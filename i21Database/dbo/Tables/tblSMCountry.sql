CREATE TABLE [dbo].[tblSMCountry] (
    [intCountryID]				INT				IDENTITY (1, 1) NOT NULL,
    [strCountry]				NVARCHAR (100)	COLLATE Latin1_General_CI_AS NOT NULL,	
	[strISOCode]				NVARCHAR (3)	COLLATE Latin1_General_CI_AS NULL,	
    [strCountryCode]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[strCountryFormat]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[strAreaCityFormat]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[strLocalNumberFormat]		NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[intAreaCityLength]			INT				NOT NULL DEFAULT 3,
    [intSort]					INT				NULL,
    [intConcurrencyId]			INT				DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_SMCountry_CoutryID] PRIMARY KEY CLUSTERED ([intCountryID] ASC), 
    CONSTRAINT [AK_tblSMCountry_Country] UNIQUE (strCountry)
);


GO

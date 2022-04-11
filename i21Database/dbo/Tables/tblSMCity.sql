CREATE TABLE [dbo].[tblSMCity]
(
    [intCityId]					INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCity]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCountryId]				INT NOT NULL, 
    [strState]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strVAT]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnRegion]					BIT NOT NULL DEFAULT 0,
    [ysnPort]					BIT NOT NULL DEFAULT 0,
	[ysnArbitration]			BIT NOT NULL DEFAULT 0,
	[strInboundText]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strOutboundText]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[ysnDefault]				bit not null default(0),
	[intLeadTime]				int not null default(0),
	[intLeadTimeAtSource]		int not null default(0),
	[intGeographicalZoneId]		INT NULL, 
    [intConcurrencyId]			INT NOT NULL DEFAULT 1, 

    CONSTRAINT [FK_tblSMCity_tblSMCountry] FOREIGN KEY (intCountryId) REFERENCES tblSMCountry(intCountryID), 
	CONSTRAINT [FK_tblSMCity_tblSMGeographicalZone] FOREIGN KEY ([intGeographicalZoneId]) REFERENCES tblSMGeographicalZone([intGeographicalZoneId]), 
    CONSTRAINT [AK_tblSMCity_City_Country_State] UNIQUE (strCity, intCountryId, strState),
	CONSTRAINT [CK_SMUniqueDefaultPerCity] check(dbo.fnCKSMUniqueDefaultPerCity(intCityId, intCountryId, ysnDefault, ysnPort) = 1)
)
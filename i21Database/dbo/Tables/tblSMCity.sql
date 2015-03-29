CREATE TABLE [dbo].[tblSMCity]
(
    [intCityId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCountryId] INT NOT NULL, 
    [strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnPort] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCity_tblSMCountry] FOREIGN KEY (intCountryId) REFERENCES tblSMCountry(intCountryID), 
    CONSTRAINT [AK_tblSMCity_City_Country_State] UNIQUE (strCity, intCountryId, strState)
)
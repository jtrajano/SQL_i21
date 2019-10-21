CREATE TABLE [dbo].[tblPRIRSCountryCode]
(
	[intIRSCountryCodeId] INT NOT NULL PRIMARY KEY, 
    [strCountry] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCode] NVARCHAR(2) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1))
)

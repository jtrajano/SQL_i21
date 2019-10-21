CREATE TABLE [dbo].[tblPRTypeTaxStatePSDCode]
(
	[intTypeTaxStatePSDCodeId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strCounty] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strSchoolDistrict] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strMunicipality] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strPSDCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1))
)

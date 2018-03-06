CREATE TABLE [dbo].[tblTFCountyLocation]
(
	[intCountyLocationId] INT IDENTITY NOT NULL,
	[strCounty] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFCountyLocation] PRIMARY KEY ([intCountyLocationId]) 
)

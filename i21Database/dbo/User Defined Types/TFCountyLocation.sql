CREATE TYPE [dbo].[TFCountyLocation] AS TABLE
(
	[intCountyLocationId] INT NOT NULL,
	[strCounty] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dblRate1] NUMERIC(18,6) NULL,
	[dblRate2] NUMERIC(18,6) NULL,
	[intMasterId] INT NULL
)

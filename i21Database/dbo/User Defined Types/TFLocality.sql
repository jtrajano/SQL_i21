CREATE TYPE [dbo].[TFLocality] AS TABLE
(
	[intLocalityId] INT NOT NULL,
	[strLocalityCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocalityZipCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocalityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intMasterId] INT NULL
)

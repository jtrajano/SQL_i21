CREATE TYPE [dbo].[TFProductCodes] AS TABLE (
	intProductCodeId INT NOT NULL
	, strProductCode NVARCHAR (10) COLLATE Latin1_General_CI_AS NOT NULL
	, strDescription NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL
	, strProductCodeGroup NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strNote NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, intMasterId INT NULL
)
CREATE TYPE [dbo].[TFTaxCriteria] AS TABLE (
	intTaxCriteriaId INT NOT NULL
	, strFormCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	, strScheduleCode NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
	, strType NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
	, strState NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
	, strTaxCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	, strCriteria NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
	, intMasterId INT NULL
)
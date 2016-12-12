CREATE TYPE [dbo].[TFTaxCriteria] AS TABLE (
	[intTaxCriteriaId] INT NOT NULL,
    [strFormCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strScheduleCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTaxCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCriteria] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
)
CREATE TYPE [dbo].[TFTaxCategory] AS TABLE(
	intTaxCategoryId INT NOT NULL
	, strState NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
    , strTaxCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
)
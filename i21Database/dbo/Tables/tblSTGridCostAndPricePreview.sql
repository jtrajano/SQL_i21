CREATE TABLE [dbo].[tblSTGridCostAndPricePreview] (
	intGridCostAndPricePreviewId	INT NOT NULL IDENTITY, 
	intItemId						INT,
    strVendorItemNumber				NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    strDescription					NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    dblNewCost						NUMERIC(18,6),
    strLocation						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    intStoreNo						INT,
    strLongUPCCode					NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    strUnit							NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	intQuantity						INT,
    dblPrice						NUMERIC(18,6),
    strCategory						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	dblCategoryMargin				NUMERIC(18,6),
    strFamily						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    strClass						NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    strGuid							UNIQUEIDENTIFIER NOT NULL, 
	intConcurrencyId				INT
);
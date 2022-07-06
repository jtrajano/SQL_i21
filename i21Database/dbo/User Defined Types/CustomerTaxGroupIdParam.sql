CREATE TYPE [dbo].[CustomerTaxGroupIdParam] AS TABLE(
	  intCustomerId				INT NULL
	, intCompanyLocationId		INT NULL
	, intItemId					INT NULL
	, intCustomerLocationId		INT NULL
	, intSiteId					INT NULL
	, intFreightTermId			INT NULL
	, strFOB					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intVendorId				INT  NULL
	, intItemCategoryId			INT NULL
	, intTaxGroupId				INT NULL
	, intLineItemId				INT NULL --ADDED
)
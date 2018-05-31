CREATE PROCEDURE [dbo].[uspARGetBestItemPrice]
	@intItemId					INT,
	@intCompanyLocationId		INT,
	@intEntityCustomerId		INT = NULL,	
	@intItemUOMId				INT = NULL,
	@dblPrice					NUMERIC(18, 6) = 0 OUTPUT
AS

IF(OBJECT_ID('tempdb..#ITEMPRICES') IS NOT NULL)
BEGIN
	DROP TABLE #ITEMPRICES
END

CREATE TABLE #ITEMPRICES (
	  intItemId		INT NULL
	, strPricing	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
	, dblPrice		NUMERIC(18, 6) NULL
)

DECLARE @intCurrencyId			INT = (SELECT TOP 1 intDefaultCurrencyId FROM dbo.tblSMCompanyPreference WITH (NOLOCK))	  
	  , @intItemLocationId		INT = (SELECT TOP 1 intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intCompanyLocationId)
	  , @intPricingLevelId		INT = NULL
	  , @dtmTransactionDate		DATETIME = GETDATE()

--GET PRICING LEVEL
SELECT TOP 1 @intPricingLevelId = CPL.intCompanyLocationPricingLevelId 
FROM tblSMCompanyLocationPricingLevel CPL
INNER JOIN (
	SELECT strLevel
	FROM tblARCustomer
	WHERE intEntityId = @intEntityCustomerId				  
) C ON CPL.strPricingLevelName = C.strLevel
WHERE CPL.intCompanyLocationId = @intCompanyLocationId

--GET RETAIL PRICE
INSERT INTO #ITEMPRICES
SELECT intItemId    = @intItemId
	 , strPricing   = 'Standard Pricing'
	 , dblPrice		= P.dblSalePrice
FROM dbo.tblICItemPricing P
WHERE P.intItemId		  = @intItemId
  AND P.intItemLocationId = @intItemLocationId

--GET PRICING LEVEL AND PROMOTIONAL PRICING
INSERT INTO #ITEMPRICES
SELECT intItemId    = @intItemId
	 , strPricing	= strPricing
	 , dblPrice		= dblPrice
FROM [dbo].[fnARGetInventoryItemPricingDetails](
	  @intItemId
    , @intEntityCustomerId
    , @intCompanyLocationId
    , @intItemUOMId
    , @dtmTransactionDate
    , 1
    , NULL
    , @intPricingLevelId
    , NULL
    , 1
    , @intCurrencyId
)

SET @dblPrice = (SELECT MIN(dblPrice) FROM #ITEMPRICES)
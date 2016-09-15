﻿CREATE VIEW [dbo].[vyuTMBEExportPrice]  
AS 

SELECT DISTINCT
	* 
FROM (
SELECT DISTINCT
	ID = A.priceId
	,name = A.strShortName
	,perUnit = CAST(ROUND(A.priceId,4) AS NUMERIC (16,4))
FROM vyuICTMProductPricing A
UNION ALL
SELECT DISTINCT
	ID = A.dblPrice
	,name = (CASE WHEN C.intItemId IS NULL THEN ISNULL(B.strShortName,'') ELSE ISNULL(C.strShortName,'') END)
	,perUnit = CAST(ROUND(dblPrice,4) AS NUMERIC (16,4))
FROM tblTMDispatch A
INNER JOIN tblICItem B
	ON A.intProductID = B.intItemId
LEFT JOIN tblICItem C
	ON A.intSubstituteProductID = C.intItemId
UNION ALL
--- CustomerPricing
SELECT DISTINCT
	ID = B.dblPrice
	,name = A.strShortName
	,perUnit = CAST(ROUND(B.dblPrice,4) AS NUMERIC (16,4))
FROM(
	SELECT
		Z.intProduct
		,D.intCustomerNumber
		,Z.intLocationId
		,Z.intCompanyLocationPricingLevelId
		,C.strShortName
	FROM tblTMSite Z
	INNER JOIN tblTMCustomer D
		ON Z.intCustomerID = D.intCustomerID
	INNER JOIN tblICItem C
		ON Z.intProduct = C.intItemId
) A
CROSS APPLY (
    SELECT TOP 1 dblPrice, strPricing, intContractDetailId FROM dbo.fnARGetItemPricingDetails(
        A.intProduct
        ,A.intCustomerNumber
        ,A.intLocationId
        ,NULL
        ,GETDATE()
        ,1
        ,NULL  --@ContractHeaderId		INT
	    ,NULL  --@ContractDetailId		INT
	    ,NULL  --@ContractNumber		NVARCHAR(50)
	    ,NULL  --@ContractSeq			INT
	    ,NULL  --@AvailableQuantity		NUMERIC(18,6)
	    ,NULL  --@UnlimitedQuantity     BIT
	    ,NULL  --@OriginalQuantity		NUMERIC(18,6)
	    ,1     --@CustomerPricingOnly	BIT
        ,NULL  --@ItemPricingOnly
        ,0     --@ExcludeContractPricing
	    ,NULL  --@VendorId				INT
	    ,NULL  --@SupplyPointId			INT
	    ,NULL  --@LastCost				NUMERIC(18,6)
	    ,NULL  --@ShipToLocationId      INT
	    ,NULL  --@VendorLocationId		INT
        ,A.intCompanyLocationPricingLevelId -- @PricingLevelId
        ,NULL
        ,NULL
        ,NULL --TermId
        ,NULL --@GetAllAvailablePricing
        )
) B


) Z

GO
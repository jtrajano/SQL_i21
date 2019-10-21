CREATE PROCEDURE [dbo].[uspARPopulateInvoiceAccountForPosting]
     @Post BIT = 0
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

IF @Post = 1
BEGIN
INSERT INTO #ARInvoiceItemAccount (
	  [intItemId]
	, [strItemNo]
	, [strType]
	, [intLocationId]
	, [intCOGSAccountId]
	, [intSalesAccountId]
	, [intInventoryAccountId]
	, [intInventoryInTransitAccountId]
	, [intGeneralAccountId]
	, [intOtherChargeIncomeAccountId]
	, [intAccountId]
	, [intDiscountAccountId]
	, [intMaintenanceSalesAccountId]
)
SELECT ARIA.[intItemId]
    , ARIA.[strItemNo]
    , ARIA.[strType]
    , ARIA.[intLocationId]
    , ARIA.[intCOGSAccountId]
    , ARIA.[intSalesAccountId]
    , ARIA.[intInventoryAccountId]
    , ARIA.[intInventoryInTransitAccountId]
    , ARIA.[intGeneralAccountId]
    , ARIA.[intOtherChargeIncomeAccountId]
    , ARIA.[intAccountId]
    , ARIA.[intDiscountAccountId]
    , ARIA.[intMaintenanceSalesAccountId]
FROM (
	SELECT DISTINCT [intItemId]
			      , [intCompanyLocationId]
	FROM #ARPostInvoiceDetail
	WHERE [intItemId] IS NOT NULL
) INV
INNER JOIN vyuARGetItemAccount ARIA ON INV.[intItemId] = ARIA.[intItemId]
								   AND INV.[intCompanyLocationId] = ARIA.[intLocationId]

INSERT INTO #ARInvoiceItemAccount (
	  [intItemId]
	, [strItemNo]
	, [strType]
	, [intLocationId]
	, [intCOGSAccountId]
	, [intSalesAccountId]
	, [intInventoryAccountId]
	, [intInventoryInTransitAccountId]
	, [intGeneralAccountId]
	, [intOtherChargeIncomeAccountId]
	, [intAccountId]
	, [intDiscountAccountId]
	, [intMaintenanceSalesAccountId]
)
SELECT ARIA.[intItemId]
    , ARIA.[strItemNo]
    , ARIA.[strType]
    , ARIA.[intLocationId]
    , ARIA.[intCOGSAccountId]
    , ARIA.[intSalesAccountId]
    , ARIA.[intInventoryAccountId]
    , ARIA.[intInventoryInTransitAccountId]
    , ARIA.[intGeneralAccountId]
    , ARIA.[intOtherChargeIncomeAccountId]
    , ARIA.[intAccountId]
    , ARIA.[intDiscountAccountId]
    , ARIA.[intMaintenanceSalesAccountId]
FROM (
	SELECT DISTINCT ARIC.[intComponentItemId]
			      , ARI.[intCompanyLocationId]
	FROM vyuARGetItemComponents ARIC
	INNER JOIN #ARPostInvoiceDetail ARI ON ARIC.[intItemId] = ARI.[intItemId]
	WHERE ARI.[intInvoiceDetailId] IS NOT NULL
	  AND NOT EXISTS(SELECT NULL FROM #ARInvoiceItemAccount IA WHERE ARIC.[intComponentItemId] = IA.[intItemId] AND ARI.[intCompanyLocationId] = IA.[intLocationId])
) INV
INNER JOIN vyuARGetItemAccount ARIA ON INV.[intComponentItemId] = ARIA.[intItemId]
								   AND INV.[intCompanyLocationId] = ARIA.[intLocationId]
END

RETURN 1
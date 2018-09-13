CREATE FUNCTION [dbo].[fnARGetItemAccounts]
(
	 @InvoicePostingTable	[dbo].[InvoicePostingTable] READONLY 
)
RETURNS @returntable TABLE
(
	 [intItemId]                         INT                                             NOT NULL
    ,[strItemNo]                         NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[strType]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[intLocationId]                     INT                                             NOT NULL 
    ,[intCOGSAccountId]                  INT                                             NULL
    ,[intSalesAccountId]                 INT                                             NULL
    ,[intInventoryAccountId]             INT                                             NULL
    ,[intInventoryInTransitAccountId]    INT                                             NULL
    ,[intGeneralAccountId]               INT                                             NULL
    ,[intOtherChargeIncomeAccountId]     INT                                             NULL
    ,[intAccountId]                      INT                                             NULL
    ,[intDiscountAccountId]              INT                                             NULL
    ,[intMaintenanceSalesAccountId]      INT                                             NULL
)
AS
BEGIN

INSERT INTO @returntable
	([intItemId]
	,[strItemNo]
	,[strType]
	,[intLocationId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intInventoryInTransitAccountId]
	,[intGeneralAccountId]
	,[intOtherChargeIncomeAccountId]
	,[intAccountId]
	,[intDiscountAccountId]
	,[intMaintenanceSalesAccountId])
SELECT
     ARIA.[intItemId]
    ,ARIA.[strItemNo]
    ,ARIA.[strType]
    ,ARIA.[intLocationId]
    ,ARIA.[intCOGSAccountId]
    ,ARIA.[intSalesAccountId]
    ,ARIA.[intInventoryAccountId]
    ,ARIA.[intInventoryInTransitAccountId]
    ,ARIA.[intGeneralAccountId]
    ,ARIA.[intOtherChargeIncomeAccountId]
    ,ARIA.[intAccountId]
    ,ARIA.[intDiscountAccountId]
    ,ARIA.[intMaintenanceSalesAccountId]
FROM
	(
	SELECT DISTINCT
		 ARI.[intItemId]
		,ARI.[intCompanyLocationId]
	FROM
		@InvoicePostingTable ARI
    WHERE
        ARI.[intInvoiceDetailId] IS NOT NULL
	) INV
INNER JOIN
    vyuARGetItemAccount ARIA
        ON INV.[intItemId] = ARIA.[intItemId]
		AND INV.[intCompanyLocationId] = ARIA.[intLocationId]


INSERT INTO @returntable
	([intItemId]
	,[strItemNo]
	,[strType]
	,[intLocationId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intInventoryInTransitAccountId]
	,[intGeneralAccountId]
	,[intOtherChargeIncomeAccountId]
	,[intAccountId]
	,[intDiscountAccountId]
	,[intMaintenanceSalesAccountId])
SELECT
     ARIA.[intItemId]
    ,ARIA.[strItemNo]
    ,ARIA.[strType]
    ,ARIA.[intLocationId]
    ,ARIA.[intCOGSAccountId]
    ,ARIA.[intSalesAccountId]
    ,ARIA.[intInventoryAccountId]
    ,ARIA.[intInventoryInTransitAccountId]
    ,ARIA.[intGeneralAccountId]
    ,ARIA.[intOtherChargeIncomeAccountId]
    ,ARIA.[intAccountId]
    ,ARIA.[intDiscountAccountId]
    ,ARIA.[intMaintenanceSalesAccountId]
FROM
	(
	SELECT DISTINCT
		ARIC.[intComponentItemId]
		,ARI.[intCompanyLocationId]
	FROM
		vyuARGetItemComponents ARIC
	INNER JOIN
		@InvoicePostingTable ARI
			ON ARIC.[intItemId] = ARI.[intItemId]
	WHERE
        ARI.[intInvoiceDetailId] IS NOT NULL
		AND NOT EXISTS(SELECT NULL FROM @returntable IA WHERE ARIC.[intComponentItemId] = IA.[intItemId] AND ARI.[intCompanyLocationId] = IA.[intLocationId])
	) INV
INNER JOIN
    vyuARGetItemAccount ARIA
        ON INV.[intComponentItemId] = ARIA.[intItemId]
		AND INV.[intCompanyLocationId] = ARIA.[intLocationId]
    

RETURN
END

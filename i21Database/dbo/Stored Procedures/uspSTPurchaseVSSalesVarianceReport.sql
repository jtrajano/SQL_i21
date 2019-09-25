CREATE PROCEDURE uspSTPurchaseVSSalesVarianceReport
	@strCategoryIdList AS NVARCHAR(MAX) = '',
	@dblVarianceQuantity AS NUMERIC(18,6),
	@dblVariancePercentage AS NUMERIC(18,6) ,
	@dtmPostedDateFrom AS DATETIME,
	@dtmPostedDateTo AS DATETIME
AS
BEGIN

DECLARE @tblSTPurchaseVSSalesVarianceReportTemp TABLE
(
	intPurchaseVSSalesVarianceReportId	int
	,intStoreId							int
	,intStoreNo							int
	,strStoreDescription				nvarchar(max)
	,intCategoryId						int
	,strCategoryCode					nvarchar(max)
	,strCategoryDescription				nvarchar(max)
	,intItemId							int
	,strItemNo							nvarchar(max)
	,strItemDescription					nvarchar(max)
	,dblSalesQuantity					numeric(18,6)
	,dblPurchaseQuantity				numeric(18,6)
	,dblVarianceQuantity				numeric(18,6)
	,dblVariancePercentage				numeric(18,6)
	,intInvoiceId						int
	,dtmCheckoutDate					datetime
	,intLocationId						int
	,intItemLocationId					int
	,intCompanyLocationId				int
	,intConcurrencyId					int
)

--INSERT TO TEMP TABLE--
INSERT INTO @tblSTPurchaseVSSalesVarianceReportTemp (
	 intStoreId
	,intStoreNo
	,strStoreDescription
	,intCategoryId
	,strCategoryCode
	,strCategoryDescription
	,intItemId
	,strItemNo
	,strItemDescription
	,intInvoiceId
	,dtmCheckoutDate
	,intItemLocationId
	,intCompanyLocationId
)

SELECT 
	  ST.intStoreId
	, ST.intStoreNo
	, ST.strDescription as strStoreDescription
	, category.intCategoryId
	, category.strCategoryCode 
	, category.strDescription as strCategoryDescription
	, Item.intItemId
	, Item.strItemNo
	, Item.strDescription AS strItemDescription
	-------------extras-------------
	,CH.intInvoiceId
	,CH.dtmCheckoutDate
	,ItemLoc.intItemLocationId
	,CL.intCompanyLocationId
FROM tblSTCheckoutItemMovements IM
LEFT JOIN tblSTCheckoutHeader CH
	ON IM.intCheckoutId = CH.intCheckoutId
LEFT JOIN tblSTStore ST
	ON CH.intStoreId = ST.intStoreId
LEFT JOIN tblSMCompanyLocation CL	
	ON ST.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN dbo.tblICItemUOM UOM 
	ON UOM.intItemUOMId = IM.intItemUPCId
LEFT JOIN tblICItem Item
	ON UOM.intItemId = Item.intItemId
LEFT JOIN tblICItemLocation ItemLoc
	ON Item.intItemId = ItemLoc.intItemId
	AND CL.intCompanyLocationId  = ItemLoc.intLocationId
LEFT JOIN tblICCategory as category 
ON category.intCategoryId = Item.intCategoryId
WHERE   (
		Item.intCategoryId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryIdList))
				OR 1 = CASE 
							WHEN @strCategoryIdList = ''
								THEN 1
							ELSE 0
					   END
			)
		AND (
				CH.dtmCheckoutDate BETWEEN @dtmPostedDateFrom AND @dtmPostedDateTo
				OR 1 = CASE 
							WHEN @dtmPostedDateFrom IS NULL AND @dtmPostedDateTo IS NULL
								THEN 1
							ELSE 0
					   END
			)

--UPDATE SALES QTY--
UPDATE @tblSTPurchaseVSSalesVarianceReportTemp 
SET dblSalesQuantity = arInvoice.dblQuantity
FROM (
	SELECT invoiceDetail.intInvoiceId
	, SUM(dblQtyShipped) as dblQuantity
	, intItemId
	, intCompanyLocationId
	FROM tblARInvoice as invoice
	LEFT JOIN tblARInvoiceDetail as invoiceDetail
	ON invoice.intInvoiceId = invoiceDetail.intInvoiceId 
	GROUP BY 
	invoiceDetail.intInvoiceId,
	invoiceDetail.intItemId,
	invoice.intCompanyLocationId
) as arInvoice
WHERE arInvoice.intInvoiceId = [@tblSTPurchaseVSSalesVarianceReportTemp].intInvoiceId 
AND arInvoice.intItemId = [@tblSTPurchaseVSSalesVarianceReportTemp].intItemId
AND arInvoice.intCompanyLocationId =  [@tblSTPurchaseVSSalesVarianceReportTemp].intCompanyLocationId



--CLEAN AND INSERT STORE ITEMS--
DELETE FROM tblSTPurchaseVSSalesVarianceReport
INSERT INTO tblSTPurchaseVSSalesVarianceReport
(
	 intStoreId
	,intStoreNo
	,strStoreDescription
	,intCategoryId
	,strCategoryCode
	,strCategoryDescription
	,intItemId
	,strItemNo
	,strItemDescription
	,intItemLocationId
	,dblSalesQuantity
	,intCompanyLocationId
)
SELECT
	intStoreId
	,intStoreNo
	,strStoreDescription
	,intCategoryId
	,strCategoryCode
	,strCategoryDescription
	,intItemId
	,strItemNo
	,strItemDescription
	,intItemLocationId
	,SUM(dblSalesQuantity)
	,intCompanyLocationId
FROM @tblSTPurchaseVSSalesVarianceReportTemp
GROUP BY 
intStoreId, 
intStoreNo, 
strStoreDescription,
intCategoryId, 
strCategoryCode, 
strCategoryDescription, 
intItemId, 
strItemNo, 
strItemDescription,
intItemLocationId,
intCompanyLocationId



--UPDATE PURCHASE QTY--
UPDATE tblSTPurchaseVSSalesVarianceReport 
SET dblPurchaseQuantity = ISNULL(inventory.dblQty,0)
FROM (
	SELECT	t.intItemId,
			t.intCategoryId,
			t.dblQty,
			t.intItemLocationId
	FROM	tblICInventoryTransaction t
			INNER JOIN tblICInventoryTransactionType ty
				ON ty.intTransactionTypeId = t.intTransactionTypeId
	WHERE	ty.strName = 'Inventory Receipt'
	) as inventory
		WHERE 
		inventory.intItemId = tblSTPurchaseVSSalesVarianceReport.intItemId
		AND inventory.intCategoryId = tblSTPurchaseVSSalesVarianceReport.intCategoryId
		AND inventory.intItemLocationId =  tblSTPurchaseVSSalesVarianceReport.intItemLocationId


UPDATE tblSTPurchaseVSSalesVarianceReport
SET dblVarianceQuantity = ISNULL(dblSalesQuantity,0) - ISNULL(dblPurchaseQuantity,0)
WHERE 
		tblSTPurchaseVSSalesVarianceReport.intItemId = tblSTPurchaseVSSalesVarianceReport.intItemId
		AND tblSTPurchaseVSSalesVarianceReport.intCategoryId = tblSTPurchaseVSSalesVarianceReport.intCategoryId
		AND tblSTPurchaseVSSalesVarianceReport.intItemLocationId =  tblSTPurchaseVSSalesVarianceReport.intItemLocationId
		AND tblSTPurchaseVSSalesVarianceReport.intCompanyLocationId =  tblSTPurchaseVSSalesVarianceReport.intCompanyLocationId

UPDATE tblSTPurchaseVSSalesVarianceReport
SET dblVariancePercentage = CASE WHEN (dblSalesQuantity IS NULL OR dblSalesQuantity = 0) 
							THEN 0 
							ELSE ISNULL(dblVarianceQuantity,0) / ISNULL(dblSalesQuantity,0)
					      END
WHERE 
			tblSTPurchaseVSSalesVarianceReport.intItemId = tblSTPurchaseVSSalesVarianceReport.intItemId
		AND tblSTPurchaseVSSalesVarianceReport.intCategoryId = tblSTPurchaseVSSalesVarianceReport.intCategoryId
		AND tblSTPurchaseVSSalesVarianceReport.intItemLocationId =  tblSTPurchaseVSSalesVarianceReport.intItemLocationId
		AND tblSTPurchaseVSSalesVarianceReport.intCompanyLocationId =  tblSTPurchaseVSSalesVarianceReport.intCompanyLocationId


SELECT * FROM tblSTPurchaseVSSalesVarianceReport
WHERE   (
		dblVarianceQuantity = @dblVarianceQuantity
		OR 1 = CASE 
					WHEN ISNULL(@dblVarianceQuantity,0) = 0
						THEN 1
					ELSE 0
				END
	)
	AND 
	 (
		dblVariancePercentage = @dblVariancePercentage
		OR 1 = CASE 
					WHEN ISNULL(@dblVariancePercentage,0) = 0
						THEN 1
					ELSE 0
				END
	)



END
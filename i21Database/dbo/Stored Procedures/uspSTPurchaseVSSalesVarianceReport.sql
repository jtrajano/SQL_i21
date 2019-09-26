CREATE PROCEDURE uspSTPurchaseVSSalesVarianceReport
	@strCategoryIdList AS NVARCHAR(MAX) = '',
	@dblVarianceQuantity AS NUMERIC(18,6),
	@dblVariancePercentage AS NUMERIC(18,6) ,
	@dtmCheckoutDateFrom AS DATETIME,
	@dtmCheckoutDateTo AS DATETIME
AS
BEGIN

DECLARE @tblSTPurchaseVSSalesVarianceReportTemp TABLE
(
	intPurchaseVSSalesVarianceReportId	int				NOT NULL identity(1,1)
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


DECLARE @tblSTPurchaseVSSalesVarianceReportOutput TABLE
(
	intPurchaseVSSalesVarianceReportId	int				NOT NULL identity(1,1)
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
				CH.dtmCheckoutDate BETWEEN @dtmCheckoutDateFrom AND @dtmCheckoutDateTo
				OR 1 = CASE 
							WHEN @dtmCheckoutDateFrom IS NULL AND @dtmCheckoutDateTo IS NULL
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


--INSERT INTO OUTPUT TABLE--
INSERT INTO @tblSTPurchaseVSSalesVarianceReportOutput
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
UPDATE @tblSTPurchaseVSSalesVarianceReportOutput
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
		inventory.intItemId = [@tblSTPurchaseVSSalesVarianceReportOutput].intItemId
		AND inventory.intCategoryId = [@tblSTPurchaseVSSalesVarianceReportOutput].intCategoryId
		AND inventory.intItemLocationId =  [@tblSTPurchaseVSSalesVarianceReportOutput].intItemLocationId


UPDATE @tblSTPurchaseVSSalesVarianceReportOutput
SET dblVarianceQuantity = ISNULL(dblSalesQuantity,0) - ISNULL(dblPurchaseQuantity,0)
WHERE 
		[@tblSTPurchaseVSSalesVarianceReportOutput].intItemId = [@tblSTPurchaseVSSalesVarianceReportOutput].intItemId
		AND [@tblSTPurchaseVSSalesVarianceReportOutput].intCategoryId = [@tblSTPurchaseVSSalesVarianceReportOutput].intCategoryId
		AND [@tblSTPurchaseVSSalesVarianceReportOutput].intItemLocationId =  [@tblSTPurchaseVSSalesVarianceReportOutput].intItemLocationId
		AND [@tblSTPurchaseVSSalesVarianceReportOutput].intCompanyLocationId =  [@tblSTPurchaseVSSalesVarianceReportOutput].intCompanyLocationId

UPDATE @tblSTPurchaseVSSalesVarianceReportOutput
SET dblVariancePercentage = CASE WHEN (dblSalesQuantity IS NULL OR dblSalesQuantity = 0) 
							THEN 0 
							ELSE ISNULL(dblVarianceQuantity,0) / ISNULL(dblSalesQuantity,0)
					      END
WHERE 
			[@tblSTPurchaseVSSalesVarianceReportOutput].intItemId = [@tblSTPurchaseVSSalesVarianceReportOutput].intItemId
		AND [@tblSTPurchaseVSSalesVarianceReportOutput].intCategoryId = [@tblSTPurchaseVSSalesVarianceReportOutput].intCategoryId
		AND [@tblSTPurchaseVSSalesVarianceReportOutput].intItemLocationId =  [@tblSTPurchaseVSSalesVarianceReportOutput].intItemLocationId
		AND [@tblSTPurchaseVSSalesVarianceReportOutput].intCompanyLocationId =  [@tblSTPurchaseVSSalesVarianceReportOutput].intCompanyLocationId


SELECT * FROM @tblSTPurchaseVSSalesVarianceReportOutput
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
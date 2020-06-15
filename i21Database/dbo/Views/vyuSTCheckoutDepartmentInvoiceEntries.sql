CREATE VIEW vyuSTCheckoutDepartmentInvoiceEntries
AS
SELECT DT.intDepartmentTotalId
       , DT.intCheckoutId
	   , DT.intCategoryId
	   , Item.intItemId

	   , Item.strItemNo
       , Cat.strCategoryCode
	   , DT.dblManagerDiscountAmount
	   , DT.dblPromotionalDiscountAmount
	   , DT.dblRefundAmount
	   , DT.intItemsSold
	   , DT.dblTotalSalesAmountComputed
	   , CASE
			WHEN PT.intCheckoutId IS NOT NULL
				THEN 'PumpTotals'
			WHEN IM.intCheckoutId IS NOT NULL
				THEN 'ItemMovements'
		END COLLATE Latin1_General_CI_AS AS strSubType
	   , CASE
			WHEN PT.intCheckoutId IS NOT NULL
				THEN PT.dblQty
			WHEN IM.intCheckoutId IS NOT NULL
				THEN IM.dblQty
			ELSE 0
		END AS dblSubTotalQty
		-- DISCOUNT (Only Item Movement has discounts)
		, CASE
			WHEN IM.intCheckoutId IS NOT NULL
				THEN 
					IM.dblDiscountAmount
			ELSE 0
		END AS dblSubTotalDiscount
	   , CASE
			WHEN PT.intCheckoutId IS NOT NULL
				THEN PT.dblTotalAmount
			WHEN IM.intCheckoutId IS NOT NULL
				THEN IM.dblTotalAmount
			ELSE 0
		END AS dblSubTotalSales

		-- QTY
	   , CASE
			WHEN PT.intCheckoutId IS NOT NULL
				THEN 
					-- =============================================
					-- PUMP TOTALS
					-- =============================================
					CASE 
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) > ISNULL(PT.dblTotalAmount, 0))
							THEN 1
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) < ISNULL(PT.dblTotalAmount, 0))
							THEN -1
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) = ISNULL(PT.dblTotalAmount, 0))
							THEN 0
					END
			WHEN IM.intCheckoutId IS NOT NULL
				THEN 
					-- =============================================
					-- ITEM MOVEMENTS
					-- =============================================
					CASE 
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0)) > 0
							THEN 1
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0)) < 0
							THEN -1
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0)) = 0
							THEN 0
					END
			WHEN (PT.intCheckoutId IS NULL AND IM.intCheckoutId IS NULL)
				THEN 
					-- =============================================
					-- DEPARTMENT TOTALS
					-- =============================================
					CASE 
						WHEN ISNULL(DT.dblTotalSalesAmountComputed, 0) > 0
							THEN 1
						WHEN ISNULL(DT.dblTotalSalesAmountComputed, 0) < 0
							THEN -1
						WHEN ISNULL(DT.dblTotalSalesAmountComputed, 0) = 0
							THEN 0
					END
			ELSE 0
		END AS dblCalculatedInvoiceQty

		-- PRICE
		, CASE
			WHEN PT.intCheckoutId IS NOT NULL
				THEN 
					-- =============================================
					-- PUMP TOTALS
					-- =============================================
					CASE 
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) > ISNULL(PT.dblTotalAmount, 0))
							THEN DT.dblTotalSalesAmountComputed - ISNULL(PT.dblTotalAmount, 0)
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) < ISNULL(PT.dblTotalAmount, 0))
							THEN ABS(ISNULL(PT.dblTotalAmount, 0) - DT.dblTotalSalesAmountComputed)
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) = ISNULL(PT.dblTotalAmount, 0))
							THEN 0
					END
			WHEN IM.intCheckoutId IS NOT NULL
				THEN 
					-- =============================================
					-- ITEM MOVEMENTS
					-- =============================================
					CASE 
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0)) > 0
							THEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0))
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0)) < 0
							THEN ABS(ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0))
						WHEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0)) = 0
							THEN (ISNULL(DT.dblTotalSalesAmountComputed, 0) - ISNULL(IM.dblTotalAmount, 0))
					END
			WHEN (PT.intCheckoutId IS NULL AND IM.intCheckoutId IS NULL)
				THEN 
					-- =============================================
					-- DEPARTMENT TOTALS
					-- =============================================
					CASE 
						WHEN ISNULL(DT.dblTotalSalesAmountComputed, 0) > 0
							THEN ISNULL(DT.dblTotalSalesAmountComputed, 0)
						WHEN ISNULL(DT.dblTotalSalesAmountComputed, 0) < 0
							THEN ABS(ISNULL(DT.dblTotalSalesAmountComputed, 0))
						WHEN ISNULL(DT.dblTotalSalesAmountComputed, 0) = 0
							THEN ISNULL(DT.dblTotalSalesAmountComputed, 0)
					END
			ELSE 0
		END AS dblCalculatedInvoicePrice
FROM tblSTCheckoutDepartmetTotals DT
INNER JOIN tblICItem Item
	ON DT.intItemId = Item.intItemId
INNER JOIN tblICCategory Cat
	ON DT.intCategoryId = Cat.intCategoryId
LEFT JOIN 
(
	SELECT sPT.intCheckoutId
	       , sPT.intCategoryId
		   , SUM(sPT.dblQuantity) AS dblQty
		   , SUM(sPT.dblAmount) AS dblTotalAmount
	FROM tblSTCheckoutPumpTotals sPT
	GROUP BY sPT.intCheckoutId, sPT.intCategoryId
) AS PT
	ON DT.intCheckoutId = PT.intCheckoutId
	AND DT.intCategoryId = PT.intCategoryId
LEFT JOIN 
(
	SELECT sIM.intCheckoutId
	       , sItem.intCategoryId
		   , SUM(sIM.intQtySold) AS dblQty
		   , SUM(sIM.dblDiscountAmount)  AS dblDiscountAmount
		   , SUM(sIM.dblGrossSales) AS dblGrossSales
		   , SUM(sIM.dblTotalSales) AS dblTotalAmount
	FROM tblSTCheckoutItemMovements sIM
	INNER JOIN tblICItemUOM sUOM
		ON sIM.intItemUPCId = sUOM.intItemUOMId
	INNER JOIN tblICItem sItem
		ON sItem.intItemId = sUOM.intItemId
	GROUP BY sIM.intCheckoutId, sItem.intCategoryId
) AS IM
	ON DT.intCheckoutId = IM.intCheckoutId
	AND DT.intCategoryId = IM.intCategoryId
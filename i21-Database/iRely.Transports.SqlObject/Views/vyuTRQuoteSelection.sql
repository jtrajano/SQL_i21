CREATE VIEW [dbo].[vyuTRQuoteSelection]
	AS 

SELECT QT.intCustomerRackQuoteHeaderId
	, QT.intEntityCustomerLocationId
	, QT.intSupplyPointId
	, QT.intItemId
	, QT.intCategoryId
	, QT.intEntityCustomerId
	, QT.ysnQuote
FROM (SELECT QH.intCustomerRackQuoteHeaderId
			, QV.intEntityCustomerLocationId
			, QV.intSupplyPointId
			, QI.intItemId
			, IC.intCategoryId
			, QH.intEntityCustomerId
			, QV.ysnQuote
		FROM tblARCustomerRackQuoteHeader QH
		LEFT JOIN tblARCustomerRackQuoteItem QI ON QI.intCustomerRackQuoteHeaderId = QH.intCustomerRackQuoteHeaderId
		LEFT JOIN tblARCustomerRackQuoteVendor QV ON QV.intCustomerRackQuoteHeaderId = QH.intCustomerRackQuoteHeaderId
		JOIN vyuICGetItemStock IC ON IC.intItemId = QI.intItemId
		
		UNION ALL
		SELECT QH.intCustomerRackQuoteHeaderId
			, QV.intEntityCustomerLocationId
			, QV.intSupplyPointId
			, IC.intItemId
			, QC.intCategoryId
			, QH.intEntityCustomerId
			, QV.ysnQuote
		FROM tblARCustomerRackQuoteHeader QH
		LEFT JOIN tblARCustomerRackQuoteCategory QC ON QH.intCustomerRackQuoteHeaderId = QC.intCustomerRackQuoteHeaderId
		LEFT JOIN tblARCustomerRackQuoteVendor QV ON QV.intCustomerRackQuoteHeaderId = QH.intCustomerRackQuoteHeaderId
		JOIN vyuICGetItemStock IC ON IC.intCategoryId = QC.intCategoryId) QT
GROUP BY QT.intCustomerRackQuoteHeaderId
	, QT.intEntityCustomerLocationId
	, QT.intSupplyPointId
	, QT.intItemId
	, QT.intCategoryId
	, QT.intEntityCustomerId
	, QT.ysnQuote
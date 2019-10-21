CREATE VIEW [dbo].[vyuTMDeliveryFillWithItemPriceReport]
AS

SELECT 
	B.intSiteId
	,dblProductCost = COALESCE(B.dblCallEntryPrice
								,(CASE WHEN A.strSpecialPricing LIKE '%Inventory - Standard Pricing%' OR  strSpecialPricing LIKE '%Inventory - Pricing Level%' OR strSpecialPricing LIKE '%Inventory - Special Pricing%' OR strSpecialPricing LIKE '%Inventory Promotional Pricing%'
									THEN A.dblPrice + ISNULL(C. dblPriceAdjustment,0.) 
									ELSE A.dblPrice END)) 
FROM vyuTMDeliveryFillReport B
INNER JOIN tblTMSite C
	ON B.intSiteId = C.intSiteID
CROSS APPLY (
	SELECT TOP 1 dblPrice,strSpecialPricing FROM dbo.[fnTMGetSpecialPricingPriceTable](
							B.strCustomerNumber
							,B.strProductId
							,CAST(B.strLocation AS NVARCHAR(5))
							,B.strItemClass
							,(CASE WHEN B.dtmCallInDate IS NULL THEN GETDATE() ELSE B.dtmCallInDate END)
							,B.dblQuantity
							,NULL,B.intSiteId)
) A

GO




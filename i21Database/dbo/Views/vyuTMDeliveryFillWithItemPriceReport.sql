CREATE VIEW [dbo].[vyuTMDeliveryFillWithItemPriceReport]
AS

SELECT 
	B.intSiteId
	,dblProductCost = COALESCE(dblCallEntryPrice,A.dblPrice) 
FROM vyuTMDeliveryFillReport B
CROSS APPLY (
	SELECT TOP 1 dblPrice FROM dbo.[fnTMGetSpecialPricingPriceTable](
							strCustomerNumber
							,strProductId
							,CAST(strLocation AS NVARCHAR(5))
							,strItemClass
							,(CASE WHEN dtmCallInDate IS NULL THEN GETDATE() ELSE dtmCallInDate END)
							,dblQuantity
							,NULL,intSiteId)
) A

GO




CREATE VIEW [dbo].[vyuICGetInventoryValuationDetail]
AS

SELECT 
	Valuation.*
	strSummaryLocationName = COALESCE(Valuation.strInTransitSourceLocationName, Valuation.strLocationName) 
FROM 
vyuICGetInventoryValuation Valuation
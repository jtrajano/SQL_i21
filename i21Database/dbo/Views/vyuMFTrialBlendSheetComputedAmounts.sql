CREATE VIEW [dbo].[vyuMFTrialBlendSheetComputedAmounts]
AS
SELECT * 
FROM
(SELECT SUM(dblWeight)															AS dblTotalWeight
	  , SUM(dblBags)															AS dblTotalBags
	  , ISNULL(SUM(dblWeight * dblSellingPrice) / NULLIF(SUM(dblWeight), 0), 0)	AS dblWAvgSellingPrice
	  , ISNULL(SUM(dblWeight * dblLandedPrice) / NULLIF(SUM(dblWeight), 0), 0)	AS dblWAvgLandedPrice
	  , ISNULL(SUM(dblWeight * dblT) / NULLIF(SUM(dblWeight), 0), 0)			AS dblWAvgT
	  , ISNULL(SUM(dblWeight * dblH) / NULLIF(SUM(dblWeight), 0), 0)			AS dblWAvgH
	  , ISNULL(SUM(dblWeight * dblI) / NULLIF(SUM(dblWeight), 0), 0)			AS dblWAvgI
	  , ISNULL(SUM(dblWeight * dblM) / NULLIF(SUM(dblWeight), 0), 0)			AS dblWAvgM
	  , ISNULL(SUM(dblWeight * dblA) / NULLIF(SUM(dblWeight), 0), 0)			AS dblWAvgA
	  , ISNULL(SUM(dblWeight * dblV) / NULLIF(SUM(dblWeight), 0), 0)			AS dblWAvgV
	  , intWorkOrderId
FROM vyuMFTrialBlendSheetDetail
GROUP BY intWorkOrderId) x

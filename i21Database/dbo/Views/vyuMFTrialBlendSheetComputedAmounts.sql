CREATE VIEW [dbo].[vyuMFTrialBlendSheetComputedAmounts]
AS
SELECT * FROM
(SELECT 
 SUM(dblWeight)[dblTotalWeight]
,SUM(dblBags)[dblTotalBags]
,SUM(dblWeight*dblSellingPrice )/SUM(dblWeight) dblWAvgSellingPrice
,SUM(dblWeight*dblLandedPrice )/SUM(dblWeight) dblWAvgLandedPrice
,SUM(dblWeight*dblT )/SUM(dblWeight) dblWAvgT
,SUM(dblWeight*dblH )/SUM(dblWeight) dblWAvgH
,SUM(dblWeight*dblI )/SUM(dblWeight) dblWAvgI
,SUM(dblWeight*dblM )/SUM(dblWeight) dblWAvgM
,SUM(dblWeight*dblA )/SUM(dblWeight) dblWAvgA
,SUM(dblWeight*dblV )/SUM(dblWeight) dblWAvgV
,intWorkOrderId
from vyuMFTrialBlendSheetDetail
GROUP BY intWorkOrderId)x

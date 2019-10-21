CREATE VIEW [dbo].[vyuMFGetQualityComparison]
	AS 

Select t1.intWorkOrderRecipeComputationId,t1.intWorkOrderId,t1.strWorkOrderNo,t1.strERPOrderNo,t1.strItemNo,t1.strTestName,t1.strPropertyName,t1.dblMinValue,t1.dblMaxValue,
ISNULL(t1.dblComputedValue,0) AS dblExpectedValue,ISNULL(t2.dblComputedValue,0) AS dblActualValue,ISNULL(t1.dblComputedValue,0)-ISNULL(t2.dblComputedValue,0) AS dblDifferenceValue
From 
(
SELECT 
wc.intWorkOrderRecipeComputationId,w.intWorkOrderId,w.strWorkOrderNo,w.strERPOrderNo,i.strItemNo,t.intTestId,t.strTestName,p.intPropertyId,p.strPropertyName,wc.dblMinValue,wc.dblMaxValue,wc.dblComputedValue 
FROM tblMFWorkOrderRecipeComputation wc 
Join tblMFWorkOrder w on wc.intWorkOrderId=w.intWorkOrderId
Join tblICItem i on w.intItemId=i.intItemId
Join tblQMProperty p on wc.intPropertyId=p.intPropertyId
Join tblQMTest t on wc.intTestId=t.intTestId
Where wc.intTypeId=1 --Blend Management
) t1
Left Join
(
SELECT 
w.intWorkOrderId,w.strWorkOrderNo,w.strERPOrderNo,i.strItemNo,t.intTestId,t.strTestName,p.intPropertyId,p.strPropertyName,wc.dblMinValue,wc.dblMaxValue,wc.dblComputedValue 
FROM tblMFWorkOrderRecipeComputation wc 
Join tblMFWorkOrder w on wc.intWorkOrderId=w.intWorkOrderId
Join tblICItem i on w.intItemId=i.intItemId
Join tblQMProperty p on wc.intPropertyId=p.intPropertyId
Join tblQMTest t on wc.intTestId=t.intTestId
Where wc.intTypeId=2 --Blend Production
) t2 ON t1.intWorkOrderId=t2.intWorkOrderId AND t1.intPropertyId=t2.intPropertyId AND t1.intTestId=t2.intTestId


CREATE PROCEDURE uspMFGetGRNIntakeComparison (@intWorkOrderId INT)
AS
DECLARE @tblMFLot TABLE (intLotId INT)

INSERT INTO @tblMFLot (intLotId)
SELECT OM.intLotId
FROM tblMFWorkOrder W
JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
WHERE W.intWorkOrderId = @intWorkOrderId

SELECT P.intPropertyId
	,P.strPropertyName
	,Convert(NUMERIC(38, 20), TR.strPropertyValue) AS strPropertyValue
INTO #GRN
FROM @tblMFLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
JOIN tblQMSample S ON S.intProductValueId = L.intLotId
	AND S.intProductTypeId = 6
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 6

SELECT P.intPropertyId
	,P.strPropertyName
	,Convert(NUMERIC(38, 20), TR.strPropertyValue) AS strPropertyValue
INTO #IP
FROM @tblMFLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
JOIN tblQMSample S ON S.intProductValueId = L.intLotId
	AND S.intProductTypeId = 6
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 9

SELECT G.intPropertyId
	,G.strPropertyName
	,AVG(G.strPropertyValue) AS [Estimated Output %]
	,AVG(I.strPropertyValue) AS [Issue to Mill %]
	,AVG(I.strPropertyValue) - AVG(G.strPropertyValue) [% Variance]
FROM #GRN G
LEFT JOIN #IP I ON I.intPropertyId = G.intPropertyId
GROUP BY G.intPropertyId
	,G.strPropertyName

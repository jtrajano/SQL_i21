CREATE PROCEDURE uspMFGetGRNIntakeComparison (@intWorkOrderId INT)
AS
DECLARE @tblMFLot TABLE (intLotId INT)
DECLARE @tblMFFinalLot TABLE (
	intLotId INT
	,strLotNumber NVARCHAR(50) collate Latin1_General_CI_AS
	)

INSERT INTO @tblMFLot (intLotId)
SELECT OM.intLotId
FROM tblMFWorkOrder W
JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
WHERE W.intWorkOrderId = @intWorkOrderId

INSERT INTO @tblMFLot (intLotId)
SELECT WI.intLotId
FROM tblMFWorkOrderInputLot WI
WHERE WI.intWorkOrderId = @intWorkOrderId
	AND ysnConsumptionReversed = 0

INSERT INTO @tblMFFinalLot (
	intLotId
	,strLotNumber
	)
SELECT L.intLotId
	,L.strLotNumber
FROM tblICLot L
WHERE L.strLotNumber IN (
		SELECT L2.strLotNumber
		FROM @tblMFLot L1
		JOIN tblICLot L2 ON L1.intLotId = L2.intLotId
		)

DECLARE @tblMFGRN TABLE (
	intPropertyId INT
	,strPropertyName NVARCHAR(50) collate Latin1_General_CI_AS
	,strPropertyValue NUMERIC(38, 20)
	,intSequenceNo INT
	)

INSERT INTO @tblMFGRN (
	intPropertyId
	,strPropertyName
	,strPropertyValue
	,intSequenceNo
	)
SELECT P.intPropertyId
	,P.strPropertyName
		,SUM(IsNULL(TR.strPropertyValue,0)*S.dblRepresentingQty)/SUM(S.dblRepresentingQty) AS strPropertyValue
	,TR.intSequenceNo
FROM @tblMFFinalLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
	AND TR.intProductTypeId = 6
	AND ISNUMERIC(TR.strPropertyValue) = 1
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	AND P.intDataTypeId IN (
		1
		,2
		)
JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 5
	AND TR.intSampleId IN (
		SELECT Max(S1.intSampleId)
		FROM tblQMSample S1
		JOIN tblQMSampleType ST1 ON S1.intSampleTypeId = ST1.intSampleTypeId
		WHERE S1.intSampleStatusId = 3
			AND S1.strLotNumber = S.strLotNumber
			AND S1.intProductTypeId = 6
			AND ST1.intControlPointId = ST.intControlPointId
		)
Group by 
	P.intPropertyId
	,P.strPropertyName
	,TR.intSequenceNo


INSERT INTO @tblMFGRN (
	intPropertyId
	,strPropertyName
	,strPropertyValue
	,intSequenceNo
	)
SELECT P.intPropertyId
	,P.strPropertyName
	,SUM(IsNULL(TR.strPropertyValue,0)*S.dblRepresentingQty)/SUM(S.dblRepresentingQty) AS strPropertyValue
	,TR.intSequenceNo
FROM @tblMFFinalLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
	AND TR.intProductTypeId = 6
	AND ISNUMERIC(TR.strPropertyValue) = 1
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	AND P.intDataTypeId IN (
		1
		,2
		)
JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 9
	AND TR.intSampleId IN (
		SELECT Max(S1.intSampleId)
		FROM tblQMSample S1
		JOIN tblQMSampleType ST1 ON S1.intSampleTypeId = ST1.intSampleTypeId
		WHERE S1.intSampleStatusId = 3
			AND S1.strLotNumber = S.strLotNumber
			AND S1.intProductTypeId = 6
			AND ST1.intControlPointId = ST.intControlPointId
		)

Group by 
	P.intPropertyId
	,P.strPropertyName
	,TR.intSequenceNo

DECLARE @tblMFIP TABLE (
	intPropertyId INT
	,strPropertyName NVARCHAR(50) collate Latin1_General_CI_AS
	,strPropertyValue NUMERIC(38, 20)
	)

INSERT INTO @tblMFIP (
	intPropertyId
	,strPropertyName
	,strPropertyValue
	)
SELECT P.intPropertyId
	,P.strPropertyName
	,SUM(IsNULL(TR.strPropertyValue,0)*S.dblRepresentingQty)/SUM(S.dblRepresentingQty) AS strPropertyValue
FROM @tblMFFinalLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
	AND ISNUMERIC(TR.strPropertyValue) = 1
	AND TR.intProductTypeId = 6
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	AND P.intDataTypeId IN (
		1
		,2
		)
JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 6
	AND TR.intSampleId IN (
		SELECT Max(S1.intSampleId)
		FROM tblQMSample S1
		JOIN tblQMSampleType ST1 ON S1.intSampleTypeId = ST1.intSampleTypeId
		WHERE S1.intSampleStatusId = 3
			AND S1.strLotNumber = S.strLotNumber
			AND S1.intProductTypeId = 6
			AND ST1.intControlPointId = ST.intControlPointId
		)
Group by 
	P.intPropertyId
	,P.strPropertyName
	,TR.intSequenceNo


SELECT G.intPropertyId
	,G.strPropertyName
	,G.strPropertyValue AS dblEstimatedOutput
	,I.strPropertyValue AS dblIssuetoMill
	,I.strPropertyValue - G.strPropertyValue AS dblVariance
FROM @tblMFGRN G
LEFT JOIN @tblMFIP I ON I.intPropertyId = G.intPropertyId
ORDER BY G.intSequenceNo

CREATE PROCEDURE uspMFGetLotQualityOutturnDetail (
	@intWorkOrderId INT
	,@intUnitMeasureId INT
	,@intCurrencyId INT = 0
	)
AS
DECLARE @dtmCurrentDateTime DATETIME
	,@ysnSubCurrency BIT
	,@intSubCurrency INT

SELECT @dtmCurrentDateTime = Getdate()

SELECT @ysnSubCurrency = ysnSubCurrency
FROM tblSMCurrency
WHERE intCurrencyID = @intCurrencyId

IF @ysnSubCurrency = 1
BEGIN
	SELECT @intSubCurrency = 100
END
ELSE
BEGIN
	SELECT @intSubCurrency = 1
END

DECLARE @tblMFLot TABLE (
	intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	)
DECLARE @tblMFFinalLot TABLE (
	intLotId INT
	,strLotNumber NVARCHAR(50) collate Latin1_General_CI_AS
	)

INSERT INTO @tblMFLot (
	intLotId
	,intItemId
	,dblQty
	,intItemUOMId
	)
SELECT WI.intLotId
	,WI.intItemId
	,WI.dblQuantity
	,WI.intItemUOMId
FROM tblMFWorkOrderInputLot WI
WHERE WI.intWorkOrderId = @intWorkOrderId
	AND WI.ysnConsumptionReversed = 0

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

SELECT L.intItemId
	,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU.intItemUOMId, dblQty)) AS dblQty
INTO #StageQty
FROM @tblMFLot L
JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId
	AND IU.intUnitMeasureId = @intUnitMeasureId
GROUP BY L.intItemId

SELECT I.intItemId
	,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(WP.intItemUOMId, IU.intItemUOMId, WP.dblQuantity)) AS dblQuantity
INTO #tblMFWorkOrderProducedLot
FROM tblMFWorkOrderProducedLot WP
JOIN tblICItem I ON I.intItemId = WP.intItemId
JOIN tblICItemUOM IU ON IU.intItemId = WP.intItemId
	AND IU.intUnitMeasureId = @intUnitMeasureId
WHERE WP.intWorkOrderId = @intWorkOrderId
	AND ysnProductionReversed = 0
GROUP BY I.intItemId

SELECT intItemId
	,dblQuantity
	,CASE 
		WHEN Sum(WP.dblQuantity) OVER () = 0
			THEN 0
		ELSE (WP.dblQuantity / Sum(WP.dblQuantity) OVER ()) * 100
		END AS [strActualOutput]
INTO #tblMFFinalWorkOrderProducedLot
FROM #tblMFWorkOrderProducedLot WP

SELECT P.intPropertyId
	,P.strPropertyName
	,SUM(TR.strPropertyValue * S.dblRepresentingQty) / SUM(S.dblRepresentingQty) AS strPropertyValue
	,P.intItemId
	,Convert(NUMERIC(38, 20), NULL) AS dblExchangePrice
	,TR.intSequenceNo
INTO #GRN
FROM @tblMFFinalLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
	AND TR.intProductTypeId = 6
	AND TR.intControlPointId IN (
		5
		,9
		)
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	AND P.intDataTypeId IN (
		1
		,2
		)
	AND ISNUMERIC(TR.strPropertyValue) = 1
JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId IN (
		5
		,9
		)
	AND S.intSampleId IN (
		SELECT Max(S1.intSampleId)
		FROM tblQMSample S1
		JOIN tblQMSampleType ST1 ON S1.intSampleTypeId = ST1.intSampleTypeId
		WHERE S1.intSampleStatusId = 3
			AND S1.strLotNumber = S.strLotNumber
			AND S1.intProductTypeId = 6
			AND ST1.intControlPointId = ST.intControlPointId
		)
GROUP BY P.intPropertyId
	,P.strPropertyName
	,P.intItemId
	,TR.intSequenceNo

INSERT INTO #GRN (
	intPropertyId
	,strPropertyName
	,intItemId
	,intSequenceNo
	)
SELECT DISTINCT 0
	,''
	,intItemId
	,- 1
FROM #StageQty

SELECT intPropertyId
	,strPropertyName
	,IsNULL(strPropertyValue, 0) AS dblEstimatedOutput
	,I.strDescription AS strGrade
	,Convert(NUMERIC(38, 5), S.dblQty) AS dblInputWeight
	,Convert(NUMERIC(38, 5), WP.dblQuantity) AS dblOutputWeight
	,Convert(NUMERIC(38, 5), IsNULL(strActualOutput, 0)) AS dblActualOutput
	,Convert(NUMERIC(38, 5), (
			CASE 
				WHEN dblCoEfficient = 0
					THEN NULL
				ELSE (
						CASE 
							WHEN Sum(CASE 
										WHEN dblCoEfficient = 0
											THEN 0
										ELSE [strActualOutput]
										END) OVER () = 0
								THEN 0
							ELSE (
									[strActualOutput] / Sum(CASE 
											WHEN dblCoEfficient = 0
												THEN 0
											ELSE [strActualOutput]
											END) OVER ()
									) * 100
							END
						)
				END
			)) AS dblCleanGradeOutput
	,Convert(NUMERIC(38, 5), (
			(
				CASE 
					WHEN dblCoEfficient = 0
						THEN IsNULL(strActualOutput, 0)
					ELSE (
							CASE 
								WHEN Sum(CASE 
											WHEN dblCoEfficient = 0
												THEN 0
											ELSE IsNULL(strActualOutput, 0)
											END) OVER () = 0
									THEN 0
								ELSE (
										IsNULL(strActualOutput, 0) / Sum(CASE 
												WHEN dblCoEfficient = 0
													THEN 0
												ELSE IsNULL(strActualOutput, 0)
												END) OVER ()
										) * 100
								END
							)
					END
				) - IsNULL(strPropertyValue, 0)
			)) AS dblVariance
	,Convert(NUMERIC(38, 3), CASE 
			WHEN PS.ysnZeroCost = 1
				THEN NULL
			ELSE (PS.dblMarketRate / @intSubCurrency) / (dbo.[fnCTConvertQuantityToTargetItemUOM](G.intItemId, PS.intMarketRatePerUnitId, @intUnitMeasureId, 1))
			END) AS dblMarketPrice
	,Convert(NUMERIC(38, 3), CASE 
			WHEN PS.ysnZeroCost = 1
				THEN NULL
			ELSE dblGradeDiff / (dbo.[fnCTConvertQuantityToTargetItemUOM](G.intItemId, PS.intMarketRatePerUnitId, @intUnitMeasureId, 1))
			END) AS dblMarketDifferential
	,Convert(NUMERIC(38, 3), CASE 
			WHEN PS.ysnZeroCost = 1
				THEN NULL
			ELSE ((dblMarketRate / @intSubCurrency) / (dbo.[fnCTConvertQuantityToTargetItemUOM](G.intItemId, PS.intMarketRatePerUnitId, @intUnitMeasureId, 1)) + dblGradeDiff / (dbo.[fnCTConvertQuantityToTargetItemUOM](G.intItemId, PS.intMarketRatePerUnitId, @intUnitMeasureId, 1))) * IsNULL(WP.dblQuantity, - S.dblQty)
			END) AS dblMTMPL
FROM #GRN G
LEFT JOIN tblICItem I ON I.intItemId = G.intItemId
LEFT JOIN #StageQty S ON S.intItemId = G.intItemId
LEFT JOIN #tblMFFinalWorkOrderProducedLot AS WP ON WP.intItemId = G.intItemId
LEFT JOIN tblMFProductionSummary PS ON PS.intItemId = G.intItemId
	AND PS.intWorkOrderId = @intWorkOrderId
ORDER BY G.intSequenceNo

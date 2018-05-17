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
SELECT OM.intLotId
	,T.intItemId
	,T.dblWeight
	,T.intWeightUOMId
FROM tblMFWorkOrder W
JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblICLot L ON L.intLotId = OM.intLotId
JOIN tblMFTask T ON T.intLotId = L.intLotId
	AND T.intOrderHeaderId = OM.intOrderHeaderId
WHERE W.intWorkOrderId = @intWorkOrderId

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
	,AVG(Convert(NUMERIC(38, 20), TR.strPropertyValue)) AS strPropertyValue
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

UPDATE #GRN
SET intItemId = I.intItemId
	,dblExchangePrice = IsNULL(dbo.fnRKGetLatestClosingPrice(IsNULL((
					SELECT TOP 1 CM.intFutureMarketId
					FROM tblICCommodityAttribute CA
					JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
						AND CA.strType = 'ProductType'
					WHERE CA.intCommodityAttributeId = I.intProductTypeId
					), C.intFutureMarketId), (
				SELECT TOP 1 intFutureMonthId
				FROM tblRKFuturesMonth
				WHERE ysnExpired = 0
					AND dtmSpotDate <= @dtmCurrentDateTime
					AND intFutureMarketId = IsNULL(C.intFutureMarketId, (
							SELECT TOP 1 CM.intFutureMarketId
							FROM tblICCommodityAttribute CA
							JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
								AND CA.strType = 'ProductType'
							WHERE CA.intCommodityAttributeId = I.intProductTypeId
							))
				ORDER BY 1 DESC
				), @dtmCurrentDateTime), 0) / @intSubCurrency
FROM #GRN G
JOIN tblICItem I ON I.intItemId = G.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId

SELECT intPropertyId
	,strPropertyName
	,strPropertyValue AS dblEstimatedOutput
	,I.strDescription AS strGrade
	,S.dblQty AS dblInputWeight
	,WP.dblQuantity AS dblOutputWeight
	,strActualOutput AS dblActualOutput
	,(
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
		) AS dblCleanGradeOutput
	,((
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
		) - strPropertyValue
		) AS dblVariance
	,dblExchangePrice AS dblMarketPrice
	,dblGradeDiff AS dblMarketDifferential
	,(dblExchangePrice + PS.dblGradeDiff) * WP.dblQuantity AS dblMTMPL
FROM #GRN G
LEFT JOIN tblICItem I ON I.intItemId = G.intItemId
LEFT JOIN #StageQty S ON S.intItemId = G.intItemId
LEFT JOIN #tblMFFinalWorkOrderProducedLot AS WP ON WP.intItemId = G.intItemId
LEFT JOIN tblMFProductionSummary PS ON PS.intItemId = G.intItemId
	AND PS.intWorkOrderId = @intWorkOrderId
ORDER BY G.intSequenceNo

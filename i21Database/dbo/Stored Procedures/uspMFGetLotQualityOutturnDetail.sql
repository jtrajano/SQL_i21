CREATE PROCEDURE uspMFGetLotQualityOutturnDetail (
	@intWorkOrderId INT
	,@intUnitMeasureId INT
	)
AS
DECLARE @dtmCurrentDateTime DATETIME

SELECT @dtmCurrentDateTime = Getdate()

DECLARE @tblMFLot TABLE (
	intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	)

INSERT INTO @tblMFLot (
	intLotId
	,intItemId
	,dblQty
	,intItemUOMId
	)
SELECT OM.intLotId
	,T.intItemId
	,T.dblQty
	,T.intItemUOMId
FROM tblMFWorkOrder W
JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblICLot L ON L.intLotId = OM.intLotId
JOIN tblMFTask T ON T.intLotId = L.intLotId
	AND T.intOrderHeaderId = OM.intOrderHeaderId
WHERE W.intWorkOrderId = @intWorkOrderId

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
	,Convert(NUMERIC(38, 20), TR.strPropertyValue) AS strPropertyValue
	,Convert(INT, NULL) AS intItemId
	,Convert(NUMERIC(38, 20), NULL) AS dblExchangePrice
INTO #GRN
FROM @tblMFLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
	AND P.intDataTypeId IN (
		1
		,2
		)
	AND ISNUMERIC(TR.strPropertyValue) = 1
JOIN tblQMSample S ON S.intProductValueId = L.intLotId
	AND S.intProductTypeId = 6
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 9

UPDATE #GRN
SET intItemId = I.intItemId
	,dblExchangePrice = IsNULL(dbo.fnRKGetLatestClosingPrice(C.intFutureMarketId, (
				SELECT TOP 1 intFutureMonthId
				FROM tblRKFuturesMonth
				WHERE ysnExpired = 0
					AND dtmSpotDate <= @dtmCurrentDateTime
					AND intFutureMarketId = C.intFutureMarketId
				ORDER BY 1 DESC
				), @dtmCurrentDateTime), 0)
FROM #GRN G
JOIN tblICItem I ON I.strItemNo = G.strPropertyName
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId

SELECT intPropertyId
	,strPropertyName
	,strPropertyValue AS dblEstimatedOutput
	,I.strDescription AS strGrade
	,S.dblQty AS dblInputWeight
	,WP.dblQuantity AS dblOutputWeight
	,strActualOutput AS dblActualOutput
	,CASE 
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
		END AS dblCleanGradeOutput
	,(
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
			END - strPropertyValue
		) AS dblVariance
	,dblExchangePrice AS dblMarketPrice
	,dblGradeDiff AS dblMarketDifferential
	,(WP.dblQuantity * dblGradeDiff * dblExchangePrice) AS dblMTMPL
FROM #GRN G
LEFT JOIN tblICItem I ON I.intItemId = G.intItemId
LEFT JOIN #StageQty S ON S.intItemId = G.intItemId
LEFT JOIN #tblMFFinalWorkOrderProducedLot AS WP ON WP.intItemId = G.intItemId
LEFT JOIN tblMFItemGradeDiff GD ON GD.intItemId = G.intItemId

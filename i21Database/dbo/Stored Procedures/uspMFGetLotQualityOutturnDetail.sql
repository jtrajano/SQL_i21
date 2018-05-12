CREATE PROCEDURE uspMFGetLotQualityOutturnDetail(
	@intWorkOrderId INT
	,@intUnitMeasureId INT
	)
AS
Declare @dtmCurrentDateTime DATETIME 
SELECT @dtmCurrentDateTime = Getdate()
DECLARE @tblMFLot TABLE (
	intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	)

INSERT INTO @tblMFLot (
	intLotId
	,intItemId
	,dblQty
	)
SELECT OM.intLotId
	,T.intItemId
	,T.dblQty
FROM tblMFWorkOrder W
JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
JOIN tblICLot L ON L.intLotId = OM.intLotId
JOIN tblMFTask T ON T.intLotId = L.intLotId
	AND T.intOrderHeaderId = OM.intOrderHeaderId
WHERE W.intWorkOrderId = @intWorkOrderId

SELECT intItemId
	,SUM(dblQty) AS dblQty
INTO #StageQty
FROM @tblMFLot
GROUP BY intItemId

SELECT I.intItemId
	,SUM(dblQuantity) AS dblQuantity
INTO #tblMFWorkOrderProducedLot
FROM tblMFWorkOrderProducedLot WP
JOIN tblICItem I ON I.intItemId = WP.intItemId
WHERE WP.intWorkOrderId = @intWorkOrderId
	AND ysnProductionReversed = 0
GROUP BY I.intItemId

Select intItemId,dblQuantity,CASE 
		WHEN Sum(WP.dblQuantity) OVER () = 0
			THEN 0
		ELSE (WP.dblQuantity / Sum(WP.dblQuantity) OVER ()) * 100
		END AS [strActualOutput]
		Into #tblMFFinalWorkOrderProducedLot
	From #tblMFWorkOrderProducedLot WP

SELECT P.intPropertyId
	,P.strPropertyName
	,Convert(NUMERIC(38, 20), TR.strPropertyValue) AS strPropertyValue
	,Convert(INT, NULL) AS intItemId
	,Convert(NUMERIC(38, 20), NULL) AS dblExchangePrice
INTO #GRN
FROM @tblMFLot L
JOIN tblQMTestResult AS TR ON TR.intProductValueId = L.intLotId
JOIN tblQMProperty AS P ON TR.intPropertyId = P.intPropertyId
JOIN tblQMSample S ON S.intProductValueId = L.intLotId
	AND S.intProductTypeId = 6
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND ST.intControlPointId = 9

	


UPDATE #GRN
SET intItemId = I.intItemId,dblExchangePrice=IsNULL(dbo.fnRKGetLatestClosingPrice(C.intFutureMarketId, (
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
	,strPropertyValue As strEstimatedOutput
	,I.strDescription As strGrade
	,S.dblQty AS 'Input Weight'
	,WP.dblQuantity AS 'Output Weight'
	,[strActualOutput]
	,CASE 
		WHEN Sum(
					CASE 
						WHEN dblCoEfficient = 0
							THEN 0
						ELSE [strActualOutput]
						END
					) OVER () = 0
			THEN 0
		ELSE ([strActualOutput] / Sum(
					CASE 
						WHEN dblCoEfficient = 0
							THEN 0
						ELSE [strActualOutput]
						END
					) OVER ())*100
		END As strCleanGradeOutput
		,CASE 
		WHEN Sum(
					CASE 
						WHEN dblCoEfficient = 0
							THEN 0
						ELSE [strActualOutput]
						END
					) OVER () = 0
			THEN 0
		ELSE ([strActualOutput] / Sum(
					CASE 
						WHEN dblCoEfficient = 0
							THEN 0
						ELSE [strActualOutput]
						END
					) OVER ())*100
		END-strPropertyValue AS [Variance]
		,dblExchangePrice as dblMarketPrice
		,dblGradeDiff As dblMarketDifferential
		,(WP.dblQuantity*dblGradeDiff*dblExchangePrice) AS [M2MP&L]
FROM #GRN G
Left JOIN tblICItem I on I.intItemId=G.intItemId
LEFT JOIN #StageQty S ON S.intItemId = G.intItemId
LEFT JOIN #tblMFFinalWorkOrderProducedLot AS WP ON WP.intItemId = G.intItemId
LEFT JOIN tblMFItemGradeDiff GD ON GD.intItemId = G.intItemId

CREATE VIEW vyuQMMarketOverview
AS
With OverallSalesData AS(
	SELECT 
	strSaleNumber,
	SUM(ISNULL(dblB1QtyBought,0) + ISNULL(dblB2QtyBought,0) +ISNULL(dblB3QtyBought,0)+ISNULL(dblB4QtyBought,0)+ISNULL(dblB5QtyBought,0))TotalSales,
	SUM(ISNULL(dblB1QtyBought,0))TotalSales_UL
	FROM tblQMSample A
	JOIN tblQMSampleType ST ON ST.intSampleTypeId =A.intSampleTypeId 
	WHERE ST.intControlPointId =1
	GROUP BY strSaleNumber
),
OverAllWeekStats AS(
	SELECT DATEPART(ww, dtmSaleDate) WeekNo,
	(CASE WHEN SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)>0 THEN 
	SUM(
		ISNULL(dblB1Price * IU.dblUnitQty * dblB1QtyBought, 0) + 
		ISNULL(dblB2Price * IU.dblUnitQty * dblB2QtyBought, 0) + 
		ISNULL(dblB3Price * IU.dblUnitQty * dblB3QtyBought, 0) + 
		ISNULL(dblB4Price * IU.dblUnitQty * dblB4QtyBought, 0) + 
		ISNULL(dblB5Price * IU.dblUnitQty * dblB5QtyBought, 0) 
	)/SUM(
		ISNULL(dblB1QtyBought * IU.dblUnitQty , 0) +
		ISNULL(dblB2QtyBought * IU.dblUnitQty , 0) +
		ISNULL(dblB3QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB4QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB5QtyBought * IU.dblUnitQty, 0)
		)
		ELSE 0 END) AveragePrice, 
	(CASE WHEN SUM(ISNULL(dblB1QtyBought, 0))>0 THEN SUM(dblB1Price * ISNULL(dblB1QtyBought , 0))/SUM(ISNULL(dblB1QtyBought, 0)) ELSE 0 END) AS AveragePrice_UL
	FROM tblQMSample A
	JOIN tblQMSampleType ST ON ST.intSampleTypeId =A.intSampleTypeId 
	LEFT JOIN tblICItemUOM IU ON IU.intItemId = A.intItemId AND IU.intUnitMeasureId  = A.intB1QtyUOMId 
	WHERE ST.intControlPointId =1
	GROUP BY DATEPART(ww, dtmSaleDate)
),
ItemSaleStat AS
(
	SELECT  
	strTeaGroup, strSaleNumber, C.strCurrency,
	SUM(ISNULL(dblB1QtyBought,0) + ISNULL(dblB2QtyBought,0) +ISNULL(dblB3QtyBought,0)+ISNULL(dblB4QtyBought,0)+ISNULL(dblB5QtyBought,0)) AS TotalSold,
	SUM(dblB1QtyBought) TotalSold_UL,
	(CASE WHEN SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)>0 THEN 
	SUM(
		ISNULL(dblB1Price * IU.dblUnitQty * dblB1QtyBought, 0) + 
		ISNULL(dblB2Price * IU.dblUnitQty * dblB2QtyBought, 0) + 
		ISNULL(dblB3Price * IU.dblUnitQty * dblB3QtyBought, 0) + 
		ISNULL(dblB4Price * IU.dblUnitQty * dblB4QtyBought, 0) + 
		ISNULL(dblB5Price * IU.dblUnitQty * dblB5QtyBought, 0) 
	)/SUM(
		ISNULL(dblB1QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB2QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB3QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB4QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB5QtyBought * IU.dblUnitQty, 0)
		)
		ELSE 0 END) AS AveragePrice,
	(CASE WHEN SUM(ISNULL(dblB1QtyBought, 0))>0 THEN SUM(dblB1Price * ISNULL(dblB1QtyBought , 0))/SUM(ISNULL(dblB1QtyBought, 0)) ELSE 0 END) AveragePrice_UL,
	SUM(
		ISNULL(dblB1QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB2QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB3QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB4QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB5QtyBought*IU.dblUnitQty, 0)
	) dblNetWeight,
	--Taste.Val AverageItemTaste,
	AVG(B.dblTeaTaste) AverageItemTaste,
	AVG(Taste.dblTeaActualTaste) dblTeaActualTaste,
	AVG(dblSupplierValuationPrice) AS AverageSupplierValuationPrice
	FROM tblQMSample A 
	JOIN tblQMSampleType ST ON ST.intSampleTypeId =A.intSampleTypeId AND  ST.intControlPointId =1
	JOIN tblMFBatch B ON A.intSampleId = B.intSampleId AND A.intLocationId =B.intLocationId 
	LEFT JOIN tblSMCurrency C ON A.intCurrencyId= C.intCurrencyID
	LEFT JOIN tblICItemUOM IU ON IU.intItemId = A.intItemId AND IU.intUnitMeasureId  = A.intB1QtyUOMId 
	--OUTER APPLY(
	--	SELECT avg(cast( T.strPropertyValue AS decimal(18,2)) )Val 
	--	FROM tblQMProperty P 
	--	left JOIN tblQMTestResult T ON T.intPropertyId = P.intPropertyId
	--	WHERE A.intItemId = P.intItemId
	--	AND P.strPropertyName = 'Taste' AND T.intSampleId  = A.intSampleId
	--)Taste
	OUTER APPLY(
		SELECT TOP 1 B1.dblTeaTaste dblTeaActualTaste
		FROM  tblMFBatch B1 
		WHERE B1.strBatchId = B.strBatchId 
		AND B1.intLocationId =B.intMixingUnitLocationId
	)Taste
	--GROUP BY  strSaleNumber,C.strCurrency,Taste.Val, strTeaGroup
	GROUP BY  strSaleNumber,C.strCurrency, strTeaGroup
),
ItemWeeklySaleStat AS
(
	SELECT  
	DATEPART(ww, dtmSaleDate) WeekNo,
	strTeaGroup,strSaleNumber, C.strCurrency,
	SUM(ISNULL(dblB1QtyBought,0) + ISNULL(dblB2QtyBought,0) +ISNULL(dblB3QtyBought,0)+ISNULL(dblB4QtyBought,0)+ISNULL(dblB5QtyBought,0)) AS TotalSold,
	SUM(IsNULL(dblB1QtyBought,0)) TotalSold_UL,
	(CASE WHEN SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)>0 THEN 
	SUM(
		ISNULL(dblB1Price * IU.dblUnitQty * dblB1QtyBought, 0) + 
		ISNULL(dblB2Price * IU.dblUnitQty * dblB2QtyBought, 0) + 
		ISNULL(dblB3Price * IU.dblUnitQty * dblB3QtyBought, 0) + 
		ISNULL(dblB4Price * IU.dblUnitQty * dblB4QtyBought, 0) + 
		ISNULL(dblB5Price * IU.dblUnitQty * dblB5QtyBought, 0) 
	)/SUM(
		ISNULL(dblB1QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB2QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB3QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB4QtyBought * IU.dblUnitQty, 0) +
		ISNULL(dblB5QtyBought * IU.dblUnitQty, 0)
		)
		ELSE 0 END) AveragePrice, 
	(CASE WHEN SUM(ISNULL(dblB1QtyBought, 0))>0 THEN SUM(dblB1Price * ISNULL(dblB1QtyBought , 0))/SUM(ISNULL(dblB1QtyBought, 0)) ELSE 0 END) AveragePrice_UL,
	SUM(
		ISNULL(dblB1QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB2QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB3QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB4QtyBought*IU.dblUnitQty, 0) +
		ISNULL(dblB5QtyBought*IU.dblUnitQty, 0)
	) dblNetWeight,
	--Taste.Val AverageItemTaste
	AVG(B.dblTeaTaste) AverageItemTaste
	FROM tblQMSample A 
	JOIN tblQMSampleType ST ON ST.intSampleTypeId =A.intSampleTypeId AND ST.intControlPointId =1
	JOIN tblMFBatch B ON A.intSampleId = B.intSampleId AND A.intLocationId =B.intLocationId 
	LEFT JOIN tblSMCurrency C ON A.intCurrencyId= C.intCurrencyID
	LEFT JOIN tblICItemUOM IU ON IU.intItemId = A.intItemId AND IU.intUnitMeasureId  = A.intB1QtyUOMId 
	--OUTER APPLY(
	--	SELECT avg(cast( T.strPropertyValue AS decimal(18,2)) )Val 
	--	FROM tblQMProperty P 
	--	left JOIN tblQMTestResult T ON T.intPropertyId = P.intPropertyId
	--	WHERE A.intItemId = P.intItemId
	--	AND P.strPropertyName = 'Taste' AND T.intSampleId = A.intSampleId
	--)Taste
	--GROUP BY strTeaGroup, strSaleNumber,C.strCurrency,Taste.Val, DATEPART(ww, dtmSaleDate)
	GROUP BY strTeaGroup, strSaleNumber,C.strCurrency, DATEPART(ww, dtmSaleDate)
	
),
HeaderData AS(
	SELECT 
	strSaleNumber,--1
	dtmSaleDate, --2
	X.AveragePrice AveragePriceCurrentWeekSale, --3
	W.AveragePrice AveragePricePrevWeekSale, --4
	U.TotalSales, --5
	U.TotalSales_UL, --7
	X.AveragePrice_UL --8
	FROM tblQMSample A
	JOIN tblQMSampleType ST ON ST.intSampleTypeId =A.intSampleTypeId 
		AND ST.intControlPointId =1
	OUTER APPLY(
		SELECT ISNULL(AveragePrice,0)AveragePrice ,ISNULL(AveragePrice_UL,0)AveragePrice_UL FROM OverAllWeekStats WHERE WeekNo = DATEPART(ww, A.dtmSaleDate)
	)X
	OUTER APPLY(
		SELECT ISNULL(AveragePrice,0)AveragePrice FROM OverAllWeekStats WHERE WeekNo = DATEPART(ww, A.dtmSaleDate) -1
	)W
	OUTER APPLY(
		SELECT ISNULL(TotalSales,0)TotalSales ,ISNULL(TotalSales_UL,0)TotalSales_UL FROM OverallSalesData WHERE strSaleNumber = A.strSaleNumber
	)U
		GROUP BY strSaleNumber, dtmSaleDate,U.TotalSales, U.TotalSales_UL,X.AveragePrice_UL,X.AveragePrice ,W.AveragePrice
),
CurrentWeek AS(
	SELECT 
	ROW_NUMBER() OVER(ORDER BY CAST(A.strSaleNumber AS INT) ASC) AS intRowId,
	DATEPART(ww, A.dtmSaleDate) WeekNo
	, A.strSaleNumber--1
	, A.dtmSaleDate--2
	, ROUND(A.AveragePriceCurrentWeekSale,2) dblAvePriceCurrentWeekSale --3
	, ROUND(A.AveragePricePrevWeekSale,2) dblAvePricePrevWeekSale--4
	, ROUND(ISNULL(A.AveragePriceCurrentWeekSale,0),2)- ROUND(ISNULL(A.AveragePricePrevWeekSale,0),2) dblAveWeekPriceChange --5
	, ROUND(A.TotalSales,2) dblTotalSales --6
	, ROUND(A.TotalSales_UL,2) dblTotalSaleUL--7
	, ROUND(A.AveragePrice_UL,2) dblAveragePriceUL --8
	, B.strTeaGroup strTeaGroup --9
	, ROUND(B.TotalSold,2) dblItemSold --10
	, ROUND(B.dblNetWeight,2) dblItemWeight --11
	, ROUND(B.AverageItemTaste,2) dblItemAverageTaste --12
	, ROUND(U.AveragePrice,2) dblItemAverageCurrentWeekPrice--13
	, ROUND(B.TotalSold_UL,2) dblItemTotalSoldUL--16
	, ROUND((B.TotalSold_UL/B.TotalSold) * 100, 2) dblItemPurchasePercentageUL --17
	, ROUND(B.AveragePrice_UL,2) dblItemAveragePriceUL --18
	, ROUND(B.AveragePrice_UL,2) - ROUND(B.AverageSupplierValuationPrice,2) dblItemAveragePriceChange --19
	, ROUND(B.AverageItemTaste,2) dblItemAverageTasteUL --20
	, ROUND(B.dblTeaActualTaste,2) - ROUND(B.AverageItemTaste ,2) dblItemAverageTasteChange --21
	, B.strCurrency 
	FROM HeaderData A JOIN ItemSaleStat B ON
	A.strSaleNumber = B.strSaleNumber
	OUTER APPLY(
		SELECT TOP 1 ISNULL(AveragePrice,0) AveragePrice FROM ItemWeeklySaleStat WHERE strTeaGroup = B.strTeaGroup AND DATEPART(ww, A.dtmSaleDate) = WeekNo
		AND B.strCurrency= strCurrency
	)U
)
SELECT B.*
, ROUND(V.AveragePrice,2) dblItemAveragePrevWeekPrice--14
, dblItemAverageCurrentWeekPrice-ROUND(ISNULL(V.AveragePrice,0),2) dblAveItemPriceChange --15
FROM CurrentWeek B
OUTER APPLY(
	SELECT TOP 1 ISNULL(AveragePrice,0) AveragePrice FROM ItemWeeklySaleStat 
	WHERE strTeaGroup = B.strTeaGroup AND WeekNo = B.WeekNo -1
	AND B.strCurrency= strCurrency
)V

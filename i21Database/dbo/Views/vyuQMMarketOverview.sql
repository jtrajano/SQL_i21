CREATE VIEW vyuQMMarketOverview
AS
With OverallSalesData as(
	select 
	strSaleNumber,
	SUM(ISNULL(dblB1QtyBought,0) + ISNULL(dblB2QtyBought,0) +ISNULL(dblB3QtyBought,0)+ISNULL(dblB4QtyBought,0)+ISNULL(dblB5QtyBought,0))TotalSales,
	SUM(ISNULL(dblB1QtyBought,0))TotalSales_UL
	from tblQMSample A
	JOIN tblQMSampleType ST on ST.intSampleTypeId =A.intSampleTypeId 
	Where ST.intControlPointId =1
	GROUP BY strSaleNumber
),
OverAllWeekStats as(
	select DATEPART(ww, dtmSaleDate) WeekNo,
	(Case When SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)>0 then 
	SUM(
		ISNULL(dblB1Price *dblB1QtyBought, 0) + 
		ISNULL(dblB2Price * dblB2QtyBought , 0) + 
		ISNULL(dblB3Price * dblB3QtyBought , 0) + 
		ISNULL(dblB4Price * dblB4QtyBought, 0) + 
		ISNULL(dblB5Price * dblB5QtyBought , 0) 
	)/SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)
		Else 0 End) AveragePrice, 
	(Case When SUM(ISNULL(dblB1QtyBought, 0))>0 Then SUM(dblB1Price * ISNULL(dblB1QtyBought , 0))/SUM(ISNULL(dblB1QtyBought, 0)) Else 0 End) AS AveragePrice_UL
	from tblQMSample A
	JOIN tblQMSampleType ST on ST.intSampleTypeId =A.intSampleTypeId 
	Where ST.intControlPointId =1
	group by DATEPART(ww, dtmSaleDate)
),
ItemSaleStat as
(
	SELECT  
	strTeaGroup, strSaleNumber, C.strCurrency,
	SUM(ISNULL(dblB1QtyBought,0) + ISNULL(dblB2QtyBought,0) +ISNULL(dblB3QtyBought,0)+ISNULL(dblB4QtyBought,0)+ISNULL(dblB5QtyBought,0)) AS TotalSold,
	SUM(dblB1QtyBought) TotalSold_UL,
	(Case When SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)>0 then 
	SUM(
		ISNULL(dblB1Price *dblB1QtyBought, 0) + 
		ISNULL(dblB2Price * dblB2QtyBought , 0) + 
		ISNULL(dblB3Price * dblB3QtyBought , 0) + 
		ISNULL(dblB4Price * dblB4QtyBought, 0) + 
		ISNULL(dblB5Price * dblB5QtyBought , 0) 
	)/SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)
		Else 0 End) AS AveragePrice,
	(Case When SUM(ISNULL(dblB1QtyBought, 0))>0 Then SUM(dblB1Price * ISNULL(dblB1QtyBought , 0))/SUM(ISNULL(dblB1QtyBought, 0)) Else 0 End) AveragePrice_UL,
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
	JOIN tblQMSampleType ST on ST.intSampleTypeId =A.intSampleTypeId AND  ST.intControlPointId =1
	JOIN tblMFBatch B ON A.intSampleId = B.intSampleId
	LEFT JOIN tblSMCurrency C on A.intCurrencyId= C.intCurrencyID
	LEFT JOIN tblICItemUOM IU ON IU.intItemId = A.intItemId AND IU.intUnitMeasureId  = A.intB1QtyUOMId 
	--OUTER APPLY(
	--	select avg(cast( T.strPropertyValue as decimal(18,2)) )Val 
	--	from tblQMProperty P 
	--	left JOIN tblQMTestResult T ON T.intPropertyId = P.intPropertyId
	--	where A.intItemId = P.intItemId
	--	AND P.strPropertyName = 'Taste' AND T.intSampleId  = A.intSampleId
	--)Taste
	OUTER APPLY(
		SELECT Top 1 B1.dblTeaTaste dblTeaActualTaste
		FROM  tblMFBatch B1 
		WHERE B1.strBatchId = B.strBatchId 
		AND B1.intLocationId =B.intMixingUnitLocationId
	)Taste
	--group by  strSaleNumber,C.strCurrency,Taste.Val, strTeaGroup
	group by  strSaleNumber,C.strCurrency, strTeaGroup
),
ItemWeeklySaleStat as
(
	SELECT  
	DATEPART(ww, dtmSaleDate) WeekNo,
	strTeaGroup,strSaleNumber, C.strCurrency,
	SUM(ISNULL(dblB1QtyBought,0) + ISNULL(dblB2QtyBought,0) +ISNULL(dblB3QtyBought,0)+ISNULL(dblB4QtyBought,0)+ISNULL(dblB5QtyBought,0)) AS TotalSold,
	SUM(IsNULL(dblB1QtyBought,0)) TotalSold_UL,
	(Case When SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)>0 then 
	SUM(
		ISNULL(dblB1Price *dblB1QtyBought, 0) + 
		ISNULL(dblB2Price * dblB2QtyBought , 0) + 
		ISNULL(dblB3Price * dblB3QtyBought , 0) + 
		ISNULL(dblB4Price * dblB4QtyBought, 0) + 
		ISNULL(dblB5Price * dblB5QtyBought , 0) 
	)/SUM(
		ISNULL(dblB1QtyBought , 0) +
		ISNULL(dblB2QtyBought , 0) +
		ISNULL(dblB3QtyBought , 0) +
		ISNULL(dblB4QtyBought , 0) +
		ISNULL(dblB5QtyBought , 0)
		)
		Else 0 End) AveragePrice, 
	(Case When SUM(ISNULL(dblB1QtyBought, 0))>0 Then SUM(dblB1Price * ISNULL(dblB1QtyBought , 0))/SUM(ISNULL(dblB1QtyBought, 0)) Else 0 End) AveragePrice_UL,
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
	JOIN tblQMSampleType ST on ST.intSampleTypeId =A.intSampleTypeId AND ST.intControlPointId =1
	JOIN tblMFBatch B ON A.intSampleId = B.intSampleId
	LEFT JOIN tblSMCurrency C on A.intCurrencyId= C.intCurrencyID
	LEFT JOIN tblICItemUOM IU ON IU.intItemId = A.intItemId AND IU.intUnitMeasureId  = A.intB1QtyUOMId 
	--OUTER APPLY(
	--	select avg(cast( T.strPropertyValue as decimal(18,2)) )Val 
	--	from tblQMProperty P 
	--	left JOIN tblQMTestResult T ON T.intPropertyId = P.intPropertyId
	--	where A.intItemId = P.intItemId
	--	AND P.strPropertyName = 'Taste' and T.intSampleId = A.intSampleId
	--)Taste
	--group by strTeaGroup, strSaleNumber,C.strCurrency,Taste.Val, DATEPART(ww, dtmSaleDate)
	group by strTeaGroup, strSaleNumber,C.strCurrency, DATEPART(ww, dtmSaleDate)
	
),
HeaderData as(
select 
strSaleNumber,--1
dtmSaleDate, --2
X.AveragePrice AveragePriceCurrentWeekSale, --3
W.AveragePrice AveragePricePrevWeekSale, --4
U.TotalSales, --5
U.TotalSales_UL, --7
X.AveragePrice_UL --8
from tblQMSample A
JOIN tblQMSampleType ST on ST.intSampleTypeId =A.intSampleTypeId 
	AND ST.intControlPointId =1
outer apply(
	select ISNULL(AveragePrice,0)AveragePrice ,ISNULL(AveragePrice_UL,0)AveragePrice_UL from OverAllWeekStats where WeekNo = DATEPART(ww, A.dtmSaleDate)
)X
outer apply(
	select ISNULL(AveragePrice,0)AveragePrice from OverAllWeekStats where WeekNo = DATEPART(ww, A.dtmSaleDate) -1
)W
outer apply(
	select ISNULL(TotalSales,0)TotalSales ,ISNULL(TotalSales_UL,0)TotalSales_UL from OverallSalesData where strSaleNumber = A.strSaleNumber
)U
	group by strSaleNumber, dtmSaleDate,U.TotalSales, U.TotalSales_UL,X.AveragePrice_UL,X.AveragePrice ,W.AveragePrice
)
select 
ROW_NUMBER() OVER(ORDER BY CAST(A.strSaleNumber AS INT) ASC) AS intRowId
,  A.strSaleNumber--1
, A.dtmSaleDate--2
, ROUND(A.AveragePriceCurrentWeekSale,2) dblAvePriceCurrentWeekSale --3
, ROUND(A.AveragePricePrevWeekSale,2) dblAvePricePrevWeekSale--4
, ROUND(ISNULL(A.AveragePriceCurrentWeekSale,0)- ISNULL(A.AveragePricePrevWeekSale,0),2) dblAveWeekPriceChange --5
, ROUND(A.TotalSales,2) dblTotalSales --6
, ROUND(A.TotalSales_UL,2) dblTotalSaleUL--7
, ROUND(A.AveragePrice_UL,2) dblAveragePriceUL --8
, B.strTeaGroup strTeaGroup --9
, ROUND(B.TotalSold,2) dblItemSold --10
, ROUND(B.dblNetWeight,2) dblItemWeight --11
, ROUND(B.AverageItemTaste,2) dblItemAverageTaste --12
, ROUND(U.AveragePrice,2) dblItemAverageCurrentWeekPrice--13
, ROUND(V.AveragePrice,2) dblItemAveragePrevWeekPrice--14
, ROUND(U.AveragePrice-ISNULL(V.AveragePrice,0),2) dblAveItemPriceChange --15
, ROUND(B.TotalSold_UL,2) dblItemTotalSoldUL--16
, ROUND((B.TotalSold/B.TotalSold_UL) * 100, 2) dblItemPurchasePercentageUL --17
, ROUND(B.AveragePrice_UL,2) dblItemAveragePriceUL --18
, ROUND(B.AveragePrice_UL -B.AverageSupplierValuationPrice,2) dblItemAveragePriceChange --19
, ROUND(B.AverageItemTaste,2) dblItemAverageTasteUL --20
, ROUND((B.dblTeaActualTaste-B.AverageItemTaste) ,2) dblItemAverageTasteChange --21
, B.strCurrency 
from HeaderData A join ItemSaleStat B on
A.strSaleNumber = B.strSaleNumber
outer apply(
	Select TOP 1 ISNULL(AveragePrice,0) AveragePrice from ItemWeeklySaleStat where strTeaGroup = B.strTeaGroup and DATEPART(ww, A.dtmSaleDate) = WeekNo

)U
outer apply(
	Select TOP 1 ISNULL(AveragePrice,0) AveragePrice from ItemWeeklySaleStat 
	where strTeaGroup = B.strTeaGroup and DATEPART(ww, A.dtmSaleDate) = WeekNo-1

)V
--where A.strSaleNumber = '00001'
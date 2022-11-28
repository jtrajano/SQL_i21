CREATE VIEW vyuQMMarketOverview
AS
With OverallSalesData as(
	select 
	strSaleNumber,
	SUM(dblB1QtyBought + dblB2QtyBought +dblB3QtyBought+dblB4QtyBought+dblB5QtyBought)TotalSales,
	SUM(dblB1QtyBought)TotalSales_UL
	from tblQMSample A
	GROUP BY strSaleNumber
),
OverAllWeekStats as(
	select DATEPART(ww, dtmSaleDate) WeekNo,
	SUM((dblB1QtyBought*dblB1Price +dblB2QtyBought* dblB2Price +dblB3QtyBought*dblB3Price
	+dblB4QtyBought* dblB4Price +dblB5QtyBought*dblB5Price))/
	sum(dblB1Price + dblB2Price + dblB3Price+ dblB4Price+ dblB5Price) AveragePrice,
	SUM(dblB1QtyBought  * dblB1Price)/
	sum(dblB1Price) AveragePrice_UL
	from tblQMSample group by DATEPART(ww, dtmSaleDate)
),
ItemSaleStat as
(
	SELECT  
	strItemNo,A.intItemId, strSaleNumber, C.strCurrency,
	SUM(dblB1QtyBought + dblB2QtyBought +dblB3QtyBought+dblB4QtyBought+dblB5QtyBought) TotalSold,
	SUM(dblB1QtyBought) TotalSold_UL,
	SUM((dblB1QtyBought*dblB1Price +dblB2QtyBought* dblB2Price +dblB3QtyBought*dblB3Price+dblB4QtyBought* dblB4Price +dblB5QtyBought*dblB5Price))/
		SUM(dblB1Price + dblB2Price + dblB3Price+ dblB4Price+ dblB5Price) AveragePrice,
	SUM(dblB1QtyBought  * dblB1Price)/SUM(dblB1Price) AveragePrice_UL,
	sum(A.dblNetWeight)dblNetWeight,
	Taste.Val AverageItemTaste,
	AVG(dblSupplierValuationPrice)AverageSupplierValuationPrice
	FROM tblQMSample A LEFT JOIN
	tblSMCurrency C on A.intCurrencyId= C.intCurrencyID
	left join tblICItem IC on IC.intItemId = A.intItemId
	OUTER APPLY(
		select avg(cast( T.strPropertyValue as decimal(18,2)) )Val 
		from tblQMProperty P 
		left JOIN tblQMTestResult T ON T.intPropertyId = P.intPropertyId
		where A.intItemId = P.intItemId
		AND P.strPropertyName = 'Taste' AND T.intSampleId  = A.intSampleId
	)Taste
	group by A.intItemId, strSaleNumber,strCurrency, strItemNo,Taste.Val
),
ItemWeeklySaleStat as
(
	SELECT  
	DATEPART(ww, dtmSaleDate) WeekNo,
	strItemNo,A.intItemId, strSaleNumber, C.strCurrency,
	SUM(dblB1QtyBought + dblB2QtyBought +dblB3QtyBought+dblB4QtyBought+dblB5QtyBought) TotalSold,
	SUM(dblB1QtyBought) TotalSold_UL,
	SUM((dblB1QtyBought*dblB1Price +dblB2QtyBought* dblB2Price +dblB3QtyBought*dblB3Price+dblB4QtyBought* dblB4Price +dblB5QtyBought*dblB5Price))/
		SUM(dblB1Price + dblB2Price + dblB3Price+ dblB4Price+ dblB5Price) AveragePrice,
	SUM(dblB1QtyBought  * dblB1Price)/SUM(dblB1Price) AveragePrice_UL,
	sum(A.dblNetWeight)dblNetWeight,
	Taste.Val AverageItemTaste
	FROM tblQMSample A LEFT JOIN
	tblSMCurrency C on A.intCurrencyId= C.intCurrencyID
	left join tblICItem IC on IC.intItemId = A.intItemId
	OUTER APPLY(
		select avg(cast( T.strPropertyValue as decimal(18,2)) )Val from tblQMProperty P 
		left JOIN tblQMTestResult T ON T.intPropertyId = P.intPropertyId
		where A.intItemId = P.intItemId
		AND P.strPropertyName = 'Taste' and T.intSampleId = A.intSampleId
	)Taste
	group by A.intItemId, strSaleNumber,strCurrency, strItemNo,Taste.Val, DATEPART(ww, dtmSaleDate)
	
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
outer apply(
	select AveragePrice,AveragePrice_UL from OverAllWeekStats where WeekNo = DATEPART(ww, A.dtmSaleDate)
)X
outer apply(
	select AveragePrice from OverAllWeekStats where WeekNo = DATEPART(ww, A.dtmSaleDate) -1
)W
outer apply(
	select TotalSales,TotalSales_UL from OverallSalesData where strSaleNumber = A.strSaleNumber
)U
	group by strSaleNumber, dtmSaleDate,U.TotalSales, U.TotalSales_UL,X.AveragePrice_UL,X.AveragePrice ,W.AveragePrice
)
select 
ROW_NUMBER() OVER(ORDER BY CAST(A.strSaleNumber AS INT) ASC) AS intRowId
,  A.strSaleNumber--1
, A.dtmSaleDate--2
, ROUND(A.AveragePriceCurrentWeekSale,2) dblAvePriceCurrentWeekSale --3
, ROUND(A.AveragePricePrevWeekSale,2) dblAvePricePrevWeekSale--4
, ROUND(A.AveragePriceCurrentWeekSale- A.AveragePricePrevWeekSale,2) dblAveWeekPriceChange --5
, ROUND(A.TotalSales,2) dblTotalSales --6
, ROUND(A.TotalSales_UL,2) dblTotalSaleUL--7
, ROUND(A.AveragePrice_UL,2) dblAveragePriceUL --8
, B.strItemNo strItemNo --9
, ROUND(B.TotalSold,2) dblItemSold --10
, ROUND(B.dblNetWeight,2) dblItemWeight --11
, ROUND(B.AverageItemTaste,2) dblItemAverageTaste --12
, ROUND(U.AveragePrice,2) dblItemAverageCurrentWeekPrice--13
, ROUND(V.AveragePrice,2) dblItemAveragePrevWeekPrice--14
, ROUND(U.AveragePrice-V.AveragePrice,2) dblAveItemPriceChange --15
, ROUND(B.TotalSold_UL,2) dblItemTotalSoldUL--16
, ROUND((B.TotalSold/B.TotalSold_UL) * 100, 2) dblItemPurchasePercentageUL --17
, ROUND(B.AveragePrice_UL,2) dblItemAveragePriceUL --18
, ROUND(B.AveragePrice_UL -B.AverageSupplierValuationPrice,2) dblItemAveragePriceChange --19
, ROUND(B.AverageItemTaste,2) dblItemAverageTasteUL --20
, ROUND(B.AverageItemTaste - B.AverageItemTaste,2) dblItemAverageTasteChange --21
, B.strCurrency 
from HeaderData A join ItemSaleStat B on
A.strSaleNumber = B.strSaleNumber
outer apply(
	Select TOP 1 AveragePrice from ItemWeeklySaleStat where intItemId = B.intItemId and DATEPART(ww, A.dtmSaleDate) = WeekNo

)U
outer apply(
	Select TOP 1 AveragePrice from ItemWeeklySaleStat 
	where intItemId = B.intItemId and DATEPART(ww, A.dtmSaleDate)-1 = WeekNo

)V
--where A.strSaleNumber = '00001'



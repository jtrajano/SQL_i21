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
  A.strSaleNumber SaleNo--1
, A.dtmSaleDate SaleDate--2
, A.AveragePriceCurrentWeekSale --3
, A.AveragePricePrevWeekSale --4
, A.AveragePriceCurrentWeekSale- A.AveragePricePrevWeekSale DiffAveWeekPrice --5
, A.TotalSales --6
, A.TotalSales_UL --7
, A.AveragePrice_UL --8
, B.strItemNo ItemNo --9
, B.TotalSold ItemQtySold --10
, B.dblNetWeight ItemWeight --11
, B.AverageItemTaste ItemAverageTaste --12
, U.AveragePrice ItemAverageCurrentWeekPrice--13
, V.AveragePrice ItemAveragePrevWeekPrice--14
, U.AveragePrice-V.AveragePrice DiffAveItemPrice --15
, B.TotalSold_UL --16
, ROUND((B.TotalSold/B.TotalSold_UL) * 100, 2) PurchasePercentage_UL --17
, B.AveragePrice --18
, B.AveragePrice -B.AverageSupplierValuationPrice DiffAvgPrice --19
, B.AverageItemTaste --20
, B.AverageItemTaste - B.AverageItemTaste DiffItemTaste --21
, B.strCurrency Currency
from HeaderData A join ItemSaleStat B on
A.strSaleNumber = B.strSaleNumber
outer apply(
	Select AveragePrice from ItemWeeklySaleStat where intItemId = B.intItemId and DATEPART(ww, A.dtmSaleDate) = WeekNo

)U
outer apply(
	Select AveragePrice from ItemWeeklySaleStat 
	where intItemId = B.intItemId and DATEPART(ww, A.dtmSaleDate)-1 = WeekNo

)V
--where A.strSaleNumber = '00001'



CREATE VIEW [dbo].[vyuTRGetImportRackPriceDetail]
	AS 

SELECT Detail.intImportRackPriceDetailId
	, Detail.intImportRackPriceId
	, strImportSupplyPoint = Detail.strSupplyPoint
	, Detail.intSupplyPointId
	, SupplyPoint.strFuelSupplier
	, strSupplyPoint = SupplyPoint.strSupplyPoint
	, Detail.dtmEffectiveDate
	, Detail.strComments
	, Detail.ysnSelected
	, ysnValidDetail = Detail.ysnValid
	, DetailItem.intImportRackPriceDetailItemId
	, strImportItemNo = DetailItem.strItemNo
	, DetailItem.intItemId
	, strItemNo = Item.strItemNo
	, DetailItem.dblVendorPrice
	, DetailItem.dblJobberPrice
	, DetailItem.strEquation
	, ysnValidDetailItem = DetailItem.ysnValid
	, strStatus = CASE WHEN Detail.ysnValid = 0 THEN Detail.strSupplyPoint
						WHEN DetailItem.ysnValid = 0 THEN DetailItem.strItemNo
						ELSE 'Success!' END					
FROM tblTRImportRackPriceDetail Detail
LEFT JOIN tblTRImportRackPriceDetailItem DetailItem ON DetailItem.intImportRackPriceDetailId = Detail.intImportRackPriceDetailId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = Detail.intSupplyPointId
LEFT JOIN tblICItem Item ON Item.intItemId = DetailItem.intItemId
WHERE Detail.ysnValid = 1 AND DetailItem.ysnValid = 1
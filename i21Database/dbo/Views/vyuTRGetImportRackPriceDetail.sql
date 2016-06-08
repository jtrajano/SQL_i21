CREATE VIEW [dbo].[vyuTRGetImportRackPriceDetail]
	AS 

SELECT Detail.intImportRackPriceDetailId
	, Detail.intImportRackPriceId
	, Detail.strSupplyPoint
	, Detail.intSupplyPointId
	, Detail.dtmEffectiveDate
	, Detail.strComments
	, Detail.ysnSelected
	, ysnValidDetail = Detail.ysnValid
	, DetailItem.intImportRackPriceDetailItemId
	, DetailItem.strItemNo
	, DetailItem.intItemId
	, DetailItem.dblVendorPrice
	, DetailItem.dblJobberPrice
	, DetailItem.strEquation
	, ysnValidDetailItem = DetailItem.ysnValid
FROM tblTRImportRackPriceDetail Detail
LEFT JOIN tblTRImportRackPriceDetailItem DetailItem ON DetailItem.intImportRackPriceDetailId = Detail.intImportRackPriceDetailId
﻿CREATE VIEW [dbo].[vyuTRGetImportRackItemError]
	AS

SELECT Detail.intImportRackPriceDetailId
	, Detail.intImportRackPriceId
	, Detail.strSupplierName
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
	, strStatus = CASE WHEN Detail.ysnValid = 0 OR DetailItem.ysnValid = 0 THEN 'Item ' + DetailItem.strItemNo + ' on Supply Point ' + Detail.strSupplyPoint + ' for Supplier ' + Detail.strSupplierName + ' was not found.'
						ELSE 'Success!' END					
FROM tblTRImportRackPriceDetail Detail
LEFT JOIN tblTRImportRackPriceDetailItem DetailItem ON DetailItem.intImportRackPriceDetailId = Detail.intImportRackPriceDetailId
WHERE Detail.ysnValid = 0 OR DetailItem.ysnValid = 0
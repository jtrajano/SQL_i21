CREATE PROCEDURE [dbo].[uspTRUpdateImportRackPriceId]
	@ImportRackPriceId INT OUTPUT
AS

SELECT TOP 1 @ImportRackPriceId = intImportRackPriceId
FROM tblTRImportRackPrice
ORDER BY intImportRackPriceId DESC

UPDATE tblTRImportRackPriceDetail
SET intSupplyPointId = dbo.fnTRSearchSupplyPointId(strSupplyPoint)
	, ysnValid = CASE WHEN ISNULL(dbo.fnTRSearchSupplyPointId(strSupplyPoint), '') <> '' THEN 1
					ELSE 0 END
	, ysnSelected = 0
WHERE intImportRackPriceId = @ImportRackPriceId

UPDATE tblTRImportRackPriceDetail
SET strSupplyPoint = 'Supply Point not found! - ' + strSupplyPoint
WHERE intImportRackPriceId = @ImportRackPriceId
	AND ysnValid = 0

UPDATE tblTRImportRackPriceDetailItem
SET intItemId = dbo.fnTRSearchItemId(RackPriceDetail.intSupplyPointId, strItemNo)
	, ysnValid = CASE WHEN ISNULL(dbo.fnTRSearchItemId(RackPriceDetail.intSupplyPointId, strItemNo), '') <> '' THEN 1
					ELSE 0 END
FROM (
	SELECT RackPriceDetail.intImportRackPriceDetailItemId
		, RackPrice.intSupplyPointId
		, RackPrice.intImportRackPriceId
	FROM tblTRImportRackPriceDetail RackPrice
	LEFT JOIN tblTRImportRackPriceDetailItem RackPriceDetail ON RackPriceDetail.intImportRackPriceDetailId = RackPrice.intImportRackPriceDetailId
) RackPriceDetail
WHERE RackPriceDetail.intImportRackPriceDetailItemId = tblTRImportRackPriceDetailItem.intImportRackPriceDetailItemId
	AND RackPriceDetail.intImportRackPriceId = @ImportRackPriceId

UPDATE tblTRImportRackPriceDetailItem
SET strItemNo = 'Item not found! - ' + strItemNo
FROM (
	SELECT RackPriceDetail.intImportRackPriceDetailItemId
		, RackPrice.intSupplyPointId
		, RackPrice.intImportRackPriceId
	FROM tblTRImportRackPriceDetail RackPrice
	LEFT JOIN tblTRImportRackPriceDetailItem RackPriceDetail ON RackPriceDetail.intImportRackPriceDetailId = RackPrice.intImportRackPriceDetailId
) RackPriceDetail
WHERE RackPriceDetail.intImportRackPriceDetailItemId = tblTRImportRackPriceDetailItem.intImportRackPriceDetailItemId
	AND RackPriceDetail.intImportRackPriceId = @ImportRackPriceId
	AND tblTRImportRackPriceDetailItem.ysnValid = 0
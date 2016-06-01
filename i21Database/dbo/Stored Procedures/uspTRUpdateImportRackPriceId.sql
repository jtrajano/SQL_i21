CREATE PROCEDURE [dbo].[uspTRUpdateImportRackPriceId]
	@ImportRackPriceId INT OUTPUT
AS

SELECT TOP 1 @ImportRackPriceId = intImportRackPriceId
FROM tblTRImportRackPrice
ORDER BY intImportRackPriceId DESC

UPDATE tblTRImportRackPriceDetail
SET intSupplyPointId = dbo.fnTRSearchSupplyPointId(strSupplyPoint)
	, ysnValid = CASE WHEN dbo.fnTRSearchSupplyPointId(strSupplyPoint) != NULL THEN 1
					ELSE 0 END
WHERE intImportRackPriceId = @ImportRackPriceId

UPDATE tblTRImportRackPriceDetailItem
SET intItemId = dbo.fnTRSearchItemId(RackPriceDetail.intSupplyPointId, strItemNo)
	, ysnValid = CASE WHEN dbo.fnTRSearchItemId(RackPriceDetail.intSupplyPointId, strItemNo) != NULL THEN 1
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
CREATE PROCEDURE [dbo].[uspTRUpdateImportRackPriceId]
	@ImportRackPriceId INT OUTPUT
AS

BEGIN

	SELECT TOP 1 @ImportRackPriceId = intImportRackPriceId
	FROM tblTRImportRackPrice
	ORDER BY intImportRackPriceId DESC

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
		, strStatus = CASE WHEN Detail.ysnValid = 0 THEN Detail.strSupplyPoint
							WHEN DetailItem.ysnValid = 0 THEN DetailItem.strItemNo
							ELSE 'Success!' END
		, intKeyId = dbo.fnTRSearchItemId(Detail.strSupplyPoint, DetailItem.strItemNo)	
	INTO #tmpRackPrice
	FROM tblTRImportRackPriceDetail Detail
	LEFT JOIN tblTRImportRackPriceDetailItem DetailItem ON DetailItem.intImportRackPriceDetailId = Detail.intImportRackPriceDetailId
	WHERE Detail.intImportRackPriceId = @ImportRackPriceId

	SELECT DISTINCT RackPrice.intImportRackPriceDetailId
		, RackPrice.intImportRackPriceDetailItemId
		, SearchValue.intSupplyPointId
		, SearchValue.strSupplier
		, SearchValue.strLocation
		, SearchValue.intItemId
		, SearchValue.strItemNo
		, SearchValue.strItemDescription
	INTO #tmpPatchTable
	FROM #tmpRackPrice RackPrice
	LEFT JOIN vyuTRGetSupplyPointSearchValue SearchValue ON SearchValue.intKeyId = RackPrice.intKeyId
	WHERE ISNULL(SearchValue.intSupplyPointId, '') <> 0 AND ISNULL(SearchValue.intItemId, '') <> ''

	UPDATE tblTRImportRackPriceDetail
	SET tblTRImportRackPriceDetail.intSupplyPointId = #tmpPatchTable.intSupplyPointId
		, tblTRImportRackPriceDetail.ysnValid = (CASE WHEN ISNULL(#tmpPatchTable.intSupplyPointId, 0) = 0 THEN 0
				ELSE 1 END)
	FROM #tmpPatchTable
	WHERE tblTRImportRackPriceDetail.intImportRackPriceDetailId = #tmpPatchTable.intImportRackPriceDetailId

	UPDATE tblTRImportRackPriceDetailItem
	SET tblTRImportRackPriceDetailItem.intItemId = #tmpPatchTable.intItemId
		, tblTRImportRackPriceDetailItem.ysnValid = (CASE WHEN ISNULL(#tmpPatchTable.intItemId, 0) = 0 THEN 0
				ELSE 1 END)
	FROM #tmpPatchTable
	WHERE tblTRImportRackPriceDetailItem.intImportRackPriceDetailItemId = #tmpPatchTable.intImportRackPriceDetailItemId

	DROP TABLE #tmpPatchTable
	DROP TABLE #tmpRackPrice

END
CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendorPricing]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--VALIDATE
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strLogLevel, strStatus, strAction, intRowNo, strField, strValue, strMessage)
SELECT * FROM dbo.fnApiSchemaValidateVendorPricing(@guiApiUniqueId, @guiLogId)

--TRANSFORM
IF NOT EXISTS(SELECT TOP 1 1 FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId AND strStatus = 'Failed')
BEGIN
	IF OBJECT_ID('tempdb..#tmpApiSchemaVendorPricing') IS NOT NULL DROP TABLE #tmpApiSchemaVendorPricing
	SELECT * INTO #tmpApiSchemaVendorPricing FROM tblApiSchemaVendorPricing WHERE guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpApiSchemaVendorPricing)
	BEGIN
		IF OBJECT_ID('tempdb..#tmpApiSchemaVendorPricingTop') IS NOT NULL DROP TABLE #tmpApiSchemaVendorPricingTop
		SELECT TOP 1 * INTO #tmpApiSchemaVendorPricingTop FROM #tmpApiSchemaVendorPricing

		INSERT INTO tblAPVendorPricing (
			intEntityVendorId,
			intEntityLocationId,
			intItemId,
			intItemUOMId,
			dtmBeginDate,
			dtmEndDate,
			dblUnit,
			intCurrencyId,
			guiApiUniqueId
		)
		SELECT V.intEntityId, EL.intEntityLocationId, I.intItemId, UM.intUnitMeasureId, VP.dtmBeginDate, VP.dtmEndDate, VP.dblPrice, C.intCurrencyID, @guiApiUniqueId
		FROM #tmpApiSchemaVendorPricingTop VP
		INNER JOIN tblAPVendor V ON V.strVendorId = VP.strVendorId
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.strLocationName = VP.strLocationName
		INNER JOIN tblICItem I ON I.strItemNo = VP.strItemNo
		INNER JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = VP.strUnitMeasure
		INNER JOIN tblSMCurrency C ON C.strCurrency = VP.strCurrency

		DELETE FROM #tmpApiSchemaVendorPricing WHERE intKey IN (SELECT intKey FROM #tmpApiSchemaVendorPricingTop)
	END
END
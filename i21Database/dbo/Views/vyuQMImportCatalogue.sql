CREATE VIEW [dbo].[vyuQMImportCatalogue]
AS
/* Created By: Jonathan Valenzuela
 * Created Date: 02/17/2023
 * Title: Catalogue Import Log
 * JIRA: QC-847
 * Description: Return list of Catalogue Import Log
 */
SELECT
     [ImportCatalogue].[intImportCatalogueId],
     [ImportCatalogue].[intConcurrencyId],
     [ImportCatalogue].[intImportLogId],
     [ImportCatalogue].[ysnSuccess],
     [ImportCatalogue].[ysnProcessed],
     [ImportCatalogue].[strLogResult],
     [ImportCatalogue].[intSampleId],
     [ImportCatalogue].[strSaleYear],
     [ImportCatalogue].[strBuyingCenter],
     [ImportCatalogue].[strSaleNumber],
     [ImportCatalogue].[strCatalogueType],
     [ImportCatalogue].[strSupplier],
     [ImportCatalogue].[strChannel],
     [ImportCatalogue].[strLotNumber],
     [ImportCatalogue].[strContractNumber],
     [ImportCatalogue].[intContractItem],
     [ImportCatalogue].[strSampleStatus],
     [ImportCatalogue].[dblBoughtPrice],
     [ImportCatalogue].[strGroupNumber],
     [ImportCatalogue].[dblSupplierValuation],
     [ImportCatalogue].[strPackageType],
     [ImportCatalogue].[strChopNumber],
     [ImportCatalogue].[strGrade],
     [ImportCatalogue].[strManufacturingLeafType],
     [ImportCatalogue].[strSeason],
     [ImportCatalogue].[strGardenMark],
     [ImportCatalogue].[strGardenGeoOrigin],
     [ImportCatalogue].[strWarehouseCode],
     [ImportCatalogue].[dtmManufacturingDate],
     [ImportCatalogue].[dblTotalQtyOffered],
     [ImportCatalogue].[intTotalNumberOfPackageBreakups],
     [ImportCatalogue].[strNoOfPackagesUOM],
     [ImportCatalogue].[intNoOfPackages],
     [ImportCatalogue].[strNoOfPackagesSecondPackageBreakUOM],
     [ImportCatalogue].[intNoOfPackagesSecondPackageBreak],
     [ImportCatalogue].[strNoOfPackagesThirdPackageBreakUOM],
     [ImportCatalogue].[intNoOfPackagesThirdPackageBreak],
     [ImportCatalogue].[strSustainability],
     [ImportCatalogue].[ysnOrganic],
     [ImportCatalogue].[dtmSaleDate],
     [ImportCatalogue].[dtmPromptDate],
     [ImportCatalogue].[strRemarks],
     [ImportCatalogue].[dblGrossWeight],
     [ImportCatalogue].[strColour],
     [ImportCatalogue].[strSize],
     [strAppearance] = CASE WHEN [ImportCatalogue].[strAppearance] <> '' THEN [ImportCatalogue].[strAppearance] ELSE APPEARANCE.strPropertyValue END,
     [strHue] = CASE WHEN [ImportCatalogue].[strHue] <> '' THEN [ImportCatalogue].[strHue] ELSE HUE.strPropertyValue END,
     [strIntensity] = CASE WHEN [ImportCatalogue].[strIntensity] <> '' THEN [ImportCatalogue].[strIntensity] ELSE INTENSITY.strPropertyValue END,
     [strTaste] = CASE WHEN [ImportCatalogue].[strTaste] <> '' THEN [ImportCatalogue].[strTaste] ELSE TASTE.strPropertyValue END,
     [strBulkDensity] = CASE WHEN [ImportCatalogue].[strBulkDensity] <> '' THEN [ImportCatalogue].[strBulkDensity] ELSE Density.strPropertyValue END,
     [strTeaMoisture] = CASE WHEN [ImportCatalogue].[strTeaMoisture] <> '' THEN [ImportCatalogue].[strTeaMoisture] ELSE Moisture.strPropertyValue END,
     [strFines] = CASE WHEN [ImportCatalogue].[strFines] <> '' THEN [ImportCatalogue].[strFines] ELSE Fines.strPropertyValue END,
     [strTeaVolume] = CASE WHEN [ImportCatalogue].[strTeaVolume] <> '' THEN [ImportCatalogue].[strTeaVolume] ELSE Volume.strPropertyValue END,
     [strDustContent] = CASE WHEN [ImportCatalogue].[strDustContent] <> '' THEN [ImportCatalogue].[strDustContent] ELSE DustLevel.strPropertyValue END,
     [strMouthfeel] = CASE WHEN [ImportCatalogue].[strMouthfeel] <> '' THEN [ImportCatalogue].[strMouthfeel] ELSE MOUTH_FEEL.strPropertyValue END,
     [ImportCatalogue].[strStyle],
     [ImportCatalogue].[strMusterLot],
     [ImportCatalogue].[strMissingLot],
     [ImportCatalogue].[strTaster],
     [ImportCatalogue].[strTastersRemarks],
     [ImportCatalogue].[strTealingoItem],
     [ImportCatalogue].[ysnBought],
     [ImportCatalogue].[dblB1QtyBought],
     [ImportCatalogue].[strB1QtyUOM],
     [ImportCatalogue].[dblB1Price],
     [ImportCatalogue].[strB1PriceUOM],
     [ImportCatalogue].[strB1CompanyCode],
     [ImportCatalogue].[strB1GroupNumber],
     [ImportCatalogue].[strB2Code],
     [ImportCatalogue].[dblB2QtyBought],
     [ImportCatalogue].[strB2QtyUOM],
     [ImportCatalogue].[dblB2Price],
     [ImportCatalogue].[strB2PriceUOM],
     [ImportCatalogue].[strB3Code],
     [ImportCatalogue].[dblB3QtyBought],
     [ImportCatalogue].[strB3QtyUOM],
     [ImportCatalogue].[dblB3Price],
     [ImportCatalogue].[strB3PriceUOM],
     [ImportCatalogue].[strB4Code],
     [ImportCatalogue].[dblB4QtyBought],
     [ImportCatalogue].[strB4QtyUOM],
     [ImportCatalogue].[dblB4Price],
     [ImportCatalogue].[strB4PriceUOM],
     [ImportCatalogue].[strB5Code],
     [ImportCatalogue].[dblB5QtyBought],
     [ImportCatalogue].[strB5QtyUOM],
     [ImportCatalogue].[dblB5Price],
     [ImportCatalogue].[strB5PriceUOM],
     [ImportCatalogue].[strBuyingOrderNumber],
     [ImportCatalogue].[str3PLStatus],
     [ImportCatalogue].[strAdditionalSupplierReference],
     [ImportCatalogue].[strAirwayBillNumberCode],
     [ImportCatalogue].[intAWBSampleReceived],
     [ImportCatalogue].[strAWBSampleReference],
     [ImportCatalogue].[dblBasePrice],
     [ImportCatalogue].[ysnBoughtAsReserve],
     [ImportCatalogue].[strCurrency],
     [ImportCatalogue].[ysnEuropeanCompliantFlag],
     [ImportCatalogue].[strEvaluatorsCodeAtTBO],
     [ImportCatalogue].[strEvaluatorsRemarks],
     [ImportCatalogue].[strFromLocationCode],
     [ImportCatalogue].[strReceivingStorageLocation],
     [ImportCatalogue].[strSampleBoxNumberTBO],
     [ImportCatalogue].[strBatchNo],
     [ImportCatalogue].[strSampleTypeName],
     [ImportCatalogue].[strBroker],
     [ImportCatalogue].[strTINNumber],
     [ImportCatalogue].[strStrategy],
     [dblBulkDensity] = ISNULL(CASE WHEN [ImportCatalogue].[dblBulkDensity] = 0 THEN NULL ELSE [ImportCatalogue].[dblBulkDensity] END, CAST(Density.strPropertyValue AS NUMERIC(18, 6))),
     [dblTeaMoisture] = ISNULL(CASE WHEN [ImportCatalogue].[dblTeaMoisture] = 0 THEN NULL ELSE [ImportCatalogue].[dblTeaMoisture] END, CAST(Moisture.strPropertyValue AS NUMERIC(18, 6))),
     [dblTeaVolume] = COALESCE(CASE WHEN [ImportCatalogue].[dblTeaVolume] = 0 THEN NULL ELSE [ImportCatalogue].[dblTeaVolume] END, CAST(Volume.strPropertyValue AS NUMERIC(18, 6)), I.dblBlendWeight),
      QMSample.strSampleNumber
FROM tblQMImportCatalogue AS ImportCatalogue
LEFT JOIN tblQMSample AS QMSample ON ImportCatalogue.intSampleId = QMSample.intSampleId
LEFT JOIN tblICItem I ON I.intItemId = QMSample.intItemId
-- Appearance
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Appearance'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strAppearance, '') = ''
     ) APPEARANCE
-- Hue
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Hue'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strHue, '') = ''
     ) HUE
-- Intensity
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Intensity'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strIntensity, '') = ''
     ) INTENSITY
-- Taste
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Taste'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strTaste, '') = ''
     ) TASTE
-- Mouth Feel
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Mouth Feel'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strMouthfeel, '') = ''
     ) MOUTH_FEEL
-- Density
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Density'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.dblBulkDensity, 0) = 0
     ) Density
-- Moisture
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Moisture'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.dblTeaMoisture, 0) = 0
     ) Moisture
-- Fines
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Fines'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strFines, '') = ''
     ) Fines
-- Volume
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Volume'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.dblTeaVolume, 0) = 0
     ) Volume
-- Dust Level
OUTER APPLY (
     SELECT TOP 1 TR.strPropertyValue
     ,TR.dblPinpointValue
     FROM tblQMTestResult TR
     JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
     AND P.strPropertyName = 'Dust Level'
     WHERE TR.intSampleId = QMSample.intSampleId
     -- AND ISNULL(ImportCatalogue.strDustContent, '') = ''
     ) DustLevel
GO

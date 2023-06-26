CREATE VIEW [dbo].[vyuRKM2MBasisImport_ErrLog]
AS 
SELECT 
	  intBasisImportErrId
	, strType
	, intConcurrencyId = 1
	, strFutMarketName
	, strCommodityCode
	, strItemNo
	, strLocation
	, strMarketZone
	, strOriginPort
	, strDestinationPort
	, strCropYear
	, strStorageLocation
	, strStorageUnit
	, strPeriodTo
	, strContractType
	--, strProductType
	--, strGrade
	--, strRegion
	--, strProductLine
	--, strClass
	--, strCertification
	--, strMTMPoint
	, strCurrency
	, strContractInventory
	, strUnitMeasure
	, dblCash
	, dblBasis
	, dblRatio
	, strErrMessage
FROM tblRKM2MBasisImport_ErrLog
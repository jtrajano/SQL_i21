CREATE VIEW vyuQMAuctionReport
AS
SELECT intSampleId					= S.intSampleId
	 , strSaleNumber				= S.strSaleNumber
	 , strSampleNote				= S.strSampleNote
	 , strBrokerName				= E.strName
	 , strAuctionPrice				= CAST(CAST(ISNULL(AUCPRICE.dblMinPrice, 0) AS DECIMAL(18,2)) AS NVARCHAR(100)) + ' - ' + CAST(CAST(ISNULL(AUCPRICE.dblMaxPrice, 0) AS DECIMAL(18,2)) AS NVARCHAR(100))
	 , strWarehouse					= SL.strSubLocationName
	 , dblSupplierValuationPrice	= ISNULL(S.dblSupplierValuationPrice, 0)
	 , strLotNumber					= S.strRepresentLotNumber
	 , strGrade						= GRADE.strDescription
	 , strInvoiceNumber				= S.strChopNumber
	 , dblQuantity					= PIUM.strUnitMeasure
	 , strQtyUOM					= PIUM.strUnitMeasure--RIUM.strUnitMeasure
	 , dblWeight					= ISNULL(S.dblSampleQty, 0)
	 , dblWeightPerQty				= RIUM.strUnitMeasure--ISNULL(dbo.fnCalculateQtyBetweenUoms(ITEM.strItemNo, SIUM.strUnitMeasure, RIUM.strUnitMeasure, ISNULL(S.dblSampleQty, 0)), 0)
	 , strPackageType				= ISNULL([dbo].[fnRemoveTrailingZeroes](S.dblRepresentingQty), 0)
	 , dblBasePrice					= ISNULL(S.dblBasePrice, 0)
	 , dblTastingScore				= ISNULL(PV.dblActualValue, 0)
	 , strSupplier					= SUP.strName
	 , strProducer 					= PRODUCER.strName
	 , strTeaLingoItem				= ITEM.strItemNo
	 , strCompanyName				= COMP.strCompanyName
	 , strCompanyAddress			= COMP.strAddress
	 , strCityStateZip				= COMP.strCity + ', ' + COMP.strState + ', ' + COMP.strZip
	 , strCompanyCountry			= COMP.strCountry
	 , strTest						= S.strComments2 
	 , strGardenMark				= GM.strGardenMark
	 , strMarketZoneCode			= MZ.strMarketZoneCode
	 , strLeafStyleSize				= ISNULL(B.strBrandCode, '') + ISNULL(VG.strName, '')
FROM tblQMSample S
LEFT JOIN tblEMEntity SUP ON S.intEntityId = SUP.intEntityId
LEFT JOIN tblEMEntity E ON S.intBrokerId = E.intEntityId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON S.intCompanyLocationSubLocationId = SL.intCompanyLocationSubLocationId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = S.intGradeId
LEFT JOIN tblICUnitMeasure SIUM ON SIUM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN tblICUnitMeasure RIUM ON RIUM.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN tblICUnitMeasure PIUM ON PIUM.intUnitMeasureId = S.intPackageTypeId
LEFT JOIN tblQMGardenMark GM ON S.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblARMarketZone MZ ON S.intMarketZoneId = MZ.intMarketZoneId
LEFT JOIN tblEMEntity PRODUCER ON GM.intProducerId = PRODUCER.intEntityId
LEFT JOIN tblICBrand B ON S.intBrandId = B.intBrandId
LEFT JOIN tblCTValuationGroup VG ON S.intValuationGroupId = VG.intValuationGroupId
OUTER APPLY (
	SELECT TOP 1 dblActualValue = CAST(ISNULL(NULLIF(TR.strPropertyValue, ''), '0') AS NUMERIC(18, 6))
	FROM tblQMTestResult TR 
	INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Taste' 
	WHERE TR.intSampleId = S.intSampleId
) PV
OUTER APPLY (
	SELECT TOP 1 *
	FROM tblSMCompanySetup
	ORDER BY intCompanySetupID ASC
) COMP
OUTER APPLY (
	SELECT dblMinPrice	= MIN(ISNULL(dblB1Price, 0))
		 , dblMaxPrice  = MAX(ISNULL(dblB1Price, 0))
	FROM tblQMSample A
	WHERE A.intGardenMarkId=S.intGardenMarkId 
		and A.intGradeId =S.intGradeId 
	  AND A.dtmSaleDate IN (Select MAX(B.dtmSaleDate) from tblQMSample B Where B.dtmSaleDate<= S.dtmSaleDate) 
) AUCPRICE
WHERE S.strSaleNumber IS NOT NULL
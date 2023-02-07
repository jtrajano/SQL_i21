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
	 , dblQuantity					= ISNULL(S.dblRepresentingQty, 0)
	 , strQtyUOM					= RIUM.strUnitMeasure
	 , dblWeight					= ISNULL(S.dblSampleQty, 0)
	 , dblWeightPerQty				= ISNULL(dbo.fnCalculateQtyBetweenUoms(ITEM.strItemNo, SIUM.strUnitMeasure, RIUM.strUnitMeasure, ISNULL(S.dblSampleQty, 0)), 0)
	 , dblBasePrice					= ISNULL(S.dblBasePrice, 0)
	 , dblTastingScore				= ISNULL(PV.dblPinpointValue, 0)
	 , strSupplier					= SUP.strName
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
LEFT JOIN tblQMGardenMark GM ON S.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblARMarketZone MZ ON S.intMarketZoneId = MZ.intMarketZoneId
LEFT JOIN tblICBrand B ON ITEM.intBrandId = B.intBrandId
LEFT JOIN tblCTValuationGroup VG ON ITEM.intValuationGroupId = VG.intValuationGroupId
OUTER APPLY (
	SELECT TOP 1 PPVP.dblPinpointValue 
	FROM tblQMProduct P  
	INNER JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId
	INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId	
    LEFT JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId
      AND DATEPART(dayofyear, GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
    WHERE PP.intProductId = P.intProductId AND PROP.strPropertyName = 'Taste'
	  AND P.intProductValueId = ITEM.intItemId
	  AND P.intProductTypeId =  2
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
	WHERE A.strSaleNumber IS NOT NULL
	  AND A.strSaleNumber = S.strSaleNumber
	GROUP BY A.strSaleNumber
) AUCPRICE
WHERE S.strSaleNumber IS NOT NULL
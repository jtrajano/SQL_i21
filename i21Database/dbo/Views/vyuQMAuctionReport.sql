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
	 , strQtyUOM					= UOM.strUnitMeasure
	 , dblWeight					= ISNULL(S.dblSampleQty, 0)
	 , dblWeightPerQty				= CASE WHEN ISNULL(S.dblRepresentingQty, 0) <> 0 THEN ISNULL(S.dblSampleQty, 0) / ISNULL(S.dblRepresentingQty, 0)  ELSE ISNULL(S.dblSampleQty, 0) END 
	 , dblBasePrice					= ISNULL(S.dblBasePrice, 0)
	 , strSupplier					= SUP.strName
	 , strTeaLingoItem				= ITEM.strItemNo
	 , strCompanyName				= COMP.strCompanyName
	 , strCompanyAddress			= COMP.strAddress
	 , strCityStateZip				= COMP.strCity + ', ' + COMP.strState + ', ' + COMP.strZip
	 , strCompanyCountry			= COMP.strCountry
	 , blbHeaderLogo				= dbo.fnSMGetCompanyLogo('Header')
FROM tblQMSample S
LEFT JOIN tblEMEntity SUP ON S.intEntityId = SUP.intEntityId
LEFT JOIN tblEMEntity E ON S.intBrokerId = E.intEntityId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON S.intCompanyLocationSubLocationId = SL.intCompanyLocationSubLocationId
LEFT JOIN tblICUnitMeasure UOM ON S.intRepresentingUOMId = UOM.intUnitMeasureId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = S.intGradeId
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
	  AND A.intSampleId < S.intSampleId
) AUCPRICE
WHERE S.strSaleNumber IS NOT NULL
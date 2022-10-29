CREATE VIEW vyuQMAuctionReport
AS
SELECT intSampleId					= S.intSampleId
	 , strSampleNumber				= S.strSampleNumber
	 , strSampleNote				= S.strSampleNote
	 , strBrokerName				= E.strName
	 , strAuctionPrice				= CAST('0.00-0.00' AS NVARCHAR(100))
	 , strWarehouse					= SL.strSubLocationName
	 , dblSupplierValuationPrice	= ISNULL(S.dblSupplierValuationPrice, 0)
	 , strLotNumber					= S.strLotNumber
	 , strGrade						= S.strGrade
	 , strInvoiceNumber				= CAST('ML2021' AS NVARCHAR(100))
	 , dblQuantity					= S.dblRepresentingQty
	 , strQtyUOM					= UOM.strUnitMeasure
	 , dblWeight					= ISNULL(S.dblNetWeight, 0)
	 , dblWeightPerQty				= ISNULL(S.dblNetWtPerPackages, 0)
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
OUTER APPLY (
	SELECT TOP 1 *
	FROM tblSMCompanySetup
	ORDER BY intCompanySetupID ASC
) COMP
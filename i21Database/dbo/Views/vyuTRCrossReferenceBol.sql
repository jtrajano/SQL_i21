CREATE VIEW [dbo].[vyuTRCrossReferenceBol]
	AS 
SELECT CRB.intCrossReferenceBolId,
    CRB.intCrossReferenceId,
    CRB.strType,
    CRB.strImportValue,
    CRB.intSupplierId,
    EMV.strName strSupplierName,
    CRB.intSupplyPointId,
    ELS.strLocationName strSupplyPoint,
    CRB.intCustomerId,
    EMC.strName strCustomerName,
    CRB.intCustomerLocationId,
    ELC.strLocationName strCustomerLocationName,
    CRB.intCompanyLocationId,
    CL.strLocationName strCompanyLocationName,
    CRB.intItemId,
    I.strItemNo,
    I.strLocationName strItemLocationName,
    CRB.intDriverId,
    EMD.strName strDriverName,
    CRB.intTruckId,
    SVTR.strTruckNumber strTruckName,
    CRB.intTrailerId,
    ST.strTrailerNumber,
    CRB.intCarrierId,
    SV.strShipVia strCarrierName,
    CRB.intConcurrencyId,
    ysnDefault = ISNULL(CRB.ysnDefault, CAST(0 AS BIT))
FROM tblTRCrossReferenceBol CRB
LEFT JOIN tblEMEntity EMV ON EMV.intEntityId = CRB.intSupplierId
LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = CRB.intSupplyPointId
    LEFT JOIN tblEMEntityLocation ELS ON ELS.intEntityLocationId = SP.intEntityLocationId
LEFT JOIN tblEMEntity EMC ON EMC.intEntityId = CRB.intCustomerId
LEFT JOIN tblEMEntityLocation ELC ON ELC.intEntityLocationId = CRB.intCustomerLocationId 
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CRB.intCompanyLocationId
LEFT JOIN vyuICGetItemStock I ON I.intItemId = CRB.intItemId
LEFT JOIN tblEMEntity EMD ON EMD.intEntityId = CRB.intDriverId
LEFT JOIN tblSCTruckDriverReference DR ON DR.intTruckDriverReferenceId = CRB.intTruckId
LEFT JOIN tblSMShipViaTrailer ST ON ST.intEntityShipViaTrailerId = CRB.intTrailerId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = CRB.intCarrierId
LEFT JOIN tblSMShipViaTruck SVTR ON SVTR.intEntityShipViaTruckId = CRB.intTruckId
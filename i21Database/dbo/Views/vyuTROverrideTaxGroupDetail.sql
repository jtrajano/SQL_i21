CREATE VIEW [dbo].[vyuTROverrideTaxGroupDetail]
	AS 
SELECT OTD.intOverrideTaxGroupDetailId, 
OTD.intOverrideTaxGroupId,  
OTD.intSupplierId,
EMV.strName strSupplierName,
OTD.intSupplyPointId,
ELS.strLocationName strSupplyPoint,
OTD.intCustomerId,
EMC.strName strCustomerName,
OTD.intCustomerShipToId,
ELC.strLocationName strCustomerShipTo,
OTD.intBulkLocationId,
CL.strLocationName strBulkLocation,
OTD.intShipViaId,
SV.strShipVia strShipViaName,
OTD.strReceiptState,
OTD.strDistributionState,
OTD.intReceiptTaxGroupId,
RTG.strTaxGroup strReceiptTaxGroup,
OTD.intDistributionTaxGroupId,
DTG.strTaxGroup strDistributionTaxGroup,
OTD.intConcurrencyId
FROM tblTROverrideTaxGroupDetail OTD
LEFT JOIN tblEMEntity EMV ON EMV.intEntityId = OTD.intSupplierId
LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = OTD.intSupplyPointId
    LEFT JOIN tblEMEntityLocation ELS ON ELS.intEntityLocationId = SP.intEntityLocationId
LEFT JOIN tblEMEntity EMC ON EMC.intEntityId = OTD.intCustomerId
LEFT JOIN tblEMEntityLocation ELC ON ELC.intEntityLocationId = OTD.intCustomerShipToId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = OTD.intBulkLocationId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = OTD.intShipViaId 
LEFT JOIN tblSMTaxGroup RTG ON RTG.intTaxGroupId = OTD.intReceiptTaxGroupId
LEFT JOIN tblSMTaxGroup DTG ON DTG.intTaxGroupId = OTD.intDistributionTaxGroupId


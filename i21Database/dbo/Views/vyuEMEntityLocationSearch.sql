CREATE VIEW [dbo].[vyuEMEntityLocationSearch]
AS
SELECT intEntityId				= EL.intEntityId
     , intEntityLocationId		= EL.intEntityLocationId
     , strLocationName			= EL.strLocationName
     , strAddress				= EL.strAddress
     , strCity					= EL.strCity
     , strCountry				= EL.strCountry
     , strCounty				= EL.strCounty
     , strState					= EL.strState
     , strZipCode				= EL.strZipCode
     , strPhone					= EL.strPhone
     , strFax					= EL.strFax
     , strNotes					= EL.strNotes
     , strOregonFacilityNumber	= EL.strOregonFacilityNumber
     , strPricingLevel			= EL.strPricingLevel
     , intShipViaId				= EL.intShipViaId
     , intTermsId				= EL.intTermsId
     , intWarehouseId			= EL.intWarehouseId
     , ysnDefaultLocation		= EL.ysnDefaultLocation
     , intFreightTermId			= EL.intFreightTermId
     , intCountyTaxCodeId		= EL.intCountyTaxCodeId
     , intTaxClassId			= EL.intTaxClassId
     , intTaxGroupId			= EL.intTaxGroupId
     , ysnActive				= EL.ysnActive
     , dblLongitude				= EL.dblLongitude
     , dblLatitude				= EL.dblLatitude
     , strTimezone				= EL.strTimezone
     , intConcurrencyId			= EL.intConcurrencyId
     , strTaxClass				= TC.strTaxClass
     , strTaxGroup				= TG.strTaxGroup
     , strCheckPayeeName		= EL.strCheckPayeeName
     , strShipVia				= SV.strShipVia
     , strTerm					= TERM.strTerm
     , strWarehouse				= LOC.strLocationName
     , strFreightTerm			= FREIGHT.strFreightTerm
     , strCountyTaxCode			= TCODE.strCounty
     , intSalespersonId			= ISNULL(EL.intSalespersonId, CUSTOMER.intSalespersonId)
     , strSalesPersonName		= SALESPERSON.strSalesPersonName
     , strDefaultCurrency		= CURRENCY.strCurrency
     , intDefaultCurrencyId		= EL.intDefaultCurrencyId
     , intVendorLinkId			= EL.intVendorLinkId
     , strVendorLinkName		= VLINK.strName
     , strLocationDescription	= EL.strLocationDescription
     , strLocationType			= EL.strLocationType
     , strFarmFieldNumber		= EL.strFarmFieldNumber
     , strFarmFieldDescription	= EL.strFarmFieldDescription
     , strFarmFSANumber			= EL.strFarmFSANumber
     , strFarmSplitNumber		= EL.strFarmSplitNumber
     , strFarmSplitType			= EL.strFarmSplitType
     , dblFarmAcres				= EL.dblFarmAcres
     , imgFieldMapFile			= EL.imgFieldMapFile
     , strFieldMapFile			= EL.strFieldMapFile
     , ysnPrint1099				= EL.ysnPrint1099
     , str1099Name				= EL.str1099Name
     , str1099Form				= EL.str1099Form
     , str1099Type				= EL.str1099Type
     , strFederalTaxId			= EL.strFederalTaxId
     , dtmW9Signed				= EL.dtmW9Signed
	 , strVATNo					= EL.strVATNo
FROM tblEMEntityLocation EL
LEFT JOIN tblSMTaxClass TC ON EL.intTaxClassId = TC.intTaxClassId
LEFT JOIN tblSMTaxGroup TG ON EL.intTaxGroupId = TG.intTaxGroupId
LEFT JOIN tblSMTaxCode TCODE ON EL.intCountyTaxCodeId = TCODE.intTaxCodeId
LEFT JOIN tblSMCurrency CURRENCY ON EL.intDefaultCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN tblSMTerm TERM ON EL.intTermsId = TERM.intTermID
LEFT JOIN tblSMFreightTerms FREIGHT ON EL.intFreightTermId = FREIGHT.intFreightTermId
LEFT JOIN tblSMCompanyLocation LOC ON EL.intWarehouseId = LOC.intCompanyLocationId
LEFT JOIN tblEMEntity VLINK ON EL.intVendorLinkId = VLINK.intEntityId
LEFT JOIN tblSMShipVia SV ON EL.intShipViaId = SV.intEntityId
LEFT JOIN tblARCustomer CUSTOMER ON EL.intEntityId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT S.intEntityId
		 , strSalespersonId	    = CASE WHEN ISNULL(S.strSalespersonId, '') = '' THEN ST.strEntityNo ELSE S.strSalespersonId END
		 , strSalesPersonName	= ST.strName
	FROM dbo.tblARSalesperson S WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
			 , strEntityNo
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) ST on S.intEntityId = ST.intEntityId
) SALESPERSON ON SALESPERSON.intEntityId = ISNULL(EL.intSalespersonId, CUSTOMER.intSalespersonId)
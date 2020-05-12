CREATE VIEW [dbo].[vyuEMEntityLocationWithType]
AS
SELECT intEntityLocationId			= EL.intEntityLocationId
	 , intEntityId					= EL.intEntityId
	 , strLocationName				= EL.strLocationName
	 , strAddress					= EL.strAddress
	 , strCity						= EL.strCity
	 , strCountry					= EL.strCountry
	 , strState						= EL.strState
	 , strZipCode					= EL.strZipCode
	 , strSupplyPoint				= EL.strLocationName
	 , intRackPriceSupplyPointId	= SP.intRackPriceSupplyPointId
	 , strGrossOrNet				= SP.strGrossOrNet
	 , ysnActive					= EL.ysnActive
	 , Vendor						= ET.Vendor
	 , Customer						= ET.Customer
	 , Salesperson					= ET.Salesperson
	 , FuturesBroker				= ET.FuturesBroker
	 , ForwardingAgent				= ET.ForwardingAgent
	 , Terminal						= ET.Terminal
	 , ShippingLine					= ET.ShippingLine
	 , Trucker						= ET.Trucker
	 , ShipVia						= ET.ShipVia
	 , Insurer						= ET.Insurer
	 , Employee						= ET.Employee
	 , Producer						= ET.Producer
	 , [User]						= ET.[User]
	 , Prospect						= ET.Prospect
	 , Competitor					= ET.Competitor
	 , Buyer						= ET.Buyer
	 , [Partner]					= ET.[Partner]
	 , Lead							= ET.Lead
	 , Veterinary					= ET.Veterinary
	 , Lien							= ET.Lien
	 , strRackPriceSupplyPoint		= SPEL.strLocationName
	 , intTerminalControlNumberId	= TCN.intTerminalControlNumberId
	 , strTerminalControlNumber		= TCN.strTerminalControlNumber
	 , strFuelDealerId1				= SP.strFuelDealerId1
	 , strFuelDealerId2				= SP.strFuelDealerId2
	 , strDefaultOrigin				= SP.strDefaultOrigin
	 , ysnMultipleDueDates			= SP.ysnMultipleDueDates
	 , intTaxGroupId				= EL.intTaxGroupId
	 , strTaxGroup					= TG.strTaxGroup
	 , intSupplyPointId				= SP.intSupplyPointId
	 , intSalespersonId				= ISNULL(EL.intSalespersonId, CUSTOMER.intSalespersonId)
	 , strSalespersonId				= SALESPERSON.strSalespersonId
	 , strSalesPersonName			= SALESPERSON.strSalesPersonName
FROM tblEMEntityLocation EL
JOIN vyuEMEntityType ET ON EL.intEntityId = ET.intEntityId
LEFT JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = EL.intEntityLocationId 
							 --AND SP.intEntityVendorId = EL.intEntityId
LEFT JOIN tblTFTerminalControlNumber TCN ON TCN.intTerminalControlNumberId = SP.intTerminalControlNumberId
LEFT JOIN tblTRSupplyPoint RPSP ON SP.intSupplyPointId = SP.intRackPriceSupplyPointId
LEFT JOIN tblEMEntityLocation SPEL ON SPEL.intEntityLocationId = RPSP.intEntityLocationId
LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = EL.intTaxGroupId
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
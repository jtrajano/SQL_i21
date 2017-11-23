CREATE VIEW [dbo].[vyuARGetLocationTax]
AS
SELECT intTransactionId					= INVOICE.intInvoiceId
	 , intCompanyLocationId				= INVOICE.intCompanyLocationId
	 , intFreightTermId					= INVOICE.intFreightTermId
	 , intCompanyLocationTaxGroupId		= TAX.intTaxGroupId
	 , strCompanyLocationName			= CASE WHEN ISNULL(FREIGHT.strFobPoint, '') = 'Destination' THEN EL.strLocationName ELSE COMPANY.strLocationName END
	 , strFreightTerm					= FREIGHT.strFreightTerm
	 , strFobPoint						= FREIGHT.strFobPoint
	 , strTaxGroup						= TAX.strTaxGroup
	 , strTaxCode						= TAX.strTaxCode
	 , strTaxClass						= TAX.strTaxClass
	 , strTransactionType				= INVOICE.strTransactionType
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
INNER JOIN (
	SELECT intCompanyLocationId
		 , intTaxGroupId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) COMPANY ON INVOICE.intCompanyLocationId = COMPANY.intCompanyLocationId
LEFT JOIN (
	SELECT intFreightTermId		 
		 , strFreightTerm
		 , strFobPoint
	FROM dbo.tblSMFreightTerms FT WITH (NOLOCK)	
) FREIGHT ON INVOICE.intFreightTermId = FREIGHT.intFreightTermId
LEFT JOIN (
	SELECT intEntityLocationId
		 , intTaxGroupId
		 , intEntityId
		 , strLocationName
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)		
) EL ON INVOICE.intShipToLocationId = EL.intEntityLocationId
	AND INVOICE.intEntityCustomerId = EL.intEntityId
LEFT JOIN (
	SELECT TG.intTaxGroupId
		 , strTaxGroup		= TG.strDescription
		 , strTaxCode		= TC.strDescription
		 , TCC.strTaxClass
	FROM dbo.tblSMTaxGroup TG WITH (NOLOCK)
	INNER JOIN (
		SELECT intTaxCodeId
			 , intTaxGroupId
		FROM dbo.tblSMTaxGroupCode WITH (NOLOCK)
	) TGC ON TG.intTaxGroupId = TGC.intTaxGroupId
	INNER JOIN (
		SELECT intTaxCodeId
			 , intTaxClassId
			 , strTaxCode
			 , strDescription
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) TC ON TGC.intTaxCodeId = TC.intTaxCodeId
	INNER JOIN (
		SELECT intTaxClassId
			 , strTaxClass			
		FROM dbo.tblSMTaxClass WITH (NOLOCK)
	) TCC ON TC.intTaxClassId = TCC.intTaxClassId
) TAX ON TAX.intTaxGroupId = CASE WHEN ISNULL(INVOICE.intFreightTermId, 0) <> 0 AND ISNULL(FREIGHT.strFobPoint, '') = 'Destination' THEN EL.intTaxGroupId ELSE COMPANY.intTaxGroupId END
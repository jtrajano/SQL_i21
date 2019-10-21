CREATE VIEW [dbo].[vyuARGetLocationTax]
AS
SELECT intCompanyLocationId				= LOCATIONS.intCompanyLocationId
	 , intShipToLocationId				= LOCATIONS.intShipToLocationId
	 , intTaxGroupId					= TAX.intTaxGroupId
	 , strCompanyLocationName			= LOCATIONS.strLocationName
	 , strTaxGroup						= TAX.strTaxGroup
	 , strTaxCode						= TAX.strTaxCode
	 , strTaxClass						= TAX.strTaxClass
FROM (
	SELECT intCompanyLocationId
		 , intShipToLocationId		= NULL
		 , intTaxGroupId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)

	UNION ALL

	SELECT intCompanyLocationId		= -99
		 , intEntityLocationId
		 , intTaxGroupId
		 , strLocationName
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) LOCATIONS
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
) TAX ON TAX.intTaxGroupId = LOCATIONS.intTaxGroupId
CREATE VIEW [dbo].[vyuCTTaxLocation]
AS
		SELECT intCompanyLocationId intTaxLocationId
		  , 1 intContractTypeId
		  , 'Origin' strTaxPoint
		  , strLocationName strTaxLocation
		  , 0 intEntityId 
	FROM tblSMCompanyLocation

	UNION ALL

	SELECT intCompanyLocationId intTaxLocationId
		 , 2 intContractTypeId
		 , 'Destination' strTaxPoint
		 , strLocationName strTaxLocation
		 , 0 intEntityId 
	FROM tblSMCompanyLocation

	UNION ALL

	SELECT  intTaxLocationId	= intEntityLocationId
		, 1 intContractTypeId
		, 'Destination' strTaxPoint
		, strLocationName strTaxLocation
		, intEntityId 
		FROM tblEMEntityLocation

	UNION ALL

	SELECT  intTaxLocationId	= intEntityLocationId
		, 2 intContractTypeId
		, 'Origin' strTaxPoint
		, strLocationName strTaxLocation
		, intEntityId 
	FROM tblEMEntityLocation
GO



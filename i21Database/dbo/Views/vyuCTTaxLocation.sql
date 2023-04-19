CREATE VIEW [dbo].[vyuCTTaxLocation]
AS
	SELECT  intTaxLocationId = intEntityLocationId
			, 1 intContractTypeId
			, 'Origin' strTaxPoint
			, strLocationName strTaxLocation
			, intEntityId 
			, intTaxGroupId
	FROM tblEMEntityLocation

	UNION ALL

	SELECT  intTaxLocationId = intCompanyLocationId
			, 1 intContractTypeId
			, 'Destination' strTaxPoint
			, strLocationName strTaxLocation
			, 0 intEntityId 
			, intTaxGroupId
	FROM tblSMCompanyLocation

	UNION ALL

	SELECT  intTaxLocationId = intCompanyLocationId
			,2 intContractTypeId
			, 'Origin' strTaxPoint
			, strLocationName strTaxLocation
			, 0 intEntityId 
			, intTaxGroupId
	FROM tblSMCompanyLocation

	UNION ALL

	SELECT  intTaxLocationId = intEntityLocationId
			, 2 intContractTypeId
			, 'Destination' strTaxPoint
			, strLocationName strTaxLocation
			, intEntityId 
			, intTaxGroupId
	FROM tblEMEntityLocation
GO



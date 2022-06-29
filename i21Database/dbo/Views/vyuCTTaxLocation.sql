CREATE VIEW [dbo].[vyuCTTaxLocation]
AS
	SELECT  intTaxLocationId = intEntityLocationId
			, 1 intContractTypeId
			, 'Origin' COLLATE Latin1_General_CI_AS strTaxPoint
			, strLocationName strTaxLocation
			, intEntityId 
	FROM tblEMEntityLocation

	UNION ALL

	SELECT  intTaxLocationId = intCompanyLocationId
			, 1 intContractTypeId
			, 'Destination' COLLATE Latin1_General_CI_AS strTaxPoint
			, strLocationName strTaxLocation
			, 0 intEntityId 
	FROM tblSMCompanyLocation

	UNION ALL

	SELECT  intTaxLocationId = intCompanyLocationId
			,2 intContractTypeId
			, 'Origin' COLLATE Latin1_General_CI_AS strTaxPoint
			, strLocationName strTaxLocation
			, 0 intEntityId 
	FROM tblSMCompanyLocation

	UNION ALL

	SELECT  intTaxLocationId = intEntityLocationId
			, 2 intContractTypeId
			, 'Destination' COLLATE Latin1_General_CI_AS strTaxPoint
			, strLocationName strTaxLocation
			, intEntityId 
	FROM tblEMEntityLocation
GO



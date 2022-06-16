CREATE VIEW [dbo].[vyuCTTaxLocation]
AS
	SELECT 1 intContractTypeId, 'Origin' strTaxPoint, strLocationName strTaxLocation, 0 intEntityId from tblSMCompanyLocation
	UNION ALL
	SELECT 2 intContractTypeId, 'Destination' strTaxPoint, strLocationName strTaxLocation, 0 intEntityId from tblSMCompanyLocation
	UNION ALL
	SELECT 1 intContractTypeId, 'Destination' strTaxPoint, strLocationName strTaxLocation, intEntityId from tblEMEntityLocation
	UNION ALL
	SELECT 2 intContractTypeId, 'Origin' strTaxPoint, strLocationName strTaxLocation, intEntityId from tblEMEntityLocation
GO



CREATE VIEW [dbo].[vyuAPVendorLocationSearch]
AS
SELECT
	a.intEntityId,
	isnull(a.strName,'') strName,
	isnull(a.strEntityNo,'') strEntityNo,
	isnull(b.strLocationName,'') strLocationName,
	isnull(b.strAddress,'') strAddress,
	isnull(b.strCity,'') strCity,
	isnull(b.strCountry,'') strCountry,
	isnull(b.strState,'') strState,
	isnull(b.strZipCode,'') strZipCode,
	isnull(b.strPhone,'') strPhone,
	isnull(b.strFax,'') strFax,
	isnull(b.strPricingLevel,'') strPricingLevel,
	isnull(b.dblLongitude,0.0) dblLongitude,
	isnull(b.dblLatitude,0.0) dblLatitude,
	isnull(b.strLocationDescription,'') strLocationDescription,
	isnull(b.strLocationType,'') strLocationType

	FROM tblEMEntity a
	INNER JOIN tblEMEntityLocation b
		ON a.intEntityId = b.intEntityId
	JOIN tblEMEntityType etype
        ON etype.intEntityId = a.intEntityId AND strType = 'Vendor'
GO



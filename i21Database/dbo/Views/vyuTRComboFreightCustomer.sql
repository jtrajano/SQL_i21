CREATE VIEW [dbo].[vyuTRComboFreightCustomer]
AS 
SELECT CFC.intComboFreightCustomerId,
	CFC.intCustomerEntityId,
	E.strName AS strCustomerName,
	E.strEntityNo AS strCustomerEntityNo,
	CFC.intCustomerLocationId,
	EL.strLocationName AS strCustomerLocation,
	CFC.dblMinimumUnit,
	CFC.strFreightRateType,
	CFC.strGallonType,
	CFC.intCategoryId,
	CA.strCategoryCode AS strCategoryCode,
	CFC.dtmEffectiveDateTime,
	CFC.intConcurrencyId
FROM tblTRComboFreightCustomer CFC
LEFT JOIN tblARCustomer C ON C.intEntityId = CFC.intCustomerEntityId
LEFT JOIN tblEMEntity E ON E.intEntityId = C.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = CFC.intCustomerLocationId AND EL.intEntityId = CFC.intCustomerEntityId
LEFT JOIN tblICCategory CA ON CA.intCategoryId = CFC.intCategoryId
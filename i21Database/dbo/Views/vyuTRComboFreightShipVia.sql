CREATE VIEW [dbo].[vyuTRComboFreightShipVia]
AS
SELECT FSV.intComboFreightShipViaId,
	FSV.intShipViaEntityId,
	E.strName AS strShipViaName,
	E.strEntityNo AS strShipViaEntityNo,
	FSV.dblMinimumUnit,
	FSV.strFreightRateType,
	FSV.strGallonType,
	FSV.intCategoryId,
	CA.strCategoryCode AS strCategoryCode,
	FSV.dtmEffectiveDateTime,
	FSV.intConcurrencyId
FROM tblTRComboFreightShipVia FSV
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = FSV.intShipViaEntityId
LEFT JOIN tblEMEntity E ON E.intEntityId = SV.intEntityId
LEFT JOIN tblICCategory CA ON CA.intCategoryId = FSV.intCategoryId

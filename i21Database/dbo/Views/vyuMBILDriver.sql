CREATE VIEW [dbo].[vyuMBILDriver]
	AS
	
SELECT Entity.intEntityId
	, strDriverNo = Entity.strEntityNo
	, strDriverName = Entity.strName
FROM tblARSalesperson SalesPerson
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = SalesPerson.intEntityId
WHERE SalesPerson.strType = 'Driver'
CREATE VIEW [dbo].[vyuEMEntityOnGroup]
AS 
SELECT ee.intEntityId, ee.strName
FROM tblEMEntityGroupDetail eg
INNER JOIN vyuEMSearch ee ON eg.intEntityId = ee.intEntityId
WHERE ee.Vendor = 1

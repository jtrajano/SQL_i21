CREATE VIEW [dbo].[vyuApiLineOfBusiness]
AS

SELECT
      lb.intLineOfBusinessId
    , lb.strLineOfBusiness
    , lb.intEntityId
	, e.strName strSalesperson
    , lb.strSICCode
    , lb.strType
FROM tblSMLineOfBusiness lb
LEFT JOIN tblEMEntity e ON e.intEntityId = lb.intEntityId
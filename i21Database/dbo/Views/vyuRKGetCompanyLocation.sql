CREATE VIEW vyuRKGetCompanyLocation 
AS

SELECT 0 as intCompanyLocationId, '- All -' as strLocationName
UNION 
SELECT intCompanyLocationId,strLocationName from tblSMCompanyLocation

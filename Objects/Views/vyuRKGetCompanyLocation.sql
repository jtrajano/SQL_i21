CREATE VIEW vyuRKGetCompanyLocation 
AS

SELECT 0 as intCompanyLocationId, '- All -' COLLATE Latin1_General_CI_AS as strLocationName
UNION 
SELECT intCompanyLocationId,strLocationName from tblSMCompanyLocation

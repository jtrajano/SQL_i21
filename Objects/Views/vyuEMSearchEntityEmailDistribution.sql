CREATE VIEW [dbo].[vyuEMSearchEntityEmailDistribution]
AS 
SELECT a.intEntityId
,a.strName
,c.intEntityId as intEntityContactId
,c.strName as strContactName
,c.strEmail
,c.strEmailDistributionOption
FROM tblEMEntity a
INNER JOIN tblEMEntityToContact b ON b.intEntityId = a.intEntityId
INNER JOIN tblEMEntity c ON c.intEntityId = b.intEntityContactId AND c.strEmailDistributionOption <> ''
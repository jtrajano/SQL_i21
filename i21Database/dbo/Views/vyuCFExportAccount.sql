CREATE VIEW [dbo].[vyuCFExportAccount]
AS
SELECT   emEnt.intEntityId, emEnt.strEntityNo, arCus.ysnActive, REPLACE(REPLACE(SUBSTRING(emEntLoc.strAddress, 1, 30), CHAR(13), ''), CHAR(10), '') AS strAddress1, 
                         REPLACE(REPLACE(SUBSTRING(emEntLoc.strAddress, 30, 30), CHAR(13), ''), CHAR(10), '') AS strAddress2, emEntLoc.strCity, emEntLoc.strPhone, emEnt.strName, 
                         emEntLoc.strZipCode, emEntLoc.strFax, emEntLoc.strState, emEnt.strEmail, '' AS dtmDateLastModified, '' AS dtmTimeLastModified, CONVERT(bit, 0) AS ysnUpdateFlag, 
                         CONVERT(numeric(18, 6), 0) AS dblCreditLimit, CONVERT(bit, 0) AS ysnCreditIndicator, emEnt.intConcurrencyId
FROM         dbo.tblEMEntity AS emEnt INNER JOIN
                         dbo.tblARCustomer AS arCus ON emEnt.intEntityId = arCus.intEntityId INNER JOIN
                         dbo.tblEMEntityLocation AS emEntLoc ON emEnt.intEntityId = emEntLoc.intEntityId
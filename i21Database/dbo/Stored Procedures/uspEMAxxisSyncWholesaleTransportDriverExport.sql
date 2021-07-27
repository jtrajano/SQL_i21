CREATE PROCEDURE [dbo].[uspEMAxxisSyncWholesaleTransportDriverExport]
AS
	DECLARE @tblDriver AS TABLE 
(
	intEntityId INT,
	strName NVARCHAR(MAX) ,
	strContactName NVARCHAR(MAX),
	strEmail NVARCHAR(MAX),
	strEmailUserName NVARCHAR(MAX),
	strShipVia NVARCHAR(MAX)
)
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF OBJECT_ID(N'tmpAxxisDriver') IS NOT NULL DROP TABLE tmpAxxisDriver

INSERT INTO @tblDriver
SELECT A.intEntityId, A.strName, NULL, A.strEmail, NULL, NULL FROM tblEMEntity A
	INNER JOIN tblEMEntityLineOfBusiness B ON A.intEntityId = B.intEntityId
	INNER JOIN tblSMLineOfBusiness C ON B.intLineOfBusinessId = C.intLineOfBusinessId
	WHERE C.strLineOfBusiness = 'Wholesale Transports'

MERGE @tblDriver AS driver
USING 
(
	SELECT A.intEntityId, B.intEntityContactId FROM @tblDriver A INNER JOIN tblEMEntityToContact B ON A.intEntityId = B.intEntityId
) AS contact
ON driver.intEntityId = contact.intEntityId
WHEN MATCHED THEN
UPDATE SET driver.strContactName = (SELECT strName FROM tblEMEntity where intEntityId = contact.intEntityContactId),
		   driver.strEmail = (SELECT strEmail FROM tblEMEntity where intEntityId = contact.intEntityContactId),
		   driver.strEmailUserName = (SELECT strEmail FROM tblEMEntity where intEntityId = contact.intEntityContactId);

SELECT strName, strContactName, strEmail, strEmailUserName, ISNULL(strShipVia, '') AS strShipVia 
INTO tmpAxxisDriver
FROM @tblDriver

END

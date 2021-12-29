CREATE PROCEDURE [dbo].[uspEMAxxisSyncWholesaleTransportDriverExport]
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF

	IF OBJECT_ID(N'tmpEMAxxisDriver') IS NOT NULL DROP TABLE tmpEMAxxisDriver

	SELECT 
		A.intEntityId, 
		ISNULL(A.strName, '') AS strName, 
		A.strName AS strContactName, 
		A.strEmail, 
		A.strEmail AS strEmailUserName, 
		ISNULL((SELECT strName from tblEMEntity where intEntityId = D.intShipViaId), '') AS strShipVia,
		CONVERT(NVARCHAR(10), ISNULL(D.ysnActive, '')) COLLATE Latin1_General_CI_AS AS ysnActive
	INTO tmpEMAxxisDriver
	FROM tblEMEntity A
	INNER JOIN tblEMEntityLineOfBusiness B ON A.intEntityId = B.intEntityId
	INNER JOIN tblSMLineOfBusiness C ON B.intLineOfBusinessId = C.intLineOfBusinessId
	INNER JOIN tblARSalesperson D ON  A.intEntityId = D.intEntityId AND D.strType = 'Driver'
	WHERE C.strLineOfBusiness = 'Wholesale Transports'

	MERGE tmpEMAxxisDriver AS driver
	USING 
	(
		SELECT A.intEntityId, B.intEntityContactId FROM tmpEMAxxisDriver A INNER JOIN tblEMEntityToContact B ON A.intEntityId = B.intEntityId AND B.ysnDefaultContact = 1
	) AS contact
	ON driver.intEntityId = contact.intEntityId
	WHEN MATCHED THEN
	UPDATE SET driver.strContactName = (SELECT ISNULL(strName, '') FROM tblEMEntity where intEntityId = contact.intEntityContactId),
			   driver.strEmail = (SELECT ISNULL(strEmail, '') FROM tblEMEntity where intEntityId = contact.intEntityContactId),
			   driver.strEmailUserName = (SELECT ISNULL(strEmail, '') FROM tblEMEntity where intEntityId = contact.intEntityContactId);

	SELECT strName AS Name, 
		   strContactName AS ContactName, 
		   strEmail AS Email, 
		   strEmailUserName AS EmailUserName, 
		   strShipVia AS ShipVia,
		   ysnActive AS Active
	FROM tmpEMAxxisDriver
END
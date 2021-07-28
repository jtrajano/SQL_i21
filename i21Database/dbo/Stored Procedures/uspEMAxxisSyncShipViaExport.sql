CREATE PROCEDURE [dbo].[uspEMAxxisSyncShipViaExport]
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF

	IF OBJECT_ID(N'tmpSMShipVia') IS NOT NULL DROP TABLE tmpSMShipVia
	IF OBJECT_ID(N'tmpSMShipViaTrailer') IS NOT NULL DROP TABLE tmpSMShipViaTrailer
	IF OBJECT_ID(N'tmpSMShipViaTruck') IS NOT NULL DROP TABLE tmpSMShipViaTruck

	SELECT A.intEntityId,
		'H' COLLATE Latin1_General_CI_AS AS HDCode,
		ISNULL(B.strExternalERPId, '') AS SCAC,
		ISNULL(B.strName, '') AS strName, 
		B.strName AS strContactName,
		B.strEmail, 
		B.strPhone, 
		ISNULL(B.strEntityNo, '') AS strEntityNo, 
		ISNULL(C.strLocationName, '') AS strLocationName,
		ISNULL(C.strCheckPayeeName, '') AS strPrintedName, 
		ISNULL(C.strAddress, '') AS strAddress1, 
		ISNULL(C.strAddress, '') AS strAddress2, 
		ISNULL(C.strCity, '') AS strCity, 
		ISNULL(C.strState, '') AS strState,
		ISNULL(C.strZipCode, '') AS strZipCode, 
		ISNULL(C.strTimezone, '') AS strTimezone, 
		ISNULL(B.strInternalNotes, '') AS strInternalNotes,
		ISNULL(A.strShipVia, '') AS strShipVia,
		ISNULL(A.strFederalId, '') AS strFederalId,
		CONVERT(NVARCHAR(10), ISNULL(A.ysnCompanyOwnedCarrier, '')) COLLATE Latin1_General_CI_AS AS ysnCompanyOwnedCarrier
	INTO tmpSMShipVia
	FROM tblSMShipVia A
	INNER JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
	INNER JOIN tblEMEntityLocation C ON C.intEntityId = A.intEntityId AND C.ysnDefaultLocation = 1

	MERGE tmpSMShipVia AS shipVia
	USING 
	(
		SELECT A.intEntityId, B.intEntityContactId FROM tmpSMShipVia A INNER JOIN tblEMEntityToContact B ON A.intEntityId = B.intEntityId AND B.ysnDefaultContact = 1
	) AS contact
	ON shipVia.intEntityId = contact.intEntityId
	WHEN MATCHED THEN
	UPDATE SET shipVia.strContactName = (SELECT ISNULL(strName, '') FROM tblEMEntity WHERE intEntityId = contact.intEntityContactId),
			   shipVia.strEmail = (SELECT ISNULL(strEmail, '') FROM tblEMEntity WHERE intEntityId = contact.intEntityContactId),
			   shipVia.strPhone = (SELECT ISNULL(strPhone, '') FROM tblEMEntity WHERE intEntityId = contact.intEntityContactId);

	SELECT 'TR' AS HDCode, 
			ISNULL(B.strShipVia, '') AS strShipVia, 
			ISNULL(A.strTruckNumber, '') AS strTruckNumber 
	INTO tmpSMShipViaTruck 
	FROM tblSMShipViaTruck A
	INNER JOIN tblSMShipVia B ON A.intEntityShipViaId = B.intEntityId

	SELECT 'TL' AS HDCode, 
			ISNULL(B.strShipVia, '') AS strShipVia, 
			ISNULL(A.strTrailerNumber, '') AS strTrailerNumber, 
			ISNULL(A.strTrailerDescription, '') AS strTrailerDescription
	INTO tmpSMShipViaTrailer 
	FROM tblSMShipViaTrailer A
	INNER JOIN tblSMShipVia B ON A.intEntityShipViaId = B.intEntityId

	SELECT HDCode,
		   SCAC,
		   strName AS Name,
		   strContactName AS ContactName,
		   strEmail AS Email,
		   strPhone AS Phone,
		   strEntityNo AS EntityNo,
		   strLocationName AS LocationName,
		   strPrintedName AS PrintedName,
		   strAddress1 AS Address1,
		   strAddress2 AS Address2,
		   strCity AS City,
		   strState AS State,
		   strZipCode AS ZipPostal,
		   strTimezone AS TimeZone,
		   strInternalNotes AS InternalNotes,
		   strShipVia AS ShipVia,
		   strFederalId AS FederalID,
		   ysnCompanyOwnedCarrier AS CompanyOwned
	FROM tmpSMShipVia
	SELECT HDCode, strShipVia AS ShipVia, strTruckNumber AS TruckNumber FROM tmpSMShipViaTruck
	SELECT HDCode, strShipVia AS ShipVia, strTrailerNumber AS TrailerNumber, strTrailerDescription AS TrailerDescription FROM tmpSMShipViaTrailer
END
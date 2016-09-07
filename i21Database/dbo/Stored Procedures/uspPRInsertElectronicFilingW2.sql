CREATE PROCEDURE [dbo].[uspPRInsertElectronicFilingW2]
	@intYear INT
	,@intUserId INT
	,@intElectronicFilingW2Id INT = NULL OUTPUT
AS

/* Check if Electronic Filing W-2 for the Year exists */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblPRElectronicFilingW2 WHERE intYear = @intYear)
BEGIN
	INSERT INTO tblPRElectronicFilingW2 
		(intYear
		,strSubmitterEIN
		,strUserID
		,strWFID
		,strCompanyName
		,strCompanyAddress
		,strCompanyDelivery
		,strCompanyCity
		,strCompanyState
		,strCompanyZipCode
		,strCompanyZipCodeExt
		,strCompanyCountry
		,strSubmitterName
		,strSubmitterAddress
		,strSubmitterDelivery
		,strSubmitterCity
		,strSubmitterState
		,strSubmitterZipCode
		,strSubmitterZipCodeExt
		,strSubmitterCountry
		,strContactName
		,strContactPhone
		,strContactEmail
		,strContactFax
		,strPreparerCode
		,strAgentIndicatorCode
		,strEmployerEIN
		,strAgentForEIN
		,ysnTerminatingBusiness
		,strEstablishmentNo
		,strOtherEIN
		,strEmployerName
		,strEmployerAddress
		,strEmployerDelivery
		,strEmployerCity
		,strEmployerState
		,strEmployerZipCode
		,strEmployerZipCodeExt
		,strEmployerCountry
		,strEmployerKind
		,strEmploymentCode
		,strTaxJurisdictionCode
		,ysnThirdPartySickPay
		,strEmployerContactName
		,strEmployerContactPhone
		,strEmployerContactFax
		,strEmployerContactEmail
		,dtmGenerated
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId)
	SELECT
		intYear = @intYear
		,strSubmitterEIN = ''
		,strUserID = ''
		,strWFID = ''
		,strCompanyName = LEFT(COM.strCompanyName, 57)
		,strCompanyAddress = LEFT(COM.strAddress, 22)
		,strCompanyDelivery = LEFT(COM.strAddress, 22)
		,strCompanyCity = LEFT(COM.strCity, 22)
		,strCompanyState = LEFT(COM.strState, 23)
		,strCompanyZipCode = CASE WHEN (COM.strCountry <> 'United States') 
								   THEN LEFT(REPLACE(COM.strZip, '-', ''), 15) 
								   ELSE LEFT(REPLACE(COM.strZip, '-', ''), 5) 
							  END
		,strCompanyZipCodeExt = CASE WHEN (COM.strCountry <> 'United States') 
									  THEN '' 
									  ELSE 
										   CASE WHEN (LEN(REPLACE(COM.strZip, '-', '')) > 5)
												THEN SUBSTRING(COM.strZip, 5, 4) 
												ELSE '' 
										   END 
								  END
		,strCompanyCountry = LEFT(COM.strCountry, 50)
		,strSubmitterName = LEFT(SUB.strName, 57)
		,strSubmitterAddress = LEFT(SUB.strAddress, 22)
		,strSubmitterDelivery = LEFT(SUB.strAddress, 22)
		,strSubmitterCity = LEFT(SUB.strCity, 22)
		,strSubmitterState = LEFT(SUB.strState, 23)
		,strSubmitterZipCode = CASE WHEN (SUB.strCountry <> 'United States') 
								   THEN LEFT(REPLACE(SUB.strZipCode, '-', ''), 15) 
								   ELSE LEFT(REPLACE(SUB.strZipCode, '-', ''), 5) 
							  END
		,strSubmitterZipCodeExt = CASE WHEN (SUB.strCountry <> 'United States') 
									  THEN '' 
									  ELSE 
										   CASE WHEN (LEN(REPLACE(SUB.strZipCode, '-', '')) > 5)
												THEN SUBSTRING(SUB.strZipCode, 5, 4) 
												ELSE '' 
										   END 
								  END
		,strSubmitterCountry = LEFT(SUB.strCountry, 50)
		,strContactName = LEFT(COM.strContactName, 27)
		,strContactPhone = LEFT(COM.strPhone, 15)
		,strContactEmail = LEFT(COM.strEmail, 40)
		,strContactFax = LEFT(COM.strFax, 10)
		,strPreparerCode = 'L'
		,strAgentIndicatorCode = ''
		,strEmployerEIN = LEFT(COM.strEin, 9)
		,strAgentForEIN = ''
		,ysnTerminatingBusiness = 0
		,strEstablishmentNo = ''
		,strOtherEIN = ''
		,strEmployerName = LEFT(COM.strCompanyName, 57)
		,strEmployerAddress = LEFT(COM.strAddress, 22)
		,strEmployerDelivery = LEFT(COM.strAddress, 22)
		,strEmployerCity = LEFT(COM.strCity, 22)
		,strEmployerState = LEFT(COM.strState, 23)
		,strEmployerZipCode = CASE WHEN (COM.strCountry <> 'United States') 
								   THEN LEFT(REPLACE(COM.strZip, '-', ''), 15) 
								   ELSE LEFT(REPLACE(COM.strZip, '-', ''), 5) 
							  END
		,strEmployerZipCodeExt = CASE WHEN (COM.strCountry <> 'United States') 
									  THEN '' 
									  ELSE 
										   CASE WHEN (LEN(REPLACE(COM.strZip, '-', '')) > 5)
												THEN SUBSTRING(COM.strZip, 5, 4) 
												ELSE '' 
										   END 
								  END
		,strEmployerCountry = LEFT(COM.strCountry, 50)
		,strEmployerKind = 'N'
		,strEmploymentCode = 'R'
		,strTaxJurisdictionCode= ''
		,ysnThirdPartySickPay = 0
		,strEmployerContactName = LEFT(COM.strContactName, 27)
		,strEmployerContactPhone = LEFT(COM.strPhone, 15)
		,strEmployerContactEmail = LEFT(COM.strEmail, 40)
		,strEmployerContactFax = LEFT(COM.strFax, 10)
		,dtmGenerated = NULL
		,intCreatedUserId = @intUserId
		,dtmCreated = GETDATE()
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
		,intConcurrencyId = 1
	FROM tblSMCompanySetup COM,
		(SELECT strName = ISNULL(EM.strName, '')
				,strAddress = ISNULL(EML.strAddress, '')
				,strCity = ISNULL(EML.strCity, '')
				,strState = ISNULL(EML.strState, '')
				,strCountry = ISNULL(EML.strCountry, '')
				,strZipCode = ISNULL(EML.strZipCode, '') 
		   FROM tblEMEntity EM
			INNER JOIN tblEMEntityLocation EML ON EM.intEntityId = EML.intEntityId AND EML.ysnDefaultLocation = 1
			INNER JOIN tblEMEntityToContact EMC ON EM.intEntityId = EMC.intEntityId AND EMC.ysnDefaultContact = 1
			INNER JOIN tblEMEntity EM2 ON EM2.intEntityId = EMC.intEntityContactId
		WHERE EM.intEntityId = @intUserId) SUB

	/* Get created Electronic Filing W-2 Id */
	SET @intElectronicFilingW2Id = SCOPE_IDENTITY()
END
ELSE
	SELECT TOP 1 @intElectronicFilingW2Id = intElectronicFilingW2Id 
	FROM tblPRElectronicFilingW2 WHERE intYear = @intYear
GO
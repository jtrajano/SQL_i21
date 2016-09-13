CREATE VIEW [dbo].[vyuPRElectronicFilingW2]
AS
SELECT
	intElectronicFilingW2Id
	,intYear
	,strSubmitterEIN
	,strUserID
	,ysnResubIndicator = CAST(CASE WHEN (strWFID <> '') THEN 1 ELSE 0 END AS BIT)
	,strWFID
	,strCompanyName
	,strCompanyAddress
	,strCompanyDelivery
	,strCompanyCity
	,strCompanyState = CASE WHEN (strCompanyCountry <> 'United States') THEN '' 
							ELSE 
								CASE WHEN (strCompanyState IN (SELECT strState FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN (SELECT TOP 1 strCode FROM tblPRTypeTaxState WHERE strState = strCompanyState)
									 WHEN (strCompanyState IN (SELECT strCode FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN strCompanyState
									 ELSE '' 
								END
							END
	,strCompanyZipCode = CASE WHEN (strCompanyCountry <> 'United States') THEN '' ELSE LEFT(strCompanyZipCode, 5) END
	,strCompanyZipCodeExt = CASE WHEN (strCompanyCountry <> 'United States') THEN '' ELSE LEFT(strCompanyZipCodeExt, 4) END
	,strCompanyForeignState = CASE WHEN (strCompanyCountry <> 'United States') THEN LEFT(strCompanyState, 23) ELSE '' END
	,strCompanyForeignPostal = CASE WHEN (strCompanyCountry <> 'United States') THEN LEFT(strCompanyZipCode + strCompanyZipCodeExt, 15) ELSE '' END
	,strCompanyForeignCountry = CASE WHEN (strCompanyCountry <> 'United States') 
								THEN (SELECT TOP 1 strCode FROM tblPRIRSCountryCode WHERE strCountry = strCompanyCountry)
								ELSE '' END
	,strSubmitterName
	,strSubmitterAddress
	,strSubmitterDelivery
	,strSubmitterCity
	,strSubmitterState = CASE WHEN (strSubmitterCountry <> 'United States') THEN '' 
							ELSE 
								CASE WHEN (strSubmitterState IN (SELECT strState FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN (SELECT TOP 1 strCode FROM tblPRTypeTaxState WHERE strState = strSubmitterState)
									 WHEN (strSubmitterState IN (SELECT strCode FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN strSubmitterState
									 ELSE '' 
								END
							END
	,strSubmitterZipCode = CASE WHEN (strSubmitterCountry <> 'United States') THEN '' ELSE LEFT(strSubmitterZipCode, 5) END
	,strSubmitterZipCodeExt = CASE WHEN (strSubmitterCountry <> 'United States') THEN '' ELSE LEFT(strSubmitterZipCodeExt, 4) END
	,strSubmitterForeignState = CASE WHEN (strSubmitterCountry <> 'United States') THEN LEFT(strSubmitterState, 23) ELSE '' END
	,strSubmitterForeignPostal = CASE WHEN (strSubmitterCountry <> 'United States') THEN LEFT(strSubmitterZipCode + strSubmitterZipCodeExt, 15) ELSE '' END
	,strSubmitterForeignCountry = CASE WHEN (strSubmitterCountry <> 'United States') 
								THEN (SELECT TOP 1 strCode FROM tblPRIRSCountryCode WHERE strCountry = strSubmitterCountry)
								ELSE '' END
	,strContactName
	,strContactPhone
	,strContactPhoneExt
	,strContactEmail
	,strContactFax
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
	,strEmployerState = CASE WHEN (strEmployerCountry <> 'United States') THEN '' 
							ELSE 
								CASE WHEN (strEmployerState IN (SELECT strState FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN (SELECT TOP 1 strCode FROM tblPRTypeTaxState WHERE strState = strEmployerState)
									 WHEN (strEmployerState IN (SELECT strCode FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN strEmployerState
									 ELSE '' 
								END
							END
	,strEmployerZipCode = CASE WHEN (strEmployerCountry <> 'United States') THEN '' ELSE LEFT(strEmployerZipCode, 5) END
	,strEmployerZipCodeExt = CASE WHEN (strEmployerCountry <> 'United States') THEN '' ELSE LEFT(strEmployerZipCodeExt, 4) END
	,strEmployerForeignState = CASE WHEN (strEmployerCountry <> 'United States') THEN LEFT(strEmployerState, 23) ELSE '' END
	,strEmployerForeignPostal = CASE WHEN (strEmployerCountry <> 'United States') THEN LEFT(strEmployerZipCode + strEmployerZipCodeExt, 15) ELSE '' END
	,strEmployerForeignCountry = CASE WHEN (strEmployerCountry <> 'United States') 
								THEN (SELECT TOP 1 strCode FROM tblPRIRSCountryCode WHERE strCountry = strEmployerCountry) 
								ELSE '' END
	,strEmployerKind = CASE WHEN (strTaxJurisdictionCode = 'P') THEN '' ELSE strEmployerKind END
	,strEmploymentCode
	,strTaxJurisdictionCode
	,ysnThirdPartySickPay
	,strEmployerContactName
	,strEmployerContactPhone
	,strEmployerContactPhoneExt
	,strEmployerContactFax
	,strEmployerContactEmail
FROM
	tblPRElectronicFilingW2
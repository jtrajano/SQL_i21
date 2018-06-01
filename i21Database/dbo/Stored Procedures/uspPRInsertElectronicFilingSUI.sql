CREATE PROCEDURE [dbo].[uspPRInsertElectronicFilingSUI]
	@intYear INT
	,@intQuarter INT
	,@intUserId INT
	,@intElectronicFilingSUIId INT = NULL OUTPUT
AS

/* Check if Electronic Filing SUI for the Year exists */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblPRElectronicFilingSUI WHERE intYear = @intYear AND intQuarter = @intQuarter)
BEGIN
	INSERT INTO tblPRElectronicFilingSUI 
		(intYear
		,intQuarter
		,strState
		,strFormat
		,strFileName
		,strSubmitterEIN
		,strSubmitterName
		,strSubmitterAddress
		,strSubmitterCity
		,strSubmitterState
		,strSubmitterZipCode
		,strSubmitterZipCodeExt
		,strSubmitterContact
		,strSubmitterContactPhone
		,strSubmitterContactPhoneExt
		,strAuthorizationNumber
		,strC3Data
		,strSuffixCode
		,strAllocationLists
		,strServiceAgentID
		,strComputer
		,strInternalLabel
		,strDensity
		,strCharacterSet
		,intTracks
		,intBlockingFactor
		,strCompanyName
		,strCompanyAddress
		,strCompanyCity
		,strCompanyState
		,strCompanyZipCode
		,strCompanyZipCodeExt
		,strReasonForAdjustment
		,strEmployerEIN
		,strEmployerName
		,strEmployerAddress
		,strEmployerCity
		,strEmployerState
		,strEmployerZipCode
		,strEmployerZipCodeExt
		,strEmploymentCode
		,strEstablishmentNumber
		,strSUIAccountNumber
		,strTaxTypeCode
		,strEmployerOtherEIN
		,dblSUITaxRate
		,dblSUITaxDue
		,dblUnderpayment
		,dblInterest
		,dblPenalty
		,dblOverpayment
		,dblEmployerAssessmentRate
		,dblEmployerAssessmentAmount
		,dblEmployeeAssessmentRate
		,dblEmployeeAssessmentAmount
		,dblTotalRemittance
		,intConcurrencyId)
	SELECT
		intYear = @intYear
		,intQuarter = @intQuarter
		,strState = LEFT(ISNULL(COM.strState, ''), 2)
		,strFormat = LEFT(ISNULL(PREV.strFormat, ''), 50)
		,strFileName = ''
		,strSubmitterEIN = LEFT(ISNULL(REPLACE(COM.strEin, '-', ''), ''), 9)
		,strSubmitterName = LEFT(ISNULL(SUB.strName, ''), 50)
		,strSubmitterAddress = LEFT(ISNULL(SUB.strAddress, ''), 40)
		,strSubmitterCity = LEFT(ISNULL(SUB.strCity, ''), 25)
		,strSubmitterState = LEFT(ISNULL(SUB.strState, ''), 2)
		,strSubmitterZipCode = LEFT(ISNULL(REPLACE(SUB.strZipCode, '-', ''), ''), 5)
		,strSubmitterZipCodeExt = LEFT(CASE WHEN (LEN(REPLACE(SUB.strZipCode, '-', '')) > 5)
									THEN SUBSTRING(SUB.strZipCode, 5, 4)
									ELSE '' END, 5)
		,strSubmitterContact = LEFT(ISNULL(SUB.strName, ''), 30)
		,strSubmitterContactPhone = LEFT(ISNULL(dbo.fnAPRemoveSpecialChars(SUB.strPhone), ''), 9)
		,strSubmitterContactPhoneExt = LEFT(ISNULL(CASE WHEN (CHARINDEX ('x', SUB.strPhone) > 0)
											   THEN SUBSTRING(SUB.strPhone, CHARINDEX('x', SUB.strPhone) + 1, LEN(SUB.strPhone))
											   ELSE '' END, ''), 5)
		,strAuthorizationNumber = LEFT(ISNULL(PREV.strAuthorizationNumber, ''), 6)
		,strC3Data = LEFT(ISNULL(PREV.strC3Data, ''), 1)
		,strSuffixCode = LEFT(ISNULL(PREV.strSuffixCode, ''), 5)
		,strAllocationLists = LEFT(ISNULL(PREV.strAllocationLists, ''), 1)
		,strServiceAgentID = LEFT(ISNULL(PREV.strServiceAgentID, ''), 9)
		,strComputer = LEFT(ISNULL(PREV.strComputer, ''), 8)
		,strInternalLabel = LEFT(ISNULL(PREV.strInternalLabel, 'NL'), 2)
		,strDensity = LEFT(ISNULL(PREV.strDensity, ''), 2)
		,strCharacterSet = LEFT(ISNULL(PREV.strCharacterSet, 'ASC'), 3)
		,intTracks = ISNULL(PREV.intTracks, 0)
		,intBlockingFactor = ISNULL(PREV.intBlockingFactor, 0)
		,strCompanyName = LEFT(ISNULL(COM.strCompanyName, ''), 44)
		,strCompanyAddress = LEFT(ISNULL(COM.strAddress, ''), 35)
		,strCompanyCity = LEFT(ISNULL(COM.strCity, ''), 20)
		,strCompanyState = LEFT(ISNULL(COM.strState, ''), 2)
		,strCompanyZipCode = LEFT(REPLACE(COM.strZip, '-', ''), 5)
		,strCompanyZipCodeExt = LEFT(CASE WHEN (LEN(REPLACE(COM.strZip, '-', '')) > 5)
									THEN SUBSTRING(COM.strZip, 5, 4)
									ELSE '' END, 5)
		,strReasonForAdjustment = ''
		,strEmployerEIN = LEFT(ISNULL(REPLACE(COM.strEin, '-', ''), ''), 9)
		,strEmployerName = LEFT(ISNULL(COM.strCompanyName, ''), 50)
		,strEmployerAddress = LEFT(ISNULL(COM.strAddress, ''), 35)
		,strEmployerCity = LEFT(ISNULL(COM.strCity, ''), 20)
		,strEmployerState = LEFT(ISNULL(COM.strState, ''), 2)
		,strEmployerZipCode = LEFT(REPLACE(COM.strZip, '-', ''), 5)
		,strEmployerZipCodeExt = CASE WHEN (LEN(REPLACE(COM.strZip, '-', '')) > 5)
									THEN SUBSTRING(COM.strZip, 5, 4)
									ELSE '' END
		,strEmploymentCode = LEFT(ISNULL(PREV.strEmploymentCode, 'R'), 1)
		,strEstablishmentNumber = LEFT(ISNULL(PREV.strEstablishmentNumber, ''), 4)
		,strSUIAccountNumber = LEFT(ISNULL(COM.strStateTaxID, ''), 15)
		,strTaxTypeCode = LEFT(ISNULL(PREV.strTaxTypeCode, ''), 4)
		,strEmployerOtherEIN = LEFT(ISNULL(REPLACE(PREV.strEmployerOtherEIN, '-', ''), ''), 9)
		,dblSUITaxRate = ISNULL((SELECT TOP 1 dblAmount FROM tblPRTypeTax WHERE strCalculationType = 'USA SUTA'), 0)
		,dblSUITaxDue = ISNULL((SELECT SUM(dblTotal) FROM vyuPRReportQuarterlySUI WHERE intYear = @intYear AND intQuarter = @intQuarter), 0)
		,dblUnderpayment = 0
		,dblInterest = 0
		,dblPenalty = 0
		,dblOverpayment = 0
		,dblEmployerAssessmentRate = 0
		,dblEmployerAssessmentAmount = 0
		,dblEmployeeAssessmentRate = 0
		,dblEmployeeAssessmentAmount = 0
		,dblTotalRemittance = 0
		,intConcurrencyId = 1
	FROM
		tblSMCompanySetup COM
		OUTER APPLY
		(SELECT strName = ISNULL(EM.strName, '')
				,strAddress = ISNULL(EML.strAddress, '')
				,strCity = ISNULL(EML.strCity, '')
				,strState = ISNULL(EML.strState, '')
				,strCountry = ISNULL(EML.strCountry, '')
				,strZipCode = ISNULL(EML.strZipCode, '')
				,strPhone = REPLACE(ISNULL(EM2.strPhone, ''), ' ', '')
		   FROM tblEMEntity EM
			INNER JOIN tblEMEntityLocation EML ON EM.intEntityId = EML.intEntityId AND EML.ysnDefaultLocation = 1
			INNER JOIN tblEMEntityToContact EMC ON EM.intEntityId = EMC.intEntityId AND EMC.ysnDefaultContact = 1
			INNER JOIN tblEMEntity EM2 ON EM2.intEntityId = EMC.intEntityContactId
		WHERE EM.intEntityId = @intUserId) SUB
		OUTER APPLY
		(SELECT TOP 1 * FROM tblPRElectronicFilingSUI ORDER BY intElectronicFilingSUIId DESC) PREV

	/* Get created Electronic Filing SUI Id */
	SET @intElectronicFilingSUIId = SCOPE_IDENTITY()
END
ELSE
	SELECT TOP 1 @intElectronicFilingSUIId = intElectronicFilingSUIId 
	FROM tblPRElectronicFilingSUI WHERE intYear = @intYear AND intQuarter = @intQuarter
GO
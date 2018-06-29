CREATE VIEW [dbo].[vyuPREmployee]
AS
SELECT
	EMP.intEntityId
	,EM.strEntityNo
	,EM.strName
	,EMP.strFirstName
	,EMP.strMiddleName
	,EMP.strLastName
	,EC.strPhone
	,EL.strAddress
	,EL.strCity
	,EL.strState
	,EL.strZipCode
	,EL.strCountry
	,EMP.ysnActive
	,EM.strTitle
	,EMP.strPayPeriod
	,strDepartment = SUBSTRING((SELECT ', '+ D.strDepartment AS [text()] FROM tblPREmployeeDepartment ED
								INNER JOIN tblPRDepartment D ON ED.intDepartmentId = D.intDepartmentId
								WHERE EMP.intEntityId = ED.intEntityEmployeeId
								ORDER BY ED.intEmployeeDepartmentId ASC
								FOR XML PATH ('')
							), 2, 1000)
	,strSupervisor = SUBSTRING((SELECT ', '+ E.strName AS [text()] FROM tblPREmployeeSupervisor ES
								INNER JOIN tblEMEntity E ON E.intEntityId = ES.intSupervisorId
								WHERE EMP.intEntityId = ES.intEntityEmployeeId
								ORDER BY ES.intEmployeeSupervisorId ASC
								FOR XML PATH ('')
							), 2, 1000)
	,EMP.strType
	,EMP.intRank
	,EMP.dtmReviewDate
	,EMP.dtmNextReview
	,EMP.dtmBirthDate
	,EMP.dtmOriginalDateHired
	,EMP.dtmDateHired
	,EMP.strMaritalStatus
	,EMP.strSpouse
	,EMP.strGender
	,strWorkCompCode = WCC.strWCCode
	,EMP.strEthnicity
	,strSocialSecurity = CASE WHEN ISNULL(EMP.strSocialSecurity, '') = '' THEN '' 
							ELSE 'xxx-xx-' + SUBSTRING(EMP.strSocialSecurity, LEN(EMP.strSocialSecurity) - 3, 4) END
	,EMP.strTerminatedReason
	,EMP.ysn1099Employee
	,strTimeEntryPassword = CASE WHEN ISNULL(EMP.strTimeEntryPassword, '') = '' THEN '' 
							ELSE '****************' END
	,EMP.strEmergencyContact
	,EMP.strEmergencyRelation
	,EMP.strEmergencyPhone
	,EMP.strEmergencyPhone2
FROM 
	tblPREmployee [EMP]
	INNER JOIN dbo.tblEMEntity [EM] 
		ON EM.intEntityId = EMP.intEntityId
	LEFT JOIN (SELECT A.intEntityId, A.ysnDefaultContact, C.strPhone, B.strTitle 
				FROM tblEMEntityToContact A 
					LEFT JOIN tblEMEntity B ON A.intEntityContactId = B.intEntityId
					LEFT JOIN tblEMEntityPhoneNumber C ON C.intEntityId = B.intEntityId) [EC]
		ON EC.intEntityId = EM.intEntityId AND EC.ysnDefaultContact = 1
	LEFT JOIN tblEMEntityLocation [EL]
		ON EMP.intEntityId = EL.intEntityId AND EL.ysnDefaultLocation = 1
	LEFT JOIN tblPRWorkersCompensation [WCC]
			on EMP.intWorkersCompensationId = WCC.intWorkersCompensationId
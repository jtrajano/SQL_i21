CREATE TABLE tblApiSchemaEmployee(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
    intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    strEmployeeId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, --tblPREmployee
    strName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strContactNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strSuffix NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strEMPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strPrintedName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strEmail NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strAdress NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strCity NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strState NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strZipCode NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strCountry NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strTimezone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDocumentDelivery1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDocumentDelivery2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDocumentDelivery3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strExternalERPId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    dtmOriginationDate [datetime] NULL,
    strLineOfBusiness1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness4 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness5 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strFirstName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          --tblPREmployee
    strMiddleName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,         --tblPREmployee
	strLastName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,           --tblPREmployee
	strNameSuffix NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,	        --tblPREmployee
    strTitle NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,              --tblPREmployee
    strType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,               --tblPREmployee
    strPayPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          --tblPREmployee
    strRank NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,               --tblPREmployee
    dtmReviewDate [datetime] NULL,                                          --tblPREmployee
    dtmNextReview [datetime] NULL,                                          --tblPREmployee
    strTimeEntryPassword NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  --tblPREmployee
    strEmergencyContact NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,   --tblPREmployee
    strEmergencyRelation NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  --tblPREmployee
    strEmergencyPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,     --tblPREmployee
    strEmergencyPhone2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,    --tblPREmployee
    dtmBirthDate [datetime] NULL,                                           --tblPREmployee
    ysnActive NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,             --tblPREmployee
    dtmOriginalDateHired [datetime] NULL,                                   --tblPREmployee
    strGender NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,             --tblPREmployee
    dtmDateHired [datetime] NULL,                                           --tblPREmployee
    strSpouse NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    strMaritalStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    strWorkPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    intWorkersCompensationId,--tblPREmployee
    strEthnicity NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    strEEOCCode NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    strSocialSecurity NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    dtmTerminated [datetime] NULL,--tblPREmployee
    strTerminatedReason NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    ysn1099Employee NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,--tblPREmployee
    strSupervisorId1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strSupervisorName1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strSupervisorId2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strSupervisorName2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strSupervisorId3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strSupervisorName3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strDepartment1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDepartmentDesc1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDepartment2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDepartmentDesc2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDepartment3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strDepartmentDesc3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strGlLocationDistributionLocation1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    dblGlLocationDistributionPercent1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strGlLocationDistributionLocation2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    dblGlLocationDistributionPercent2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strGlLocationDistributionLocation3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    dblGlLocationDistributionPercent3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    ysnStatutoryEmployee NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    ysnThirdPartySickPay NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    ysnRetirementPlan NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

)
CREATE TABLE tblApiSchemaEmployee(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
    intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    strEmployeeId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL,     --Required
    strName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL,           --Required
    strContactNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strSuffix NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strEMPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,              --The Eployee's Class Either "Vendor Base" or "Customer Base" only
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
    strDocumentDelivery1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  --Employee's Document Delivery "Direct Email","Email","Fax" and "Web Portal" only
    strDocumentDelivery2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  --Employee's Document Delivery "Direct Email","Email","Fax" and "Web Portal" only
    strDocumentDelivery3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  --Employee's Document Delivery "Direct Email","Email","Fax" and "Web Portal" only
    strExternalERPId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    dtmOriginationDate [datetime] NULL,
    strLineOfBusiness1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness4 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strLineOfBusiness5 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strFirstName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          
    strMiddleName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,         
	strLastName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,           
	strNameSuffix NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,	        
    strTitle NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,              
    strType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,               
    strPayPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          
    strRank NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,               
    dtmReviewDate [datetime] NULL,                                          
    dtmNextReview [datetime] NULL,                                          
    strTimeEntryPassword NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  
    strEmergencyContact NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,   
    strEmergencyRelation NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,  
    strEmergencyPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,     
    strEmergencyPhone2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,    
    dtmBirthDate [datetime] NULL,                                           
    ysnActive BIT  NULL,                 --Boolean with values "Y" and "N" only
    dtmOriginalDateHired [datetime] NULL,                          
    strGender NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,             
    dtmDateHired [datetime] NOT NULL,                                           --Required                                 
    strSpouse NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strMaritalStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          --Employee's Marital Status "Single","Married","Widowed","Divorced" and "Others" Only
    strWorkPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    intWorkersCompensationId INT NOT NULL,                                      --Required. Employye's Compensation Code Example is "8805", "0016" and "8006" depends on their compensation codes
    strEthnicity NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strEEOCCode NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strSocialSecurity NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL,     --Required
    dtmTerminated [datetime] NULL,
    strTerminatedReason NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    ysn1099Employee BIT  NULL,           --Boolean with values "Y" and "N" only
    strSupervisorId1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          --Employee ID of the Supervisor
    strSupervisorName1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,        --Employee Name of the Supervisor
    strSupervisoreTitle1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,      --Employee Title of the Supervisor
    strSupervisorId2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          --Employee ID of the Supervisor
    strSupervisorName2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,        --Employee Name of the Supervisor
    strSupervisoreTitle2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,      --Employee Title of the Supervisor
    strSupervisorId3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,          --Employee ID of the Supervisor
    strSupervisorName3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,        --Employee Name of the Supervisor
    strSupervisoreTitle3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,      --Employee Title of the Supervisor
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
    ysnStatutoryEmployee BIT  NULL,      --Boolean with values "Y" and "N" only
    ysnThirdPartySickPay BIT  NULL,      --Boolean with values "Y" and "N" only
    ysnRetirementPlan BIT  NULL          --Boolean with values "Y" and "N" only

)
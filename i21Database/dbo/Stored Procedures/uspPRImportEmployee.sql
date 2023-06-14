CREATE PROCEDURE dbo.uspPRImportEmployee(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN  
  
DECLARE @NewId as INT  
DECLARE @EntityId as INT  
DECLARE @EmployeeID as NVARCHAR(50)  
DECLARE @Department1 as NVARCHAR(50)  
DECLARE @DepartmentDesc1 as NVARCHAR(50)  
DECLARE @Department2 as NVARCHAR(50)  
DECLARE @DepartmentDesc2 as NVARCHAR(50)  
DECLARE @Department3 as NVARCHAR(50)  
DECLARE @DepartmentDesc3 as NVARCHAR(50)  
DECLARE @strClass as NVARCHAR(50)  
  
DECLARE @SupervisorId1 as NVARCHAR(50)  
DECLARE @SupervisorName1 as NVARCHAR(50)  
DECLARE @SupervisorTitle1 as NVARCHAR(50)  
DECLARE @SupervisorId2 as NVARCHAR(50)  
DECLARE @SupervisorName2 as NVARCHAR(50)  
DECLARE @SupervisorTitle2 as NVARCHAR(50)  
DECLARE @SupervisorId3 as NVARCHAR(50)  
DECLARE @SupervisorName3 as NVARCHAR(50)  
DECLARE @SupervisorTitle3 as NVARCHAR(50)  
  
DECLARE @LineOfBusiness1 as NVARCHAR(50)  
DECLARE @LineOfBusiness2 as NVARCHAR(50)  
DECLARE @LineOfBusiness3 as NVARCHAR(50)  
DECLARE @LineOfBusiness4 as NVARCHAR(50)  
DECLARE @LineOfBusiness5 as NVARCHAR(50)  
  
DECLARE @EmployeeGlLocation1 as NVARCHAR(50)  
DECLARE @EmployeeGlLocationPercentage1 as FLOAT (50)  
DECLARE @EmployeeGlLocation2 as NVARCHAR(50)  
DECLARE @EmployeeGlLocationPercentage2 as FLOAT (50)  
DECLARE @EmployeeGlLocation3 as NVARCHAR(50)  
DECLARE @EmployeeGlLocationPercentage3 as FLOAT (50)  
  
DECLARE @strName as NVARCHAR(50)  
DECLARE @strEmail as NVARCHAR(50)  
DECLARE @ysnPrint1099 as BIT  
DECLARE @strContactNumber as NVARCHAR(50)  
DECLARE @strTitle as NVARCHAR(50)  
DECLARE @strPhone as NVARCHAR(50)  
DECLARE @strEmail2 as NVARCHAR(50)  
DECLARE @strTimezone as NVARCHAR(50)  
DECLARE @intLanguageId as NVARCHAR(50)  
DECLARE @strEntityNo as NVARCHAR(50)  
DECLARE @ysnActive as BIT  
DECLARE @strDocumentDelivery  as NVARCHAR(50)  
DECLARE @strDocumentDelivery1  as NVARCHAR(50)  
DECLARE @strDocumentDelivery2  as NVARCHAR(50)  
DECLARE @strDocumentDelivery3 as NVARCHAR(50)  

--for logs
DECLARE @strDocumentDeliveryLog1  as NVARCHAR(50)  
DECLARE @strDocumentDeliveryLog2  as NVARCHAR(50)  
DECLARE @strDocumentDeliveryLog3 as NVARCHAR(50) 
DECLARE @strPayPeriodLog as NVARCHAR(50)
DECLARE @strMaritalStatusLog as NVARCHAR(50)
DECLARE @strEthnicityLog as NVARCHAR(50)
DECLARE @strEEOCCodeLog as NVARCHAR(50)
DECLARE @strGenderLog as NVARCHAR(50)
DECLARE @strTypeLog as NVARCHAR(50)
  
  
DECLARE @strExternalERPId as NVARCHAR(50)  
DECLARE @intEntityRank as NVARCHAR(50)  
DECLARE @strDepartment as NVARCHAR(50)  
DECLARE @strFirstName as NVARCHAR(50)  
DECLARE @strMiddleName as NVARCHAR(50)  
DECLARE @strLastName as NVARCHAR(50)  
DECLARE @strAddress as NVARCHAR(50)  
DECLARE @strCity as NVARCHAR(50)  
DECLARE @strState as NVARCHAR(50)  
DECLARE @strCountry as NVARCHAR(50)  
DECLARE @strZipCode as NVARCHAR(50)  
DECLARE @strEmPhone as NVARCHAR(50)  
DECLARE @strRank as NVARCHAR(50)  
  
DECLARE @strEmployeeId as NVARCHAR(50)  
DECLARE @strNameSuffix as NVARCHAR(50)  
DECLARE @strSuffix as NVARCHAR(50)  
DECLARE @strType as NVARCHAR(50)  
DECLARE @strPayPeriod as NVARCHAR(50)  
DECLARE @intRank as INT  
DECLARE @dtmReviewDate as NVARCHAR(50)  
DECLARE @dtmNextReview as NVARCHAR(50)  
DECLARE @strTimeEntryPassword as NVARCHAR(50)  
DECLARE @strEmergencyContact as NVARCHAR(50)  
DECLARE @strEmergencyRelation as NVARCHAR(50)  
DECLARE @strEmergencyPhone as NVARCHAR(50)  
DECLARE @strEmergencyPhone2 as NVARCHAR(50)  
DECLARE @dtmBirthDate as NVARCHAR(50)  
DECLARE @dtmOriginalDateHired as NVARCHAR(50)  
DECLARE @dtmOriginationDate as NVARCHAR(50)  
  
DECLARE @strGender as NVARCHAR(50)  
DECLARE @dtmDateHired as NVARCHAR(50)  
DECLARE @strSpouse as NVARCHAR(50)  
DECLARE @strMaritalStatus as NVARCHAR(50)  
DECLARE @strWorkPhone as NVARCHAR(50)  
DECLARE @intWorkersCompensationId as INT  
DECLARE @strEthnicity as NVARCHAR(50)  
DECLARE @strEEOCCode as NVARCHAR(50)  
DECLARE @strSocialSecurity as NVARCHAR(50)  
DECLARE @dtmTerminated as NVARCHAR(50)  
DECLARE @strTerminatedReason as NVARCHAR(50)  
DECLARE @ysn1099Employee as BIT  
DECLARE @ysnStatutoryEmployee as BIT  
DECLARE @ysnThirdPartySickPay as BIT  
DECLARE @ysnRetirementPlan as BIT  
  
--for checking  
DECLARE @LineOfBusiness1Count AS INT  
DECLARE @LineOfBusiness2Count AS INT  
DECLARE @LineOfBusiness3Count AS INT  
DECLARE @LineOfBusiness4Count AS INT  
DECLARE @LineOfBusiness5Count AS INT  
DECLARE @CountryCount AS INT  
DECLARE @RankCount AS INT  
DECLARE @EntityCount AS INT  
  
DECLARE @ysnImport as BIT  
  
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)  
SELECT  
 guiApiImportLogDetailId = NEWID()  
   ,guiApiImportLogId = @guiLogId  
   ,strField  = 'Employee ID'  
   ,strValue  = SE.strEmployeeId  
   ,strLogLevel  = 'Error'  
   ,strStatus  = 'Failed'  
   ,intRowNo  = SE.intRowNumber  
   ,strMessage  = 'Cannot find the Employee No: '+ CAST(ISNULL(SE.strEmployeeId, '') AS NVARCHAR(100)) + '.'  
   FROM tblApiSchemaEmployee SE  
   LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
   WHERE SE.guiApiUniqueId = @guiApiUniqueId  
   AND SE.strEmployeeId IS NULL  
  
  
SELECT * INTO #TempEmployeeDetails FROM tblApiSchemaEmployee where guiApiUniqueId = @guiApiUniqueId  
  
 WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDetails)  
 BEGIN  
  SET @strDocumentDelivery1 = NULL
  SET @strDocumentDelivery2 = NULL
  SET @strDocumentDelivery3 = NULL

  SET @Department1 = NULL
  SET @Department2 = NULL
  SET @Department3 = NULL

  SET @EmployeeGlLocation1 = NULL
  SET @EmployeeGlLocation2 = NULL
  SET @EmployeeGlLocation3 = NULL
  SELECT TOP 1   
    @EmployeeID = strEmployeeId   
   ,@LineOfBusiness1 = LTRIM(RTRIM(temp.strLineOfBusiness1))  
   ,@LineOfBusiness2 = LTRIM(RTRIM(temp.strLineOfBusiness2))   
   ,@LineOfBusiness3 = LTRIM(RTRIM(temp.strLineOfBusiness3))   
   ,@LineOfBusiness4 = LTRIM(RTRIM(temp.strLineOfBusiness4))   
   ,@LineOfBusiness5 = LTRIM(RTRIM(temp.strLineOfBusiness5))   
   ,@strCountry = LTRIM(RTRIM(temp.strCountry))  
   ,@strType = LTRIM(RTRIM(temp.strType))  
   ,@strPayPeriod = LTRIM(RTRIM(temp.strPayPeriod))  
   ,@strRank = LTRIM(RTRIM(temp.strRank))  
   ,@intWorkersCompensationId = temp.intWorkersCompensationId  
   ,@strEthnicity = LTRIM(RTRIM(temp.strEthnicity))  
   ,@strEEOCCode = LTRIM(RTRIM(temp.strEEOCCode))  
   ,@strGender = LTRIM(RTRIM(temp.strGender))  
   ,@strDocumentDelivery1 = LTRIM(RTRIM(temp.strDocumentDelivery1))  
   ,@strDocumentDelivery2 = LTRIM(RTRIM(temp.strDocumentDelivery2))  
   ,@strDocumentDelivery3 = LTRIM(RTRIM(temp.strDocumentDelivery3))  
   ,@strMaritalStatus = LTRIM(RTRIM(temp.strMaritalStatus))  
   ,@strEthnicity = LTRIM(RTRIM(temp.strEthnicity))  
   ,@strEEOCCode = LTRIM(RTRIM(temp.strEEOCCode))  
   ,@strGender = LTRIM(RTRIM(temp.strGender))  
  FROM #TempEmployeeDetails temp  

  SET @strDocumentDeliveryLog1 = @strDocumentDelivery1
  SET @strDocumentDeliveryLog2 = @strDocumentDelivery2
  SET @strDocumentDeliveryLog3 = @strDocumentDelivery3
  SET @strPayPeriodLog = @strPayPeriod
  SET @strMaritalStatusLog = @strMaritalStatus
  SET @strEthnicityLog = @strEthnicity
  SET @strEEOCCodeLog = @strEEOCCode
  SET @strGenderLog = @strGender
  SET @strTypeLog = @strType
  
  SELECT TOP 1 @EntityId = intEntityId FROM tblPREmployee WHERE strEmployeeId = @EmployeeID  
  
  --checking line of business  
  SELECT TOP 1 @LineOfBusiness1Count = COUNT(strLineOfBusiness) FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1  
  SELECT TOP 1 @LineOfBusiness2Count = COUNT(strLineOfBusiness) FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2  
  SELECT TOP 1 @LineOfBusiness3Count = COUNT(strLineOfBusiness) FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3  
  SELECT TOP 1 @LineOfBusiness4Count = COUNT(strLineOfBusiness) FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4  
  SELECT TOP 1 @LineOfBusiness5Count = COUNT(strLineOfBusiness) FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5  
  
  -- SET @LineOfBusiness1 = CASE WHEN @LineOfBusiness1Count = 0 THEN '' ELSE @LineOfBusiness1 END  
  -- SET @LineOfBusiness2 = CASE WHEN @LineOfBusiness2Count = 0 THEN '' ELSE @LineOfBusiness2 END  
  -- SET @LineOfBusiness3 = CASE WHEN @LineOfBusiness3Count = 0 THEN '' ELSE @LineOfBusiness3 END  
  -- SET @LineOfBusiness4 = CASE WHEN @LineOfBusiness4Count = 0 THEN '' ELSE @LineOfBusiness4 END  
  -- SET @LineOfBusiness5 = CASE WHEN @LineOfBusiness5Count = 0 THEN '' ELSE @LineOfBusiness5 END  
  
  --checking Country  
  SELECT TOP 1 @CountryCount = COUNT(strCountry) FROM tblSMCountry WHERE strCountry = @strCountry  
  
  SET @strDocumentDelivery1 = CASE WHEN @strDocumentDelivery1 <> '' AND @strDocumentDelivery1 IN('Direct Mail','Email','Fax','Web Portal') THEN @strDocumentDelivery1 WHEN @strDocumentDelivery1 IS NULL THEN 'NO VAL' ELSE 'NONE' END    
  SET @strDocumentDelivery2 = CASE WHEN @strDocumentDelivery2 <> '' AND @strDocumentDelivery2 IN('Direct Mail','Email','Fax','Web Portal') THEN @strDocumentDelivery2 WHEN @strDocumentDelivery2 IS NULL THEN 'NO VAL' ELSE 'NONE' END    
  SET @strDocumentDelivery3 = CASE WHEN @strDocumentDelivery3 <> '' AND @strDocumentDelivery3 IN('Direct Mail','Email','Fax','Web Portal') THEN @strDocumentDelivery3 WHEN @strDocumentDelivery3 IS NULL THEN 'NO VAL' ELSE 'NONE' END    
  
  SET @strType = CASE WHEN @strType <> '' AND @strType IN('Full-Time','Part-Time') THEN @strType ELSE '' END  
  SET @strPayPeriod = CASE WHEN @strPayPeriod <> '' AND @strPayPeriod   
   IN(  
     'Daily'  
    ,'Weekly'  
    ,'Bi-Weekly'  
    ,'Semi-Monthly'  
    ,'Monthly'  
    ,'Quarterly'  
    ,'Annual'  
  ) THEN @strPayPeriod ELSE '' END  
  
  SELECT TOP 1 @RankCount = COUNT(strDescription) FROM tblPREmployeeRank WHERE strDescription = @strRank  
  
  SET @strMaritalStatus = CASE WHEN @strMaritalStatus <> '' AND @strMaritalStatus   
   IN(  
     'Single'  
    ,'Married'  
    ,'Divorced'  
    ,'Widowed'  
    ,'Other'  
  ) THEN @strMaritalStatus ELSE '' END  
  
  --SELECT TOP 1 intWorkersCompensationId from tblPRWorkersCompensation where strWCCode = @intWorkersCompensationId  
  
  SET @strEthnicity = CASE WHEN @strEthnicity <> '' AND @strEthnicity   
   IN(  
     'Hispanic or Latino'  
    ,'White (not Hispanic or Latino)'  
    ,'Black or African American (not Hispanic or Latino)'  
    ,'Native Hawaiian or Other Pacific Islander (not Hispanic or Latino)'  
    ,'Asian (not Hispanic or Latino)'  
    ,'American Indian or Alaska Native (not Hispanic or Latino)'  
    ,'Two or More Races (not Hispanic or Latino)'  
  ) THEN @strEthnicity ELSE '' END  
  
  SET @strEEOCCode = CASE WHEN @strEEOCCode <> '' AND @strEEOCCode   
   IN(  
      '1.1 - Executive/Senior Level Officials and Managers'  
     ,'1.2 - First/Mid Level Officials & Managers'  
     ,'2 - Professionals'  
     ,'3 - Technicians'  
     ,'4 - Sales Workers'  
     ,'5 - Administrative Support Workers'  
     ,'6 - Craft Workers'  
     ,'7 - Operatives'  
     ,'8 - Laborers & Helpers'  
     ,'9 - Service Workers'  
  ) THEN @strEEOCCode ELSE '' END  
  
  SET @strGender = CASE WHEN @strGender <> '' AND @strGender IN('Male','Female') THEN @strGender ELSE '' END  
  
  --Setting back import value  
  SET @ysnImport = 0  
  
  --Combo validation  
  IF(@CountryCount IS NOT NULL AND @CountryCount != 0)  
   BEGIN  
    IF(@LineOfBusiness1Count != 0 OR @LineOfBusiness1 IS NULL)  
     BEGIN  
      IF(@LineOfBusiness2Count != 0 OR @LineOfBusiness2 IS NULL)  
       BEGIN  
        IF(@LineOfBusiness3Count != 0 OR @LineOfBusiness3 IS NULL)  
         BEGIN  
          IF(@LineOfBusiness4Count != 0 OR @LineOfBusiness4 IS NULL)  
           BEGIN  
            IF(@LineOfBusiness5Count != 0 OR @LineOfBusiness5 IS NULL)  
             BEGIN  
              IF((@strDocumentDelivery1 IS NOT NULL AND @strDocumentDelivery1 != 'NONE') OR @strDocumentDelivery1 = 'NO VAL')  
               BEGIN  
                IF((@strDocumentDelivery2 IS NOT NULL AND @strDocumentDelivery2 != 'NONE') OR @strDocumentDelivery2 = 'NO VAL')  
                 BEGIN  
                  IF((@strDocumentDelivery3 IS NOT NULL AND @strDocumentDelivery3 != 'NONE') OR @strDocumentDelivery3 = 'NO VAL')  
                  BEGIN  
                   IF(@strType IS NOT NULL AND @strType != '')  
                    BEGIN  
                     IF(@strPayPeriod IS NOT NULL AND @strPayPeriod != '')  
                      BEGIN  
                       IF(@RankCount IS NOT NULL AND @RankCount != 0)  
                        BEGIN  
                         IF(@strMaritalStatus IS NOT NULL AND @strMaritalStatus != '')  
                          BEGIN  
                           IF(@strEthnicity IS NOT NULL AND @strEthnicity != '')  
                            BEGIN  
                             IF(@strEEOCCode IS NOT NULL AND @strEEOCCode != '')  
                              BEGIN  
                               IF(@strGender IS NOT NULL AND @strGender != '')  
                                BEGIN  
                                  SET @ysnImport = 1 
                                END  
                               ELSE  
                                BEGIN  
                                 INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                                 SELECT TOP 1  
                                   NEWID()  
                                  , guiApiImportLogId = @guiLogId  
                                  , strField = 'Gender'  
                                  , strValue = @strGenderLog  
                                  , strLogLevel = 'Error'  
                                  , strStatus = 'Failed'  
                                  , intRowNo = SE.intRowNumber  
                                  , strMessage = 'Wrong input/format for Employee Gender. Please try again.'  
                                  FROM tblApiSchemaEmployee SE  
                                 LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                                 WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                                 AND SE.strEmployeeId = @EmployeeID  
  
                                 DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                                END  
                              END  
                             ELSE  
                              BEGIN  
                               INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                               SELECT TOP 1  
                                 NEWID()  
                                , guiApiImportLogId = @guiLogId  
                                , strField = 'EEOC Code'  
                                , strValue = @strEEOCCodeLog  
                                , strLogLevel = 'Error'  
                                , strStatus = 'Failed'  
                                , intRowNo = SE.intRowNumber  
                                , strMessage = 'Wrong input/format for Employee EEOC Code. Please try again.'  
                                FROM tblApiSchemaEmployee SE  
                               LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                               WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                               AND SE.strEmployeeId = @EmployeeID  
  
                               DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                              END  
                             
                            END  
                           ELSE  
                            BEGIN  
                             INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                             SELECT TOP 1  
                               NEWID()  
                              , guiApiImportLogId = @guiLogId  
                              , strField = 'Ethnicity'  
                              , strValue = @strEthnicityLog
                              , strLogLevel = 'Error'  
                              , strStatus = 'Failed'  
                              , intRowNo = SE.intRowNumber  
                              , strMessage = 'Wrong input/format for Employee Ethnicity. Please try again.'  
                              FROM tblApiSchemaEmployee SE  
                             LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                             WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                             AND SE.strEmployeeId = @EmployeeID  
  
                             DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                            END  
                          END  
                         ELSE  
                          BEGIN  
                           INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                           SELECT TOP 1  
                             NEWID()  
                            , guiApiImportLogId = @guiLogId  
                            , strField = 'Marital Status'  
                            , strValue = @strMaritalStatusLog  
                            , strLogLevel = 'Error'  
                            , strStatus = 'Failed'  
                            , intRowNo = SE.intRowNumber  
                            , strMessage = 'Wrong input/format for Employee Marital Status. Please try again.'  
                            FROM tblApiSchemaEmployee SE  
                           LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                           WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                           AND SE.strEmployeeId = @EmployeeID  
  
                           DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                          END  
                       
                        END  
                       ELSE  
                        BEGIN  
                         INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                         SELECT TOP 1  
                           NEWID()  
                          , guiApiImportLogId = @guiLogId  
                          , strField = 'Rank'  
                          , strValue = @strRank  
                          , strLogLevel = 'Error'  
                          , strStatus = 'Failed'  
                          , intRowNo = SE.intRowNumber  
                          , strMessage = 'Wrong input/format for Employee Rank. Please try again.'  
                          FROM tblApiSchemaEmployee SE  
                         LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                         WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                         AND SE.strEmployeeId = @EmployeeID  
  
                         DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                        END  
                       
                      END  
                     ELSE  
                      BEGIN  
                       INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                       SELECT TOP 1  
                         NEWID()  
                        , guiApiImportLogId = @guiLogId  
                        , strField = 'Pay Period'  
                        , strValue = @strPayPeriodLog  
                        , strLogLevel = 'Error'  
                        , strStatus = 'Failed'  
                        , intRowNo = SE.intRowNumber  
                        , strMessage = 'Wrong input/format for Employee Pay Period. Please try again.'  
                        FROM tblApiSchemaEmployee SE  
                       LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                       WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                       AND SE.strEmployeeId = @EmployeeID  
  
                       DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                      END  
                       
                    END  
                   ELSE  
                    BEGIN  
                     INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                     SELECT TOP 1  
                       NEWID()  
                      , guiApiImportLogId = @guiLogId  
                      , strField = 'Type'  
                      , strValue = @strTypeLog  
                      , strLogLevel = 'Error'  
                      , strStatus = 'Failed'  
                      , intRowNo = SE.intRowNumber  
                      , strMessage = 'Wrong input/format for Employee Type. Please try again.'  
                      FROM tblApiSchemaEmployee SE  
                     LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                     WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                     AND SE.strEmployeeId = @EmployeeID  
  
                     DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                    END  
                  END  
                  ELSE  
                   BEGIN  
                    INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                    SELECT TOP 1  
                       NEWID()  
                     , guiApiImportLogId = @guiLogId  
                     , strField = 'Document Delivery 3'  
                     , strValue = @strDocumentDeliveryLog3  
                     , strLogLevel = 'Error'  
                     , strStatus = 'Failed'  
                     , intRowNo = SE.intRowNumber  
                     , strMessage = 'Wrong input/format for Document Delivery 3. Please try again.'  
                       FROM tblApiSchemaEmployee SE  
                      LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                      WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                      AND SE.strEmployeeId = @EmployeeID  
  
                      DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                   END  
                 END  
                ELSE  
                 BEGIN  
                  INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                  SELECT TOP 1  
                     NEWID()  
                   , guiApiImportLogId = @guiLogId  
                   , strField = 'Document Delivery 2'  
                   , strValue = @strDocumentDeliveryLog2  
                   , strLogLevel = 'Error'  
                   , strStatus = 'Failed'  
                   , intRowNo = SE.intRowNumber  
                   , strMessage = 'Wrong input/format for Document Delivery 2. Please try again.'  
                     FROM tblApiSchemaEmployee SE  
                    LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                    WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                    AND SE.strEmployeeId = @EmployeeID  
  
                    DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
                 END  
               END  
              ELSE  
               BEGIN  
                INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
                SELECT TOP 1  
                   NEWID()  
                 , guiApiImportLogId = @guiLogId  
                 , strField = 'Document Delivery 1'  
                 , strValue = @strDocumentDeliveryLog1  
                 , strLogLevel = 'Error'  
                 , strStatus = 'Failed'  
                 , intRowNo = SE.intRowNumber  
                 , strMessage = 'Wrong input/format for Document Delivery 1. Please try again.'  
                   FROM tblApiSchemaEmployee SE  
                  LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                  WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                  AND SE.strEmployeeId = @EmployeeID  
  
                  DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
               END  
             END  
            ELSE  
             BEGIN  
              INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
              SELECT TOP 1  
                 NEWID()  
               , guiApiImportLogId = @guiLogId  
               , strField = 'Line of Business 5'  
               , strValue = @LineOfBusiness5  
               , strLogLevel = 'Error'  
               , strStatus = 'Failed'  
               , intRowNo = SE.intRowNumber  
               , strMessage = 'Wrong input/format for Line of Business 5. Please try again.'  
                 FROM tblApiSchemaEmployee SE  
                LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
                WHERE SE.guiApiUniqueId = @guiApiUniqueId  
                AND SE.strEmployeeId = @EmployeeID  
  
                DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
             END  
           END  
          ELSE  
           BEGIN  
            INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
            SELECT TOP 1  
               NEWID()  
             , guiApiImportLogId = @guiLogId  
             , strField = 'Line of Business 4'  
             , strValue = @LineOfBusiness4  
             , strLogLevel = 'Error'  
             , strStatus = 'Failed'  
             , intRowNo = SE.intRowNumber  
             , strMessage = 'Wrong input/format for Line of Business 4. Please try again.'  
               FROM tblApiSchemaEmployee SE  
              LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
              WHERE SE.guiApiUniqueId = @guiApiUniqueId  
              AND SE.strEmployeeId = @EmployeeID  
  
              DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
           END  
         END  
        ELSE  
         BEGIN  
          INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
          SELECT TOP 1  
             NEWID()  
           , guiApiImportLogId = @guiLogId  
           , strField = 'Line of Business 3'  
           , strValue = @LineOfBusiness3  
           , strLogLevel = 'Error'  
           , strStatus = 'Failed'  
           , intRowNo = SE.intRowNumber  
           , strMessage = 'Wrong input/format for Line of Business 3. Please try again.'  
             FROM tblApiSchemaEmployee SE  
            LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
            WHERE SE.guiApiUniqueId = @guiApiUniqueId  
            AND SE.strEmployeeId = @EmployeeID  
  
            DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
         END  
       END  
      ELSE  
       BEGIN  
        INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
        SELECT TOP 1  
           NEWID()  
         , guiApiImportLogId = @guiLogId  
         , strField = 'Line of Business 2'  
         , strValue = @LineOfBusiness2  
         , strLogLevel = 'Error'  
         , strStatus = 'Failed'  
         , intRowNo = SE.intRowNumber  
         , strMessage = 'Wrong input/format for Line of Business 2. Please try again.'  
           FROM tblApiSchemaEmployee SE  
          LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
          WHERE SE.guiApiUniqueId = @guiApiUniqueId  
          AND SE.strEmployeeId = @EmployeeID  
  
          DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
       END  
     END  
    ELSE  
     BEGIN  
      INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
      SELECT TOP 1  
         NEWID()  
       , guiApiImportLogId = @guiLogId  
       , strField = 'Line of Business 1'  
       , strValue = @LineOfBusiness1  
       , strLogLevel = 'Error'  
       , strStatus = 'Failed'  
       , intRowNo = SE.intRowNumber  
       , strMessage = 'Wrong input/format for Line of Business 1. Please try again.'  
         FROM tblApiSchemaEmployee SE  
        LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
        WHERE SE.guiApiUniqueId = @guiApiUniqueId  
        AND SE.strEmployeeId = @EmployeeID  
  
        DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
     END  
   END  
  ELSE  
   BEGIN  
    INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
    SELECT TOP 1  
       NEWID()  
     , guiApiImportLogId = @guiLogId  
     , strField = 'Country'  
     , strValue = @strCountry  
     , strLogLevel = 'Error'  
     , strStatus = 'Failed'  
     , intRowNo = SE.intRowNumber  
     , strMessage = 'Wrong input/format for Country. Please try again.'  
       FROM tblApiSchemaEmployee SE  
      LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
      WHERE SE.guiApiUniqueId = @guiApiUniqueId  
      AND SE.strEmployeeId = @EmployeeID  
  
      DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
   END  
  
  BEGIN TRY
	  IF (@ysnImport = 1)  
	BEGIN  
  
   IF @EntityId IS NULL  
    BEGIN  
    
    SELECT @EntityCount = COUNT(strEntityNo) FROM tblEMEntity WHERE strEntityNo = @EmployeeID

    IF(@EntityCount != 0 OR @EntityCount IS NOT NULL)
    BEGIN
      INSERT INTO tblEMEntity (  
      strName  
     ,ysnPrint1099  
     ,strContactNumber  
     ,strTitle  
     ,strPhone  
     ,strEmail2  
     ,intLanguageId  
     ,strEntityNo  
     ,ysnActive  
     ,strExternalERPId  
     ,intEntityRank  
     ,strDateFormat  
     ,strNumberFormat  
     ,strFieldDelimiter  
     ,strDepartment  
     ,strSuffix  
     ,dtmOriginationDate  
     ,strMobile  
     ) SELECT   
       strName  
      ,ysn1099Employee  
      ,''  
      ,strTitle  
      ,''  
      ,strEmail  
      ,1  
      ,strEmployeeId  
      ,ysnActive  
      ,strExternalERPId  
      ,strRank = (SELECT intRank FROM tblPREmployeeRank WHERE strDescription = EME.strRank)  
      ,'M/d/yyyy'  
      ,'1,234,567.89'  
      ,'Comma'  
      ,strDepartment1  
      ,strSuffix  
      ,dtmOriginationDate  
      ,''  
      FROM #TempEmployeeDetails EME  
      WHERE EME.strEmployeeId = @EmployeeID  
  
     SET @NewId = SCOPE_IDENTITY()  
  
     SET @strDocumentDelivery = ''  
  
     SELECT TOP 1   
     @strDocumentDelivery1 = DC.strDocumentDelivery1,  
     @strDocumentDelivery2 = DC.strDocumentDelivery2,  
     @strDocumentDelivery3 = DC.strDocumentDelivery3,  
     @strEmPhone = strEMPhone,  
     @strName = strName,  
     @strClass = strClass,  
     @strPhone = strPhone  
     FROM #TempEmployeeDetails DC WHERE DC.strEmployeeId = @EmployeeID  
  
     IF @strDocumentDelivery1 IS NOT NULL  
     BEGIN  
      SET @strDocumentDelivery = @strDocumentDelivery1  
  
     END  
  
     IF @strDocumentDelivery2 IS NOT NULL  
     BEGIN  
      IF @strDocumentDelivery IS NULL  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery2  
       END  
      ELSE  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery + ',' + @strDocumentDelivery2  
       END  
     END  
  
     IF @strDocumentDelivery3 IS NOT NULL  
     BEGIN  
      IF @strDocumentDelivery IS NULL  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery3  
       END  
      ELSE  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery + ',' + @strDocumentDelivery3  
       END  
     END  
      
     UPDATE tblEMEntity SET strDocumentDelivery = @strDocumentDelivery  WHERE intEntityId = @NewId  
  
  
  
     --INSERT TO CONTACT ENTITY  
     INSERT INTO tblEMEntity (  
       strName  
      ,strEmail  
      ,ysnPrint1099  
      ,strContactNumber  
      ,strMobile  
      ,strPhone  
      ,strTimezone  
      ,intLanguageId  
      ,ysnActive  
      ,strSuffix  
      ,intEntityRank  
      ,intConcurrencyId  
      ,strEntityNo  
     )  
     SELECT   
       EME.strName  
      ,EME.strEmail  
      ,EME.ysn1099Employee  
      ,EME.strContactNumber  
      ,EME.strPhone  
      ,EME.strEMPhone  
      ,EME.strTimezone  
      ,1  
      ,EME.ysnActive  
      ,EME.strSuffix  
      ,(SELECT intRank FROM tblPREmployeeRank WHERE strDescription = EME.strRank)  
      ,1  
      ,''  
      FROM #TempEmployeeDetails EME  
      WHERE EME.strEmployeeId = @EmployeeID  
  
     DECLARE @ContactId AS INT  
     SET @ContactId = SCOPE_IDENTITY()  
  
     DECLARE @ysnDefault BIT  
     SET @ysnDefault = 1  
  
     --INSERT [dbo].[tblEMEntity] ([strName], strNickName, strTitle, strContactNumber,strMobile)  
     --SELECT strName,strName,strTitle,strContactNumber,strEMPhone FROM #TempEmployeeDetails CT WHERE CT.strEmployeeId = @EmployeeID  
  
     DECLARE @EntityPhoneID AS NVARCHAR(50)  
     SET @EntityPhoneID = SCOPE_IDENTITY()  
  
     INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)  
     select top 1 @ContactId, strEMPhone, (SELECT intDefaultCountryId FROM tblSMCompanyPreference) FROM #TempEmployeeDetails  
  
     INSERT INTO tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)  
     select top 1 @ContactId, strPhone, (SELECT intDefaultCountryId FROM tblSMCompanyPreference) FROM #TempEmployeeDetails  
  
     INSERT [dbo].[tblEMEntityLocation] ([intEntityId], [strLocationName], [strAddress], [strCity], [strState], [strCountry], [strZipCode],[strTimezone], [ysnDefaultLocation],[strCheckPayeeName],[strPhone])  
     SELECT @NewId, strName, strAdress,strCity,strState, strCountry,strZipCode,strTimezone,@ysnDefault, strName, strEMPhone  
     FROM #TempEmployeeDetails LC WHERE LC.strEmployeeId = @EmployeeID  
  
     DECLARE @EntityLocationId INT  
     SET @EntityLocationId = SCOPE_IDENTITY()  
  
     DECLARE @EntityContactId INT  
     SET @EntityContactId = SCOPE_IDENTITY()  
  
     INSERT [dbo].[tblEMEntityToContact] ([intEntityId], [intEntityContactId], [intEntityLocationId],[ysnPortalAccess], ysnDefaultContact,intConcurrencyId)  
     VALUES         (@NewId, @ContactId, (SELECT TOP 1 intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @NewId), 0,@ysnDefault,1)  
  
  
     if not exists(select top 1 1 from tblEMEntityType where intEntityId = @NewId)  
     begin  
      --insert into tblEMEntityType  
      INSERT INTO tblEMEntityType ( intEntityId, strType, intConcurrencyId)  
      VALUES (@NewId, 'Employee', 0)  
     end  
  
  
     INSERT INTO tblEMEntityNote(dtmDate,dtmTime,intDuration,strUser,strSubject,strNotes,intEntityId)  
     SELECT   
      GETDATE(),  
      '00:00:01',  
      1,  
      'CSV',  
      'CSV CONV',  
       c.strNotes,  
       c.intEntityId  
       FROM tblEMEntity c WHERE c.intEntityId = @NewId  
    END
    ELSE
    BEGIN
      SELECT @NewId = intEntityId FROM tblEMEntity WHERE strEntityNo = @EmployeeID
    END

     
  
     INSERT INTO tblPREmployee  
     (  
      intEntityId,  
      strEmployeeId,  
      strFirstName,  
      strMiddleName,  
      strLastName,  
      strNameSuffix,  
      strType,  
      strPayPeriod,  
      intRank,  
      dtmReviewDate,  
      dtmNextReview,  
      strTimeEntryPassword,  
      strEmergencyContact,  
      strEmergencyRelation,  
      strEmergencyPhone,  
      strEmergencyPhone2,  
      dtmBirthDate,  
      ysnActive,  
      dtmOriginalDateHired,  
      strGender,  
      dtmDateHired,  
      strSpouse,  
      strMaritalStatus,  
      strWorkPhone,  
      intWorkersCompensationId,  
      strEthnicity,  
      strEEOCCode,  
      strSocialSecurity,  
      dtmTerminated,  
      strTerminatedReason,  
      ysn1099Employee,  
      ysnStatutoryEmployee,  
      ysnThirdPartySickPay,  
      ysnRetirementPlan,  
      guiApiUniqueId  
     )  
     SELECT   
      @NewId,  
      strEmployeeId,  
      strFirstName,  
      strMiddleName,  
      strLastName,  
      strNameSuffix,  
      strType,  
      strPayPeriod,  
      intRank         = (SELECT intRank FROM tblPREmployeeRank WHERE strDescription = PRST.strRank),  
      dtmReviewDate,  
      dtmNextReview,  
      strTimeEntryPassword,  
      strEmergencyContact,  
      strEmergencyRelation,  
      strEmergencyPhone,  
      strEmergencyPhone2,  
      dtmBirthDate,  
      ysnActive,  
      dtmOriginalDateHired,  
      strGender,  
      dtmDateHired,  
      strSpouse,  
      strMaritalStatus,  
      strWorkPhone,  
      intWorkersCompensationId    = (SELECT TOP 1 intWorkersCompensationId from tblPRWorkersCompensation where strWCCode = intWorkersCompensationId),  
      strEthnicity,  
      strEEOCCode,  
      strSocialSecurity,  
      dtmTerminated,  
      strTerminatedReason,  
      ysn1099Employee,  
      ysnStatutoryEmployee,  
      ysnThirdPartySickPay,  
      ysnRetirementPlan,  
      @guiApiUniqueId  
      FROM #TempEmployeeDetails PRST  
      WHERE PRST.strEmployeeId = @EmployeeID  
  
     UPDATE tblPREmployee SET   
      intWorkersCompensationId  
      = (SELECT TOP 1 intWorkersCompensationId from tblPRWorkersCompensation where strWCCode =   
       (SELECT TOP 1 intWorkersCompensationId FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID))  
      WHERE intEntityId = @NewId  
      
     SELECT TOP 1 @Department1 = strDepartment1, @DepartmentDesc1 = strDepartmentDesc1,  
         @Department2 = strDepartment2, @DepartmentDesc2 = strDepartmentDesc2,  
         @Department3 = strDepartment3, @DepartmentDesc3 = strDepartmentDesc3,  
  
         @LineOfBusiness1 = strLineOfBusiness1,  
         @LineOfBusiness2 = strLineOfBusiness2,  
         @LineOfBusiness3 = strLineOfBusiness3,  
         @LineOfBusiness4 = strLineOfBusiness4,  
         @LineOfBusiness5 = strLineOfBusiness5,   
          
         @SupervisorId1 = strSupervisorId1, @SupervisorName1 = strSupervisorName1, @SupervisorTitle1 = strSupervisoreTitle1,  
         @SupervisorId2 = strSupervisorId2, @SupervisorName2 = strSupervisorName2, @SupervisorTitle2 = strSupervisoreTitle2,  
         @SupervisorId3 = strSupervisorId3, @SupervisorName3 = strSupervisorName3, @SupervisorTitle3 = strSupervisoreTitle3,  
         @EmployeeGlLocation1 =  strGlLocationDistributionLocation1,@EmployeeGlLocationPercentage1 = dblGlLocationDistributionPercent1,  
         @EmployeeGlLocation2 =  strGlLocationDistributionLocation2,@EmployeeGlLocationPercentage2 = dblGlLocationDistributionPercent2,  
         @EmployeeGlLocation3 =  strGlLocationDistributionLocation3,@EmployeeGlLocationPercentage3 = strGlLocationDistributionLocation3  
       FROM #TempEmployeeDetails A  
      WHERE strEmployeeId = @EmployeeID  
        
       --SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1  
       --SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2  
       --SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3  
  
       --RETURN  
  
     IF @Department1 IS NOT NULL AND @Department1 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department1)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @NewId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))  
       BEGIN  
        INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId,intConcurrencyId)VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1),1)  
       END  
      END  
       
     END  
  
     IF @Department2 IS NOT NULL AND @Department2 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department2)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @NewId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))  
       BEGIN  
        INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId,intConcurrencyId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2),1)   
       END  
      END  
       
     END  
  
     IF @Department3 IS NOT NULL  AND @Department3 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department3)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @NewId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3))  
       BEGIN  
        INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId,intConcurrencyId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3),1)  
       END  
      END  
     END  
  
  
     --SET IDENTITY_INSERT tblEMEntityLineOfBusiness ON  
  
     IF @LineOfBusiness1 IS NOT NULL AND @LineOfBusiness1 != ''  
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))  
       BEGIN  
        INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1),1)  
       END  
      END  
     END  
  
     IF @LineOfBusiness2 IS NOT NULL AND @LineOfBusiness2 != ''  
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))  
       BEGIN  
        INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2),1)  
       END  
      END  
     END  
  
     IF @LineOfBusiness3 IS NOT NULL AND @LineOfBusiness3 != ''  
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))  
       BEGIN  
        INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3),1)  
       END  
      END  
     END  
  
     IF @LineOfBusiness4 IS NOT NULL AND @LineOfBusiness4 != ''  
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))  
       BEGIN  
        INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4),1)  
       END  
      END  
     END  
  
     IF @LineOfBusiness5 IS NOT NULL AND @LineOfBusiness5 != ''  
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5))  
       BEGIN  
        INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5),1)  
       END  
      END  
     END  
  
     --SET IDENTITY_INSERT tblEMEntityLineOfBusiness OFF  
      
  
     IF @SupervisorId1 IS NOT NULL AND @SupervisorId1 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @NewId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1))  
       BEGIN  
        INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId,intConcurrencyId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1),1)  
       END  
      END  
     END  
  
     IF @SupervisorId2 IS NOT NULL  AND @SupervisorId2 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @NewId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))  
       BEGIN  
        INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId,intConcurrencyId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2),1)  
       END  
      END  
     END  
  
     IF @SupervisorId3 IS NOT NULL  AND @SupervisorId3 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @NewId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3))  
       BEGIN  
        INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId,intConcurrencyId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3),1)  
       END  
      END  
     END  
  
      
     IF @EmployeeGlLocation1 IS NOT NULL  AND @EmployeeGlLocation1 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @NewId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1))  
       BEGIN  
        INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId) VALUES (@NewId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1),@EmployeeGlLocationPercentage1,1)  
       END  
      END  
     END  
  
      
     IF @EmployeeGlLocation2 IS NOT NULL   AND @EmployeeGlLocation2 != ''
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @NewId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2))  
       BEGIN  
        INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId) VALUES (@NewId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2),@EmployeeGlLocationPercentage2,1)  
       END  
      END  
     END  
  
      
     IF @EmployeeGlLocation3 IS NOT NULL  AND @EmployeeGlLocation3 != '' 
     BEGIN  
      IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation3)  
      BEGIN  
       IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @NewId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation3))  
       BEGIN  
        INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId) VALUES (@NewId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation3),@EmployeeGlLocationPercentage3,1)  
       END  
      END  
     END  
  
     DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
    END  
  
   --UPDATE   
   ELSE  
    BEGIN  
     --SELECT ALL RECORDS FROM TEMP TABLE  
     SELECT TOP 1 @Department1 = strDepartment1, @DepartmentDesc1 = strDepartmentDesc1,  
         @Department2 = strDepartment2, @DepartmentDesc2 = strDepartmentDesc2,  
         @Department3 = strDepartment3, @DepartmentDesc3 = strDepartmentDesc3,  
  
         @LineOfBusiness1 = strLineOfBusiness1, @LineOfBusiness2 = strLineOfBusiness2,  
         @LineOfBusiness3 = strLineOfBusiness3, @LineOfBusiness4 = strLineOfBusiness4,  
         @LineOfBusiness5 = strLineOfBusiness5,   
          
         @SupervisorId1 = strSupervisorId1, @SupervisorName1 = strSupervisorName1, @SupervisorTitle1 = strSupervisoreTitle1,  
         @SupervisorId2 = strSupervisorId2, @SupervisorName2 = strSupervisorName2, @SupervisorTitle2 = strSupervisoreTitle2,  
         @SupervisorId3 = strSupervisorId3, @SupervisorName3 = strSupervisorName3, @SupervisorTitle3 = strSupervisoreTitle3  
       ,@strName = strName  
       ,@strEmail = strEmail  
       ,@ysnPrint1099 = ysn1099Employee  
       ,@strContactNumber = strContactNumber  
       ,@strTitle = A.strTitle  
       ,@strPhone = strPhone  
       ,@strEmail2 = strEmail  
       ,@strTimezone = strTimezone  
       ,@strEntityNo = strEmployeeId  
       ,@ysnActive = ysnActive  
       ,@strEmPhone = strEMPhone  
       --,@strDocumentDelivery = strDocumentDelivery1 + ',' + strDocumentDelivery2 + ',' + strDocumentDelivery3  
       ,@strDocumentDelivery1 = strDocumentDelivery1  
       ,@strDocumentDelivery2 = strDocumentDelivery2  
       ,@strDocumentDelivery3 = strDocumentDelivery3  
       ,@strExternalERPId = strExternalERPId  
       ,@intEntityRank = (SELECT intRank FROM tblPREmployeeRank WHERE strDescription = A.strRank)  
       ,@strDepartment = strDepartment1  
       ,@strFirstName = strFirstName  
       ,@strMiddleName = strMiddleName  
       ,@strLastName = strLastName  
       ,@strCity = strCity  
       ,@strState = strState  
       ,@strCountry = strCountry  
       ,@strZipCode =strZipCode  
       ,@dtmOriginationDate = dtmOriginationDate  
       ,@strAddress = strAdress  
  
       ,@strNameSuffix = strNameSuffix  
       ,@strSuffix = strSuffix  
       ,@strType = strType  
       ,@strPayPeriod = strPayPeriod  
       ,@intRank = (SELECT TOP 1 intRank FROM tblPREmployeeRank where strDescription = A.strRank)  
       ,@dtmReviewDate = dtmReviewDate  
       ,@dtmNextReview = dtmNextReview  
       ,@strTimeEntryPassword = strTimeEntryPassword  
       ,@strEmergencyContact = strEmergencyContact  
       ,@strEmergencyRelation = strEmergencyRelation  
       ,@strEmergencyPhone = strEmergencyPhone  
       ,@strEmergencyPhone2 = strEmergencyPhone2  
       ,@dtmBirthDate = dtmBirthDate  
       ,@dtmOriginalDateHired = dtmOriginalDateHired  
       ,@strGender = strGender  
       ,@dtmDateHired = dtmDateHired  
       ,@strSpouse = strSpouse  
       ,@strMaritalStatus = strMaritalStatus  
       ,@strWorkPhone = strWorkPhone  
       ,@intWorkersCompensationId = intWorkersCompensationId  
       ,@strEthnicity = strEthnicity  
       ,@strEEOCCode = strEEOCCode  
       ,@strSocialSecurity = strSocialSecurity  
       ,@dtmTerminated = dtmTerminated  
       ,@strTerminatedReason = strTerminatedReason  
       ,@ysn1099Employee = ysn1099Employee  
       ,@ysnStatutoryEmployee = ysnStatutoryEmployee  
       ,@ysnThirdPartySickPay = ysnThirdPartySickPay  
       ,@ysnRetirementPlan = ysnRetirementPlan  
       ,@EmployeeGlLocation1 = strGlLocationDistributionLocation1  
       ,@EmployeeGlLocationPercentage1 = dblGlLocationDistributionPercent1  
       ,@EmployeeGlLocation2 = strGlLocationDistributionLocation2  
       ,@EmployeeGlLocationPercentage2 = dblGlLocationDistributionPercent2  
       ,@EmployeeGlLocation3 = strGlLocationDistributionLocation3  
       ,@EmployeeGlLocationPercentage3 = dblGlLocationDistributionPercent3  
       FROM #TempEmployeeDetails A  
     WHERE strEmployeeId = @EmployeeID  
  
      
     --UPDATE ENTITY  
     UPDATE tblEMEntity SET  
      strName = @strName  
     ,strSuffix = @strNameSuffix  
     ,strEmail = @strEmail  
     ,ysnPrint1099 = @ysnPrint1099  
     ,strContactNumber = @strContactNumber  
     ,strTitle = @strTitle  
     ,strPhone = @strEmPhone  
     ,strEmail2 = @strEmail  
     ,strTimezone = @strTimezone  
     ,strEntityNo = @strEntityNo  
     ,ysnActive = @ysnActive  
     ,strExternalERPId = @strExternalERPId  
     ,intEntityRank = @intEntityRank  
     ,strDepartment = @strDepartment  
     ,dtmOriginationDate = @dtmOriginationDate  
     ,strMobile = @strPhone  
     WHERE intEntityId = @EntityId  
  
     UPDATE tblEMEntity SET  
       strName = @strName  
      ,strEmail = @strEmail  
      ,ysnPrint1099 = @ysn1099Employee  
      ,strContactNumber = @strContactNumber  
      ,strMobile =  @strPhone  
      ,strPhone = @strEmPhone  
      ,strTimezone = @strTimezone  
      ,intLanguageId = 1  
      ,ysnActive = @ysnActive  
      ,strSuffix = @strSuffix  
      ,intEntityRank = @intRank  
      ,strEntityNo = ''  
     WHERE intEntityId = (@EntityId + 1)  
  
  
     IF @strDocumentDelivery1 IS NOT NULL  
     BEGIN  
      SET @strDocumentDelivery = @strDocumentDelivery1  
  
     END  
  
     IF @strDocumentDelivery2 IS NOT NULL  
     BEGIN  
      IF @strDocumentDelivery IS NULL  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery2  
       END  
      ELSE  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery + ',' + @strDocumentDelivery2  
       END  
     END  
  
     IF @strDocumentDelivery3 IS NOT NULL  
     BEGIN  
      IF @strDocumentDelivery IS NULL  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery3  
       END  
      ELSE  
       BEGIN  
        SET @strDocumentDelivery = @strDocumentDelivery + ',' + @strDocumentDelivery3  
       END  
     END  
  
     UPDATE tblEMEntity SET strDocumentDelivery = @strDocumentDelivery WHERE intEntityId = @EntityId  
  
     DECLARE @UContactId AS INT  
  
     SELECT TOP 1 @UContactId = intEntityId FROM tblEMEntity where strName = @strName and strContactNumber = @strContactNumber and strMobile != '' and strPhone != ''  
      
     IF EXISTS (SELECT TOP 1 * FROM tblEMEntityPhoneNumber WHERE intEntityId = @UContactId)  
      BEGIN  
       UPDATE tblEMEntityPhoneNumber SET strPhone = @strEmPhone WHERE intEntityId = @UContactId  
      END  
      
     IF EXISTS (SELECT TOP 1 * FROM tblEMEntityMobileNumber WHERE intEntityId = @UContactId)  
      BEGIN  
       UPDATE tblEMEntityMobileNumber SET strPhone = @strPhone WHERE intEntityId = @UContactId  
      END  
  
     UPDATE tblEMEntityLocation SET   
     [strLocationName] = @strName  
     ,[strAddress] = @strAddress  
     ,[strCity] = @strCity  
     ,[strState] = @strState  
     ,[strCountry] = @strCountry  
     ,[strZipCode] = @strZipCode  
     ,[strTimezone] = @strTimezone  
     ,[strCheckPayeeName] = @strName  
     ,[strPhone] = @strEmPhone  
     WHERE intEntityLocationId = (SELECT TOP 1 intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId)  
  
     --UPDATE tblEMEntityToContact SET [intEntityContactId] = @EntityId  
     --WHERE intEntityToContactId = (SELECT TOP 1 intEntityToContactId FROM tblEMEntityToContact WHERE intEntityId = @EntityId)  
  
  
     UPDATE tblPREmployee SET  
     strFirstName = @strFirstName  
     ,strMiddleName = @strMiddleName  
     ,strLastName = @strLastName  
     ,strNameSuffix = @strNameSuffix  
     ,strType = @strType  
     ,strPayPeriod = @strPayPeriod  
     ,intRank = @intRank  
     ,dtmReviewDate = @dtmReviewDate  
     ,dtmNextReview = @dtmNextReview  
     ,strTimeEntryPassword = @strTimeEntryPassword  
     ,strEmergencyContact = @strEmergencyContact  
     ,strEmergencyRelation = @strEmergencyRelation  
     ,strEmergencyPhone = @strEmergencyPhone  
     ,strEmergencyPhone2 = @strEmergencyPhone2  
     ,dtmBirthDate = @dtmBirthDate  
     ,dtmOriginalDateHired = @dtmOriginalDateHired  
     ,strGender = @strGender  
     ,dtmDateHired = @dtmDateHired  
     ,strSpouse = @strSpouse  
     ,strMaritalStatus = @strMaritalStatus  
     ,strWorkPhone = @strWorkPhone  
     ,intWorkersCompensationId = (SELECT TOP 1 intWorkersCompensationId from tblPRWorkersCompensation where strWCCode = @intWorkersCompensationId)  
     ,strEthnicity = @strEthnicity  
     ,strEEOCCode = @strEEOCCode  
     ,strSocialSecurity = @strSocialSecurity  
     ,dtmTerminated = @dtmTerminated  
     ,strTerminatedReason = @strTerminatedReason  
     ,ysn1099Employee = @ysn1099Employee  
     ,ysnStatutoryEmployee = @ysnStatutoryEmployee  
     ,ysnThirdPartySickPay = @ysnThirdPartySickPay  
     ,ysnRetirementPlan = @ysnRetirementPlan  
     WHERE intEntityId = @EntityId  
  
  
  
     --SELECT VALIDATION DEPARTMENT PER COLUMN  
     SELECT @Department1 = strDepartment1, @DepartmentDesc1 = strDepartmentDesc1       
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblPRDepartment PRD ON A.strDepartment1 = PRD.strDepartment  
     INNER JOIN tblPREmployeeDepartment C ON B.intEntityId = C.intEntityEmployeeId AND PRD.intDepartmentId = C.intDepartmentId  
      where strDepartment1 = @Department1  
      AND strDepartmentDesc1 = @DepartmentDesc1  
  
     SELECT @Department2 = strDepartment2, @DepartmentDesc2 = strDepartmentDesc2       
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblPRDepartment PRD ON A.strDepartment1 = PRD.strDepartment  
     INNER JOIN tblPREmployeeDepartment C ON B.intEntityId = C.intEntityEmployeeId AND PRD.intDepartmentId = C.intDepartmentId  
      where strDepartment2 = @Department2  
      AND strDepartmentDesc2 = @DepartmentDesc2  
  
     SELECT @Department3 = strDepartment3, @DepartmentDesc3 = strDepartmentDesc3       
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblPRDepartment PRD ON A.strDepartment1 = PRD.strDepartment  
     INNER JOIN tblPREmployeeDepartment C ON B.intEntityId = C.intEntityEmployeeId AND PRD.intDepartmentId = C.intDepartmentId  
      where strDepartment3 = @Department3  
      AND strDepartmentDesc3 = @DepartmentDesc3  
  
     --DELETE EXISTING RECORD  
     DELETE FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @EntityId  
  
     IF @Department1 IS NOT NULL  AND @Department1 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department1)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @EntityId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))  
        BEGIN  
         INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))  
        END  
       END  
      END  
  
     IF @Department2 IS NOT NULL  AND @Department2 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department2)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @EntityId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))  
        BEGIN  
         INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))  
        END       
       END  
      END  
      
     IF @Department3 IS NOT NULL  AND @Department3 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department3)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @EntityId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3))  
        BEGIN  
         INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3))  
        END       
       END  
      END  
  
     -- SELECT VALIDATION FOR LINE OF BUSINESS  
     SELECT @LineOfBusiness1 = strLineOfBusiness1    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblSMLineOfBusiness PRL ON A.strLineOfBusiness1 = PRL.strLineOfBusiness  
     INNER JOIN tblEMEntityLineOfBusiness C ON B.intEntityId = C.intEntityId AND C.intLineOfBusinessId = PRL.intLineOfBusinessId  
      WHERE strLineOfBusiness1 = @LineOfBusiness1  
  
     SELECT @LineOfBusiness2 = strLineOfBusiness2    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblSMLineOfBusiness PRL ON A.strLineOfBusiness2 = PRL.strLineOfBusiness  
     INNER JOIN tblEMEntityLineOfBusiness C ON B.intEntityId = C.intEntityId AND C.intLineOfBusinessId = PRL.intLineOfBusinessId  
      WHERE strLineOfBusiness2 = @LineOfBusiness2  
  
     SELECT @LineOfBusiness3 = strLineOfBusiness3    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblSMLineOfBusiness PRL ON A.strLineOfBusiness3 = PRL.strLineOfBusiness  
     INNER JOIN tblEMEntityLineOfBusiness C ON B.intEntityId = C.intEntityId AND C.intLineOfBusinessId = PRL.intLineOfBusinessId  
      WHERE strLineOfBusiness3 = @LineOfBusiness3  
       
     SELECT @LineOfBusiness4 = strLineOfBusiness4    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblSMLineOfBusiness PRL ON A.strLineOfBusiness4 = PRL.strLineOfBusiness  
     INNER JOIN tblEMEntityLineOfBusiness C ON B.intEntityId = C.intEntityId AND C.intLineOfBusinessId = PRL.intLineOfBusinessId  
      WHERE strLineOfBusiness4 = @LineOfBusiness4  
  
     SELECT @LineOfBusiness5 = strLineOfBusiness5    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblSMLineOfBusiness PRL ON A.strLineOfBusiness5 = PRL.strLineOfBusiness  
     INNER JOIN tblEMEntityLineOfBusiness C ON B.intEntityId = C.intEntityId AND C.intLineOfBusinessId = PRL.intLineOfBusinessId  
      WHERE strLineOfBusiness5 = @LineOfBusiness5  
  
     --DELETE EXISTING RECORD BEFORE RE-INSERT  
     DELETE FROM tblEMEntityLineOfBusiness WHERE intEntityId = @EntityId  
  
     --UPDATE LINE OF BUSINESS  
     IF @LineOfBusiness1 IS NOT NULL  AND @LineOfBusiness1 != ''  
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @EntityId AND intLineOfBusinessId = (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))  
        BEGIN  
         INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId)   
         VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))  
        END  
       END  
      END  
  
     IF @LineOfBusiness2 IS NOT NULL  AND @LineOfBusiness2 != ''  
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @EntityId AND intLineOfBusinessId = (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))  
        BEGIN  
         INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId)   
         VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))  
        END  
       END  
      END  
  
     IF @LineOfBusiness3 IS NOT NULL  AND @LineOfBusiness3 != ''  
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @EntityId AND intLineOfBusinessId = (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))  
        BEGIN  
         INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId)   
         VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))  
        END  
       END  
      END  
  
     IF @LineOfBusiness4 IS NOT NULL  AND @LineOfBusiness4 != ''  
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @EntityId AND intLineOfBusinessId = (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))  
        BEGIN  
         INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId)   
         VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))  
        END  
       END  
      END  
  
     IF @LineOfBusiness5 IS NOT NULL  AND @LineOfBusiness5 != ''  
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @EntityId AND intLineOfBusinessId = (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5))  
        BEGIN  
         INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId)   
         VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5))  
        END  
       END  
      END  
  
  
  
     -- SELECT VALIDATION FOR LINE OF BUSINESS  
     SELECT @SupervisorId1 = strSupervisorId1,@SupervisorName1 = strSupervisorName1, @SupervisorTitle1 = strSupervisoreTitle1    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblPREmployeeSupervisor PRS ON B.intEntityId = PRS.intEntityEmployeeId  
      WHERE strSupervisorId1 = @SupervisorId1  
      AND strSupervisorName1 = @SupervisorName1  
      AND strSupervisoreTitle1 = @SupervisorTitle1  
  
     SELECT @SupervisorId2 = strSupervisorId2,@SupervisorName2 = strSupervisorName2, @SupervisorTitle2 = strSupervisoreTitle2    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblPREmployeeSupervisor PRS ON B.intEntityId = PRS.intEntityEmployeeId  
      WHERE strSupervisorId2 = @SupervisorId2  
      AND strSupervisorName2 = @SupervisorName2  
      AND strSupervisoreTitle2 = @SupervisorTitle2  
  
     SELECT @SupervisorId3 = strSupervisorId3,@SupervisorName3 = strSupervisorName3, @SupervisorTitle3 = strSupervisoreTitle3    
     FROM #TempEmployeeDetails A  
     INNER JOIN tblPREmployee B ON A.strEmployeeId = B.strEmployeeId  
     INNER JOIN tblPREmployeeSupervisor PRS ON B.intEntityId = PRS.intEntityEmployeeId  
      WHERE strSupervisorId3 = @SupervisorId3  
      AND strSupervisorName3 = @SupervisorName3  
      AND strSupervisoreTitle3 = @SupervisorTitle3  
  
     --DELETE EXISTING RECORD BEFORE RE-INSERT  
     DELETE FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @EntityId  
  
     --UPDATE SUPERVISOR DATA  
     IF @SupervisorId1 IS NOT NULL AND @SupervisorId1 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @EntityId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1))  
        BEGIN  
         INSERT tblPREmployeeSupervisor(intEntityEmployeeId,intSupervisorId)   
         VALUES (@EntityId,(SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1))  
        END  
       END  
        
      END  
     IF @SupervisorId2 IS NOT NULL   AND @SupervisorId2 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @EntityId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))  
        BEGIN  
         INSERT tblPREmployeeSupervisor(intEntityEmployeeId,intSupervisorId)   
         VALUES (@EntityId,(SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))  
        END  
       END  
      END  
     IF @SupervisorId3 IS NOT NULL   AND @SupervisorId3 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @EntityId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3))  
        BEGIN  
         INSERT tblPREmployeeSupervisor(intEntityEmployeeId,intSupervisorId)   
         VALUES (@EntityId,(SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3))  
        END  
       END  
      END  
  
     --DELETE EXISTING RECORD BEFORE RE-INSERT  
     DELETE FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @EntityId  
  
     IF @EmployeeGlLocation1 IS NOT NULL  AND @EmployeeGlLocation1 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @EntityId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1) AND dblPercentage = @EmployeeGlLocationPercentage1)  
        BEGIN  
         INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId)   
         VALUES (@EntityId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1),@EmployeeGlLocationPercentage1,1)  
        END  
       END  
      END  
     IF @EmployeeGlLocation2 IS NOT NULL  AND @EmployeeGlLocation2 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @EntityId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2) AND dblPercentage = @EmployeeGlLocationPercentage2)  
        BEGIN  
         INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId)   
         VALUES (@EntityId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2),@EmployeeGlLocationPercentage2,1)  
        END  
       END  
      END  
     IF @EmployeeGlLocation3 IS NOT NULL  AND @EmployeeGlLocation3 != ''
      BEGIN  
       IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation3)  
       BEGIN  
        IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @EntityId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation3) AND dblPercentage = @EmployeeGlLocationPercentage3)  
        BEGIN  
         INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId)   
         VALUES (@EntityId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation3),@EmployeeGlLocationPercentage3,1)  
        END  
       END  
      END  
    END  
   DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
  
   INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
   SELECT TOP 1  
      NEWID()  
    , guiApiImportLogId = @guiLogId  
    , strField = 'Entity and Employee'  
    , strValue = CAST(ISNULL(SE.strEmployeeId, '') AS NVARCHAR(100))  
    , strLogLevel = 'Info'  
    , strStatus = 'Success'  
    , intRowNo = SE.intRowNumber  
    , strMessage = 'The entity and employee record has been successfully imported.'  
   FROM tblApiSchemaEmployee SE  
   LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
   WHERE SE.guiApiUniqueId = @guiApiUniqueId  
   AND SE.strEmployeeId = @EmployeeID  
  END  
 END TRY

  BEGIN CATCH
	    INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)  
		SELECT TOP 1  
		NEWID()  
		, guiApiImportLogId = @guiLogId  
		, strField = 'Employee Record'  
		, strValue = @EmployeeID  
		, strLogLevel = 'Error'  
		, strStatus = 'Failed'  
		, intRowNo = SE.intRowNumber  
		, strMessage = 'Issues encountered while importing employee records. Please try again.'  
		FROM tblApiSchemaEmployee SE  
		LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId  
		WHERE SE.guiApiUniqueId = @guiApiUniqueId  
		AND SE.strEmployeeId = @EmployeeID  

		DELETE FROM #TempEmployeeDetails WHERE strEmployeeId = @EmployeeID  
  END CATCH



 END  
  
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDetails'))   
 DROP TABLE #TempEmployeeDetails  
  
END


GO
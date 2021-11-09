CREATE PROCEDURE dbo.uspPRImportEmployee(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'D0EB8AB4-B08C-457C-8558-49C150FF9F79'
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()


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





--INSERT INTO tblApiImportLogDetail(guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
--SELECT
--	  guiApiImportLogId 	= @guiLogId
--   ,strField			= 'Employee ID'
--   ,strValue			= SE.strEmployeeId
--   ,strLogLevel		= 'Error'
--   ,strStatus			= 'Failed'
--   ,intRowNo			= SE.intRowNumber
--   ,strMessage		= 'Cannot find the Employee No: '+ ISNULL(SE.strEmployeeId,'') + '.'
--   FROM tblApiSchemaEmployee SE
--   LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId
--   WHERE SE.guiApiUniqueId = @guiApiUniqueId

--select strExternalERPId,* FROM #TempEmployeeDetails
--DROP TABLE #TempEmployeeDetails

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
SELECT
	guiApiImportLogDetailId = NEWID()
   ,guiApiImportLogId = @guiLogId
   ,strField		= 'Employee ID'
   ,strValue		= SE.strEmployeeId
   ,strLogLevel		= 'Error'
   ,strStatus		= 'Failed'
   ,intRowNo		= SE.intRowNumber
   ,strMessage		= 'Cannot find the Employee No: '+ CAST(ISNULL(SE.strEmployeeId, '') AS NVARCHAR(100)) + '.'
   FROM tblApiSchemaEmployee SE
   LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId
   WHERE SE.guiApiUniqueId = @guiApiUniqueId
   AND SE.strEmployeeId IS NULL


SELECT * INTO #TempEmployeeDetails FROM tblApiSchemaEmployee where guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDetails)
	BEGIN
		SELECT TOP 1 @EmployeeID = strEmployeeId FROM #TempEmployeeDetails
		SELECT TOP 1 @EntityId = intEntityId FROM tblPREmployee WHERE strEmployeeId = @EmployeeID

		IF @EntityId IS NULL
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
					,strRank	= (SELECT intRank FROM tblPREmployeeRank WHERE strDescription = EME.strRank)
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
					,EME.strEMPhone
					,EME.strPhone
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

				--select * from tblEMEntityMobileNumber where intEntityId = 2434

				--select * from tblEMEntityPhoneNumber where intEntityId = 2434


				INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
				select top 1 @ContactId, strEMPhone, (SELECT intDefaultCountryId FROM tblSMCompanyPreference) FROM #TempEmployeeDetails

				INSERT INTO tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
				select top 1 @ContactId, strPhone, (SELECT intDefaultCountryId FROM tblSMCompanyPreference) FROM #TempEmployeeDetails

				INSERT [dbo].[tblEMEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strState], [strCountry], [strZipCode],[strTimezone], [ysnDefaultLocation],[strCheckPayeeName],[strPhone])
				SELECT @NewId, strName, strAdress,strCity,strState, strCountry,strZipCode,strTimezone,@ysnDefault, strName, strEMPhone
				FROM #TempEmployeeDetails LC WHERE LC.strEmployeeId = @EmployeeID

				DECLARE @EntityLocationId INT
				SET @EntityLocationId = SCOPE_IDENTITY()

				DECLARE @EntityContactId INT
				SET @EntityContactId = SCOPE_IDENTITY()

				INSERT [dbo].[tblEMEntityToContact] ([intEntityId], [intEntityContactId], [intEntityLocationId],[ysnPortalAccess], ysnDefaultContact,intConcurrencyId)
				VALUES							  (@NewId, @ContactId, (SELECT TOP 1 intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @NewId), 0,@ysnDefault,1)


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
					intRank									= (SELECT intRank FROM tblPREmployeeRank WHERE strDescription = PRST.strRank),
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
					intWorkersCompensationId				= (SELECT TOP 1 intWorkersCompensationId from tblPRWorkersCompensation where strWCCode = intWorkersCompensationId),
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

				IF @Department1 IS NOT NULL 
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department1)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @NewId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))
						BEGIN
							INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId,intConcurrencyId)VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1),1)
						END
					END
					
				END

				IF @Department2 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department2)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @NewId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))
						BEGIN
							INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId,intConcurrencyId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2),1)	
						END
					END
					
				END

				IF @Department3 IS NOT NULL
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

				IF @LineOfBusiness1 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))
						BEGIN
							INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1),1)
						END
					END
				END

				IF @LineOfBusiness2 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))
						BEGIN
							INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2),1)
						END
					END
				END

				IF @LineOfBusiness3 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))
						BEGIN
							INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3),1)
						END
					END
				END

				IF @LineOfBusiness4 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblEMEntityLineOfBusiness WHERE intEntityId = @NewId AND intLineOfBusinessId = (SELECT TOP 1 intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))
						BEGIN
							INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId,intConcurrencyId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4),1)
						END
					END
				END

				IF @LineOfBusiness5 IS NOT NULL
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
				

				IF @SupervisorId1 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @NewId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1))
						BEGIN
							INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId,intConcurrencyId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1),1)
						END
					END
				END

				IF @SupervisorId2 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @NewId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))
						BEGIN
							INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId,intConcurrencyId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2),1)
						END
					END
				END

				IF @SupervisorId3 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeSupervisor WHERE intEntityEmployeeId = @NewId AND intSupervisorId = (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3))
						BEGIN
							INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId,intConcurrencyId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3),1)
						END
					END
				END

				
				IF @EmployeeGlLocation1 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @NewId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1))
						BEGIN
							INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId) VALUES (@NewId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation1),@EmployeeGlLocationPercentage1,1)
						END
					END
				END

				
				IF @EmployeeGlLocation2 IS NOT NULL
				BEGIN
					IF EXISTS (SELECT TOP 1 * FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2)
					BEGIN
						IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @NewId AND intProfitCenter = (SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2))
						BEGIN
							INSERT INTO tblPREmployeeLocationDistribution (intEntityEmployeeId,intProfitCenter,dblPercentage,intConcurrencyId) VALUES (@NewId,(SELECT TOP 1 intAccountSegmentId FROM tblGLAccountSegment WHERE strCode = @EmployeeGlLocation2),@EmployeeGlLocationPercentage2,1)
						END
					END
				END

				
				IF @EmployeeGlLocation3 IS NOT NULL
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
				,strPhone = @strPhone
				,strEmail2 = @strEmail
				,strTimezone = @strTimezone
				,strEntityNo = @strEntityNo
				,ysnActive = @ysnActive
				,strExternalERPId = @strExternalERPId
				,intEntityRank = @intEntityRank
				,strDepartment = @strDepartment
				,dtmOriginationDate = @dtmOriginationDate
				,strMobile = @strEmPhone
				WHERE intEntityId = @EntityId

				UPDATE tblEMEntity SET
					 strName = @strName
					,strEmail = @strEmail
					,ysnPrint1099 = @ysn1099Employee
					,strContactNumber = @strContactNumber
					,strMobile = @strEmPhone
					,strPhone = @strPhone
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

				IF @Department1 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department1)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @EntityId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))
							BEGIN
								INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))
							END
						END
					END

				IF @Department2 IS NOT NULL
					BEGIN
						IF EXISTS (SELECT TOP 1 * FROM tblPRDepartment WHERE strDepartment = @Department2)
						BEGIN
							IF NOT EXISTS (SELECT TOP 1 * FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = @EntityId AND intDepartmentId = (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))
							BEGIN
								INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))
							END					
						END
					END
				
				IF @Department3 IS NOT NULL
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
				IF @LineOfBusiness1 IS NOT NULL
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

				IF @LineOfBusiness2 IS NOT NULL
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

				IF @LineOfBusiness3 IS NOT NULL
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

				IF @LineOfBusiness4 IS NOT NULL
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

				IF @LineOfBusiness5 IS NOT NULL
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
				IF @SupervisorId1 IS NOT NULL
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
				IF @SupervisorId2 IS NOT NULL
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
				IF @SupervisorId3 IS NOT NULL
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

				IF @EmployeeGlLocation1 IS NOT NULL
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
				IF @EmployeeGlLocation2 IS NOT NULL
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
				IF @EmployeeGlLocation3 IS NOT NULL
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

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDetails')) 
	DROP TABLE #TempEmployeeDetails

END


GO
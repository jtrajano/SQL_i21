CREATE PROCEDURE dbo.uspPRImportEmployee(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'36107DA8-7812-47AF-93E3-97D3BB4D0630'
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
DECLARE @strPhone as NVARCHAR(50)




--INSERT INTO tblApiImportLogDetail(guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
--SELECT
--	guiApiImportLogId = @guiLogId
--   ,strField		= 'Employee ID'
--   ,strValue		= SE.strEmployeeId
--   ,strLogLevel		= 'Error'
--   ,strStatus		= 'Failed'
--   ,intRowNo		= SE.intRowNumber
--   ,strMessage		= 'Cannot find the Employee No: '+ ISNULL(SE.strEmployeeId,'') + '.'
--   FROM tblApiSchemaEmployee SE
--   LEFT JOIN tblPREmployee E ON E.strEmployeeId = SE.strEmployeeId
--   WHERE SE.guiApiUniqueId = @guiApiUniqueId

--select strExternalERPId,* FROM #TempEmployeeDetails
--DROP TABLE #TempEmployeeDetails


SELECT * INTO #TempEmployeeDetails FROM tblApiSchemaEmployee where guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDetails)
	BEGIN
		SELECT TOP 1 @EmployeeID = strEmployeeId FROM #TempEmployeeDetails
		SELECT TOP 1 @EntityId = intEntityId FROM tblPREmployee WHERE strEmployeeId = @EmployeeID

		IF @EntityId IS NULL
			BEGIN
				INSERT INTO tblEMEntity (
				 strName
				,strEmail
				,ysnPrint1099
				,strContactNumber
				,strTitle
				,strPhone
				,strEmail2
				,strTimezone
				,intLanguageId
				,strEntityNo
				,ysnActive
				,strDocumentDelivery
				,strExternalERPId
				,intEntityRank
				,strDateFormat
				,strNumberFormat
				,strFieldDelimiter
				) SELECT strName
					,strEmail
					,ysn1099Employee			= CASE WHEN ysn1099Employee = 'Y' THEN 1 ELSE 0 END
					,strContactNumber
					,strTitle
					,strPhone
					,strEmail
					,strTimezone
					,1
					,strEmployeeId
					,ysnActive					= CASE WHEN ysnActive = 'Y' THEN 1 ELSE 0 END
					,strDocumentDelivery1 + ',' + strDocumentDelivery2 + ',' + strDocumentDelivery3
					,strExternalERPId
					,strRank					= (SELECT intRank FROM tblPREmployeeRank WHERE strDescription = strRank)
					,'M/d/yyyy'
					,'1,234,567.89'
					,'Comma' FROM #TempEmployeeDetails EME
					WHERE EME.strEmployeeId = @EmployeeID

				SET @NewId = SCOPE_IDENTITY()


				INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
				select top 1 @NewId, strPhone, (SELECT intDefaultCountryId FROM tblSMCompanyPreference) FROM #TempEmployeeDetails


				INSERT [dbo].[tblEMEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strState], [strZipCode], [ysnDefaultLocation])
				SELECT @NewId, @EmployeeID + ' ' + strFirstName + ' ' + strMiddleName + ' ' + strLastName, '',strCity,strState,strZipCode,0 
				FROM #TempEmployeeDetails

				DECLARE @EntityLocationId INT
				SET @EntityLocationId = SCOPE_IDENTITY()

				DECLARE @EntityContactId INT
				SET @EntityContactId = SCOPE_IDENTITY()

				INSERT [dbo].[tblEMEntityToContact] ([intEntityId], [intEntityContactId], [intEntityLocationId],[ysnPortalAccess], ysnDefaultContact)
				VALUES							  (@NewId, @EntityContactId, @EntityLocationId, 0,0)


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
					ysnRetirementPlan
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
					intRank									= (SELECT TOP 1 intEmployeeRankId FROM tblPREmployeeRank where intEmployeeRankId = intRank),
					dtmReviewDate,
					dtmNextReview,
					strTimeEntryPassword,
					strEmergencyContact,
					strEmergencyRelation,
					strEmergencyPhone,
					strEmergencyPhone2,
					dtmBirthDate,
					ysnActive = CASE WHEN ysnActive = 'Y' THEN 1 ELSE 0 END,
					dtmOriginalDateHired,
					strGender,
					dtmDateHired,
					strSpouse,
					strMaritalStatus,
					strWorkPhone,
					intWorkersCompensationId = (SELECT TOP 1 intWorkersCompensationId from tblPRWorkersCompensation where strWCCode = intWorkersCompensationId),
					strEthnicity,
					strEEOCCode,
					strSocialSecurity,
					dtmTerminated,
					strTerminatedReason,
					ysn1099Employee = (CASE WHEN ysn1099Employee = 'Y' THEN 1 ELSE 0 END),
					ysnStatutoryEmployee = CASE WHEN ysnStatutoryEmployee = 'Y' THEN 1 ELSE 0 END,
					ysnThirdPartySickPay = (CASE WHEN PRST.ysnThirdPartySickPay = 'Y' THEN 1 ELSE 0 END),
					ysnRetirementPlan = (CASE WHEN PRST.ysnRetirementPlan = 'Y' THEN 1 ELSE 0 END)
					FROM #TempEmployeeDetails PRST
					WHERE PRST.strEmployeeId = @EmployeeID
				
				SELECT @Department1 = strDepartment1, @DepartmentDesc1 = strDepartmentDesc1,
					   @Department2 = strDepartment2, @DepartmentDesc2 = strDepartmentDesc2,
					   @Department3 = strDepartment3, @DepartmentDesc3 = strDepartmentDesc3,

					   @LineOfBusiness1 = strLineOfBusiness1, @LineOfBusiness2 = strLineOfBusiness2,
					   @LineOfBusiness3 = strLineOfBusiness3, @LineOfBusiness4 = strLineOfBusiness4,
					   @LineOfBusiness5 = strLineOfBusiness5, 
					   
					   @SupervisorId1 = strSupervisorId1, @SupervisorName1 = strSupervisorName1, @SupervisorTitle1 = strSupervisoreTitle1,
					   @SupervisorId2 = strSupervisorId2, @SupervisorName2 = strSupervisorName2, @SupervisorTitle2 = strSupervisoreTitle2,
					   @SupervisorId3 = strSupervisorId3, @SupervisorName3 = strSupervisorName3, @SupervisorTitle3 = strSupervisoreTitle3
				  FROM #TempEmployeeDetails A

				IF @Department1 IS NOT NULL 
				BEGIN
					INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))
				END

				IF @Department2 IS NOT NULL
				BEGIN
					INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))	
				END

				IF @Department3 IS NOT NULL
				BEGIN
					INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3))
				END
				
				IF @Department3 IS NOT NULL
				BEGIN
					
					INSERT INTO tblPREmployeeDepartment (intEntityEmployeeId,intDepartmentId) VALUES (@NewId, (SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3))
				END

				--SET IDENTITY_INSERT tblEMEntityLineOfBusiness ON

				IF @LineOfBusiness1 IS NOT NULL
				BEGIN
					INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))
				END

				IF @LineOfBusiness2 IS NOT NULL
				BEGIN
					INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))
				END

				IF @LineOfBusiness3 IS NOT NULL
				BEGIN
					INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))
				END

				IF @LineOfBusiness4 IS NOT NULL
				BEGIN
					INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))
				END

				IF @LineOfBusiness5 IS NOT NULL
				BEGIN
					INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5))
				END
				
				--SET IDENTITY_INSERT tblEMEntityLineOfBusiness OFF 
				

				INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))
				INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))
				INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))
				INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))
				INSERT INTO tblEMEntityLineOfBusiness (intEntityId, intEntityLineOfBusinessId) VALUES (@NewId, (SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5))


				INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1))
				INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))
				INSERT INTO tblPREmployeeSupervisor (intEntityEmployeeId,intSupervisorId) VALUES (@NewId, (SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId3))

				DELETE FROM #TempEmployeeDetails WHERE guiApiUniqueId = @guiApiUniqueId
			END

		--UPDATE 
		ELSE
			BEGIN
				--SELECT ALL RECORDS FROM TEMP TABLE
				SELECT @Department1 = strDepartment1, @DepartmentDesc1 = strDepartmentDesc1,
					   @Department2 = strDepartment2, @DepartmentDesc2 = strDepartmentDesc2,
					   @Department3 = strDepartment3, @DepartmentDesc3 = strDepartmentDesc3,

					   @LineOfBusiness1 = strLineOfBusiness1, @LineOfBusiness2 = strLineOfBusiness2,
					   @LineOfBusiness3 = strLineOfBusiness3, @LineOfBusiness4 = strLineOfBusiness4,
					   @LineOfBusiness5 = strLineOfBusiness5, 
					   
					   @SupervisorId1 = strSupervisorId1, @SupervisorName1 = strSupervisorName1, @SupervisorTitle1 = strSupervisoreTitle1,
					   @SupervisorId2 = strSupervisorId2, @SupervisorName2 = strSupervisorName2, @SupervisorTitle2 = strSupervisoreTitle2,
					   @SupervisorId3 = strSupervisorId3, @SupervisorName3 = strSupervisorName3, @SupervisorTitle3 = strSupervisoreTitle3
				  FROM #TempEmployeeDetails A
				WHERE strEmployeeId = @EmployeeID



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

				IF @Department1 IS NULL
					BEGIN
						INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department1))
					END

				IF @Department2 IS NULL
					BEGIN
						INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department2))
					END
				
				IF @Department3 IS NULL
					BEGIN
						INSERT tblPREmployeeDepartment (intEntityEmployeeId, intDepartmentId) VALUES (@EntityId,(SELECT intDepartmentId FROM tblPRDepartment WHERE strDepartment = @Department3))
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

				--UPDATE LINE OF BUSINESS
				IF @LineOfBusiness1 IS NULL
					BEGIN
						INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId) 
						VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness1))
					END

				IF @LineOfBusiness2 IS NULL
					BEGIN
						INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId) 
						VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness2))
					END

				IF @LineOfBusiness3 IS NULL
					BEGIN
						INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId) 
						VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness3))
					END

				IF @LineOfBusiness4 IS NULL
					BEGIN
						INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId) 
						VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness4))
					END

				IF @LineOfBusiness5 IS NULL
					BEGIN
						INSERT tblEMEntityLineOfBusiness (intEntityId, intLineOfBusinessId) 
						VALUES (@EntityId,(SELECT intLineOfBusinessId FROM tblSMLineOfBusiness WHERE strLineOfBusiness = @LineOfBusiness5))
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

				--UPDATE SUPERVISOR DATA
				IF @SupervisorId1 IS NULL
					BEGIN
						INSERT tblPREmployeeSupervisor(intEntityEmployeeId,intSupervisorId) 
						VALUES (@EntityId,(SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId1))
					END
				IF @SupervisorId2 IS NULL
					BEGIN
						INSERT tblPREmployeeSupervisor(intEntityEmployeeId,intSupervisorId) 
						VALUES (@EntityId,(SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))
					END
				IF @SupervisorId1 IS NULL
					BEGIN
						INSERT tblPREmployeeSupervisor(intEntityEmployeeId,intSupervisorId) 
						VALUES (@EntityId,(SELECT intEntityId FROM tblPREmployee WHERE strEmployeeId = @SupervisorId2))
					END
			END
			DELETE FROM #TempEmployeeDetails WHERE guiApiUniqueId = @guiApiUniqueId
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDetails')) 
	DROP TABLE #TempEmployeeDetails

END

GO
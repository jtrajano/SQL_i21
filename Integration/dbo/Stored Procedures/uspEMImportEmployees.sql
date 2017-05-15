GO
	PRINT 'START OF CREATING [uspEMImportEmployees] SP'
GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspEMImportEmployees')
DROP PROCEDURE [dbo].uspEMImportEmployees
GO


EXEC('


CREATE PROCEDURE [dbo].[uspEMImportEmployees]
	@EmployeId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

SET @Total = 0
IF(@Update = 1 AND @EmployeId IS NOT NULL)
BEGIN

	IF(EXISTS(SELECT 1 FROM prempmst WHERE premp_emp = SUBSTRING(@EmployeId, 1, 10)))
	BEGIN	

		UPDATE prempmst SET
			premp_first_name		= ISNULL(B.strFirstName,''''),																	--[strFirstName]
			premp_initial			= ISNULL(CAST(B.strMiddleName AS CHAR(1)), ''''),													--[strMiddleName]
			premp_last_name			= ISNULL(CAST(B.strLastName AS CHAR(20)),''''),													--[strLastName]
			premp_extension			= ISNULL(CAST(D.strSuffix AS CHAR(5)),''''),														--[strNameSuffix]
			premp_status			= Case when B.ysnActive = 1 then ''A'' else '''' end,												--[ysnActive] --
			premp_orig_hire_dt		= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmOriginalDateHired, 120), 10), ''-'', ''''), null),		--[dtmOriginalDateHired]
			premp_last_hire_dt		= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmDateHired, 120), 10), ''-'', ''''), null),				--[dtmDateHired]						
			premp_birth_dt			= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmBirthDate, 120), 10), ''-'', ''''), null),				--[dtmBirthDate]						
			premp_sex				= ISNULL(CAST(B.strGender AS CHAR(1)),''''),														--[strGender]
			premp_marital_status	= ISNULL(CAST(B.strMaritalStatus AS CHAR(1)),''''),												--[strMaritalStatus]
			premp_spouse			= ISNULL(CAST(B.strSpouse AS CHAR(30)),''''),														--[strSpouse]
			premp_phone				= ISNULL(CAST(B.strWorkPhone AS CHAR(15)),''''),													--[strWorkPhone]			
			premp_race				= ISNULL(CAST(B.strEthnicity AS CHAR(1)),''''),													--[strEthnicity]
			premp_eeo_code			= ISNULL(CAST(B.strEEOCCode AS CHAR(1)),''''),													--[strEEOCCode]
			premp_ssn				= ISNULL(CAST(dbo.fnEMGetNumberFromString(B.strSocialSecurity) AS CHAR(4)),''''),												--[strSocialSecurity]
			premp_term_dt			= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmTerminated, 120), 10), ''-'', ''''), null),				--[dtmTerminated]						
			premp_term_code			= ISNULL(CAST(B.strTerminatedReason AS CHAR(2)),''''),											--[strTerminatedReason]
			premp_emer_contact		= ISNULL(CAST(B.strEmergencyContact AS CHAR(30)),''''),											--[strEmergencyContact]
			premp_emer_phone		= ISNULL(CAST(B.strEmergencyPhone AS CHAR(15)),''''),												--[strEmergencyPhone]
			premp_doctor_phone		= ISNULL(CAST(B.strEmergencyPhone2 AS CHAR(15)),''''),											--[strEmergencyPhone2]
			premp_pay_cycle			= ISNULL(CAST(B.strPayPeriod AS CHAR(1)),''''),													--[strPayPeriod] 			
			premp_last_review_dt	= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmReviewDate, 120), 10), ''-'', ''''), null),				--[dtmReviewDate]						
			premp_next_review_dt	= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmNextReview, 120), 10), ''-'', ''''), null),				--[dtmNextReviewed]						
			premp_pension_flag_9	= CASE WHEN B.ysnRetirementPlan = 1 then ''1'' else ''0'' end,										--[ysnRetirementPlan]
			premp_std_hrs			= ISNULL(B.dblRegularHours,0),																	--[dblRegularHours]
			premp_user_rev_dt		= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmLastModified, 120), 10), ''-'', ''''), null),			--[dtmLastModified]									
			premp_addr1				= CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(SUBSTRING(C.strAddress,1,30), 0, CHARINDEX(CHAR(10),C.strAddress)) ELSE SUBSTRING(C.strAddress,1,30) END,
			premp_addr2				= CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress) + 1, LEN(C.strAddress)),1,30) ELSE NULL END,
			premp_city				= ISNULL(SUBSTRING(C.strCity,1,20),''''),
			premp_state				= ISNULL(SUBSTRING(C.strState,1,2),''''),
			premp_zip				= ISNULL(SUBSTRING(C.strZipCode,1,10),'''')

			--



		FROM prempmst 		
		INNER JOIN tblPREmployee B
			ON prempmst.premp_emp COLLATE Latin1_General_CI_AS = SUBSTRING(B.strEmployeeId, 1, 10) COLLATE Latin1_General_CI_AS
		INNER JOIN tblEMEntity A
			ON A.intEntityId = B.intEntityEmployeeId
		INNER JOIN tblEMEntityLocation C
			ON A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
		INNER JOIN tblEMEntityToContact G
			ON A.intEntityId = G.intEntityId and G.ysnDefaultContact = 1
		INNER JOIN tblEMEntity D
			ON  G.intEntityContactId = D.intEntityId		
		LEFT JOIN tblEMEntityPhoneNumber I
			ON D.intEntityId = I.intEntityId
		WHERE prempmst.premp_emp =  SUBSTRING(@EmployeId, 1, 10)
	END
	ELSE
	BEGIN		
		INSERT INTO prempmst(
		premp_emp,
		premp_first_name,
		premp_initial,
		premp_last_name,
		premp_extension,
		premp_status,
		premp_orig_hire_dt,
		premp_last_hire_dt,
		premp_birth_dt,
		premp_sex,
		premp_marital_status,
		premp_spouse,
		premp_phone,
		premp_race,
		premp_eeo_code,
		premp_ssn,
		premp_term_dt,
		premp_term_code,
		premp_emer_contact,
		premp_emer_phone,
		premp_doctor_phone,
		premp_pay_cycle,
		premp_last_review_dt,
		premp_next_review_dt,
		premp_pension_flag_9,
		premp_std_hrs,
		premp_user_rev_dt,
		premp_addr1,
		premp_addr2,
		premp_city,
		premp_state,
		premp_zip,
		premp_dept
		)
		SELECT 
			premp_emp						= CASE WHEN CHARINDEX(CHAR(10), B.strEmployeeId) > 0 THEN SUBSTRING(B.strEmployeeId, 0, CHARINDEX(CHAR(10),B.strEmployeeId)) ELSE B.strEmployeeId END,
			premp_first_name				= ISNULL(B.strFirstName,''''),																	--[strFirstName]
			premp_initial					= ISNULL(CAST(B.strMiddleName AS CHAR(1)), ''''),													--[strMiddleName]
			premp_last_name					= ISNULL(CAST(B.strLastName AS CHAR(20)),''''),													--[strLastName]
			premp_extension					= ISNULL(CAST(D.strSuffix AS CHAR(5)),''''),														--[strNameSuffix]
			premp_status					= Case when B.ysnActive = 1 then ''A'' else '''' end,												--[ysnActive] --
			premp_orig_hire_dt				= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmOriginalDateHired, 120), 10), ''-'', ''''), null),		--[dtmOriginalDateHired]
			premp_last_hire_dt				= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmDateHired, 120), 10), ''-'', ''''), null),				--[dtmDateHired]						
			premp_birth_dt					= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmBirthDate, 120), 10), ''-'', ''''), null),				--[dtmBirthDate]						
			premp_sex						= ISNULL(CAST(B.strGender AS CHAR(1)),''''),														--[strGender]
			premp_marital_status			= ISNULL(CAST(B.strMaritalStatus AS CHAR(1)),''''),												--[strMaritalStatus]
			premp_spouse					= ISNULL(CAST(B.strSpouse AS CHAR(30)),''''),														--[strSpouse]
			premp_phone						= ISNULL(CAST(B.strWorkPhone AS CHAR(15)),''''),													--[strWorkPhone]			
			premp_race						= ISNULL(CAST(B.strEthnicity AS CHAR(1)),''''),													--[strEthnicity]
			premp_eeo_code					= ISNULL(CAST(B.strEEOCCode AS CHAR(1)),''''),													--[strEEOCCode]
			premp_ssn						= ISNULL(CAST(dbo.fnEMGetNumberFromString(B.strSocialSecurity) AS CHAR(4)),''''),												--[strSocialSecurity]
			premp_term_dt					= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmTerminated, 120), 10), ''-'', ''''), null),				--[dtmTerminated]						
			premp_term_code					= ISNULL(CAST(B.strTerminatedReason AS CHAR(2)),''''),											--[strTerminatedReason]
			premp_emer_contact				= ISNULL(CAST(B.strEmergencyContact AS CHAR(30)),''''),											--[strEmergencyContact]
			premp_emer_phone				= ISNULL(CAST(B.strEmergencyPhone AS CHAR(15)),''''),												--[strEmergencyPhone]
			premp_doctor_phone				= ISNULL(CAST(B.strEmergencyPhone2 AS CHAR(15)),''''),											--[strEmergencyPhone2]
			premp_pay_cycle					= ISNULL(CAST(B.strPayPeriod AS CHAR(1)),''''),													--[strPayPeriod] 			
			premp_last_review_dt			= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmReviewDate, 120), 10), ''-'', ''''), null),				--[dtmReviewDate]						
			premp_next_review_dt			= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmNextReview, 120), 10), ''-'', ''''), null),				--[dtmNextReviewed]						
			premp_pension_flag_9			= CASE WHEN B.ysnRetirementPlan = 1 then ''1'' else ''0'' end,										--[ysnRetirementPlan]
			premp_std_hrs					= ISNULL(B.dblRegularHours,0),																	--[dblRegularHours]
			premp_user_rev_dt				= ISNULL(REPLACE(LEFT(CONVERT(VARCHAR, B.dtmLastModified, 120), 10), ''-'', ''''), null),			--[dtmLastModified]									
			premp_addr1						= CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(SUBSTRING(C.strAddress,1,30), 0, CHARINDEX(CHAR(10),C.strAddress)) ELSE SUBSTRING(C.strAddress,1,30) END,
			premp_addr2						= CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress) + 1, LEN(C.strAddress)),1,30) ELSE NULL END,
			premp_city						= ISNULL(SUBSTRING(C.strCity,1,20),''''),
			premp_state						= ISNULL(SUBSTRING(C.strState,1,2),''''),
			premp_zip						= ISNULL(SUBSTRING(C.strZipCode,1,10),''''),





			premp_dept						= ''''
						
		FROM
			tblEMEntity A
		INNER JOIN tblPREmployee B
			ON A.intEntityId = B.intEntityEmployeeId		
		INNER JOIN tblEMEntityLocation C
			ON A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
		INNER JOIN tblEMEntityToContact G
			ON A.intEntityId = G.intEntityId and G.ysnDefaultContact = 1
		INNER JOIN tblEMEntity D
			ON  G.intEntityContactId = D.intEntityId		
		LEFT JOIN tblEMEntityPhoneNumber I
			ON D.intEntityId = I.intEntityId

		WHERE B.strEmployeeId=  @EmployeId
	
	END

RETURN;
END

IF(@Update = 0 AND @EmployeId IS NULL)
BEGIN	
	
	PRINT ''1 Time Employee Synchronization''

	DECLARE @strName NVARCHAR(100)
	DECLARE @strFirstName NVARCHAR(100)
	DECLARE @strMiddleName NVARCHAR(100)
	DECLARE @strLastName NVARCHAR(100)
	DECLARE @strSuffix NVARCHAR(50)
	DECLARE @strAddress NVARCHAR(MAX)
	DECLARE @strCity	NVARCHAR(MAX)
	DECLARE @strState	NVARCHAR(MAX)
	DECLARE @strZip		NVARCHAR(MAX)
	DECLARE @strPhone	NVARCHAR(100)
	DECLARE @strNickName NVARCHAR(100)
	DECLARE @strTitle NVARCHAR(255)
	
	DECLARE @originEmployee NVARCHAR(50)


	DECLARE @dtmOrigHireDate		NVARCHAR(100)
	DECLARE @dtmLastHireDate		NVARCHAR(100)
	DECLARE @dtmBirthDate			NVARCHAR(100)
	DECLARE @strSex					NVARCHAR(10)
	DECLARE @strMaritalStatus		NVARCHAR(10)
	DECLARE @strSpouse				NVARCHAR(100)
	DECLARE @strEthnicity			NVARCHAR(50)
	DECLARE @strEEOCCode			NVARCHAR(50)
	DECLARE @strSocialSecurity		NVARCHAR(50)
	DECLARE @dtmTerminated			NVARCHAR(50)
	DECLARE @strTerminatedReason	NVARCHAR(50)
	DECLARE @strEmergencyContact	NVARCHAR(50)
	DECLARE @strEmergencyPhone		NVARCHAR(50)
	DECLARE @strEmergencyPhone2		NVARCHAR(50)
	DECLARE @strPayPeriod			NVARCHAR(50)
	DECLARE @dtmReviewDate			NVARCHAR(50)
	DECLARE @dtmNextReview			NVARCHAR(50)
	DECLARE @ysnRetirementPlan		NVARCHAR(50)
	DECLARE @dblRegularHours		NVARCHAR(50)
	DECLARE @dtmLastModified		NVARCHAR(50)
	DECLARE @strType				NVARCHAR(100)
	DECLARE @strDepartment			NVARCHAR(50)
	
	SELECT premp_emp INTO #tmpprempmst 
	FROM prempmst
		where premp_emp COLLATE Latin1_General_CI_AS not in (select strEmployeeOriginId from tblSMUserSecurity ) or premp_emp COLLATE Latin1_General_CI_AS not in (select strEmployeeId from tblPREmployee)
		 and ( premp_term_dt = 0 or premp_term_dt > replace(convert(nvarchar, DATEADD(YEAR,-1, getdate()), 102),''.'', '''') )
	
	WHILE (EXISTS(SELECT 1 FROM #tmpprempmst))
	BEGIN
		
		DECLARE @continue BIT = 0;

		SELECT @originEmployee = premp_emp FROM #tmpprempmst

		IF(EXISTS(SELECT 1 FROM prempmst WHERE premp_emp = @originEmployee))
		BEGIN

			SET @continue = 1;

            SELECT TOP 1
                --Entities
                @strName			= premp_first_name + '' '' +premp_initial + '' '' + premp_last_name,                
				@strNickName		= premp_nickname,
				@strTitle			= premp_job_title,
				@strFirstName		= premp_first_name,
				@strMiddleName		= premp_initial,
				@strLastName		= premp_last_name,
				@strSuffix			= premp_extension,
                --Contacts                
                @strPhone			= ISNULL(premp_phone,''''),                

                --Locations                
                @strAddress			= dbo.fnTrim(ISNULL(premp_addr1,'''')) + CHAR(10) + dbo.fnTrim(ISNULL(premp_addr2,'''')),
                @strCity			= premp_city,                    
                @strState			= premp_state,
                @strZip				= dbo.fnTrim(premp_zip),
                --Employee
                @originEmployee		= premp_emp,
				@dtmOrigHireDate	= case when premp_orig_hire_dt = 0 then null else premp_orig_hire_dt end,
				@dtmLastHireDate	= case when premp_last_hire_dt = 0 then null else premp_last_hire_dt end,
				@dtmBirthDate		= case when premp_last_hire_dt = 0 then null else premp_birth_dt end,
				@strSex				= CASE WHEN premp_sex = ''M'' THEN ''Male'' 
										WHEN premp_sex = ''F'' THEN ''Female'' end ,
				@strType			= Case when premp_employment = ''F'' then ''Full-Time''
										else ''Part-Time'' end,
				@strMaritalStatus	= CASE WHEN premp_marital_status = ''M'' then ''Married''
										WHEN premp_marital_status = ''W'' then ''Widowed''
										WHEN premp_marital_status = ''S'' then ''Single''
										WHEN premp_marital_status = ''U'' then ''Other''
										WHEN premp_marital_status = ''D'' then ''Divorced''
										ELSE ''Other'' END,
				@strSpouse			= premp_spouse,						
				@strEthnicity		= CASE WHEN premp_race = ''C'' THEN ''Caucasian'' --[not int the list ]
										WHEN premp_race = ''H'' THEN ''Hispanic or Latino''
										WHEN premp_race = ''I'' THEN ''American Indian or Alaska Native (not Hispanic or Latino)''
										WHEN premp_race = ''T'' THEN ''Two or More Races (not Hispanic or Latino)''
										WHEN premp_race = ''N'' THEN ''Afro-American'' --[not int the list ]
										WHEN premp_race = ''O'' THEN ''Oriental'' --[not int the list ]
										WHEN premp_race = ''P'' THEN ''Pacific Islander'' --[not int the list ]									
										END,
				@strEEOCCode		= CASE WHEN premp_eeo_code = ''1'' THEN ''1.2 - First/Mid Level Officials & Managers''
										WHEN premp_eeo_code = ''2'' THEN ''2 - Professionals''
										WHEN premp_eeo_code = ''3'' THEN ''3 - Technicians''
										WHEN premp_eeo_code = ''4'' THEN ''4 - Sales Workers''
										WHEN premp_eeo_code = ''5'' THEN ''5 - Administrative Support Workers''
										WHEN premp_eeo_code = ''6'' THEN ''6 - Craft Workers''
										WHEN premp_eeo_code = ''7'' THEN ''7 - Operatives''
										WHEN premp_eeo_code = ''8'' THEN ''8 - Laborers & Helpers''
										WHEN premp_eeo_code = ''9'' THEN ''9 - Service Workers''
										WHEN premp_eeo_code = ''10'' THEN ''1.1 - Executive/Senior Level Officials and Managers''				
										END, 
				@strSocialSecurity	= premp_ssn,
				@dtmTerminated		= case when premp_term_dt = 0 then null else premp_term_dt end,
				@strTerminatedReason= case when len(premp_term_code) > 100 then SUBSTRING(premp_term_code, 0, 100) else premp_term_code end,
				@strEmergencyContact= case when len(premp_emer_contact) > 25 then SUBSTRING(premp_emer_contact, 0, 25) else premp_emer_contact end,
				@strEmergencyPhone	= case when len(premp_emer_phone) > 25 then SUBSTRING(premp_emer_phone, 0, 25) else premp_emer_phone end,
				@strEmergencyPhone2	= case when len(premp_doctor_phone) > 25 then SUBSTRING(premp_doctor_phone, 0, 25) else premp_doctor_phone end,
				@strPayPeriod		= CASE WHEN premp_pay_cycle = ''W'' then ''Weekly''
										WHEN premp_pay_cycle = ''M'' then ''Monthly''
										WHEN premp_pay_cycle = ''Q'' then ''Quarterly''
										WHEN premp_pay_cycle = ''B'' then ''Bi-Weekly''
										WHEN premp_pay_cycle = ''S'' then ''Semi-Monthly''
										WHEN premp_pay_cycle = ''A'' then ''Annual''
										WHEN premp_pay_cycle = ''D'' then ''Daily'' end,
				@dtmReviewDate		= case when premp_last_review_dt = 0 then null else premp_last_review_dt end,
				@dtmNextReview		= case when premp_next_review_dt = 0 then null else premp_next_review_dt end ,
				@ysnRetirementPlan	= premp_pension_flag_9,
				@dblRegularHours	= premp_std_hrs,
				@dtmLastModified	= CASE WHEN ISNULL(premp_user_rev_dt,0) = 0 THEN NULL ELSE premp_user_rev_dt END,
				@strDepartment		= premp_dept
					
            FROM prempmst
            WHERE premp_emp = @originEmployee
		END
		
		IF(@continue = 1)
		BEGIN
		PRINT ''INSERT Entity Record''

		DECLARE @EntityId INT
		if not exists(select top 1 1 from tblSMUserSecurity where strEmployeeOriginId = @originEmployee)
		begin
			--INSERT Entity record 
			INSERT [dbo].[tblEMEntity]	([strName], [strContactNumber], [strEntityNo])
			VALUES						(@strName, '''',  @originEmployee)

			
			SET @EntityId = SCOPE_IDENTITY()

			PRINT ''INSERT Entity Contact Record''

			INSERT [dbo].[tblEMEntity] ([strName], strNickName, strTitle, strContactNumber)
				VALUES					(@strName, @strNickName, @strTitle, '''')

			DECLARE @ContactEntityId INT
			--Create contact record only if there is contact
			SET @ContactEntityId = SCOPE_IDENTITY()		
		
			DECLARE @EntityContactId INT
			SET @EntityContactId = @ContactEntityId


			INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
			select top 1 @ContactEntityId, @strPhone, intDefaultCountryId FROM tblSMCompanyPreference
			/*INSERT INTO tblEMEntityToContact( intEntityId, intEntityContactId, ysnPortalAccess, ysnDefaultContact)
			VALUES (@EntityId, @ContactEntityId, 0, 1)*/


			

			INSERT [dbo].[tblEMEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strState], [strZipCode], [ysnDefaultLocation])
			VALUES								(@EntityId, @originEmployee + '''' + @strName, @strAddress, @strCity, @strState, @strZip, 1)

			DECLARE @EntityLocationId INT
			SET @EntityLocationId = SCOPE_IDENTITY()

			INSERT [dbo].[tblEMEntityToContact] ([intEntityId], [intEntityContactId], [intEntityLocationId],[ysnPortalAccess], ysnDefaultContact)
			VALUES							  (@EntityId, @EntityContactId, @EntityLocationId, 0, 1)/**/

		end
		else
		begin
			select top 1  @EntityId = intEntityUserSecurityId from tblSMUserSecurity  where strEmployeeOriginId = @originEmployee
		end
		if not exists(select top 1 1 from tblEMEntityType where intEntityId = @EntityId)
		begin
			--insert into tblEMEntityType
			INSERT INTO tblEMEntityType ( intEntityId, strType, intConcurrencyId)
			VALUES (@EntityId, ''Employee'', 0)
		end
		
		
		
		
		insert into tblPREmployee(intEntityEmployeeId, strEmployeeId, strWorkPhone, intRank, dtmOriginalDateHired, dtmDateHired,	dtmBirthDate,	strGender,	strMaritalStatus,	strSpouse,	strEthnicity,	strEEOCCode,	strSocialSecurity,   	dtmTerminated,	strTerminatedReason,	strEmergencyContact,	strEmergencyPhone,	strEmergencyPhone2,	strPayPeriod,	dtmReviewDate,	dtmNextReview,	ysnRetirementPlan,	dblRegularHours,	dtmLastModified, strFirstName, strMiddleName, strLastName, strNameSuffix, strType)
		values(@EntityId, @originEmployee, @strPhone, 9,@dtmOrigHireDate, @dtmLastHireDate,		 @dtmBirthDate,	 @strSex,	@strMaritalStatus,	@strSpouse, @strEthnicity,	 @strEEOCCode,	 @strSocialSecurity,  @dtmTerminated, @strTerminatedReason, @strEmergencyContact, @strEmergencyPhone,	  @strEmergencyPhone2, @strPayPeriod, @dtmReviewDate,	 @dtmNextReview,	 @ysnRetirementPlan,  @dblRegularHours,	 @dtmLastModified, @strFirstName, @strMiddleName, @strLastName, @strSuffix, @strType)
		
		
		insert into tblEMEntityNote(dtmDate,dtmTime,intDuration,strUser,strSubject,strNotes,intEntityId)
		select 
			cast(cast(99999999-prcmt_date as nvarchar) as date),
			''00:00:01'',
			1,
			''ORIG'',
			''ORIGIN CONV'',
			 prcmt_line,
			 c.intEntityId
				from prempmst a 
					join prcmtmst b
						on a.premp_emp = b.prcmt_emp
					join tblEMEntity c
						on a.premp_emp COLLATE Latin1_General_CI_AS = c.strEntityNo COLLATE Latin1_General_CI_AS 
							and c.strEntityNo = @originEmployee

		if(@strDepartment <> '''' )
		begin
			if not exists(select top 1 1 from tblPRDepartment where strDepartment = @strDepartment)
			begin
				insert into tblPRDepartment(strDepartment, strDescription)
				values (@strDepartment, @strDepartment + '' - from origin'')
			end


			insert into tblPREmployeeDepartment(intEntityEmployeeId, intDepartmentId)
			select top 1 @EntityId, intDepartmentId from tblPRDepartment where strDepartment = @strDepartment
		end
		
		 
		
		set @Total = @Total + 1
		
		IF(@@ERROR <> 0) 
		BEGIN
			PRINT @@ERROR;
			RETURN;
		END

		END

		DELETE FROM #tmpprempmst WHERE premp_emp = @originEmployee

	END
	
	

	

END


IF(@Update = 1 AND @EmployeId IS NULL) 
BEGIN
	SELECT @Total = COUNT(premp_emp)  			
	FROM prempmst
	where premp_emp COLLATE Latin1_General_CI_AS not in (select strEmployeeOriginId from tblSMUserSecurity ) or premp_emp COLLATE Latin1_General_CI_AS not in (select strEmployeeId from tblPREmployee)
END





')

GO
	PRINT 'END OF Execute [uspEMImportEmployees] SP'
GO
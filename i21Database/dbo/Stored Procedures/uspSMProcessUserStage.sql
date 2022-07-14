CREATE PROCEDURE uspSMProcessUserStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForChecking	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForError	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForInsert	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForArchive	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUsersStageList	
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tmpUsersStageList (
		intUserStageId				INT,
		strUserName					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strUserId					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strExtErpId					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strEmail					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strPhone					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strMobile					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strContactName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strLocationName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strAddress					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strCity						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strZip						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strCountry					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strUserRole					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		ysnActive					BIT DEFAULT 0,

		strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
		strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
		ysnMailSent					BIT DEFAULT 0
	);

	INSERT INTO #tmpUsersStageList
	SELECT *
	FROM tblSMUserStage
	ORDER BY intUserStageId

	DECLARE @UserStageId INT
	DECLARE @Username NVARCHAR(100)
	DECLARE @UserId NVARCHAR(100)
	DECLARE @ExtErpId NVARCHAR(100)
	DECLARE @Email NVARCHAR(100)
	DECLARE @Phone NVARCHAR(100)
	DECLARE @Mobile NVARCHAR(100)
	DECLARE @ContactName NVARCHAR(100)
	DECLARE @LocationName NVARCHAR(100)
	DECLARE @Address NVARCHAR(100)
	DECLARE @City NVARCHAR(100)
	DECLARE @State NVARCHAR(100)
	DECLARE @Zip NVARCHAR(100)
	DECLARE @Country NVARCHAR(100)
	DECLARE @UserRole NVARCHAR(100)
	DECLARE @Active BIT
	DECLARE @ErrorMessage NVARCHAR(500) = ''
	DECLARE @ExistingCountryId INT = 0
	DECLARE @ExistingLocationId INT = 0
	DECLARE @ExistingUserRoleId INT = 0 
	DECLARE @ExistingUserPolicy INT = 0
	DECLARE @NewUserEntityId INT = 0
	DECLARE @NewContactEntityId INT = 0
	DECLARE @NewLocationId INT = 0
	DECLARE @NewUserStageErrorId INT
	DECLARE @ErrorDetailLocation NVARCHAR(100)
	DECLARE @ErrorDetailRole NVARCHAR(100)
	DECLARE @DetailLocation NVARCHAR(100)
	DECLARE @DetailRole NVARCHAR(100)
	DECLARE @ExistingDetailLocation INT
	DECLARE @ExistingDetalRole INT
	DECLARE @newEntityNo NVARCHAR(50)
	DECLARE @InsertDetailLocation NVARCHAR(100)
	DECLARE @InsertDetailRole NVARCHAR(100)
	DECLARE @ExistingInsertDetailLocation INT
	DECLARE @ExistingInsertDetailRole INT
	DECLARE @NewUserStageArchiveId INT
	DECLARE @ArchiveDetailLocation NVARCHAR(100)
	DECLARE @ArchiveDetailRole NVARCHAR(100)
	DECLARE	@ExistingEntityCredentialId INT = 0
	DECLARE @ExistingUserEntityId INT = 0
	DECLARE @ExistingContactEntityId INT = 0
	DECLARE @ExistingEntityLocationId INT = 0
	DECLARE @TransactionType NVARCHAR(50)

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUsersStageList)
	BEGIN
		SELECT		TOP 1
					@UserStageId = intUserStageId,
					@Username = strUserName,
					@UserId = strUserId,
					@ExtErpId = strExtErpId,
					@Email = strEmail,
					@Phone = strPhone,
					@Mobile = strMobile,
					@ContactName = strContactName,
					@LocationName = strLocationName,
					@Address = strAddress,
					@City = strCity,
					@State = strState,
					@Zip = strZip,
					@Country = strCountry,
					@UserRole = strUserRole,
					@Active = ysnActive
		FROM		#tmpUsersStageList

		SET			@ExistingEntityCredentialId = 0
		SET			@ExistingUserEntityId = 0
		SELECT		@ExistingEntityCredentialId = intEntityCredentialId,
					@ExistingUserEntityId = intEntityId
		FROM		dbo.tblEMEntityCredential
		WHERE		strUserName = @UserId

		SET			@ExistingCountryId = 0
		SELECT		@ExistingCountryId = intCountryID
		FROM		dbo.tblSMCountry
		WHERE		strCountry = @Country

		SET			@ExistingLocationId = 0
		SELECT		@ExistingLocationId = intCompanyLocationId
		FROM		dbo.tblSMCompanyLocation
		WHERE		strLocationName = @LocationName

		SET			@ExistingUserRoleId = 0
		SELECT		@ExistingUserRoleId = intUserRoleID
		FROM		dbo.tblSMUserRole
		WHERE		strName = @UserRole

		IF (ISNULL(@ExistingUserEntityId, 0) = 0)
		BEGIN
			SET @TransactionType = 'Added'
		END
		ELSE
		BEGIN
			SET @TransactionType = 'Updated'
		END

		IF (ISNULL(@ExistingCountryId, 0) = 0)
		BEGIN
			SET		@ErrorMessage = ISNULL(@ErrorMessage, '') + 'Country (' + @Country + ') is not existing. '
		END

		IF (ISNULL(@ExistingLocationId, 0) = 0)
		BEGIN
			SET		@ErrorMessage = ISNULL(@ErrorMessage, '') + 'Company Location (' + @LocationName + ') is not existing. '
		END

		IF (ISNULL(@ExistingUserRoleId, 0) = 0)
		BEGIN
			SET		@ErrorMessage = ISNULL(@ErrorMessage, '') + 'User Role (' + @UserRole + ') is not existing. '
		END

		CREATE TABLE #tmpUserLocationRolesForChecking (
			intUserStageDetailId INT,
			intUserStageId INT,
			strLocation NVARCHAR(100),
			strRole NVARCHAR(100)
		);

		CREATE TABLE #tmpUserLocationRolesForError (
			intUserStageDetailId INT,
			intUserStageId INT,
			strLocation NVARCHAR(100),
			strRole NVARCHAR(100)
		);

		CREATE TABLE #tmpUserLocationRolesForInsert (
			intUserStageDetailId INT,
			intUserStageId INT,
			strLocation NVARCHAR(100),
			strRole NVARCHAR(100)
		);

		CREATE TABLE #tmpUserLocationRolesForArchive (
			intUserStageDetailId INT,
			intUserStageId INT,
			strLocation NVARCHAR(100),
			strRole NVARCHAR(100)
		);

		INSERT INTO #tmpUserLocationRolesForChecking
		SELECT *
		FROM tblSMUserDetailStage
		WHERE intUserStageId = @UserStageId
		ORDER BY intUserStageDetailId

		INSERT INTO #tmpUserLocationRolesForError
		SELECT *
		FROM tblSMUserDetailStage
		WHERE intUserStageId = @UserStageId
		ORDER BY intUserStageDetailId

		INSERT INTO #tmpUserLocationRolesForInsert
		SELECT *
		FROM tblSMUserDetailStage
		WHERE intUserStageId = @UserStageId
		ORDER BY intUserStageDetailId

		INSERT INTO #tmpUserLocationRolesForArchive
		SELECT *
		FROM tblSMUserDetailStage
		WHERE intUserStageId = @UserStageId
		ORDER BY intUserStageDetailId

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserLocationRolesForChecking)
		BEGIN
			SET @DetailLocation = ''
			SET @DetailRole = ''
			SET @ExistingDetailLocation = 0
			SET @ExistingDetalRole = 0

			SELECT	TOP 1
					@DetailLocation = strLocation,
					@DetailRole = strRole
			FROM	#tmpUserLocationRolesForChecking

			SELECT	@ExistingDetailLocation = intCompanyLocationId
			FROM	dbo.tblSMCompanyLocation
			WHERE	strLocationName = @DetailLocation

			SELECT	@ExistingDetalRole = intUserRoleID
			FROM	dbo.tblSMUserRole
			WHERE	strName = @DetailRole

			IF (ISNULL(@ExistingDetailLocation, 0) = 0)
			BEGIN
				SET	@ErrorMessage = ISNULL(@ErrorMessage, '') + 'Company Location (' + @DetailLocation + ') is not existing. '
			END

			IF (ISNULL(@ExistingDetalRole, 0) = 0)
			BEGIN
				SET	@ErrorMessage = ISNULL(@ErrorMessage, '') + 'User Role (' + @DetailRole + ') is not existing. '
			END

			DELETE TOP (1) FROM #tmpUserLocationRolesForChecking
		END

		DROP TABLE #tmpUserLocationRolesForChecking

		IF (ISNULL(@ErrorMessage, '') <> '')
		BEGIN
			SET @NewUserStageErrorId = 0

			-- TRANSFER TO tblSMUserStageError
			INSERT INTO tblSMUserStageError (strUserName, strUserId, strExtErpId, strEmail, strPhone, strMobile, strContactName, strLocationName, strAddress, strCity, strState, strZip, strCountry, strUserRole, ysnActive, strTransactionType, strErrorMessage, strImportStatus)
			VALUES (@Username, @UserId, @ExtErpId, @Email, @Phone, @Mobile, @ContactName, @LocationName, @Address, @City, @State, @Zip, @Country, @UserRole, @Active, @TransactionType, @ErrorMessage, 'Failed')

			SET @NewUserStageErrorId = SCOPE_IDENTITY()

			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserLocationRolesForError)
			BEGIN
				SET @ErrorDetailLocation = ''
				SET @ErrorDetailRole = ''

				SELECT	TOP 1
						@ErrorDetailLocation = strLocation,
						@ErrorDetailRole = strRole
				FROM	#tmpUserLocationRolesForError

				INSERT INTO  tblSMUserDetailStageError (intUserStageErrorId, strLocation, strRole)
				VALUES (@NewUserStageErrorId, @ErrorDetailLocation, @ErrorDetailRole)

				DELETE TOP (1) FROM #tmpUserLocationRolesForError
			END

			DROP TABLE #tmpUserLocationRolesForError

			DELETE FROM tblSMUserStage WHERE intUserStageId = @UserStageId
			DELETE FROM tblSMUserDetailStage WHERE intUserStageId = @UserStageId
		END
		ELSE
		BEGIN
			IF (ISNULL(@ExistingUserEntityId, 0) = 0)
			BEGIN
				SET @newEntityNo = ''

				EXEC uspSMGetStartingNumber 43, @newEntityNo OUTPUT

				-- CREATE tblEMEntity (User)
				INSERT INTO tblEMEntity (strName, strEmail, strWebsite, strInternalNotes, ysnPrint1099, str1099Name, str1099Form, str1099Type, strFederalTaxId, imgPhoto, strContactNumber, strTitle, strDepartment, strMobile, strPhone, 
										 strPhone2, strEmail2, strNotes, strContactMethod, strTimezone, strEntityNo, strContactType, ysnActive, ysnReceiveEmail, strEmailDistributionOption, dtmOriginationDate, intDefaultCountryId, 
										 strDocumentDelivery, strNickName, strSuffix, strExternalERPId, intEntityRank, strDateFormat, strNumberFormat, strFieldDelimiter, ysnSent, intConcurrencyId)
				VALUES (
					@Username, --strName
					@Email,	--strEmail
					'', --strWebsite
					'', --strInternalNotes
					0,  --ysnPrint1099
					'', --str1099Name
					'', --str1099Form
					'', --str1099Type
					'', --strFederalTaxId
					CONVERT(VARBINARY(max), ''), --imgPhoto
					'', --strContactNumber
					'', --strTitle
					'', --strDepartment
					@Mobile, --strMobile
					@Phone, --strPhone
					'', --strPhone2
					'', --strEmail2
					'', --strNotes
					'', --strContactMethod
					'', --strTimezone
					@newEntityNo, --strEntityNo
					'', --strContactType
					0, --ysnActive
					0, --ysnReceiveEmail
					'', --strEmailDistributionOption
					GETUTCDATE(), --dtmOriginationDate
					NULL, --intDefaultCountryId
					'', --strDocumentDelivery
					'', --strNickName
					'', --strSuffix
					@ExtErpId, --strExternalERPId
					1, --intEntityRank
					'M/d/yyyy', --strDateFormat
					'1,234,567.89', --strNumberFormat
					'Comma', --strFieldDelimiter,
					0, --ysnSent
					1) --intConcurrencyId
			
				SELECT @NewUserEntityId = SCOPE_IDENTITY()

				-- CREATE tblEMEntity (Contact)
				INSERT INTO tblEMEntity (strName, strEmail, strWebsite, strInternalNotes, ysnPrint1099, str1099Name, str1099Form, str1099Type, strFederalTaxId, imgPhoto, strContactNumber, strTitle, strDepartment, strMobile, strPhone, 
										 strPhone2, strEmail2, strNotes, strContactMethod, strTimezone, strEntityNo, strContactType, ysnActive, ysnReceiveEmail, strEmailDistributionOption, dtmOriginationDate, intDefaultCountryId, 
										 strDocumentDelivery, strNickName, strSuffix, strExternalERPId, intEntityRank, strDateFormat, strNumberFormat, strFieldDelimiter, ysnSent, intConcurrencyId)
				VALUES (
					@ContactName, --strName
					@Email,	--strEmail
					'', --strWebsite
					'', --strInternalNotes
					0,  --ysnPrint1099
					'', --str1099Name
					'', --str1099Form
					'', --str1099Type
					'', --strFederalTaxId
					CONVERT(VARBINARY(max), ''), --imgPhoto
					'', --strContactNumber
					'', --strTitle
					'', --strDepartment
					@Mobile, --strMobile
					@Phone, --strPhone
					'', --strPhone2
					'', --strEmail2
					'', --strNotes
					'', --strContactMethod
					'', --strTimezone
					'', --strEntityNo
					'', --strContactType
					1, --ysnActive
					0, --ysnReceiveEmail
					'', --strEmailDistributionOption
					NULL, --dtmOriginationDate
					@ExistingCountryId, --intDefaultCountryId
					'', --strDocumentDelivery
					'', --strNickName
					'', --strSuffix
					@ExtErpId, --strExternalERPId
					1, --intEntityRank
					NULL, --strDateFormat
					NULL, --strNumberFormat
					'Comma', --strFieldDelimiter,
					0, --ysnSent
					1) --intConcurrencyId

				SELECT @NewContactEntityId = SCOPE_IDENTITY()

				-- CREATE tblEMEntityType
				INSERT tblEMEntityType (intEntityId, strType, intConcurrencyId)
				VALUES (@NewUserEntityId, 'User', 1)

				--CREATE tblSMUserSecurity
				SELECT		@ExistingUserPolicy = intSecurityPolicyId
				FROM		dbo.tblSMSecurityPolicy
				WHERE		strPolicyName = 'Default User Policy'

				INSERT INTO tblSMUserSecurity (intEntityId, intUserRoleID, intCompanyLocationId, intSecurityPolicyId, strUserName, strJIRAUserName, strFullName, strDashboardRole, strFirstName, strMiddleName, strLastName, strPhone, strLocation, strEmail,
											   strMenuPermission, strMenu, strForm, strFavorite, ysnDisabled, ysnAdmin, ysnRequirePurchasingApproval, intInvalidAttempt, ysnLockedOut, strEmployeeOriginId, ysnStoreManager, ysnUnrestricted,
											   ysnPitOperator, intConcurrencyId, ysnSecurityPolicyUpdated, ysnOverrideDistribution, ysnActiveDirectory, ysnStoreDPRDetail)
				VALUES (
						@NewUserEntityId, --intEntityId
						@ExistingUserRoleId, --intUserRoleID
						@ExistingLocationId, --intCompanyLocationId
						@ExistingUserPolicy, --intSecurityPolicyId
						@UserId, --strUserName
						'', --strJIRAUserName
						'', --strFullName
						'', --strDashboardRole
						'', --strFirstName
						'', --strMiddleName
						'', --strLastName
						@Phone, --strPhone
						'', --strLocation
						@Email, --strEmail
						'', --strMenuPermission
						'', --strMenu
						'', --strForm
						'', --strFavorite
						~@Active, --ysnDisabled
						1, --ysnAdmin
						0, --ysnRequirePurchasingApproval
						0, --intInvalidAttempt
						0, --ysnLockedOut
						'', --strEmployeeOriginId
						0, --ysnStoreManager
						0, --ysnUnrestricted
						0, --ysnPitOperator
						1, --intConcurrencyId
						0, --ysnSecurityPolicyUpdated
						0, --ysnOverrideDistribution
						0, --ysnActiveDirectory
						0) --ysnStoreDPRDetail

				--CREATE tblEMEntityCredential
				INSERT INTO tblEMEntityCredential (intEntityId, strUserName, strPassword, ysnTFAEnabled, ysnNotEncrypted, strEmail, ysnEmailConfirmed, strPhone, ysnPhoneConfirmed, strSecurityStamp, ysnTwoFactorEnabled, ysnLockoutEnabled,
												   intAccessFailedCount, intGridLayoutConcurrencyId, intCompanyGridLayoutConcurrencyId, intConcurrencyId)
				VALUES (
						@NewUserEntityId, --intEntityId
						@UserId, --strUserName
						dbo.fnAESEncryptASym('DefaultPassword@123'), --strPassword
						0, --ysnTFAEnabled
						0, --ysnNotEncrypted
						@Email, --strEmail
						1, --ysnEmailConfirmed
						@Phone, --strPhone
						1, --ysnPhoneConfirmed
						NEWID(), --strSecurityStamp
						0, --ysnTwoFactorEnabled
						0, --ysnLockoutEnabled
						0, --intAccessFailedCount
						0, --intGridLayoutConcurrencyId
						0, --intCompanyGridLayoutConcurrencyId
						1) --intConcurrencyId

				-- CREATE tblEMEntityLocation
				INSERT INTO tblEMEntityLocation (intEntityId, strLocationName, strAddress, strCity, strCountry, strState, strZipCode, strPhone, strFax, strPricingLevel, strNotes, ysnDefaultLocation, ysnActive, dblLongitude, dblLatitude,
												 strTimezone, strCheckPayeeName, strLocationType, dblFarmAcres, strOriginLinkCustomer, intConcurrencyId)
				VALUES (
						@NewUserEntityId, --intEntityId
						@LocationName, --strLocationName
						@Address, --strAddress
						@City, --strCity
						@Country, --strCountry
						@State, --strState
						@Zip, --strZipCode
						@Phone, --strPhone
						'', --strFax,
						'', --strPricingLevel
						'', --strNotes
						1, --ysnDefaultLocation
						1, --ysnActive
						0, --dblLongitude
						0, --dblLatitude
						'', --strTimezone
						@Username, --strCheckPayeeName
						'Location', --strLocationType
						0, --dblFarmAcres
						'', --strOriginLinkCustomer
						1) --intConcurrencyId

				SELECT @NewLocationId = SCOPE_IDENTITY()

				--CREATE tblEMEntityToContact
				INSERT INTO tblEMEntityToContact (intEntityId, intEntityContactId, intEntityLocationId, ysnPortalAccess, ysnPortalAdmin, ysnDefaultContact, intConcurrencyId)
				VALUES (
						@NewUserEntityId, --intEntityId
						@NewContactEntityId, --intEntityContactId
						@NewLocationId, --intEntityLocationId,
						0, --ysnPortalAccess
						0, --ysnPortalAdmin
						1, --ysnDefaultContact
						1) --intConcurrencyId

				--CREATE tblEMEntityPhoneNumber
				INSERT INTO tblEMEntityPhoneNumber (intEntityId, strPhone, strPhoneCountry, strPhoneArea, strPhoneLocal, strPhoneExtension, strPhoneLookUp, strMaskLocal, strMaskArea, strFormatCountry, strFormatArea, strFormatLocal,
													intCountryId, intAreaCityLength, ysnDisplayCountryCode, intConcurrencyId)
				VALUES (
						@NewUserEntityId, --intEntityId
						@Phone, --strPhone
						'', --strPhoneCountry
						'', --strPhoneArea
						'', --strPhoneLocal
						'', --strPhoneExtension
						'', --strPhoneLookUp
						'', --strMaskLocal
						'', --strMaskArea
						'', --strFormatCountry
						'', --strFormatArea
						'', --strFormatLocal
						@ExistingCountryId, --intCountryId
						0, --intAreaCityLength
						0, --ysnDisplayCountryCode
						1) --intConcurrencyId

				--CREATE tblSMUserSecurityCompanyLocationRolePermission (Details)
				WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserLocationRolesForInsert)
				BEGIN
					SET @InsertDetailLocation = ''
					SET @InsertDetailRole = ''
					SET @ExistingInsertDetailLocation = 0
					SET @ExistingInsertDetailRole = 0

					SELECT	TOP 1
							@InsertDetailLocation = strLocation,
							@InsertDetailRole = strRole
					FROM	#tmpUserLocationRolesForInsert

					SELECT	@ExistingInsertDetailLocation = intCompanyLocationId
					FROM	dbo.tblSMCompanyLocation
					WHERE	strLocationName = @InsertDetailLocation

					SELECT	@ExistingInsertDetailRole = intUserRoleID
					FROM	dbo.tblSMUserRole
					WHERE	strName = @InsertDetailRole

					INSERT tblSMUserSecurityCompanyLocationRolePermission (intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId, intConcurrencyId)
					VALUES (@NewUserEntityId, @NewUserEntityId, @ExistingInsertDetailRole, @ExistingInsertDetailLocation, 1)

					DELETE TOP (1) FROM #tmpUserLocationRolesForInsert
				END

				DROP TABLE #tmpUserLocationRolesForInsert

				-- TRANSFER TO tblSMUserStageArchive
				INSERT INTO tblSMUserStageArchive(strUserName, strUserId, strExtErpId, strEmail, strPhone, strMobile, strContactName, strLocationName, strAddress, strCity, strState, strZip, strCountry, strUserRole, ysnActive, strTransactionType, strErrorMessage, strImportStatus)
				VALUES (@Username, @UserId, @ExtErpId, @Email, @Phone, @Mobile, @ContactName, @LocationName, @Address, @City, @State, @Zip, @Country, @UserRole, @Active, @TransactionType, 'Success', 'Processed')
		
				SET @NewUserStageArchiveId = 0
				SET @NewUserStageArchiveId = SCOPE_IDENTITY()

				WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserLocationRolesForArchive)
				BEGIN
					SET @ArchiveDetailLocation = ''
					SET @ArchiveDetailRole = ''

					SELECT	TOP 1
							@ArchiveDetailLocation = strLocation,
							@ArchiveDetailRole = strRole
					FROM	#tmpUserLocationRolesForArchive

					INSERT INTO tblSMUserDetailStageArchive(intUserStageArchiveId, strLocation, strRole)
					VALUES (@NewUserStageArchiveId, @ArchiveDetailLocation, @ArchiveDetailRole)

					DELETE TOP (1) FROM #tmpUserLocationRolesForArchive
				END

				DROP TABLE #tmpUserLocationRolesForArchive

				DELETE FROM tblSMUserStage WHERE intUserStageId = @UserStageId
				DELETE FROM tblSMUserDetailStage WHERE intUserStageId = @UserStageId

				--AuditLog
				--DECLARE @SingleAuditLogParam SingleAuditLogParam
				--INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
				--		SELECT 1, '', 'Created', 'Created - Record: ' + CAST(@UserId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL

				--EXEC uspSMSingleAuditLog
				--	@screenName     = 'EntityManagement.view.Entity',
				--	@recordId       = @NewUserEntityId,
				--	@entityId       = 1,
				--	@AuditLogParam  = @SingleAuditLogParam  
			END
			ELSE
			BEGIN
				SET		@ExistingContactEntityId = 0
				SET		@ExistingEntityLocationId = 0
				SELECT	@ExistingContactEntityId = intEntityContactId,
						@ExistingEntityLocationId = intEntityLocationId
				FROM	dbo.tblEMEntityToContact
				WHERE	intEntityId = @ExistingUserEntityId

				--UPDATE tblEMEntity (User)
				UPDATE	tblEMEntity
				SET		strName = @Username,
						strEmail = @Email,
						strMobile = @Mobile,
						strPhone = @Phone,
						strExternalERPId = @ExtErpId
				WHERE	intEntityId = @ExistingUserEntityId

				--UPDATE tblEMEntity (Contact)
				UPDATE	tblEMEntity
				SET		strName = @ContactName,
						strEmail = @Email,
						strMobile = @Mobile,
						strPhone = @Phone,
						ysnActive = @Active, 
						intDefaultCountryId = @ExistingCountryId,
						strExternalERPId = @ExtErpId
				WHERE	intEntityId = @ExistingContactEntityId

				--UPDATE tblSMUserSecurity
				UPDATE	tblSMUserSecurity
				SET		intUserRoleID = @ExistingUserRoleId,
						intCompanyLocationId = @ExistingLocationId,
						strPhone = @Phone,
						strEmail = @Email,
						ysnDisabled = ~@Active
				WHERE	intEntityId = @ExistingUserEntityId

				--UPDATE tblEMEntityCredential
				UPDATE	tblEMEntityCredential
				SET		strEmail = @Email,
						strPhone = @Phone
				WHERE	intEntityId = @ExistingUserEntityId

				--UPDATE tblEMEntityLocation
				UPDATE	tblEMEntityLocation
				SET		strLocationName = @LocationName,
						strAddress = @Address,
						strCity = @City,
						strCountry = @Country,
						strState = @State,
						strZipCode = @Zip,
						strPhone = @Phone,
						strCheckPayeeName = @Username
				WHERE	intEntityLocationId = @ExistingEntityLocationId

				--UPDATE tblEMEntityPhoneNumber
				UPDATE	tblEMEntityPhoneNumber
				SET		strPhone = @Phone,
						intCountryId = @ExistingCountryId
				WHERE	intEntityId = @ExistingUserEntityId

				--CREATE tblSMUserSecurityCompanyLocationRolePermission (Details)
				DELETE 
				FROM	tblSMUserSecurityCompanyLocationRolePermission
				WHERE	intEntityId = @ExistingUserEntityId

				WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserLocationRolesForInsert)
				BEGIN
					SET @InsertDetailLocation = ''
					SET @InsertDetailRole = ''
					SET @ExistingInsertDetailLocation = 0
					SET @ExistingInsertDetailRole = 0

					SELECT	TOP 1
							@InsertDetailLocation = strLocation,
							@InsertDetailRole = strRole
					FROM	#tmpUserLocationRolesForInsert

					SELECT	@ExistingInsertDetailLocation = intCompanyLocationId
					FROM	dbo.tblSMCompanyLocation
					WHERE	strLocationName = @InsertDetailLocation

					SELECT	@ExistingInsertDetailRole = intUserRoleID
					FROM	dbo.tblSMUserRole
					WHERE	strName = @InsertDetailRole

					INSERT tblSMUserSecurityCompanyLocationRolePermission (intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId, intConcurrencyId)
					VALUES (@ExistingUserEntityId, @ExistingUserEntityId, @ExistingInsertDetailRole, @ExistingInsertDetailLocation, 1)

					DELETE TOP (1) FROM #tmpUserLocationRolesForInsert
				END

				DROP TABLE #tmpUserLocationRolesForInsert

				-- TRANSFER TO tblSMUserStageArchive
				INSERT INTO tblSMUserStageArchive(strUserName, strUserId, strExtErpId, strEmail, strPhone, strMobile, strContactName, strLocationName, strAddress, strCity, strState, strZip, strCountry, strUserRole, ysnActive, strTransactionType, strErrorMessage, strImportStatus)
				VALUES (@Username, @UserId, @ExtErpId, @Email, @Phone, @Mobile, @ContactName, @LocationName, @Address, @City, @State, @Zip, @Country, @UserRole, @Active, @TransactionType, 'Success', 'Processed')
		
				SET @NewUserStageArchiveId = 0
				SET @NewUserStageArchiveId = SCOPE_IDENTITY()

				WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserLocationRolesForArchive)
				BEGIN
					SET @ArchiveDetailLocation = ''
					SET @ArchiveDetailRole = ''

					SELECT	TOP 1
							@ArchiveDetailLocation = strLocation,
							@ArchiveDetailRole = strRole
					FROM	#tmpUserLocationRolesForArchive

					INSERT INTO tblSMUserDetailStageArchive(intUserStageArchiveId, strLocation, strRole)
					VALUES (@NewUserStageArchiveId, @ArchiveDetailLocation, @ArchiveDetailRole)

					DELETE TOP (1) FROM #tmpUserLocationRolesForArchive
				END

				DROP TABLE #tmpUserLocationRolesForArchive

				DELETE FROM tblSMUserStage WHERE intUserStageId = @UserStageId
				DELETE FROM tblSMUserDetailStage WHERE intUserStageId = @UserStageId
			END
		END

		DELETE TOP (1) FROM #tmpUsersStageList
	END

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForChecking	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForError	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForInsert	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUserLocationRolesForArchive	
	END TRY
	BEGIN CATCH
	END CATCH

	BEGIN TRY
		DROP TABLE #tmpUsersStageList	
	END TRY
	BEGIN CATCH
	END CATCH
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
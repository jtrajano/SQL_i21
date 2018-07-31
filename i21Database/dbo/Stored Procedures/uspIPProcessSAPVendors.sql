CREATE PROCEDURE [dbo].[uspIPProcessSAPVendors] @strSessionId NVARCHAR(50) = ''
	,@strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinVendor INT
	DECLARE @strVendorName NVARCHAR(100)
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intStageEntityId INT
	DECLARE @intNewStageEntityId INT
	DECLARE @intEntityId INT
	DECLARE @strEntityNo NVARCHAR(50)
	DECLARE @strTerm NVARCHAR(100)
	DECLARE @intTermId INT
	DECLARE @strCurrency NVARCHAR(50)
	DECLARE @intCurrencyId INT
	DECLARE @intEntityLocationId INT
	DECLARE @strCity NVARCHAR(MAX)
	DECLARE @strCountry NVARCHAR(MAX)
	DECLARE @strZipCode NVARCHAR(MAX)
	DECLARE @strAddress NVARCHAR(MAX)
	DECLARE @strAddress1 NVARCHAR(MAX)
	DECLARE @strAccountNo NVARCHAR(100)
	DECLARE @strTaxNo NVARCHAR(100)
	DECLARE @strFLOId NVARCHAR(100)
	DECLARE @intEntityContactId INT
	DECLARE @strPhone NVARCHAR(100)
	DECLARE @strJson NVARCHAR(Max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @intCountryId INT
	DECLARE @ysnDeleted BIT
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblEntityContactIdOutput TABLE (intEntityId INT)
	DECLARE @strCustomerCode NVARCHAR(50)
	DECLARE @strState NVARCHAR(MAX)

	SELECT @strCustomerCode = strCustomerCode
	FROM tblIPCompanyPreference

	IF IsNULL(@strCustomerCode, '') = ''
	BEGIN
		RAISERROR (
				'Customer code cannot be blank.'
				,16
				,1
				)

		RETURN
	END

	IF ISNULL(@strSessionId, '') = ''
		SELECT @intMinVendor = MIN(intStageEntityId)
		FROM tblIPEntityStage
		WHERE strEntityType = 'Vendor'
	ELSE IF @strSessionId = 'ProcessOneByOne'
		SELECT @intMinVendor = MIN(intStageEntityId)
		FROM tblIPEntityStage
		WHERE strEntityType = 'Vendor'
	ELSE
		SELECT @intMinVendor = MIN(intStageEntityId)
		FROM tblIPEntityStage
		WHERE strEntityType = 'Vendor'
			AND strSessionId = @strSessionId

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strAccountNo, '') + ', '
	FROM tblIPEntityStage

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strName, '') + ', '
	FROM tblIPEntityStage

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intMinVendor IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1
			SET @strVendorName = NULL
			SET @intEntityId = NULL
			SET @strEntityNo = NULL
			SET @strTerm = NULL
			SET @intTermId = NULL
			SET @strCurrency = NULL
			SET @intCurrencyId = NULL
			SET @intEntityLocationId = NULL
			SET @strCity = NULL
			SET @strCountry = NULL
			SET @strZipCode = NULL
			SET @strAddress = NULL
			SET @strAddress1 = NULL
			SET @strAccountNo = NULL
			SET @strTaxNo = NULL
			SET @strFLOId = NULL
			SET @intEntityContactId = NULL
			SET @strPhone = NULL
			SET @intCountryId = NULL
			SET @ysnDeleted = 0

			DELETE
			FROM @tblEntityContactIdOutput

			SELECT @intStageEntityId = intStageEntityId
				,@strVendorName = strName
				,@strTerm = strTerm
				,@strCurrency = strCurrency
				,@strAccountNo = strAccountNo
				,@ysnDeleted = ISNULL(ysnDeleted, 0)
			FROM tblIPEntityStage
			WHERE strEntityType = 'Vendor'
				AND intStageEntityId = @intMinVendor

			--SET @strInfo1 = ISNULL(@strAccountNo, '')
			--SET @strInfo2 = ISNULL(@strVendorName, '')
			SELECT @intEntityId = [intEntityId]
			FROM tblAPVendor
			WHERE strVendorAccountNum = @strAccountNo

			SELECT @intTermId = intTermID
			FROM tblSMTerm
			WHERE strTermCode = @strTerm

			SELECT @intCurrencyId = intCurrencyID
			FROM tblSMCurrency
			WHERE strCurrency = @strCurrency

			IF ISNULL(@strAccountNo, '') = ''
				RAISERROR (
						'Account No is required.'
						,16
						,1
						)

			BEGIN TRAN

			IF @strCustomerCode = 'JDE'
				BEGIN
					SELECT @intCountryId = c.intCountryID
						,@strCountry = c.strCountry
						,@strState = strState
					FROM tblIPEntityStage e
					JOIN tblSMCountry c ON e.strCountry = c.strISOCode
					WHERE intStageEntityId = @intStageEntityId
				END
				ELSE
				BEGIN
					SELECT @intCountryId = c.intCountryID
						,@strCountry = c.strCountry
						,@strState = strState
					FROM tblIPEntityStage e
					JOIN tblSMCountry c ON e.strCountry = c.strCountry
					WHERE intStageEntityId = @intStageEntityId
				END

			IF ISNULL(@intEntityId, 0) = 0 --Create
			BEGIN
				IF @ysnDeleted = 1
					RAISERROR (
							'Vendor does not exist for deletion.'
							,16
							,1
							)

				IF ISNULL(@intTermId, 0) = 0
					RAISERROR (
							'Term not found.'
							,16
							,1
							)

				IF ISNULL(@intCurrencyId, 0) = 0
					RAISERROR (
							'Currency not found.'
							,16
							,1
							)

				IF ISNULL(@strVendorName, '') = ''
					RAISERROR (
							'Vendor Name is required.'
							,16
							,1
							)

				IF (
						SELECT ISNULL(strCity, '')
						FROM tblIPEntityStage
						WHERE intStageEntityId = @intStageEntityId
						) = ''
					RAISERROR (
							'City is required.'
							,16
							,1
							)

				IF (
						SELECT ISNULL(strAccountNo, '')
						FROM tblIPEntityStage
						WHERE intStageEntityId = @intStageEntityId
						) = ''
					RAISERROR (
							'Account No is required.'
							,16
							,1
							)

				IF NOT EXISTS (
						SELECT 1
						FROM tblIPEntityContactStage
						WHERE intStageEntityId = @intStageEntityId
						)
					AND @strCustomerCode = 'JDE'
					RAISERROR (
							'Contact Name is required.'
							,16
							,1
							)

				IF (
						SELECT TOP 1 ISNULL(strFirstName, '')
						FROM tblIPEntityContactStage
						WHERE intStageEntityId = @intStageEntityId
						) = ''
					AND @strCustomerCode = 'JDE'
					RAISERROR (
							'Contact Name is required.'
							,16
							,1
							)

				EXEC uspSMGetStartingNumber 43
					,@strEntityNo OUT

				--Entity
				INSERT INTO tblEMEntity (
					strName
					,strEntityNo
					,ysnActive
					,strContactNumber
					)
				SELECT strName
					,@strEntityNo
					,1
					,''
				FROM tblIPEntityStage
				WHERE intStageEntityId = @intStageEntityId

				SELECT @intEntityId = SCOPE_IDENTITY()

				--Entity Type
				INSERT INTO tblEMEntityType (
					intEntityId
					,strType
					,intConcurrencyId
					)
				VALUES (
					@intEntityId
					,'Vendor'
					,0
					)

				--Entity Location
				INSERT INTO tblEMEntityLocation (
					intEntityId
					,strLocationName
					,strAddress
					,strCity
					,strCountry
					,strZipCode
					,intTermsId
					,ysnDefaultLocation
					,ysnActive
					,strState
					,strCheckPayeeName
					)
				SELECT @intEntityId
					,LEFT(strCity, 50)
					,ISNULL(strAddress, '') + ' ' + ISNULL(strAddress1, '')
					,strCity
					,@strCountry
					,strZipCode
					,@intTermId
					,1
					,1
					,@strState
					,LEFT(strCity, 50)
				FROM tblIPEntityStage
				WHERE intStageEntityId = @intStageEntityId

				SELECT @intEntityLocationId = SCOPE_IDENTITY()

				UPDATE tblEMEntity
				SET intDefaultLocationId = @intEntityLocationId
				WHERE intEntityId = @intEntityId

				--Vendor
				INSERT INTO tblAPVendor (
					[intEntityId]
					,intCurrencyId
					,strVendorId
					,ysnPymtCtrlActive
					,strTaxNumber
					,intBillToId
					,intShipFromId
					,strFLOId
					,intVendorType
					,ysnWithholding
					,dblCreditLimit
					,strVendorAccountNum
					,intTermsId
					)
				SELECT @intEntityId
					,@intCurrencyId
					,@strEntityNo
					,1
					,strTaxNo
					,@intEntityLocationId
					,@intEntityLocationId
					,strFLOId
					,0
					,0
					,0.0
					,strAccountNo
					,@intTermId
				FROM tblIPEntityStage
				WHERE intStageEntityId = @intStageEntityId

				--available to term list
				IF NOT EXISTS (
						SELECT 1
						FROM tblAPVendorTerm
						WHERE intEntityVendorId = @intEntityId
							AND intTermId = @intTermId
						)
					INSERT INTO tblAPVendorTerm (
						intEntityVendorId
						,intTermId
						)
					VALUES (
						@intEntityId
						,@intTermId
						)

				--Add Contacts to Entity table
				INSERT INTO tblEMEntity (
					strName
					,strContactNumber
					,ysnActive
					)
				OUTPUT inserted.intEntityId
				INTO @tblEntityContactIdOutput
				SELECT ISNULL([strFirstName], '') + ' ' + ISNULL([strLastName], '')
					,ISNULL([strFirstName], '') + ' ' + ISNULL([strLastName], '')
					,1
				FROM tblIPEntityContactStage
				WHERE intStageEntityId = @intStageEntityId

				--Map Contacts to Vendor
				INSERT INTO tblEMEntityToContact (
					intEntityId
					,intEntityContactId
					,intEntityLocationId
					,ysnPortalAccess
					)
				SELECT @intEntityId
					,intEntityId
					,@intEntityLocationId
					,0
				FROM @tblEntityContactIdOutput

				--Set default contact
				UPDATE tblEMEntityToContact
				SET ysnDefaultContact = 1
				WHERE intEntityToContactId = (
						SELECT TOP 1 intEntityToContactId
						FROM tblEMEntityToContact
						WHERE intEntityId = @intEntityId
						)

				--Add Phone
				INSERT INTO tblEMEntityPhoneNumber (
					intEntityId
					,strPhone
					,intCountryId
					)
				SELECT t1.intEntityId
					,t2.strPhone
					,@intCountryId
				FROM (
					SELECT ROW_NUMBER() OVER (
							ORDER BY intEntityId ASC
							) AS intRowNo
						,*
					FROM @tblEntityContactIdOutput
					) t1
				JOIN (
					SELECT ROW_NUMBER() OVER (
							ORDER BY intStageEntityContactId ASC
							) AS intRowNo
						,*
					FROM tblIPEntityContactStage
					WHERE intStageEntityId = @intStageEntityId
					) t2 ON t1.intRowNo = t2.intRowNo

				--Add Audit Trail Record
				SET @strJson = '{"action":"Created","change":"Created - Record: ' + CONVERT(VARCHAR, @intEntityId) + '","keyValue":' + CONVERT(VARCHAR, @intEntityId) + ',"iconCls":"small-new-plus","leaf":true}'

				SELECT @dtmDate = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), dtmCreated)
				FROM tblIPEntityStage
				WHERE intStageEntityId = @intStageEntityId

				IF @dtmDate IS NULL
					SET @dtmDate = GETUTCDATE()

				SELECT @strUserName = strCreatedUserName
				FROM tblIPEntityStage
				WHERE intStageEntityId = @intStageEntityId

				SELECT @intUserId = e.intEntityId
				FROM tblEMEntity e
				JOIN tblEMEntityType et ON e.intEntityId = et.intEntityId
				WHERE e.strExternalERPId = @strUserName
					AND et.strType = 'User'

				INSERT INTO tblSMAuditLog (
					strActionType
					,strTransactionType
					,strRecordNo
					,strDescription
					,strRoute
					,strJsonData
					,dtmDate
					,intEntityId
					,intConcurrencyId
					)
				VALUES (
					'Created'
					,'EntityManagement.view.Entity'
					,@intEntityId
					,''
					,''
					,@strJson
					,@dtmDate
					,@intUserId
					,1
					)
			END
			ELSE
			BEGIN --Update
				IF @ysnDeleted = 1
				BEGIN
					UPDATE tblEMEntity
					SET ysnActive = 0
					WHERE intEntityId = @intEntityId

					UPDATE tblAPVendor
					SET ysnPymtCtrlActive = 0
						,ysnDeleted = 1
					WHERE [intEntityId] = @intEntityId

					GOTO MOVE_TO_ARCHIVE
				END
				ELSE
				BEGIN
					UPDATE tblEMEntity
					SET ysnActive = 1
					WHERE intEntityId = @intEntityId

					UPDATE tblAPVendor
					SET ysnPymtCtrlActive = 1
						,ysnDeleted = 0
					WHERE [intEntityId] = @intEntityId
				END

				SELECT TOP 1 @intEntityLocationId = intEntityLocationId
				FROM tblEMEntityLocation
				WHERE intEntityId = @intEntityId

				SELECT @strAddress = strAddress
					,@strAddress1 = strAddress1
					,@strCity = strCity
					,@strCountry = strCountry
					,@strZipCode = strZipCode
					,@strTaxNo = strTaxNo
					,@strFLOId = strFLOId
					,@strState = strState
				FROM tblIPEntityStage
				WHERE intStageEntityId = @intStageEntityId

				--Update Address details
				IF ISNULL(@strTerm, '/') <> '/'
					AND ISNULL(@intTermId, 0) = 0
					RAISERROR (
							'Term not found.'
							,16
							,1
							)

				IF ISNULL(@strCurrency, '/') <> '/'
					AND ISNULL(@intCurrencyId, 0) = 0
					RAISERROR (
							'Currency not found.'
							,16
							,1
							)

				IF ISNULL(@strCity, '/') <> '/'
					AND ISNULL(@strCity, '') = ''
					RAISERROR (
							'City is required.'
							,16
							,1
							)

				IF ISNULL(@strAddress, '/') <> '/'
				BEGIN
					IF ISNULL(@strAddress1, '/') <> '/'
						SET @strAddress = @strAddress + ' ' + @strAddress1

					UPDATE tblEMEntityLocation
					SET strAddress = @strAddress
					WHERE intEntityLocationId = @intEntityLocationId
				END

				IF ISNULL(@strCity, '/') <> '/'
					UPDATE tblEMEntityLocation
					SET strLocationName = @strCity
						,strCity = @strCity
						,strCheckPayeeName = Left(@strCity, 50)
					WHERE intEntityLocationId = @intEntityLocationId

				IF ISNULL(@strCountry, '/') <> '/'
					UPDATE tblEMEntityLocation
					SET strCountry = @strCountry
					WHERE intEntityLocationId = @intEntityLocationId

				IF ISNULL(@strState, '/') <> '/'
					UPDATE tblEMEntityLocation
					SET strState = @strState
					WHERE intEntityLocationId = @intEntityLocationId

				IF ISNULL(@strZipCode, '/') <> '/'
					UPDATE tblEMEntityLocation
					SET strZipCode = @strZipCode
					WHERE intEntityLocationId = @intEntityLocationId

				IF ISNULL(@strTerm, '/') <> '/'
				BEGIN
					UPDATE tblEMEntityLocation
					SET intTermsId = @intTermId
					WHERE intEntityLocationId = @intEntityLocationId

					UPDATE tblAPVendor
					SET intTermsId = @intTermId
					WHERE [intEntityId] = @intEntityId

					--available to term list
					IF NOT EXISTS (
							SELECT 1
							FROM tblAPVendorTerm
							WHERE intEntityVendorId = @intEntityId
								AND intTermId = @intTermId
							)
						INSERT INTO tblAPVendorTerm (
							intEntityVendorId
							,intTermId
							)
						VALUES (
							@intEntityId
							,@intTermId
							)
				END

				--Entity table Update
				IF ISNULL(@strVendorName, '/') <> '/'
					UPDATE tblEMEntity
					SET strName = @strVendorName
						,strContactNumber = @strVendorName
					WHERE intEntityId = @intEntityId

				--Vendor table update
				IF ISNULL(@strCurrency, '/') <> '/'
					UPDATE tblAPVendor
					SET intCurrencyId = @intCurrencyId
					WHERE [intEntityId] = @intEntityId

				IF ISNULL(@strFLOId, '/') <> '/'
					UPDATE tblAPVendor
					SET strFLOId = @strFLOId
					WHERE [intEntityId] = @intEntityId

				IF ISNULL(@strTaxNo, '/') <> '/'
					UPDATE tblAPVendor
					SET strTaxNumber = @strTaxNo
					WHERE [intEntityId] = @intEntityId

				--Update Phone
				SELECT @intEntityContactId = intEntityId
				FROM tblEMEntity
				WHERE strName = (
						SELECT TOP 1 ISNULL([strFirstName], '') + ' ' + ISNULL([strLastName], '')
						FROM tblIPEntityContactStage
						WHERE intStageEntityId = @intStageEntityId
						)

				SELECT TOP 1 @strPhone = strPhone
				FROM tblIPEntityContactStage
				WHERE intStageEntityId = @intStageEntityId

				IF ISNULL(@strPhone, '/') <> '/'
					UPDATE tblEMEntityPhoneNumber
					SET strPhone = @strPhone
					WHERE intEntityId = @intEntityContactId

				--Add New Contacts
				--Add Contacts to Entity table
				INSERT INTO tblEMEntity (
					strName
					,strContactNumber
					,ysnActive
					)
				OUTPUT inserted.intEntityId
				INTO @tblEntityContactIdOutput
				SELECT ISNULL([strFirstName], '') + ' ' + ISNULL([strLastName], '')
					,ISNULL([strFirstName], '') + ' ' + ISNULL([strLastName], '')
					,1
				FROM tblIPEntityContactStage
				WHERE intStageEntityId = @intStageEntityId
					AND ISNULL([strFirstName], '') + ' ' + ISNULL([strLastName], '') NOT IN (
						SELECT strName
						FROM tblEMEntity
						)

				--Map Contacts to Vendor
				INSERT INTO tblEMEntityToContact (
					intEntityId
					,intEntityContactId
					,intEntityLocationId
					,ysnPortalAccess
					)
				SELECT @intEntityId
					,intEntityId
					,@intEntityLocationId
					,0
				FROM @tblEntityContactIdOutput

				--Add Phone
				INSERT INTO tblEMEntityPhoneNumber (
					intEntityId
					,strPhone
					,intCountryId
					)
				SELECT t1.intEntityId
					,t2.strPhone
					,(
						SELECT TOP 1 intCountryID
						FROM tblSMCountry
						WHERE strCountry = (
								SELECT TOP 1 strCountry
								FROM tblEMEntityLocation
								WHERE intEntityLocationId = @intEntityLocationId
								)
						)
				FROM (
					SELECT ROW_NUMBER() OVER (
							ORDER BY intEntityId ASC
							) AS intRowNo
						,*
					FROM @tblEntityContactIdOutput
					) t1
				JOIN (
					SELECT ROW_NUMBER() OVER (
							ORDER BY intStageEntityContactId ASC
							) AS intRowNo
						,*
					FROM tblIPEntityContactStage
					WHERE intStageEntityId = @intStageEntityId
					) t2 ON t1.intRowNo = t2.intRowNo
			END

			MOVE_TO_ARCHIVE:

			--Move to Archive
			INSERT INTO tblIPEntityArchive (
				strName
				,strEntityType
				,strAddress
				,strAddress1
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strPhone
				,strAccountNo
				,strTaxNo
				,strFLOId
				,strTerm
				,strCurrency
				,ysnDeleted
				,dtmCreated
				,strCreatedUserName
				,strSessionId
				)
			SELECT strName
				,strEntityType
				,strAddress
				,strAddress1
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strPhone
				,strAccountNo
				,strTaxNo
				,strFLOId
				,strTerm
				,strCurrency
				,ysnDeleted
				,dtmCreated
				,strCreatedUserName
				,@strSessionId
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId

			SELECT @intNewStageEntityId = SCOPE_IDENTITY()

			INSERT INTO tblIPEntityContactArchive (
				intStageEntityId
				,strEntityName
				,strFirstName
				,strLastName
				,strPhone
				)
			SELECT @intNewStageEntityId
				,strEntityName
				,strFirstName
				,strLastName
				,strPhone
			FROM tblIPEntityContactStage
			WHERE intStageEntityId = @intStageEntityId

			DELETE
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPEntityError (
				strName
				,strEntityType
				,strAddress
				,strAddress1
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strPhone
				,strAccountNo
				,strTaxNo
				,strFLOId
				,strTerm
				,strCurrency
				,ysnDeleted
				,dtmCreated
				,strCreatedUserName
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strName
				,strEntityType
				,strAddress
				,strAddress1
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strPhone
				,strAccountNo
				,strTaxNo
				,strFLOId
				,strTerm
				,strCurrency
				,ysnDeleted
				,dtmCreated
				,strCreatedUserName
				,@ErrMsg
				,'Failed'
				,@strSessionId
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId

			SELECT @intNewStageEntityId = SCOPE_IDENTITY()

			INSERT INTO tblIPEntityContactError (
				intStageEntityId
				,strEntityName
				,strFirstName
				,strLastName
				,strPhone
				)
			SELECT @intNewStageEntityId
				,strEntityName
				,strFirstName
				,strLastName
				,strPhone
			FROM tblIPEntityContactStage
			WHERE intStageEntityId = @intStageEntityId

			DELETE
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId
		END CATCH

		IF ISNULL(@strSessionId, '') = ''
			SELECT @intMinVendor = MIN(intStageEntityId)
			FROM tblIPEntityStage
			WHERE strEntityType = 'Vendor'
				AND intStageEntityId > @intMinVendor
		ELSE IF @strSessionId = 'ProcessOneByOne'
			SELECT @intMinVendor = NULL
		ELSE
			SELECT @intMinVendor = MIN(intStageEntityId)
			FROM tblIPEntityStage
			WHERE strEntityType = 'Vendor'
				AND intStageEntityId > @intMinVendor
				AND strSessionId = @strSessionId
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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

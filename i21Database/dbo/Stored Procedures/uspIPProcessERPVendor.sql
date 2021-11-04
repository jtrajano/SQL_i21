CREATE PROCEDURE uspIPProcessERPVendor @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	--SET ANSI_WARNINGS OFF
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intStageEntityId INT
		,@strStatus NVARCHAR(50)
		,@strAccountNo NVARCHAR(50)
		,@strName NVARCHAR(100)
		,@strTerm NVARCHAR(50)
		,@strEntityType NVARCHAR(50)
		,@strCurrency NVARCHAR(50)
		,@strDefaultLocation NVARCHAR(50)
		,@strTaxNo NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intEntityId INT
		,@ysnActive BIT
		,@intTermsId INT
		,@intCurrencyId INT
		,@intDefaultLocationId INT
		,@intNewStageEntityId INT
		,@strEntityNo NVARCHAR(50)
	DECLARE @intStageEntityTermId INT
		,@intDetailActionId INT
		,@intDetailLineType INT
		,@strDetailLocation NVARCHAR(200)
		,@strDetailAddress NVARCHAR(MAX)
		,@strDetailCity NVARCHAR(100)
		,@strDetailState NVARCHAR(100)
		,@strDetailZip NVARCHAR(100)
		,@strDetailCountry NVARCHAR(100)
		,@strDetailTerm NVARCHAR(100)
	DECLARE @intDetailCountryId INT
		,@intDetailTermId INT
		,@intEntityContactId INT
		,@intEntityLocationId INT
	DECLARE @tblEMEntity TABLE (
		strOldName NVARCHAR(100)
		,ysnOldActive BIT
		,strNewName NVARCHAR(100)
		,ysnNewActive BIT
		)
	DECLARE @tblAPVendor TABLE (
		intOldCurrencyId INT
		,intOldTermsId INT
		,strOldTaxNumber NVARCHAR(20)
		,intNewCurrencyId INT
		,intNewTermsId INT
		,strNewTaxNumber NVARCHAR(20)
		)
	DECLARE @tblEMEntityType TABLE (
		intEntityTypeId INT
		,strType NVARCHAR(100)
		)
	DECLARE @tblAPVendorTerm TABLE (
		intVendorTermId INT
		,intTermId INT
		,strRowState NVARCHAR(10)
		)
	DECLARE @tblEMEntityNewLocation TABLE (
		intEntityLocationId INT
		,strLocationName NVARCHAR(200)
		,strRowState NVARCHAR(10)
		)
	DECLARE @tblEMEntityLocation TABLE (
		intEntityLocationId INT
		,strRowState NVARCHAR(10)
		,strOldAddress NVARCHAR(MAX)
		,strOldCity NVARCHAR(MAX)
		,strOldCountry NVARCHAR(MAX)
		,strOldZipCode NVARCHAR(MAX)
		,strOldState NVARCHAR(MAX)
		,strOldCheckPayeeName NVARCHAR(MAX)
		,strOldPhone NVARCHAR(MAX)
		,strOldFax NVARCHAR(MAX)
		,intOldTermsId INT
		,ysnOldDefaultLocation BIT
		,strNewAddress NVARCHAR(MAX)
		,strNewCity NVARCHAR(MAX)
		,strNewCountry NVARCHAR(MAX)
		,strNewZipCode NVARCHAR(MAX)
		,strNewState NVARCHAR(MAX)
		,strNewCheckPayeeName NVARCHAR(MAX)
		,strNewPhone NVARCHAR(MAX)
		,strNewFax NVARCHAR(MAX)
		,intNewTermsId INT
		,ysnNewDefaultLocation BIT
		)
	DECLARE @intAuditDetailId INT

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @intStageEntityId = MIN(intStageEntityId)
	FROM tblIPEntityStage

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strAccountNo, '') + ', '
	FROM tblIPEntityStage

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strEntityType, '') + ', '
	FROM (
		SELECT DISTINCT strEntityType
		FROM tblIPEntityStage
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intStageEntityId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strStatus = NULL
				,@strAccountNo = NULL
				,@strName = NULL
				,@strTerm = NULL
				,@strEntityType = NULL
				,@strCurrency = NULL
				,@strDefaultLocation = NULL
				,@strTaxNo = NULL

			SELECT @intCompanyLocationId = NULL
				,@intEntityId = NULL
				,@ysnActive = NULL
				,@intTermsId = NULL
				,@intCurrencyId = NULL
				,@intDefaultLocationId = NULL
				,@intNewStageEntityId = NULL
				,@strEntityNo = NULL
				,@intAuditDetailId = NULL
				,@intStageEntityTermId = NULL
				,@intEntityContactId = NULL
				,@intEntityLocationId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreated
				,@strCreatedBy = strCreatedUserName
				,@strStatus = strStatus
				,@strAccountNo = strAccountNo
				,@strName = strName
				,@strTerm = strTerm
				,@strEntityType = strEntityType
				,@strCurrency = strCurrency
				,@strDefaultLocation = strDefaultLocation
				,@strTaxNo = strTaxNo
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId

			IF EXISTS (
					SELECT 1
					FROM tblIPEntityArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + LTRIM(@intTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intEntityId = intEntityId
			FROM dbo.tblAPVendor WITH (NOLOCK)
			WHERE strVendorAccountNum = @strAccountNo

			SELECT @intTermsId = intTermID
			FROM dbo.tblSMTerm WITH (NOLOCK)
			WHERE strTermCode = @strTerm

			SELECT @intCurrencyId = intCurrencyID
			FROM dbo.tblSMCurrency WITH (NOLOCK)
			WHERE strCurrency = @strCurrency

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strStatus, '') NOT IN (
					'Active'
					,'In-active'
					)
			BEGIN
				SELECT @strError = 'Status not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strStatus = 'Active'
				SELECT @ysnActive = 1
			ELSE
				SELECT @ysnActive = 0

			IF ISNULL(@strAccountNo, '') = ''
			BEGIN
				SELECT @strError = 'Vendor Account No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strName, '') = ''
			BEGIN
				SELECT @strError = 'Vendor Name cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intTermsId IS NULL
			BEGIN
				SELECT @strError = 'Terms Code not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strEntityType, '') NOT IN (
					'Vendor'
					,'Shipping Line'
					,'Forwarding Agent'
					,'Ship Via'
					,'Broker'
					,'Producer'
					)
			BEGIN
				SELECT @strError = 'Entity Type not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intCurrencyId IS NULL
			BEGIN
				SELECT @strError = 'Currency not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strDefaultLocation, '') = ''
			BEGIN
				SELECT @strError = 'Default Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intActionId <> 4
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblAPVendor V
						WHERE V.strVendorAccountNum = @strAccountNo
						)
					SELECT @intActionId = 2
				ELSE
					SELECT @intActionId = 1
			END

			IF @intActionId = 1
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblAPVendor V
						WHERE V.strVendorAccountNum = @strAccountNo
						)
				BEGIN
					SELECT @strError = 'Vendor Account No ''' + @strAccountNo + ''' already exists.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END
			ELSE
			BEGIN
				IF @intEntityId IS NULL
				BEGIN
					SELECT @strError = 'Vendor not found.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END

			-- Entity Location and Term validation
			SELECT @intStageEntityTermId = MIN(intStageEntityTermId)
			FROM tblIPEntityTermStage
			WHERE intStageEntityId = @intStageEntityId

			WHILE (@intStageEntityTermId IS NOT NULL)
			BEGIN
				SELECT @intDetailActionId = NULL
					,@intDetailLineType = NULL
					,@strDetailLocation = NULL
					,@strDetailAddress = NULL
					,@strDetailCity = NULL
					,@strDetailState = NULL
					,@strDetailZip = NULL
					,@strDetailCountry = NULL
					,@strDetailTerm = NULL

				SELECT @intDetailCountryId = NULL
					,@intDetailTermId = NULL
					,@intEntityContactId = NULL
					,@intEntityLocationId = NULL

				SELECT @intDetailActionId = intActionId
					,@intDetailLineType = intLineType
					,@strDetailLocation = strLocation
					,@strDetailAddress = strAddress
					,@strDetailCity = strCity
					,@strDetailState = strState
					,@strDetailZip = strZip
					,@strDetailCountry = strCountry
					,@strDetailTerm = strTerm
				FROM tblIPEntityTermStage
				WHERE intStageEntityTermId = @intStageEntityTermId

				IF ISNULL(@intDetailActionId, 0) NOT IN (
						1
						,2
						,4
						)
				BEGIN
					SELECT @strError = 'Detail - Action Id not found.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				IF ISNULL(@intDetailLineType, 0) NOT IN (
						1
						,2
						,3
						)
				BEGIN
					SELECT @strError = 'Detail - Line Type not found.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				IF @intDetailLineType = 1
				BEGIN
					IF ISNULL(@strDetailLocation, '') = ''
					BEGIN
						SELECT @strError = 'Detail - Location Name cannot be blank.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					IF ISNULL(@strDetailAddress, '') = ''
					BEGIN
						SELECT @strError = 'Detail - Address cannot be blank.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					--IF ISNULL(@strDetailCity, '') = ''
					--BEGIN
					--	SELECT @strError = 'Detail - City cannot be blank.'

					--	RAISERROR (
					--			@strError
					--			,16
					--			,1
					--			)
					--END

					--IF ISNULL(@strDetailState, '') = ''
					--BEGIN
					--	SELECT @strError = 'Detail - State cannot be blank.'

					--	RAISERROR (
					--			@strError
					--			,16
					--			,1
					--			)
					--END

					--IF ISNULL(@strDetailZip, '') = ''
					--BEGIN
					--	SELECT @strError = 'Detail - Zip Code cannot be blank.'

					--	RAISERROR (
					--			@strError
					--			,16
					--			,1
					--			)
					--END

					SELECT @intDetailCountryId = intCountryID
					FROM dbo.tblSMCountry WITH (NOLOCK)
					WHERE strCountry = @strDetailCountry

					IF @intDetailCountryId IS NULL
					BEGIN
						SELECT @strError = 'Detail - Country not found.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END
				END
				ELSE IF @intDetailLineType = 3
				BEGIN
					SELECT @intDetailTermId = intTermID
					FROM dbo.tblSMTerm WITH (NOLOCK)
					WHERE strTermCode = @strDetailTerm

					IF @intDetailTermId IS NULL
					BEGIN
						SELECT @strError = 'Detail - Terms Code not found.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END
				END

				SELECT @intStageEntityTermId = MIN(intStageEntityTermId)
				FROM tblIPEntityTermStage
				WHERE intStageEntityTermId > @intStageEntityTermId
					AND intStageEntityId = @intStageEntityId
			END

			BEGIN TRAN

			IF @intActionId = 1
			BEGIN
				--Entity
				IF NOT EXISTS (
						SELECT 1
						FROM tblEMEntity
						WHERE intEntityId = @intEntityId
						)
				BEGIN
					EXEC uspSMGetStartingNumber 43
						,@strEntityNo OUT

					INSERT INTO tblEMEntity (
						strName
						,strEntityNo
						,ysnActive
						,strContactNumber
						,intConcurrencyId
						)
					SELECT @strName
						,@strEntityNo
						,1
						,''
						,1

					SELECT @intEntityId = SCOPE_IDENTITY()

					--Entity Type
					IF NOT EXISTS (
							SELECT 1
							FROM tblEMEntityType ET
							WHERE ET.intEntityId = @intEntityId
								AND ET.strType = 'Vendor'
							)
					BEGIN
						INSERT INTO tblEMEntityType (
							intEntityId
							,strType
							,intConcurrencyId
							)
						VALUES (
							@intEntityId
							,'Vendor'
							,1
							)
					END

					IF NOT EXISTS (
							SELECT 1
							FROM tblEMEntityType ET
							WHERE ET.intEntityId = @intEntityId
								AND ET.strType = 'Futures Broker'
							)
					BEGIN
						INSERT INTO tblEMEntityType (
							intEntityId
							,strType
							,intConcurrencyId
							)
						VALUES (
							@intEntityId
							,'Futures Broker'
							,1
							)
					END

					--Entity Type
					IF NOT EXISTS (
							SELECT 1
							FROM tblEMEntityType ET
							WHERE ET.intEntityId = @intEntityId
								AND ET.strType = @strEntityType
							)
					BEGIN
						INSERT INTO tblEMEntityType (
							intEntityId
							,strType
							,intConcurrencyId
							)
						OUTPUT inserted.intEntityTypeId
							,inserted.strType
						INTO @tblEMEntityType
						SELECT @intEntityId
							,@strEntityType
							,1

						IF @strEntityType = 'Ship Via'
						BEGIN
							IF NOT EXISTS (
									SELECT 1
									FROM tblSMShipVia
									WHERE intEntityId = @intEntityId
									)
							BEGIN
								INSERT INTO tblSMShipVia (
									intEntityId
									,strShipVia
									,strShippingService
									,strFreightBilledBy
									,ysnCompanyOwnedCarrier
									,ysnActive
									,intSort
									)
								SELECT @intEntityId
									,@strName
									,'None'
									,'Other'
									,0
									,1
									,0
							END
						END
					END

					--Entity Location
					INSERT INTO tblEMEntityLocation (
						intEntityId
						,strLocationName
						,strAddress
						,strCity
						,strCountry
						,strZipCode
						,strState
						,strCheckPayeeName
						,strPhone
						,strFax
						,intTermsId
						,ysnDefaultLocation
						,ysnActive
						,intConcurrencyId
						)
					SELECT @intEntityId
						,strLocation
						,strAddress
						,strCity
						,strCountry
						,strZip
						,strState
						,LEFT(strCity, 50)
						,strPhone
						,strFax
						,T.intTermID
						,(
							CASE 
								WHEN @strDefaultLocation = ETS.strLocation
									THEN 1
								ELSE 0
								END
							)
						,1
						,1
					FROM tblIPEntityTermStage ETS
					LEFT JOIN tblSMTerm T ON T.strTermCode = ETS.strTerm
					WHERE ETS.intStageEntityId = @intStageEntityId
						AND ETS.intLineType = 1
						AND strLocation NOT IN (
							SELECT strLocationName
							FROM tblEMEntityLocation
							WHERE intEntityId = @intEntityId
							)

					SELECT @intDefaultLocationId = intEntityLocationId
					FROM dbo.tblEMEntityLocation
					WHERE strLocationName = @strDefaultLocation
						AND intEntityId = @intEntityId

					IF ISNULL(@intDefaultLocationId, 0) > 0
					BEGIN
						UPDATE tblEMEntity
						SET intDefaultLocationId = @intDefaultLocationId
						WHERE intEntityId = @intEntityId
					END

					--Vendor
					IF NOT EXISTS (
							SELECT 1
							FROM tblAPVendor V
							WHERE V.intEntityId = @intEntityId
							)
					BEGIN
						INSERT INTO tblAPVendor (
							intEntityId
							,intCurrencyId
							,strVendorId
							,ysnPymtCtrlActive
							,strTaxNumber
							,intBillToId
							,intShipFromId
							,intVendorType
							,ysnWithholding
							,dblCreditLimit
							,strVendorAccountNum
							,intTermsId
							,intConcurrencyId
							)
						SELECT @intEntityId
							,@intCurrencyId
							,@strEntityNo
							,1
							,@strTaxNo
							,@intDefaultLocationId
							,@intDefaultLocationId
							,0
							,0
							,0.0
							,@strAccountNo
							,@intTermsId
							,1
					END

					--Default Terms list
					IF NOT EXISTS (
							SELECT 1
							FROM tblAPVendorTerm
							WHERE intEntityVendorId = @intEntityId
								AND intTermId = @intTermsId
							)
					BEGIN
						INSERT INTO tblAPVendorTerm (
							intEntityVendorId
							,intTermId
							,intConcurrencyId
							)
						VALUES (
							@intEntityId
							,@intTermsId
							,1
							)
					END

					-- Other Terms list
					INSERT INTO tblAPVendorTerm (
						intEntityVendorId
						,intTermId
						,intConcurrencyId
						)
					SELECT @intEntityId
						,intTermID
						,1
					FROM tblIPEntityTermStage S
					JOIN tblSMTerm T ON S.strTerm = T.strTermCode
					WHERE S.intStageEntityId = @intStageEntityId
						AND S.intLineType = 3
						AND T.intTermID NOT IN (
							SELECT intTermId
							FROM tblAPVendorTerm VT
							WHERE VT.intEntityVendorId = @intEntityId
							)

					--Add Contacts to Entity table
					INSERT INTO tblEMEntity (
						strName
						,ysnActive
						,strContactNumber
						,strEmail
						,intConcurrencyId
						)
					SELECT @strName
						,1
						,''
						,''
						,1

					SELECT @intEntityContactId = SCOPE_IDENTITY()

					SELECT TOP 1 @intEntityLocationId = intEntityLocationId
					FROM tblEMEntityLocation
					WHERE intEntityId = @intEntityId
						AND ysnDefaultLocation = 1

					--Map Contacts to Vendor
					INSERT INTO tblEMEntityToContact (
						intEntityId
						,intEntityContactId
						,intEntityLocationId
						,ysnPortalAccess
						,ysnDefaultContact
						,intConcurrencyId
						)
					SELECT @intEntityId
						,@intEntityContactId
						,@intEntityLocationId
						,0
						,1
						,1

					EXEC uspSMAuditLog @keyValue = @intEntityId
						,@screenName = 'EntityManagement.view.Entity'
						,@entityId = @intUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@details = ''
				END
			END
			ELSE IF @intActionId = 2
			BEGIN
				DELETE
				FROM @tblEMEntity

				UPDATE tblEMEntity
				SET intConcurrencyId = intConcurrencyId + 1
					,strName = @strName
					,ysnActive = @ysnActive
				OUTPUT deleted.strName
					,deleted.ysnActive
					,inserted.strName
					,inserted.ysnActive
				INTO @tblEMEntity
				WHERE intEntityId = @intEntityId

				DELETE
				FROM @tblEMEntityType

				--Entity Type
				IF NOT EXISTS (
						SELECT 1
						FROM tblEMEntityType ET
						WHERE ET.intEntityId = @intEntityId
							AND ET.strType = @strEntityType
						)
				BEGIN
					INSERT INTO tblEMEntityType (
						intEntityId
						,strType
						,intConcurrencyId
						)
					OUTPUT inserted.intEntityTypeId
						,inserted.strType
					INTO @tblEMEntityType
					SELECT @intEntityId
						,@strEntityType
						,1

					IF @strEntityType = 'Ship Via'
					BEGIN
						IF NOT EXISTS (
								SELECT 1
								FROM tblSMShipVia
								WHERE intEntityId = @intEntityId
								)
						BEGIN
							INSERT INTO tblSMShipVia (
								intEntityId
								,strShipVia
								,strShippingService
								,strFreightBilledBy
								,ysnCompanyOwnedCarrier
								,ysnActive
								,intSort
								)
							SELECT @intEntityId
								,@strName
								,'None'
								,'Other'
								,0
								,1
								,0
						END
					END
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblEMEntityType ET
						WHERE ET.intEntityId = @intEntityId
							AND ET.strType = 'Futures Broker'
						)
				BEGIN
					INSERT INTO tblEMEntityType (
						intEntityId
						,strType
						,intConcurrencyId
						)
					OUTPUT inserted.intEntityTypeId
						,inserted.strType
					INTO @tblEMEntityType
					SELECT @intEntityId
						,'Futures Broker'
						,1
				END

				DELETE
				FROM @tblEMEntityNewLocation

				--Entity Location
				INSERT INTO tblEMEntityLocation (
					intEntityId
					,strLocationName
					,strAddress
					,strCity
					,strCountry
					,strZipCode
					,strState
					,strCheckPayeeName
					,strPhone
					,strFax
					,intTermsId
					,ysnDefaultLocation
					,ysnActive
					,intConcurrencyId
					)
				OUTPUT inserted.intEntityLocationId
					,inserted.strLocationName
					,'Added'
				INTO @tblEMEntityNewLocation
				SELECT @intEntityId
					,strLocation
					,strAddress
					,strCity
					,strCountry
					,strZip
					,strState
					,LEFT(strCity, 50)
					,strPhone
					,strFax
					,T.intTermID
					,(
						CASE 
							WHEN @strDefaultLocation = ETS.strLocation
								THEN 1
							ELSE 0
							END
						)
					,1
					,1
				FROM tblIPEntityTermStage ETS
				LEFT JOIN tblSMTerm T ON T.strTermCode = ETS.strTerm
				WHERE ETS.intStageEntityId = @intStageEntityId
					AND ETS.intLineType = 1
					AND ETS.intActionId = 1
					AND strLocation NOT IN (
						SELECT strLocationName
						FROM tblEMEntityLocation
						WHERE intEntityId = @intEntityId
						)

				DELETE EL
				OUTPUT deleted.intEntityLocationId
					,deleted.strLocationName
					,'Deleted'
				INTO @tblEMEntityNewLocation
				FROM tblEMEntityLocation EL
				JOIN tblIPEntityTermStage ETS ON ETS.strLocation = EL.strLocationName
					AND EL.intEntityId = @intEntityId
					AND ETS.intStageEntityId = @intStageEntityId
					AND ETS.intLineType = 1
					AND ETS.intActionId = 4

				DELETE
				FROM @tblEMEntityLocation

				UPDATE EL
				SET strAddress = ETS.strAddress
					,strCity = ETS.strCity
					,strCountry = ETS.strCountry
					,strZipCode = ETS.strZip
					,strState = ETS.strState
					,strCheckPayeeName = LEFT(ETS.strCity, 50)
					,strPhone = ETS.strPhone
					,strFax = ETS.strFax
					,intTermsId = T.intTermID
					,ysnDefaultLocation = (
						CASE 
							WHEN @strDefaultLocation = ETS.strLocation
								THEN 1
							ELSE 0
							END
						)
				OUTPUT inserted.intEntityLocationId
					,'Modified'
					,deleted.strAddress
					,deleted.strCity
					,deleted.strCountry
					,deleted.strZipCode
					,deleted.strState
					,deleted.strCheckPayeeName
					,deleted.strPhone
					,deleted.strFax
					,deleted.intTermsId
					,deleted.ysnDefaultLocation
					,inserted.strAddress
					,inserted.strCity
					,inserted.strCountry
					,inserted.strZipCode
					,inserted.strState
					,inserted.strCheckPayeeName
					,inserted.strPhone
					,inserted.strFax
					,inserted.intTermsId
					,inserted.ysnDefaultLocation
				INTO @tblEMEntityLocation
				FROM tblEMEntityLocation EL
				JOIN tblIPEntityTermStage ETS ON ETS.strLocation = EL.strLocationName
					AND EL.intEntityId = @intEntityId
					AND ETS.intStageEntityId = @intStageEntityId
					AND ETS.intLineType = 1
					AND ETS.intActionId = 2
				LEFT JOIN tblSMTerm T ON T.strTermCode = ETS.strTerm

				DELETE
				FROM @tblAPVendor

				--Vendor
				UPDATE tblAPVendor
				SET intConcurrencyId = intConcurrencyId + 1
					,intCurrencyId = @intCurrencyId
					,intTermsId = @intTermsId
					,strTaxNumber = @strTaxNo
				OUTPUT deleted.intCurrencyId
					,deleted.intTermsId
					,deleted.strTaxNumber
					,inserted.intCurrencyId
					,inserted.intTermsId
					,inserted.strTaxNumber
				INTO @tblAPVendor
				WHERE intEntityId = @intEntityId

				DELETE
				FROM @tblAPVendorTerm

				--Default Terms list
				IF NOT EXISTS (
						SELECT 1
						FROM tblAPVendorTerm
						WHERE intEntityVendorId = @intEntityId
							AND intTermId = @intTermsId
						)
				BEGIN
					INSERT INTO tblAPVendorTerm (
						intEntityVendorId
						,intTermId
						,intConcurrencyId
						)
					OUTPUT inserted.intVendorTermId
						,inserted.intTermId
						,'Added'
					INTO @tblAPVendorTerm
					SELECT @intEntityId
						,@intTermsId
						,1
				END

				-- Other Terms list
				INSERT INTO tblAPVendorTerm (
					intEntityVendorId
					,intTermId
					,intConcurrencyId
					)
				OUTPUT inserted.intVendorTermId
					,inserted.intTermId
					,'Added'
				INTO @tblAPVendorTerm
				SELECT @intEntityId
					,T.intTermID
					,1
				FROM tblIPEntityTermStage ETS
				JOIN tblSMTerm T ON T.strTermCode = ETS.strTerm
				WHERE ETS.intStageEntityId = @intStageEntityId
					AND ETS.intLineType = 3
					AND ETS.intActionId = 1
					AND T.intTermID NOT IN (
						SELECT intTermId
						FROM tblAPVendorTerm
						WHERE intEntityVendorId = @intEntityId
						)

				DELETE VT
				OUTPUT deleted.intVendorTermId
					,deleted.intTermId
					,'Deleted'
				INTO @tblAPVendorTerm
				FROM tblAPVendorTerm VT
				JOIN tblSMTerm T ON T.intTermID = VT.intTermId
					AND VT.intEntityVendorId = @intEntityId
				JOIN tblIPEntityTermStage ETS ON ETS.strTerm = T.strTermCode
					AND ETS.intStageEntityId = @intStageEntityId
					AND ETS.intLineType = 3
					AND ETS.intActionId = 4

				IF NOT EXISTS (
						SELECT TOP 1 1
						FROM tblEMEntityToContact EC
						WHERE EC.intEntityId = @intEntityId
						)
				BEGIN
					--Add Contacts to Entity table
					INSERT INTO tblEMEntity (
						strName
						,ysnActive
						,strContactNumber
						,strEmail
						,intConcurrencyId
						)
					SELECT @strName
						,1
						,''
						,''
						,1

					SELECT @intEntityContactId = SCOPE_IDENTITY()

					SELECT TOP 1 @intEntityLocationId = intEntityLocationId
					FROM tblEMEntityLocation
					WHERE intEntityId = @intEntityId
						AND ysnDefaultLocation = 1

					--Map Contacts to Vendor
					INSERT INTO tblEMEntityToContact (
						intEntityId
						,intEntityContactId
						,intEntityLocationId
						,ysnPortalAccess
						,ysnDefaultContact
						,intConcurrencyId
						)
					SELECT @intEntityId
						,@intEntityContactId
						,@intEntityLocationId
						,0
						,1
						,1
				END

				DECLARE @strDetails NVARCHAR(MAX) = ''

				IF EXISTS (
						SELECT 1
						FROM @tblEMEntity
						WHERE IsNULL(strOldName, '') <> IsNULL(strNewName, '')
						)
					SELECT @strDetails += '{"change":"strName","iconCls":"small-gear","from":"' + IsNULL(strOldName, '') + '","to":"' + IsNULL(strNewName, '') + '","leaf":true,"changeDescription":"Name"},'
					FROM @tblEMEntity

				IF EXISTS (
						SELECT 1
						FROM @tblEMEntity
						WHERE IsNULL(ysnOldActive, 0) <> IsNULL(ysnNewActive, 0)
						)
					SELECT @strDetails += '{"change":"ysnActive","iconCls":"small-gear","from":"' + LTRIM(ysnOldActive) + '","to":"' + LTRIM(ysnNewActive) + '","leaf":true,"changeDescription":"Active"},'
					FROM @tblEMEntity

				IF EXISTS (
						SELECT 1
						FROM @tblAPVendor
						WHERE IsNULL(intOldCurrencyId, 0) <> IsNULL(intNewCurrencyId, 0)
						)
					SELECT @strDetails += '{"change":"strCurrency","iconCls":"small-gear","from":"' + ISNULL(C.strCurrency, '') + '","to":"' + ISNULL(C1.strCurrency, '') + '","leaf":true,"changeDescription":"Currency"},'
					FROM @tblAPVendor V
					LEFT JOIN tblSMCurrency C ON C.intCurrencyID = V.intOldCurrencyId
					LEFT JOIN tblSMCurrency C1 ON C1.intCurrencyID = V.intNewCurrencyId

				IF EXISTS (
						SELECT 1
						FROM @tblAPVendor
						WHERE IsNULL(intOldTermsId, 0) <> IsNULL(intNewTermsId, 0)
						)
					SELECT @strDetails += '{"change":"strTerm","iconCls":"small-gear","from":"' + ISNULL(T.strTerm, '') + '","to":"' + ISNULL(T1.strTerm, '') + '","leaf":true,"changeDescription":"Default Terms"},'
					FROM @tblAPVendor V
					LEFT JOIN tblSMTerm T ON T.intTermID = V.intOldTermsId
					LEFT JOIN tblSMTerm T1 ON T1.intTermID = V.intNewTermsId

				IF EXISTS (
						SELECT 1
						FROM @tblAPVendor
						WHERE IsNULL(strOldTaxNumber, '') <> IsNULL(strNewTaxNumber, '')
						)
					SELECT @strDetails += '{"change":"strTaxNumber","iconCls":"small-gear","from":"' + IsNULL(strOldTaxNumber, '') + '","to":"' + IsNULL(strNewTaxNumber, '') + '","leaf":true,"changeDescription":"Tax No"},'
					FROM @tblAPVendor

				IF EXISTS (
						SELECT 1
						FROM @tblEMEntityType
						)
				BEGIN
					SELECT @strDetails += '{"change":"tblEMEntityTypes","children":['

					SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + strType + '","keyValue":' + ltrim(intEntityTypeId) + ',"iconCls":"small-new-plus","leaf":true},'
					FROM @tblEMEntityType

					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Entity Type"},'
				END

				IF EXISTS (
						SELECT 1
						FROM @tblEMEntityNewLocation
						WHERE strRowState = 'Added'
							OR strRowState = 'Deleted'
						)
				BEGIN
					SELECT @strDetails += '{"change":"tblEMEntityLocations","children":['

					SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + strLocationName + '","keyValue":' + ltrim(intEntityLocationId) + ',"iconCls":"small-new-plus","leaf":true},'
					FROM @tblEMEntityNewLocation
					WHERE strRowState = 'Added'

					SELECT @strDetails += '{"action":"Deleted","change":"Deleted - Record: ' + strLocationName + '","keyValue":' + ltrim(intEntityLocationId) + ',"iconCls":"small-new-minus","leaf":true},'
					FROM @tblEMEntityNewLocation
					WHERE strRowState = 'Deleted'

					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Entity Location"},'
				END

				IF EXISTS (
						SELECT 1
						FROM @tblAPVendorTerm
						WHERE strRowState = 'Added'
							OR strRowState = 'Deleted'
						)
				BEGIN
					SELECT @strDetails += '{"change":"tblAPVendorTerms","children":['

					SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + T.strTerm + '","keyValue":' + ltrim(intVendorTermId) + ',"iconCls":"small-new-plus","leaf":true},'
					FROM @tblAPVendorTerm VT
					LEFT JOIN tblSMTerm T ON T.intTermID = VT.intTermId
					WHERE strRowState = 'Added'

					SELECT @strDetails += '{"action":"Deleted","change":"Deleted - Record: ' + T.strTerm + '","keyValue":' + ltrim(intVendorTermId) + ',"iconCls":"small-new-minus","leaf":true},'
					FROM @tblAPVendorTerm VT
					LEFT JOIN tblSMTerm T ON T.intTermID = VT.intTermId
					WHERE strRowState = 'Deleted'

					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Specific Terms"},'
				END

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intEntityId
						,@screenName = 'EntityManagement.view.Entity'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END

				DECLARE @strLocationDetails NVARCHAR(MAX) = ''

				WHILE EXISTS (
						SELECT TOP 1 NULL
						FROM @tblEMEntityLocation
						)
				BEGIN
					SELECT @strLocationDetails = ''
					
					SELECT TOP 1 @intAuditDetailId = intEntityLocationId
					FROM @tblEMEntityLocation

					SELECT @strLocationDetails += '{"change":"strAddress","iconCls":"small-gear","from":"' + IsNULL(strOldAddress, '') + '","to":"' + IsNULL(strNewAddress, '') + '","leaf":true,"changeDescription":"Address"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldAddress, '') <> IsNULL(strNewAddress, '')

					SELECT @strLocationDetails += '{"change":"strCity","iconCls":"small-gear","from":"' + IsNULL(strOldCity, '') + '","to":"' + IsNULL(strNewCity, '') + '","leaf":true,"changeDescription":"City"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldCity, '') <> IsNULL(strNewCity, '')

					SELECT @strLocationDetails += '{"change":"strCountry","iconCls":"small-gear","from":"' + IsNULL(strOldCountry, '') + '","to":"' + IsNULL(strNewCountry, '') + '","leaf":true,"changeDescription":"Country"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldCountry, '') <> IsNULL(strNewCountry, '')

					SELECT @strLocationDetails += '{"change":"strZipCode","iconCls":"small-gear","from":"' + IsNULL(strOldZipCode, '') + '","to":"' + IsNULL(strNewZipCode, '') + '","leaf":true,"changeDescription":"Zip Code"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldZipCode, '') <> IsNULL(strNewZipCode, '')

					SELECT @strLocationDetails += '{"change":"strState","iconCls":"small-gear","from":"' + IsNULL(strOldState, '') + '","to":"' + IsNULL(strNewState, '') + '","leaf":true,"changeDescription":"State"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldState, '') <> IsNULL(strNewState, '')

					SELECT @strLocationDetails += '{"change":"strCheckPayeeName","iconCls":"small-gear","from":"' + IsNULL(strOldCheckPayeeName, '') + '","to":"' + IsNULL(strNewCheckPayeeName, '') + '","leaf":true,"changeDescription":"Check Payee Name"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldCheckPayeeName, '') <> IsNULL(strNewCheckPayeeName, '')

					SELECT @strLocationDetails += '{"change":"strPhone","iconCls":"small-gear","from":"' + IsNULL(strOldPhone, '') + '","to":"' + IsNULL(strNewPhone, '') + '","leaf":true,"changeDescription":"Phone"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldPhone, '') <> IsNULL(strNewPhone, '')

					SELECT @strLocationDetails += '{"change":"strFax","iconCls":"small-gear","from":"' + IsNULL(strOldFax, '') + '","to":"' + IsNULL(strNewFax, '') + '","leaf":true,"changeDescription":"Fax"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(strOldFax, '') <> IsNULL(strNewFax, '')

					SELECT @strLocationDetails += '{"change":"strTerms","iconCls":"small-gear","from":"' + IsNULL(T.strTerm, '') + '","to":"' + IsNULL(T1.strTerm, '') + '","leaf":true,"changeDescription":"Terms"},'
					FROM @tblEMEntityLocation EL
					LEFT JOIN tblSMTerm T ON T.intTermID = EL.intOldTermsId
					LEFT JOIN tblSMTerm T1 ON T1.intTermID = EL.intNewTermsId
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(intOldTermsId, 0) <> IsNULL(intNewTermsId, 0)

					SELECT @strLocationDetails += '{"change":"ysnDefaultLocation","iconCls":"small-gear","from":"' + LTRIM(ysnOldDefaultLocation) + '","to":"' + LTRIM(ysnNewDefaultLocation) + '","leaf":true,"changeDescription":"Default Location"},'
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
						AND IsNULL(ysnOldDefaultLocation, 0) <> IsNULL(ysnNewDefaultLocation, 0)

					IF (LEN(@strLocationDetails) > 1)
					BEGIN
						SET @strLocationDetails = SUBSTRING(@strLocationDetails, 0, LEN(@strLocationDetails))

						EXEC uspSMAuditLog @keyValue = @intAuditDetailId
							,@screenName = 'EntityManagement.view.EntityLocation'
							,@entityId = @intUserId
							,@actionType = 'Updated'
							,@actionIcon = 'small-tree-modified'
							,@details = @strLocationDetails
					END

					DELETE
					FROM @tblEMEntityLocation
					WHERE intEntityLocationId = @intAuditDetailId
				END
			END
			ELSE IF @intActionId = 4
			BEGIN
				IF @intEntityId > 0
				BEGIN
					DELETE
					FROM tblEMEntity
					WHERE intEntityId = @intEntityId

					EXEC uspSMAuditLog @keyValue = @intEntityId
						,@screenName = 'EntityManagement.view.Entity'
						,@entityId = @intUserId
						,@actionType = 'Deleted'
				END
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,5 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			INSERT INTO tblIPEntityArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreated
				,strCreatedUserName
				,strStatus
				,strAccountNo
				,strName
				,strTerm
				,strEntityType
				,strCurrency
				,strDefaultLocation
				,strTaxNo
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreated
				,strCreatedUserName
				,strStatus
				,strAccountNo
				,strName
				,strTerm
				,strEntityType
				,strCurrency
				,strDefaultLocation
				,strTaxNo
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId

			SELECT @intNewStageEntityId = SCOPE_IDENTITY()

			INSERT INTO tblIPEntityTermArchive (
				intStageEntityId
				,strEntityName
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,intActionId
				,intLineType
				,strLocation
				,strAddress
				,strCity
				,strState
				,strZip
				,strCountry
				,strPhone
				,strFax
				,strTerm
				)
			SELECT @intNewStageEntityId
				,strEntityName
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,intActionId
				,intLineType
				,strLocation
				,strAddress
				,strCity
				,strState
				,strZip
				,strCountry
				,strPhone
				,strFax
				,strTerm
			FROM tblIPEntityTermStage
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

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,5 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			INSERT INTO tblIPEntityError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreated
				,strCreatedUserName
				,strStatus
				,strAccountNo
				,strName
				,strTerm
				,strEntityType
				,strCurrency
				,strDefaultLocation
				,strTaxNo
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreated
				,strCreatedUserName
				,strStatus
				,strAccountNo
				,strName
				,strTerm
				,strEntityType
				,strCurrency
				,strDefaultLocation
				,strTaxNo
				,@ErrMsg
				,'Failed'
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId

			SELECT @intNewStageEntityId = SCOPE_IDENTITY()

			INSERT INTO tblIPEntityTermError (
				intStageEntityId
				,strEntityName
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,intActionId
				,intLineType
				,strLocation
				,strAddress
				,strCity
				,strState
				,strZip
				,strCountry
				,strPhone
				,strFax
				,strTerm
				)
			SELECT @intNewStageEntityId
				,strEntityName
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,intActionId
				,intLineType
				,strLocation
				,strAddress
				,strCity
				,strState
				,strZip
				,strCountry
				,strPhone
				,strFax
				,strTerm
			FROM tblIPEntityTermStage
			WHERE intStageEntityId = @intStageEntityId

			DELETE
			FROM tblIPEntityStage
			WHERE intStageEntityId = @intStageEntityId
		END CATCH

		SELECT @intStageEntityId = MIN(intStageEntityId)
		FROM tblIPEntityStage
		WHERE intStageEntityId > @intStageEntityId
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

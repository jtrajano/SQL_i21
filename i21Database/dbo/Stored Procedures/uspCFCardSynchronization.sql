CREATE PROCEDURE [dbo].[uspCFCardSynchronization]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	 @strCardNumber					NVARCHAR(MAX)	 =	 ''
	,@strParticipantNumber			NVARCHAR(MAX)	 =	 ''
	,@strAccountNumber				NVARCHAR(MAX)	 =	 ''
	,@strVehicleNumber				NVARCHAR(MAX)	 =   ''
	,@strVehicleDescription			NVARCHAR(MAX)	 =   ''
	,@intManualEntryCode			INT				 =   NULL
	,@strLimitCode					NVARCHAR(MAX)	 =   ''
	,@strProductAuthCode			NVARCHAR(MAX)	 =   ''
	,@strCardStatus					NVARCHAR(MAX)	 =   ''
	,@strPINNumber					NVARCHAR(MAX)	 =   ''
	,@strLabel						NVARCHAR(MAX)	 =   ''
	,@strCardType 					NVARCHAR(MAX)	 =   ''
	,@dtmExpirationDate				NVARCHAR(MAX)	 =	 ''
	,@strSessionId					NVARCHAR(MAX)
	,@strImportDate					NVARCHAR(MAX)
	,@strNetworkParticipantId		NVARCHAR(MAX)	 =	 ''
	,@intNetworkId					INT				 =   NULL
	--,@intUserID


AS
BEGIN

	DECLARE @intAccountId			INT
	DECLARE @intSycnType			INT
	DECLARE @strAction				NVARCHAR(MAX)	 =	 ''
	DECLARE @dtmImportDate			DATETIME
	DECLARE @ysnIsVehicleNumeric	BIT 

	

	--VALIDATE ACCOUNT--
	---VALIDATE ACCOUNT---

	--DECLARE @intAccountId AS INT = 0
	DECLARE @strErrorRecordId NVARCHAR(MAX) = ''
	DECLARE @tblCFNumericAccount TABLE(
			intAccountId				int
			,strAccountNumber			nvarchar(MAX)
	)

	DECLARE @tblCFCharAccount TABLE(
			intAccountId				int
			,strAccountNumber			nvarchar(MAX)
	)

	IF(ISNULL(@strAccountNumber,'') != '')
	BEGIN
		IF(ISNUMERIC(@strAccountNumber) = 1)
		BEGIN
			INSERT INTO @tblCFNumericAccount(
				 intAccountId		
				,strAccountNumber	
			)
			SELECT 
				 intAccountId			
				,strCustomerNumber	
			FROM vyuCFAccountCustomer 
			WHERE strCustomerNumber not like '%[^0-9]%' and strCustomerNumber != ''

			SET @intAccountId =
			(SELECT TOP 1 intAccountId
			FROM @tblCFNumericAccount
			WHERE CAST(strAccountNumber AS BIGINT) = CAST(@strAccountNumber AS BIGINT))
				
		END
		ELSE
		BEGIN
			INSERT INTO @tblCFCharAccount(
				intAccountId		
				,strAccountNumber	
			)
				SELECT 
				 intAccountId			
				,strCustomerNumber	
			FROM vyuCFAccountCustomer 
		    WHERE strCustomerNumber like '%[^0-9]%' and strCustomerNumber != ''

			SET @intAccountId =
			(SELECT TOP 1 intAccountId
			FROM @tblCFCharAccount
			WHERE strAccountNumber = @strAccountNumber)

		END
	END
	ELSE
	BEGIN 
		print 'Invalid account number'
		INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
			,'Invalid account number' as strMessage
			,@strErrorRecordId
			,@dtmImportDate

		RETURN
	END

	IF(ISNULL(@intAccountId,0) = 0)
	BEGIN
		print 'Cannot account number'
		INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
			,'Cannot account number ' + @strAccountNumber as strMessage
			,@strErrorRecordId
			,@dtmImportDate

		RETURN
	END

	--VALIDATE TYPE--
	IF(ISNULL(@strCardType,'') != '')
	BEGIN
		IF(LOWER(@strCardType) = 's' OR LOWER(@strCardType) = 'd')
		BEGIN
			SET @intSycnType = 1
		END
		ELSE IF(LOWER(@strCardType) = 'v') 
		BEGIN
			SET @intSycnType = 2
		END
		ELSE
		BEGIN
			SET @intSycnType = 0
			print 'invalid card type'

			INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Invalid card type' as strMessage
				,''
				,@dtmImportDate
			RETURN

		END
	END
	ELSE
	BEGIN
		print 'invalid card type'

	INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Invalid card type' as strMessage
				,''
				,@dtmImportDate
		RETURN

	END
	--VALIDATE TYPE--


	
	IF(@intSycnType = 1)
	BEGIN
	--CHECK IF CARD EXIST--
		SET @strErrorRecordId = 'card - ' + @strCardNumber
		IF((SELECT COUNT(*) FROM tblCFCard where strCardNumber = @strCardNumber AND intAccountId = @intAccountId) = 0)
		BEGIN
			SET @strAction = 'addcard'
		END
		ELSE
		BEGIN
			SET @strAction = 'editcard'
		END
	--CHECK IF CARD EXIST--
	END
	ELSE
	BEGIN
		DECLARE @tblCFNumericVehicle TABLE(
		 intVehicleId				int
		,strVehicleNumber			nvarchar(MAX)
		,intAccountId				int
		)

		DECLARE @tblCFCharVehicle TABLE(
			 intVehicleId				int
			,strVehicleNumber			nvarchar(MAX)
			,intAccountId				int
		)

		DECLARE @intVehicleId INT
	
		IF(@strVehicleNumber IS NOT NULL)
		BEGIN

			IF(ISNUMERIC(@strVehicleNumber) = 1)
			BEGIN

				--INT VEHICLE NUMBER--
				INSERT INTO @tblCFNumericVehicle(
						intVehicleId			
					,strVehicleNumber
					,intAccountId
				)	
				SELECT 
						intVehicleId			
					,strVehicleNumber	
					,intAccountId		
				FROM tblCFVehicle 
				WHERE strVehicleNumber not like '%[^0-9]%' and strVehicleNumber != ''
				AND intAccountId = @intAccountId

				SET @intVehicleId =
				(SELECT TOP 1 intVehicleId
				FROM @tblCFNumericVehicle
				WHERE CAST(strVehicleNumber AS BIGINT) = CAST(@strVehicleNumber AS BIGINT))


			END
			ELSE
			BEGIN
					--CHAR VEHICLE NUMBER--
					INSERT INTO @tblCFCharVehicle(
						 intVehicleId			
						,strVehicleNumber
						,intAccountId
					)	
					SELECT 
						 intVehicleId			
						,strVehicleNumber	
						,intAccountId		
					FROM tblCFVehicle WHERE strVehicleNumber like '%[^0-9]%' and strVehicleNumber != ''
					AND intAccountId = @intAccountId

					SET @intVehicleId =
					(SELECT TOP 1 intVehicleId
					FROM @tblCFNumericVehicle
					WHERE strVehicleNumber = @strVehicleNumber)

				END
		END
		
	--CHECK IF VEHICLE EXIST--
		SET @strErrorRecordId = 'vehicle - ' + @strVehicleNumber
		IF(ISNULL(@intVehicleId,0) = 0)
		BEGIN
			SET @strAction = 'addvehicle'
		END
		ELSE
		BEGIN
			SET @strAction = 'editvehicle'
		END
	--CHECK IF VEHICLE EXIST--
	END


	

	----------------------VALIDATIONS-----------------------
	IF(@intSycnType = 1)
	BEGIN

		DECLARE @ysnCardStatus BIT = 0
		IF(ISNULL(@strCardStatus,'') != '')
		BEGIN
			IF(@strCardStatus = 'V')
			BEGIN
				SET @ysnCardStatus = 1
			END
			ELSE IF(@strCardStatus = 'I')
			BEGIN
				SET @ysnCardStatus = 0
			END
			ELSE
			BEGIN
				print 'Invalid card status'
				INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
					,'Invalid card status' as strMessage
					,@strErrorRecordId
					,@dtmImportDate
				RETURN
			END
		END
		ELSE
		BEGIN
			print 'Invalid card status'
		INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Invalid card status' as strMessage
				,@strErrorRecordId
				,@dtmImportDate
			RETURN
		END


		DECLARE @intProductAuthCode AS INT = 0
		DECLARE @tblCFNumericProdAuth TABLE(
			 intProductAuthId			int
			,strNetworkGroupNumber			nvarchar(MAX)
		)
		DECLARE @tblCFCharProdAuth TABLE(
			 intProductAuthId			int
			,strNetworkGroupNumber			nvarchar(MAX)
		)
		IF(ISNULL(@strProductAuthCode,'') != '')
		BEGIN
			IF(ISNUMERIC(@strProductAuthCode) = 1)
			BEGIN
				INSERT INTO @tblCFNumericProdAuth(
					intProductAuthId			
					,strNetworkGroupNumber
				)	
				SELECT 
					 intProductAuthId			
					,strNetworkGroupNumber	
				FROM tblCFProductAuth 
				WHERE strNetworkGroupNumber not like '%[^0-9]%' and strNetworkGroupNumber != ''
				AND intNetworkId = @intNetworkId

				SET @intProductAuthCode =
				(SELECT TOP 1 intProductAuthId
				FROM @tblCFNumericProdAuth
				WHERE CAST(strNetworkGroupNumber AS BIGINT) = CAST(@strProductAuthCode AS BIGINT))
				
			END
			ELSE
			BEGIN
				INSERT INTO @tblCFCharProdAuth(
					 intProductAuthId			
					,strNetworkGroupNumber
				)	
				SELECT 
					 intProductAuthId			
					,strNetworkGroupNumber	
				FROM tblCFProductAuth  WHERE strNetworkGroupNumber like '%[^0-9]%' and strNetworkGroupNumber != ''
				AND intNetworkId = @intNetworkId

				SET @intProductAuthCode =
				(SELECT TOP 1 intProductAuthId
				FROM @tblCFCharProdAuth
				WHERE strNetworkGroupNumber = @strProductAuthCode)

			END
		END
		ELSE
		BEGIN 
			print 'Invalid product auth'
		INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Invalid product auth' as strMessage
				,@strErrorRecordId
				,@dtmImportDate

			SET @intProductAuthCode = NULL
			--RETURN
		END
		IF(ISNULL(@intProductAuthCode,0) = 0)
		BEGIN
			print 'Cannot find product auth'
			INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Cannot find product auth ' + @strProductAuthCode as strMessage
				,@strErrorRecordId
				,@dtmImportDate

			SET @intProductAuthCode = NULL
			--RETURN
		END


		DECLARE @d		varchar(8)
		DECLARE @m		varchar(2)
		DECLARE @yr		varchar(4)
		DECLARE @day	varchar(2)
		IF(ISNULL(@dtmExpirationDate,'') != '')
		BEGIN
			SET @d = @dtmExpirationDate 
			SET @day = '01' 
			SET @m = SUBSTRING(@d,3,2) 
			SET @yr = '20' + SUBSTRING(@d,1,2) 
	
			SET @dtmExpirationDate = CONVERT(datetime,(@m +'/'+ @day +'/'+ @yr)) 
		END
		ELSE
		BEGIN
			print 'Invalid expiration date'
			INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Invalid expiration date' as strMessage
				,@strErrorRecordId
				,@dtmImportDate
			RETURN
		END


		IF (ISNULL(@strNetworkParticipantId,'') NOT LIKE '%'+ISNULL(@strParticipantNumber,'')+'%' )
		BEGIN
			print 'Participant id not match'
			INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
				,'Participant id not match' as strMessage
				,@strErrorRecordId
				,@dtmImportDate
		
			RETURN
		END

	END
	----------------------VALIDATIONS-----------------------



	---------------------DEFAULTS---------------------
	SET @dtmImportDate = Convert(varchar(30),@strImportDate,102)
	
	---------------------DEFAULTS---------------------

	IF(@strAction = 'addcard')
	BEGIN
		
		BEGIN TRY 
		BEGIN TRANSACTION
			DECLARE @intAddCardIdentity INT
			DELETE FROM tblCFTempCSUAuditLog

			INSERT INTO tblCFCard
			(
 				 intAccountId
				,strCardNumber
				,intEntryCode
				,ysnActive
				,dtmIssueDate
				,strCardDescription
				,dtmCardExpiratioYearMonth
				,intCardLimitedCode
				,intProductAuthId
				,strCardPinNumber
				,intNetworkId
				,ysnCardForOwnUse				
				,ysnIgnoreCardTransaction		
				,ysnCardLocked		
			)
			SELECT
				 @intAccountId
				,@strCardNumber
				,@intManualEntryCode
				,@ysnCardStatus
				,GETDATE()
				,@strLabel
				,@dtmExpirationDate
				,@strLimitCode
				,@intProductAuthCode
				,@strPINNumber
				,@intNetworkId
				,0		
				,0		
				,0


			SET @intAddCardIdentity = SCOPE_IDENTITY()

			INSERT INTO tblCFTempCSUCard
			(
				 intCardId
				,intNetworkId
				,strCardNumber
				,strCardDescription
				,intAccountId
				,intProductAuthId
				,intEntryCode
				,strCardXReference
				,strCardForOwnUse
				,intExpenseItemId
				,intDefaultFixVehicleNumber
				,intDepartmentId
				,dtmLastUsedDated
				,intCardTypeId
				,dtmIssueDate
				,ysnActive
				,ysnCardLocked
				,strCardPinNumber
				,dtmCardExpiratioYearMonth
				,strCardValidationCode
				,intNumberOfCardsIssued
				,intCardLimitedCode
				,intCardFuelCode
				,strCardTierCode
				,strCardOdometerCode
				,strCardWCCode
				,strSplitNumber
				,intCardManCode
				,intCardShipCat
				,intCardProfileNumber
				,intCardPositionSite
				,intCardvehicleControl
				,intCardCustomPin
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnIgnoreCardTransaction
				,strComment
			)
			SELECT TOP 1
				 intCardId
				,intNetworkId
				,strCardNumber
				,ISNULL(strCardDescription,'')
				,intAccountId
				,intProductAuthId
				,intEntryCode
				,strCardXReference
				,strCardForOwnUse
				,intExpenseItemId
				,intDefaultFixVehicleNumber
				,intDepartmentId
				,dtmLastUsedDated
				,intCardTypeId
				,dtmIssueDate
				,ysnActive
				,ysnCardLocked
				,strCardPinNumber
				,dtmCardExpiratioYearMonth
				,strCardValidationCode
				,intNumberOfCardsIssued
				,intCardLimitedCode
				,intCardFuelCode
				,strCardTierCode
				,strCardOdometerCode
				,strCardWCCode
				,strSplitNumber
				,intCardManCode
				,intCardShipCat
				,intCardProfileNumber
				,intCardPositionSite
				,intCardvehicleControl
				,intCardCustomPin
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnIgnoreCardTransaction
				,strComment
			FROM tblCFCard 
			WHERE intCardId = @intAddCardIdentity
			INSERT INTO tblCFCSUAuditLog
			(
				 strSessionId
				,intPK
				,strType
				,strTableName
				,strFieldName
				,strOldValue
				,strNewValue
				,dtmUpdateDate
				,strUserName
				,strRecord
				,strAccountNumber
			)
			SELECT 
				 @strSessionId
				 ,intPK
				 ,strType
				 ,strTableName
				 ,strFieldName
				 ,strOldValue
				 ,strNewValue
				 ,@dtmImportDate
				 ,strUserName	
				 ,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
				,@strAccountNumber
			FROM 
			tblCFTempCSUAuditLog

			DELETE FROM tblCFTempCSUAuditLog
			DELETE FROM tblCFTempCSUCard


		COMMIT TRANSACTION
		END TRY 

		BEGIN CATCH

		print ERROR_MESSAGE()

		ROLLBACK TRANSACTION
		END CATCH


	END


	IF(@strAction = 'editcard')
	BEGIN
		
		BEGIN TRY 
		BEGIN TRANSACTION

			INSERT INTO tblCFTempCSUCard
			(
				 intCardId
				,intNetworkId
				,strCardNumber
				,strCardDescription
				,intAccountId
				,intProductAuthId
				,intEntryCode
				,strCardXReference
				,strCardForOwnUse
				,intExpenseItemId
				,intDefaultFixVehicleNumber
				,intDepartmentId
				,dtmLastUsedDated
				,intCardTypeId
				,dtmIssueDate
				,ysnActive
				,ysnCardLocked
				,strCardPinNumber
				,dtmCardExpiratioYearMonth
				,strCardValidationCode
				,intNumberOfCardsIssued
				,intCardLimitedCode
				,intCardFuelCode
				,strCardTierCode
				,strCardOdometerCode
				,strCardWCCode
				,strSplitNumber
				,intCardManCode
				,intCardShipCat
				,intCardProfileNumber
				,intCardPositionSite
				,intCardvehicleControl
				,intCardCustomPin
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnIgnoreCardTransaction
				,strComment
			)
			SELECT TOP 1
				 intCardId
				,intNetworkId
				,strCardNumber
				,ISNULL(strCardDescription,'')
				,intAccountId
				,intProductAuthId
				,intEntryCode
				,strCardXReference
				,strCardForOwnUse
				,intExpenseItemId
				,intDefaultFixVehicleNumber
				,intDepartmentId
				,dtmLastUsedDated
				,intCardTypeId
				,dtmIssueDate
				,ysnActive
				,ysnCardLocked
				,strCardPinNumber
				,dtmCardExpiratioYearMonth
				,strCardValidationCode
				,intNumberOfCardsIssued
				,intCardLimitedCode
				,intCardFuelCode
				,strCardTierCode
				,strCardOdometerCode
				,strCardWCCode
				,strSplitNumber
				,intCardManCode
				,intCardShipCat
				,intCardProfileNumber
				,intCardPositionSite
				,intCardvehicleControl
				,intCardCustomPin
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnIgnoreCardTransaction
				,strComment
			FROM tblCFCard 
			WHERE strCardNumber = @strCardNumber
			AND intAccountId = @intAccountId

			DELETE FROM tblCFTempCSUAuditLog


			UPDATE tblCFTempCSUCard SET 
			 strCardNumber				   = @strCardNumber
			,intEntryCode				   = @intManualEntryCode
			,ysnActive					   = @ysnCardStatus
			,strCardDescription			   = @strLabel
			,dtmCardExpiratioYearMonth	   = @dtmExpirationDate
			,intCardLimitedCode			   = @strLimitCode
			,intProductAuthId			   = @intProductAuthCode
			,strCardPinNumber			   = @strPINNumber
			WHERE strCardNumber = @strCardNumber

			UPDATE tblCFCard SET 
			 strCardNumber				   = @strCardNumber
			,intEntryCode				   = @intManualEntryCode
			,ysnActive					   = @ysnCardStatus
			,strCardDescription			   = @strLabel
			,dtmCardExpiratioYearMonth	   = @dtmExpirationDate
			,intCardLimitedCode			   = @strLimitCode
			,intProductAuthId			   = @intProductAuthCode
			,strCardPinNumber			   = @strPINNumber
			WHERE strCardNumber = @strCardNumber

			INSERT INTO tblCFCSUAuditLog
			(
				 strSessionId
				,intPK
				,strType
				,strTableName
				,strFieldName
				,strOldValue
				,strNewValue
				,dtmUpdateDate
				,strUserName
				,strRecord
				,strAccountNumber
			)
			SELECT 
				 @strSessionId
				 ,intPK
				 ,strType
				 ,strTableName
				 ,strFieldName
				 ,strOldValue
				 ,strNewValue
				 ,@dtmImportDate
				 ,strUserName	
				 ,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
				,@strAccountNumber
			FROM 
			tblCFTempCSUAuditLog

			DELETE FROM tblCFTempCSUAuditLog
			DELETE FROM tblCFTempCSUCard


		COMMIT TRANSACTION
		END TRY 

		BEGIN CATCH

		ROLLBACK TRANSACTION
		END CATCH

	END
	

	IF(@strAction = 'addvehicle')
	BEGIN
		
		BEGIN TRY 
		BEGIN TRANSACTION
			DECLARE @intAddVehicleIdentity INT
			DELETE FROM tblCFTempCSUAuditLog

			INSERT INTO tblCFVehicle
			(
 				 intAccountId
				,strVehicleNumber
				,strVehicleDescription
			)
			SELECT
				 @intAccountId
				,@strVehicleNumber
				,@strLabel

			SET @intAddVehicleIdentity = SCOPE_IDENTITY()

			INSERT INTO tblCFTempCSUVehicle
			(
				 intVehicleId
				,intAccountId
				,strVehicleNumber
				,strCustomerUnitNumber
				,strVehicleDescription
				,intDaysBetweenService
				,intMilesBetweenService
				,intLastReminderOdometer
				,dtmLastReminderDate
				,dtmLastServiceDate
				,intLastServiceOdometer
				,strNoticeMessageLine1
				,strNoticeMessageLine2
				,strVehicleForOwnUse
				,intExpenseItemId
				,strLicencePlateNumber
				,strDepartment
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnActive
				,intDepartmentId
			)
			SELECT TOP 1
				 intVehicleId
				,intAccountId
				,strVehicleNumber
				,strCustomerUnitNumber
				,strVehicleDescription
				,intDaysBetweenService
				,intMilesBetweenService
				,intLastReminderOdometer
				,dtmLastReminderDate
				,dtmLastServiceDate
				,intLastServiceOdometer
				,strNoticeMessageLine1
				,strNoticeMessageLine2
				,strVehicleForOwnUse
				,intExpenseItemId
				,strLicencePlateNumber
				,strDepartment
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnActive
				,intDepartmentId
			FROM tblCFVehicle 
			WHERE intVehicleId = @intAddVehicleIdentity


			INSERT INTO tblCFCSUAuditLog
			(
				 strSessionId
				,intPK
				,strType
				,strTableName
				,strFieldName
				,strOldValue
				,strNewValue
				,dtmUpdateDate
				,strUserName
				,strRecord
				,strAccountNumber
			)
			SELECT 
				 @strSessionId
				 ,intPK
				 ,strType
				 ,strTableName
				 ,strFieldName
				 ,strOldValue
				 ,strNewValue
				 ,@dtmImportDate
				 ,strUserName	
				 ,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
				,@strAccountNumber
			FROM 
			tblCFTempCSUAuditLog

			DELETE FROM tblCFTempCSUAuditLog
			DELETE FROM tblCFTempCSUVehicle


		COMMIT TRANSACTION
		END TRY 

		BEGIN CATCH

		print ERROR_MESSAGE()

		ROLLBACK TRANSACTION
		END CATCH

	END

	IF(@strAction = 'editvehicle')
	BEGIN

	BEGIN TRY 
		BEGIN TRANSACTION

		INSERT INTO tblCFTempCSUVehicle
			(
				 intVehicleId
				,intAccountId
				,strVehicleNumber
				,strCustomerUnitNumber
				,strVehicleDescription
				,intDaysBetweenService
				,intMilesBetweenService
				,intLastReminderOdometer
				,dtmLastReminderDate
				,dtmLastServiceDate
				,intLastServiceOdometer
				,strNoticeMessageLine1
				,strNoticeMessageLine2
				,strVehicleForOwnUse
				,intExpenseItemId
				,strLicencePlateNumber
				,strDepartment
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnActive
				,intDepartmentId
			)
			SELECT TOP 1
				 intVehicleId
				,intAccountId
				,strVehicleNumber
				,strCustomerUnitNumber
				,strVehicleDescription
				,intDaysBetweenService
				,intMilesBetweenService
				,intLastReminderOdometer
				,dtmLastReminderDate
				,dtmLastServiceDate
				,intLastServiceOdometer
				,strNoticeMessageLine1
				,strNoticeMessageLine2
				,strVehicleForOwnUse
				,intExpenseItemId
				,strLicencePlateNumber
				,strDepartment
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,intConcurrencyId
				,dtmLastModified
				,ysnCardForOwnUse
				,ysnActive
				,intDepartmentId
			FROM tblCFVehicle 
			WHERE intVehicleId = @intVehicleId
			AND intAccountId = @intAccountId

		--SELECT * FROM tblCFTempCSUVehicle

		DELETE FROM tblCFTempCSUAuditLog

		UPDATE tblCFTempCSUVehicle SET 
		 strVehicleNumber		= @strVehicleNumber
		,strVehicleDescription	= @strLabel
		WHERE intVehicleId = @intVehicleId

		UPDATE tblCFVehicle SET 
		 strVehicleNumber		= @strVehicleNumber
		,strVehicleDescription	= @strLabel
		WHERE intVehicleId = @intVehicleId

		INSERT INTO tblCFCSUAuditLog
		(
			strSessionId
			,intPK
			,strType
			,strTableName
			,strFieldName
			,strOldValue
			,strNewValue
			,dtmUpdateDate
			,strUserName
			,strRecord
			,strAccountNumber
		)
		SELECT 
			@strSessionId
			,intPK
			,strType
			,strTableName
			,strFieldName
			,strOldValue
			,strNewValue
			,@dtmImportDate
			,strUserName	
			,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
			,@strAccountNumber
		FROM 
		tblCFTempCSUAuditLog


		DELETE FROM tblCFTempCSUAuditLog
		DELETE FROM tblCFTempCSUVehicle


	COMMIT TRANSACTION
	END TRY 

	BEGIN CATCH

	INSERT INTO tblCFCSULog
			(
				 strAccountNumber
				,strCardNumber
				,strMessage
				,strRecordId
				,dtmUpdateDate

			)
			SELECT 
				 @strAccountNumber
				,@strCardNumber
		,ERROR_MESSAGE()
		,''
		,@dtmImportDate

	ROLLBACK TRANSACTION
	END CATCH

	END

END
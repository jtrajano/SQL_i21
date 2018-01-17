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
	,@dtmExpirationDate				DATETIME		 =	 NULL
	,@strSessionId					NVARCHAR(MAX)
	,@strImportDate					NVARCHAR(MAX)
	,@strNetworkParticipantId		NVARCHAR(MAX)	 =	 ''
	--,@intUserID


AS
BEGIN

	DECLARE @intAccountId			INT
	DECLARE @intSycnType			INT
	DECLARE @strAction				NVARCHAR(MAX)	 =	 ''
	DECLARE @dtmImportDate			DATETIME


	SET @dtmImportDate = Convert(varchar(30),@strImportDate,102)

	--VALIDATE ACCOUNT--
	IF(ISNULL(@strAccountNumber,'') != '')
	BEGIN
		SELECT TOP 1 @intAccountId = intAccountId FROM vyuCFAccountCustomer WHERE strCustomerNumber = @strAccountNumber
	END
	ELSE
	BEGIN
		print 'Invalid account number'
		INSERT INTO tblCFCSULog
		(
			 strAccountNumber
			,strMessage
			,strRecordId
			,dtmUpdateDate
		)
		SELECT 
			 @strAccountNumber
			,'Invalid account number' as strMessage
			,''
			,@dtmImportDate
		RETURN
	END
	
	
	IF(ISNULL(@intAccountId,0) = 0)
	BEGIN
		SELECT TOP 1 @intAccountId = intAccountId FROM tblCFNetworkAccount WHERE strNetworkAccountId = @strAccountNumber
	END


	IF(ISNULL(@intAccountId,0) = 0)
	BEGIN
		print 'Invalid account number'
		INSERT INTO tblCFCSULog
		(
			 strAccountNumber
			,strMessage
			,strRecordId
			,dtmUpdateDate
		)
		SELECT 
			 @strAccountNumber
			,'Invalid account number' as strMessage
			,''
			,@dtmImportDate
		RETURN
	END

	
	IF (ISNULL(@strNetworkParticipantId,'') != ISNULL(@strParticipantNumber,'') )
	BEGIN
		print 'Participant id not match'
		INSERT INTO tblCFCSULog
		(
			 strAccountNumber
			,strMessage
			,strRecordId
			,dtmUpdateDate
		)
		SELECT 
			 @strAccountNumber
			,'Participant id not match' as strMessage
			,''
			,@dtmImportDate
		
		RETURN
	END
	




	--VALIDATE ACCOUNT--


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
				,strMessage
				,strRecordId
				,dtmUpdateDate
			)
			SELECT 
				 @strAccountNumber
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
				,strMessage
				,strRecordId
				,dtmUpdateDate
			)
			SELECT 
				 @strAccountNumber
				,'Invalid card type' as strMessage
				,''
				,@dtmImportDate
		RETURN

	END
	--VALIDATE TYPE--


	IF(@intSycnType = 1)
	BEGIN
	--CHECK IF CARD EXIST--
		IF((SELECT COUNT(*) FROM tblCFCard where strCardNumber = @strCardNumber) = 0)
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
	--CHECK IF VEHICLE EXIST--
		IF((SELECT COUNT(*) FROM tblCFVehicle where strVehicleNumber = @strVehicleNumber) = 0)
		BEGIN
			SET @strAction = 'addvehicle'
		END
		ELSE
		BEGIN
			SET @strAction = 'editvehicle'
		END
	--CHECK IF VEHICLE EXIST--
	END



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
			)
			SELECT
				 @intAccountId
				,@strCardNumber
				,@intManualEntryCode
				,1
				,GETDATE()
				,@strLabel

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

			DELETE FROM tblCFTempCSUAuditLog

			UPDATE tblCFTempCSUCard SET 
			 strCardNumber = @strCardNumber
			,intEntryCode = @intManualEntryCode
			WHERE strCardNumber = @strCardNumber

			UPDATE tblCFCard SET 
			 strCardNumber = @strCardNumber
			,intEntryCode = @intManualEntryCode
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
			WHERE strVehicleNumber = @strVehicleNumber

		DELETE FROM tblCFTempCSUAuditLog

		UPDATE tblCFTempCSUVehicle SET 
		 strVehicleNumber		= @strVehicleNumber
		,strVehicleDescription	= @strVehicleDescription
		WHERE strVehicleNumber = @strVehicleNumber

		UPDATE tblCFVehicle SET 
		 strVehicleNumber		= @strVehicleNumber
		,strVehicleDescription	= @strVehicleDescription
		WHERE strVehicleNumber = @strVehicleNumber

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
		FROM 
		tblCFTempCSUAuditLog


		DELETE FROM tblCFTempCSUAuditLog
		DELETE FROM tblCFTempCSUVehicle


	COMMIT TRANSACTION
	END TRY 

	BEGIN CATCH

	INSERT INTO tblCFCSULog(
		 strAccountNumber
		,strMessage
		,strRecordId
		,dtmUpdateDate
	)
	SELECT 
		@strAccountNumber
		,ERROR_MESSAGE()
		,''
		,@dtmImportDate

	ROLLBACK TRANSACTION
	END CATCH

	END

END
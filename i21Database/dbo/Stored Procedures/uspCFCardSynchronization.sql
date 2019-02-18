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

	---------FIELD NAME SETUP---------
	
	DECLARE @tblCFEnumFieldName AS TABLE
	(
		 strOriginal nvarchar(50) COLLATE Latin1_General_CI_AS 
		,strModified nvarchar(50) COLLATE Latin1_General_CI_AS 
	)
	INSERT INTO @tblCFEnumFieldName
	(strOriginal,strModified)
	VALUES 
	----------VEHICLE FIELDS-----------
	('intVehicleId'					,'Vehicle')
	,('intAccountId'				,'Account')
	,('strVehicleNumber'			,'Vehicle Number')
	,('strCustomerUnitNumber'		,'Customer Unit Number')
	,('strVehicleDescription'		,'Vehicle Description')
	,('intDaysBetweenService'		,'Days Between Service')
	,('intMilesBetweenService'		,'Miles Between Service')
	,('intLastReminderOdometer'		,'Last Reminder Odometer')
	,('dtmLastReminderDate'			,'Last Reminder Date')
	,('dtmLastServiceDate'			,'Last Service Date')
	,('intLastServiceOdometer'		,'Last Service Odometer')
	,('strNoticeMessageLine1'		,'Notice Message Line 1')
	,('strNoticeMessageLine2'		,'Notice Message Line 2')
	,('strVehicleForOwnUse'			,'Vehicle For Own Use')
	,('intExpenseItemId'			,'Expense Item')
	,('strLicencePlateNumber'		,'Licence Plate Number')
	,('strDepartment'				,'Department')
	,('intCreatedUserId'			,'Created User')
	,('dtmCreated'					,'Created')
	,('intLastModifiedUserId'		,'Last Modified User')
	,('intConcurrencyId'			,'Concurrency')
	,('dtmLastModified'				,'Last Modified')
	,('ysnCardForOwnUse'			,'Card For Own Use')
	,('ysnActive'					,'Active')
	,('intDepartmentId'				,'Department')
	,('strComment'					,'Comment')
	----------CARD FIELDS-----------
	,('intCardId'					,'Card')
	,('intNetworkId'				,'Network')
	,('strCardNumber'				,'Card Number')
	,('strCardDescription'			,'Card Description')
	,('intAccountId'				,'Account')
	,('intProductAuthId'			,'Product Auth')
	,('intEntryCode'				,'Entry Code')
	,('strCardXReference'			,'Card X Reference')
	,('strCardForOwnUse'			,'Card For OwnUse')
	,('intExpenseItemId'			,'Expense Item')
	,('intDefaultFixVehicleNumber'	,'Default Vehicle Number')
	,('intDepartmentId'				,'Department')
	,('dtmLastUsedDated'			,'Last Used Dated')
	,('intCardTypeId'				,'Card Type')
	,('dtmIssueDate'				,'Issue Date')
	,('ysnActive'					,'Active')
	,('ysnCardLocked'				,'Card Locked')
	,('strCardPinNumber'			,'Card Pin Number')
	,('dtmCardExpiratioYearMonth'	,'Card Expiratio Year Month')
	,('strCardValidationCode'		,'Card Validation Code')
	,('intNumberOfCardsIssued'		,'Number Of Cards Issued')
	,('intCardLimitedCode'			,'Card Limited Code')
	,('intCardFuelCode'				,'Card Fuel Code')
	,('strCardTierCode'				,'CardTier Code')
	,('strCardOdometerCode'			,'Card OdometerCode')
	,('strCardWCCode'				,'Card WC Code')
	,('strSplitNumber'				,'Split Number')
	,('intCardManCode'				,'Card Man Code')
	,('intCardShipCat'				,'Card Ship Cat')
	,('intCardProfileNumber'		,'Card Profile Number')
	,('intCardPositionSite'			,'Card Position Site')
	,('intCardvehicleControl'		,'Card Vehicle Control')
	,('intCardCustomPin'			,'Card Custom Pin')
	,('intCreatedUserId'			,'Created User')
	,('dtmCreated'					,'Created')
	,('intLastModifiedUserId'		,'Last Modified User')
	,('intConcurrencyId'			,'Concurrency Id')
	,('dtmLastModified'				,'Last Modified')
	,('ysnCardForOwnUse'			,'Card For Own Use')
	,('ysnIgnoreCardTransaction'	,'Ignore Card Transaction')
	,('strComment'					,'Comment')
	,('intDefaultDriverPin'			,'Default Driver Pin')
		---------FIELD NAME SETUP---------

	DECLARE @intAccountId			INT
	DECLARE @intSycnType			INT
	DECLARE @strAction				NVARCHAR(MAX)	 =	 ''
	DECLARE @dtmImportDate			DATETIME
	DECLARE @ysnIsVehicleNumeric	BIT 
	DECLARE @strNetwork				NVARCHAR(MAX)	 =   ''
	

	SELECT TOP 1 @strNetwork = strNetwork FROM tblCFNetwork WHERE intNetworkId = @intNetworkId

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

			DELETE FROM @tblCFNumericAccount
			IF(ISNULL(@intAccountId,0) = 0)
			BEGIN
				INSERT INTO @tblCFNumericAccount(
				 intAccountId		
				,strAccountNumber	
				)
				SELECT 
					 intAccountId			
					,strNetworkAccountId	
				FROM tblCFNetworkAccount 
				WHERE strNetworkAccountId not like '%[^0-9]%' and strNetworkAccountId != ''


				SET @intAccountId =
				(SELECT TOP 1 intAccountId
				FROM @tblCFNumericAccount
				WHERE CAST(strAccountNumber AS BIGINT) = CAST(@strAccountNumber AS BIGINT))

			END
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

			DELETE FROM @tblCFCharAccount
			IF(ISNULL(@intAccountId,0) = 0)
			BEGIN
				INSERT INTO @tblCFCharAccount(
					intAccountId		
					,strAccountNumber	
				)
					SELECT 
					 intAccountId			
					,strNetworkAccountId	
				FROM tblCFNetworkAccount 
				WHERE strNetworkAccountId like '%[^0-9]%' and strNetworkAccountId != ''


				SET @intAccountId =
				(SELECT TOP 1 intAccountId
				FROM @tblCFCharAccount
				WHERE strAccountNumber = @strAccountNumber)

			END

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
		print 'Cannot find account number'
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
			,'Cannot find account number ' + @strAccountNumber as strMessage
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


	DECLARE @ysnCardExist BIT = 0
	DECLARE @intCardAccountId INT = 0

	IF(@intSycnType = 1)
	BEGIN
	--CHECK IF CARD EXIST--
		SET @strErrorRecordId = 'card - ' + @strCardNumber

		SELECT  @intCardAccountId = intAccountId FROM tblCFCard where strCardNumber = @strCardNumber
		IF(ISNULL(@intCardAccountId,0) != 0)
		BEGIN
			SET @ysnCardExist = 1
		END

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

		--CF-1934--
		IF(LEN(@strVehicleNumber) < 4)
		BEGIN
			SET @strVehicleNumber = LEFT(replicate('0', (4 - LEN(@strVehicleNumber))) + @strVehicleNumber, 4) 
		END

	
		IF(@strVehicleNumber IS NOT NULL)
		BEGIN

			IF(ISNUMERIC(@strVehicleNumber) = 1)
			BEGIN

				IF(CAST(@strVehicleNumber AS BIGINT) = 0)
				BEGIN
					print 'Invalid vehicle number'
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
							,'Invalid vehicle number ' + @strVehicleNumber  as strMessage
							,@strErrorRecordId
							,@dtmImportDate

					RETURN
				END

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

		IF(ISNULL(@ysnCardExist,0) = 1)
		BEGIN
			DECLARE @strCardExistError NVARCHAR(MAX)
			DECLARE @strCardCustomer NVARCHAR(MAX)
			
			SELECT TOP 1 @strCardCustomer = strCustomerNumber FROM vyuCFAccountCustomer WHERE intAccountId = @intCardAccountId

			IF(@intAccountId != @intCardAccountId)
			BEGIN
				SET @strCardExistError = 'Card ' + @strCardNumber + ' already exists for another Customer ' + @strCardCustomer + ' and cannot be added/changed'
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
					,@strCardExistError as strMessage
					,@strErrorRecordId
					,@dtmImportDate

				RETURN
			END
		END

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
	ELSE
	BEGIN
	DECLARE @ysnVehicleStatus BIT = 0
		IF(ISNULL(@strCardStatus,'') != '')
		BEGIN
			IF(@strCardStatus = 'V')
			BEGIN
				SET @ysnVehicleStatus = 1
			END
			ELSE IF(@strCardStatus = 'I')
			BEGIN
				SET @ysnVehicleStatus = 0
			END
			ELSE
			BEGIN
				print 'Invalid vehicle status'
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
				,@strVehicleNumber
					,'Invalid vehicle status' as strMessage
					,@strErrorRecordId
					,@dtmImportDate
				RETURN
			END
		END
		ELSE
		BEGIN
			print 'Invalid vehicle status'
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
				,@strVehicleNumber
				,'Invalid vehicle status' as strMessage
				,@strErrorRecordId
				,@dtmImportDate
			RETURN
		END
	END
	----------------------VALIDATIONS-----------------------



	---------------------DEFAULTS---------------------
	SET @dtmImportDate = Convert(varchar(30),@strImportDate,102)
	DECLARE @intNetworkCardType  NVARCHAR(MAX)
	
	---------------------DEFAULTS---------------------

	IF(@strAction = 'addcard')
	BEGIN
		
		BEGIN TRY 
		BEGIN TRANSACTION
			DECLARE @intAddCardIdentity INT

			SELECT TOP 1 @intNetworkCardType = intCardTypeId FROM tblCFCardType WHERE intNetworkId = @intNetworkId AND strCSUCardType = @strCardType

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
				,intCardTypeId
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
				,@intNetworkCardType


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
				,intNetworkId
				,strNetwork
				,strRawOldValue
				,strRawNewValue
			)
			SELECT 
				 @strSessionId
				 ,intPK
				 ,strType
				 ,strTableName
				 ,strFieldName =  (SELECT TOP 1 ISNULL(strModified,strFieldName) FROM @tblCFEnumFieldName WHERE strOriginal = strFieldName)
				 ,strOldValue = (CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strOldValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strOldValue  = 0 THEN 'No'
								WHEN strOldValue  = 1 THEN 'Yes'
								ELSE strOldValue
							 END)
					ELSE strOldValue
				END)
				 ,strNewValue = (CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strNewValue  = 0 THEN 'No'
								WHEN strNewValue  = 1 THEN 'Yes'
								ELSE strNewValue
							 END)
					ELSE strNewValue
				 END)
				 ,@dtmImportDate
				 ,strUserName	
				 ,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
				,@strAccountNumber
				,@intNetworkId
				,@strNetwork
				,strOldValue
				,strNewValue

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

			SELECT TOP 1 @intNetworkCardType = intCardTypeId FROM tblCFCardType WHERE intNetworkId = @intNetworkId AND strCSUCardType = @strCardType

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
			,intCardTypeId				   = @intNetworkCardType
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
			,intCardTypeId				   = @intNetworkCardType
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
				,intNetworkId
				,strNetwork
				,strRawOldValue
				,strRawNewValue
				
			)
			SELECT 
				 @strSessionId
				 ,intPK
				 ,strType
				 ,strTableName
				 ,strFieldName =  (SELECT TOP 1 ISNULL(strModified,strFieldName) FROM @tblCFEnumFieldName WHERE strOriginal = strFieldName)
				 ,strOldValue = (CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strOldValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strOldValue  = 0 THEN 'No'
								WHEN strOldValue  = 1 THEN 'Yes'
								ELSE strOldValue
							 END)
					ELSE strOldValue
				END)
				, strNewValue = CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strNewValue  = 0 THEN 'No'
								WHEN strNewValue  = 1 THEN 'Yes'
								ELSE strNewValue
							 END)
					ELSE strNewValue
				END
				 ,@dtmImportDate
				 ,strUserName	
				 ,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
				,@strAccountNumber
				,@intNetworkId
				,@strNetwork
				,strOldValue
				,strNewValue

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
				,ysnActive
			)
			SELECT
				 @intAccountId
				,@strVehicleNumber
				,@strLabel
				,@ysnVehicleStatus

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
				,intNetworkId
				,strNetwork
				,strRawOldValue
				,strRawNewValue
			)
			SELECT 
				 @strSessionId
				 ,intPK
				 ,strType
				 ,strTableName
				 ,strFieldName =  (SELECT TOP 1 ISNULL(strModified,strFieldName) FROM @tblCFEnumFieldName WHERE strOriginal = strFieldName)
				 ,strOldValue = (CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strOldValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strOldValue  = 0 THEN 'No'
								WHEN strOldValue  = 1 THEN 'Yes'
								ELSE strOldValue
							 END)
					ELSE strOldValue
				END)
				, strNewValue = CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strNewValue  = 0 THEN 'No'
								WHEN strNewValue  = 1 THEN 'Yes'
								ELSE strNewValue
							 END)
					ELSE strNewValue
				END
				 ,@dtmImportDate
				 ,strUserName	
				 ,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
				,@strAccountNumber
				,@intNetworkId
				,@strNetwork
				,strOldValue
				,strNewValue
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


		DELETE FROM tblCFTempCSUAuditLog

		UPDATE tblCFTempCSUVehicle SET 
		 strVehicleNumber		= @strVehicleNumber
		,strVehicleDescription	= @strLabel
		,ysnActive				= @ysnVehicleStatus
		WHERE intVehicleId = @intVehicleId

		UPDATE tblCFVehicle SET 
		 strVehicleNumber		= @strVehicleNumber
		,strVehicleDescription	= @strLabel
		,ysnActive				= @ysnVehicleStatus
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
			,intNetworkId
			,strNetwork
			,strRawOldValue
			,strRawNewValue
		)
		SELECT 
			@strSessionId
			,intPK
			,strType
			,strTableName
			,strFieldName =  (SELECT TOP 1 ISNULL(strModified,strFieldName) FROM @tblCFEnumFieldName WHERE strOriginal = strFieldName)
			,strOldValue = (CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strOldValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CONVERT(INT,ISNULL(strOldValue,0)))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strOldValue  = 0 THEN 'No'
								WHEN strOldValue  = 1 THEN 'Yes'
								ELSE strOldValue
							 END)
					ELSE strOldValue
				END)
				, strNewValue = CASE
					WHEN strFieldName = 'intNetworkId'
						THEN (SELECT TOP 1 strNetwork + '-' + strNetworkDescription FROM tblCFNetwork WHERE intNetworkId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intAccountId'
						THEN (SELECT TOP 1 strEntityNo + ' - ' + strName FROM tblCFAccount as acct
							  INNER JOIN tblEMEntity as ent
							  ON acct.intCustomerId = ent.intEntityId WHERE intAccountId =  CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intProductAuthId'
						THEN (SELECT TOP 1 strNetworkGroupNumber + '-' + strDescription FROM tblCFProductAuth WHERE intProductAuthId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intExpenseItemId'
						THEN (SELECT TOP 1 strItemNo + '-' + strShortName FROM tblICItem WHERE intItemId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultFixVehicleNumber'
						THEN (SELECT TOP 1 strVehicleNumber + '-' + strVehicleDescription FROM tblCFVehicle WHERE intVehicleId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDepartmentId'
						THEN (SELECT TOP 1 strDepartment + '-' + strDepartmentDescription FROM tblCFDepartment WHERE intDepartmentId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intCardTypeId'
						THEN (SELECT TOP 1 strCardType + '-' + strDescription FROM tblCFCardType WHERE intCardTypeId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName = 'intDefaultDriverPin'
						THEN (SELECT TOP 1 strDriverPinNumber + '-' + strDriverDescription FROM tblCFDriverPin WHERE intDriverPinId = CAST(ISNULL(strNewValue,0) AS int))
					WHEN strFieldName like 'ysn%'
						THEN (CASE
								WHEN strNewValue  = 0 THEN 'No'
								WHEN strNewValue  = 1 THEN 'Yes'
								ELSE strNewValue
							 END)
					ELSE strNewValue
				END
			,@dtmImportDate
			,strUserName	
			,strRecord = CASE
							WHEN strTableName = 'tblCFCard' 
							THEN (SELECT TOP 1 strCardNumber FROM tblCFCard WHERE intCardId = intPK)
							WHEN strTableName = 'tblCFVehicle'
							THEN (SELECT TOP 1 strVehicleNumber FROM tblCFVehicle WHERE intVehicleId = intPK)
						END
			,@strAccountNumber
			,@intNetworkId
			,@strNetwork
			,strOldValue
			,strNewValue
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
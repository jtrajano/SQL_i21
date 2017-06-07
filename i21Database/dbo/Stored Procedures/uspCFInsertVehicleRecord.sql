CREATE PROCEDURE [dbo].[uspCFInsertVehicleRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------

	 @strAccountId					NVARCHAR(MAX)	 =	 ''
	,@strExpenseItemId				NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@strVehicleNumber				NVARCHAR(MAX)	 =	 ''
	,@strCustomerUnitNumber			NVARCHAR(MAX)	 =	 ''
	,@strVehicleDescription			NVARCHAR(MAX)	 =	 ''
	,@strLicencePlateNumber			NVARCHAR(MAX)	 =	 ''
	,@ysnCardForOwnUse				NVARCHAR(MAX)	 =	 'N'
	,@ysnActive						NVARCHAR(MAX)	 =	 'Y'
	,@strNoticeMessageLine1			NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@dtmLastReminderDate			DATETIME		 =	 NULL
	,@dtmLastServiceDate			DATETIME		 =	 NULL
	---------------------------------------------------------
	,@intLastServiceOdometer		INT				 =	 0
	,@intDaysBetweenService			INT				 =	 0
	,@intMilesBetweenService		INT				 =	 0
	,@intLastReminderOdometer		INT				 =	 0
	---------------------------------------------------------

AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicateCard					      INT = 0
	---------------------------------------------------------
	DECLARE @intVehicleId							  INT = 0
	DECLARE @intAccountId							  INT = 0
	DECLARE @intExpenseItemId						  INT = 0
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strVehicleNumber = NULL OR @strVehicleNumber = '')
	BEGIN
		SET @strVehicleNumber = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strVehicleNumber,'Vehicle number is required')
		SET @ysnHasError = 1
	END
	IF(@strAccountId = NULL OR @strAccountId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strVehicleNumber,'Account is required')
		SET @ysnHasError = 1
	END
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	

	--IF(@ysnHasError = 1)
	--BEGIN
	--	RETURN
	--END

	---------------------------------------------------------
	--				VALID VALUE TO OTHER TABLE		       --
	---------------------------------------------------------

	--Account
	IF (@strAccountId != '')
		BEGIN 
			SELECT @intAccountId = CFAcc.intAccountId
			FROM tblARCustomer as ARCus
			INNER JOIN tblCFAccount as CFAcc
			ON ARCus.[intEntityId] = CFAcc.intCustomerId
			WHERE strCustomerNumber = @strAccountId
			IF (@intAccountId = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strVehicleNumber,'Unable to find match for '+ @strAccountId +' on account list')
				SET @ysnHasError = 1
			END
			ELSE
			BEGIN
				---------------------------------------------------------
				--			      DUPLICATE VEHICLE NUMBER				   --
				---------------------------------------------------------
				SELECT @intDuplicateCard = COUNT(*) FROM tblCFVehicle WHERE strVehicleNumber = @strVehicleNumber AND intAccountId = @intAccountId 
				IF (@intDuplicateCard > 0)
				BEGIN
					INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
					VALUES (@strVehicleNumber,'Duplicate vehicle for '+ @strVehicleNumber)
					SET @ysnHasError = 1
				END
	
				---------------------------------------------------------
			END
		END
	ELSE
		BEGIN
			SET @intAccountId = NULL
		END


	--Expense Item
	IF (@strExpenseItemId != '')
		BEGIN 
			SELECT @intExpenseItemId = intItemId  
			FROM tblICItem
			WHERE strItemNo = @strExpenseItemId
			IF (@intExpenseItemId = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strVehicleNumber,'Unable to find match for '+ @strExpenseItemId +' on item list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intExpenseItemId = NULL
		END

	---------------------------------------------------------
	
	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--Active
	IF (@ysnCardForOwnUse = 'N')
		BEGIN 
			SET @ysnCardForOwnUse = 0
		END
	ELSE IF (@ysnCardForOwnUse = 'Y')
		BEGIN
			SET @ysnCardForOwnUse = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strVehicleNumber,'Invalid card for own use '+ @ysnCardForOwnUse +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


		IF (@ysnActive = 'N')
		BEGIN 
			SET @ysnActive = 0
		END
	ELSE IF (@ysnActive = 'Y')
		BEGIN
			SET @ysnActive = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strVehicleNumber,'Invalid card for own use '+ @ysnActive +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				INSERT ACCOUNT RECORD			       --		
	---------------------------------------------------------
	BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO tblCFVehicle(
				 intAccountId
				,strVehicleNumber
				,strCustomerUnitNumber
				,strVehicleDescription
				,strLicencePlateNumber
				,ysnCardForOwnUse
				,intExpenseItemId
				,intDaysBetweenService
				,intMilesBetweenService
				,intLastReminderOdometer
				,dtmLastReminderDate
				,dtmLastServiceDate
				,intLastServiceOdometer
				,strNoticeMessageLine1
				,ysnActive)
			VALUES(
				 @intAccountId
				,@strVehicleNumber
				,@strCustomerUnitNumber
				,@strVehicleDescription
				,@strLicencePlateNumber
				,@ysnCardForOwnUse
				,@intExpenseItemId
				,@intDaysBetweenService
				,@intMilesBetweenService
				,@intLastReminderOdometer
				,@dtmLastReminderDate
				,@dtmLastServiceDate
				,@intLastServiceOdometer
				,@strNoticeMessageLine1
				,@ysnActive)

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strVehicleNumber,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
		
END
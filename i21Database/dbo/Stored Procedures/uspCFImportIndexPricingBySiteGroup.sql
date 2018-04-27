CREATE PROCEDURE [dbo].[uspCFImportIndexPricingBySiteGroup]
	
	 @strPriceIndex					NVARCHAR(MAX)	 =	 ''
	,@strSiteGroup					NVARCHAR(MAX)	 =	 ''
	,@strDate						NVARCHAR(MAX)	 =	 ''
	,@strItemNumber					NVARCHAR(MAX)	 =	 ''
	,@strPrice						NVARCHAR(MAX)	 =	 ''
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
	DECLARE @intDepartmentId						  INT = 0
	DECLARE @strAccountId		NVARCHAR(30)
	DECLARE @strVehicleNumber	NVARCHAR(30)
	DECLARE @strDepartment		NVARCHAR(30)
	DECLARE @strExpenseItemId		NVARCHAR(30)
	DECLARE @ysnCardForOwnUse BIT
     
	DECLARE @strCustomerUnitNumber NVARCHAR(30)
	DECLARE @strVehicleDescription NVARCHAR(30)
	DECLARE @strLicencePlateNumber NVARCHAR(30)

	DECLARE @intDaysBetweenService INT = 0
	DECLARE @intMilesBetweenService INT = 0
	DECLARE @intLastReminderOdometer INT = 0
	DECLARE @dtmLastReminderDate DATETIME
	DECLARE @dtmLastServiceDate DATETIME
	DECLARE @intLastServiceOdometer INT = 0
	DECLARE @strNoticeMessageLine1 NVARCHAR(30)
	DECLARE @ysnActive BIT 
	---------------------------------------------------------



	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strPriceIndex = NULL OR @strPriceIndex = '')
	BEGIN
		SET @strPriceIndex = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Price Index is required')
		SET @ysnHasError = 1
	END
	IF(@strSiteGroup = NULL OR @strSiteGroup = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Site Group is required')
		SET @ysnHasError = 1
	END
	IF(@strDate = NULL OR @strDate = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strDate,'Date is required')
		SET @ysnHasError = 1
	END
	IF(@strItemNumber = NULL OR @strItemNumber = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemNumber,'Item NUmber is required')
		SET @ysnHasError = 1
	END
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	
	---------------------------------------------------------
	--				VALID VALUE TO OTHER TABLE		       --
	---------------------------------------------------------

	--Account
	IF (@strSiteGroup != '')
		BEGIN 
			SELECT @strSiteGroup = CFAcc.intAccountId
			FROM tblCF as ARCus
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


	--Department
	IF (@strDepartment != '' AND @intAccountId > 0)
	BEGIN 
		SELECT @intDepartmentId = ISNULL(intDepartmentId ,0)
		FROM tblCFDepartment 
		WHERE strDepartment = @strDepartment AND intAccountId = @intAccountId

		IF (@intDepartmentId = 0)
		BEGIN
			INSERT tblCFDepartment (intAccountId,strDepartment)
			VALUES (@intAccountId,@strDepartment)
			SET @intDepartmentId = SCOPE_IDENTITY()
		END
	END
	ELSE
	BEGIN
		SET @intDepartmentId = NULL
	END
	
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
				,ysnActive
				,intDepartmentId)
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
				,@ysnActive
				,@intDepartmentId)

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
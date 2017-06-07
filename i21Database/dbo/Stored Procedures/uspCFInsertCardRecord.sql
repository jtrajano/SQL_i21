CREATE PROCEDURE [dbo].[uspCFInsertCardRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	 @strNetworkId					NVARCHAR(MAX)	 =	 ''
	,@strAccountId					NVARCHAR(MAX)	 =	 ''
	,@strExpenseItemId				NVARCHAR(MAX)	 =	 ''
	,@strDefaultFixVehicleNumber	NVARCHAR(MAX)	 =	 ''
	,@strDepartmentId				NVARCHAR(MAX)	 =	 ''
	,@strCardTypeId					NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@strCardNumber					NVARCHAR(MAX)	 =	 ''
	,@strCardDescription			NVARCHAR(MAX)	 =	 ''
	,@strCardValidationCode			NVARCHAR(MAX)	 =	 ''
	,@strCardPinNumber				NVARCHAR(MAX)	 =	 ''
	,@strCardTierCode				NVARCHAR(MAX)	 =	 ''
	,@strCardOdometerCode			NVARCHAR(MAX)	 =	 ''
	,@strCardWCCode					NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@dtmIssueDate					DATETIME		 =	 NULL
	,@dtmCardExpiratioYearMonth		DATETIME		 =	 NULL
	,@dtmLastUsedDated				DATETIME		 =	 NULL
	---------------------------------------------------------
	,@ysnActive						NVARCHAR(MAX)	 =	 'N'
	,@ysnCardForOwnUse				NVARCHAR(MAX)	 =	 'N'
	,@ysnIgnoreCardTransaction		NVARCHAR(MAX)	 =	 'N'
	,@ysnCardLocked					NVARCHAR(MAX)	 =	 'N'
	---------------------------------------------------------
	,@intNumberOfCardsIssued		INT				 =	 0
	,@intCardLimitedCode			INT				 =	 0
	,@intCardFuelCode				INT				 =	 0
	---------------------------------------------------------
	,@intEntryCode					INT				 =	 0
	,@strProductAuthorization		NVARCHAR(MAX)	 =	 ''
	,@strComment					NVARCHAR(MAX)	 =	 ''

AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicateCard					      INT = 0
	---------------------------------------------------------
	DECLARE @intNetworkId							  INT = 0
	DECLARE @intAccountId							  INT = 0
	DECLARE @intExpenseItemId						  INT = 0
	DECLARE @intDefaultFixVehicleNumber				  INT = 0
	DECLARE @intDepartmentId						  INT = 0
	DECLARE @intCardTypeId							  INT = 0
	DECLARE @intCardId								  INT = 0
	DECLARE @intProductAuthId						  INT = 0
	---------------------------------------------------------



	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	IF(@intEntryCode < 0 OR @intEntryCode > 7)
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCardNumber,'Invalid entry code')
		SET @ysnHasError = 1
	END

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strCardNumber = NULL OR @strCardNumber = '')
	BEGIN
		SET @strCardNumber = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCardNumber,'Card number is required')
		SET @ysnHasError = 1
	END
	IF(@strAccountId = NULL OR @strAccountId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCardNumber,'Account is required')
		SET @ysnHasError = 1
	END
	IF(@strNetworkId = NULL OR @strNetworkId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCardNumber,'Network is required')
		SET @ysnHasError = 1
	END
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--			      DUPLICATE CARD NUMBER				   --
	---------------------------------------------------------
	--Customer
	SELECT  @intCardId = intCardId 
	FROM tblCFCard 
	WHERE strCardNumber = @strCardNumber
	
	
	SELECT @intDuplicateCard = COUNT(*) FROM tblCFCard WHERE strCardNumber = @strCardNumber
	IF (@intDuplicateCard > 0)
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCardNumber,'Duplicate card for '+ @strCardNumber)
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

	--Network
	IF (@strNetworkId != '')
	BEGIN 
		SELECT @intNetworkId = intNetworkId 
		FROM tblCFNetwork 
		WHERE strNetwork = @strNetworkId
		IF (@intNetworkId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Unable to find match for '+ @strNetworkId +' on network list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intNetworkId = NULL
	END

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
			VALUES (@strCardNumber,'Unable to find match for '+ @strAccountId +' on account list')
			SET @ysnHasError = 1
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
			VALUES (@strCardNumber,'Unable to find match for '+ @strExpenseItemId +' on item list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intExpenseItemId = NULL
	END

	--Vehicle Number
	IF (@strDefaultFixVehicleNumber != '')
	BEGIN 
		SELECT @intDefaultFixVehicleNumber = intVehicleId 
		FROM tblCFVehicle 
		WHERE strVehicleNumber = @strDefaultFixVehicleNumber
		IF (@intDefaultFixVehicleNumber = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Unable to find match for '+ @strDefaultFixVehicleNumber +' on vehicle list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intDefaultFixVehicleNumber = NULL
	END

	--Product Authorization
	IF (@strProductAuthorization != '')
	BEGIN 
		SELECT @intProductAuthId = intProductAuthId 
		FROM tblCFProductAuth 
		WHERE strNetworkGroupNumber = @strProductAuthorization
		IF (@intProductAuthId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Unable to find match for '+ @strProductAuthorization +' on product authorization list')
			--SET @ysnHasError = 1
			SET @intProductAuthId = NULL
		END
	END
	ELSE
	BEGIN
		SET @intProductAuthId = NULL
	END

	--Department
	IF (@strDepartmentId != '' AND @intAccountId > 0)
	BEGIN 
		SELECT @intDepartmentId = intDepartmentId 
		FROM tblCFDepartment 
		WHERE strDepartment = @strDepartmentId AND intAccountId = @intAccountId

		IF (@intDepartmentId = 0)
		BEGIN
			INSERT tblCFDepartment (intAccountId,strDepartment)
			VALUES (@intAccountId,@strDepartmentId)
			SET @intDepartmentId = SCOPE_IDENTITY()
		END
	END
	ELSE
	BEGIN
		SET @intDepartmentId = NULL
	END

	--Card Type
	IF (@strCardTypeId != '')
	BEGIN 
		SELECT @intCardTypeId = intCardTypeId 
		FROM tblCFCardType 
		WHERE strCardType = @strCardTypeId
		IF (@intCardTypeId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Unable to find match for '+ @strCardTypeId +' on card type list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intCardTypeId = NULL
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
			VALUES (@strCardNumber,'Invalid card active value'+ @ysnActive +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Card For Own Use
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
			VALUES (@strCardNumber,'Invalid card for own use value '+ @ysnCardForOwnUse +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Ignored Card Transaction
	IF (@ysnIgnoreCardTransaction = 'N')
		BEGIN 
			SET @ysnIgnoreCardTransaction = 0
		END
	ELSE IF (@ysnIgnoreCardTransaction = 'Y')
		BEGIN
			SET @ysnIgnoreCardTransaction = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Invalid ignored card transaction value '+ @ysnIgnoreCardTransaction +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Summary by miscellaneous
	IF (@ysnCardLocked = 'N')
		BEGIN 
			SET @ysnCardLocked = 0
		END
	ELSE IF (@ysnCardLocked = 'Y')
		BEGIN
			SET @ysnCardLocked = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Invalid card locked value '+ @ysnCardLocked +'. Value should be Y or N only')
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

			INSERT INTO tblCFCard(
			  intNetworkId					
			 ,intAccountId					
			 ,intExpenseItemId				
			 ,intDefaultFixVehicleNumber	
			 ,intDepartmentId				
			 ,intCardTypeId					
			 ,strCardNumber					
			 ,strCardDescription			
			 ,strCardValidationCode			
			 ,strCardPinNumber				
			 ,strCardTierCode				
			 ,strCardOdometerCode			
			 ,strCardWCCode					
			 ,dtmIssueDate					
			 ,dtmCardExpiratioYearMonth		
			 ,dtmLastUsedDated				
			 ,ysnActive						
			 ,ysnCardForOwnUse				
			 ,ysnIgnoreCardTransaction		
			 ,ysnCardLocked					
			 ,intNumberOfCardsIssued		
			 ,intCardLimitedCode			
			 ,intCardFuelCode
			 ,intEntryCode
			 ,strComment
			 ,intProductAuthId
			 )
			VALUES(
			  @intNetworkId					
			 ,@intAccountId					
			 ,@intExpenseItemId				
			 ,@intDefaultFixVehicleNumber	
			 ,@intDepartmentId				
			 ,@intCardTypeId					
			 ,@strCardNumber					
			 ,@strCardDescription			
			 ,@strCardValidationCode			
			 ,@strCardPinNumber				
			 ,@strCardTierCode				
			 ,@strCardOdometerCode			
			 ,@strCardWCCode					
			 ,@dtmIssueDate					
			 ,@dtmCardExpiratioYearMonth		
			 ,@dtmLastUsedDated				
			 ,@ysnActive						
			 ,@ysnCardForOwnUse				
			 ,@ysnIgnoreCardTransaction		
			 ,@ysnCardLocked					
			 ,@intNumberOfCardsIssued		
			 ,@intCardLimitedCode			
			 ,@intCardFuelCode
			 ,@intEntryCode
			 ,@strComment
			 ,@intProductAuthId
			 )

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCardNumber,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
		
END
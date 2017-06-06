
CREATE  PROCEDURE [dbo].[uspCFInsertItemRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	
	 @strItemCode					NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@strNetworkId					NVARCHAR(MAX)	 =	 ''
	,@strSite						NVARCHAR(MAX)	 =	 ''
	,@strARItem						NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@strDescription				NVARCHAR(MAX)	 =	 ''

	,@strIncludeInQuantityDiscount	NVARCHAR(MAX)	 =	 'N'
	,@strMPGCalculation				NVARCHAR(MAX)	 =	 'N'
	,@strChargeOregonP				NVARCHAR(MAX)	 =	 'N'
	,@strCarryNegligibleBalance		NVARCHAR(MAX)	 =	 'N'
	---------------------------------------------------------


AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicateItem					      INT = 0
	---------------------------------------------------------
	DECLARE @intNetworkId							  INT = 0
	DECLARE @intARItemId							  INT = 0
	DECLARE @intSiteId								  INT = 0
	---------------------------------------------------------
	DECLARE @ysnIncludeInQuantityDiscount			  BIT = 0
	DECLARE @ysnMPGCalculation						  BIT = 0
	DECLARE @ysnChargeOregonP						  BIT = 0
	DECLARE @ysnCarryNegligibleBalance				  BIT = 0
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strItemCode = NULL OR @strItemCode = '')
	BEGIN
		SET @strItemCode = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemCode,'Item code is required')
		SET @ysnHasError = 1
	END
	IF(@strNetworkId = NULL OR @strNetworkId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemCode,'Network is required')
		SET @ysnHasError = 1
	END
	IF(@strARItem = NULL OR @strARItem = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemCode,'AR Item is required')
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
	IF (@strNetworkId != '')
		BEGIN 
			
			SELECT TOP 1 @intNetworkId = intNetworkId
			FROM tblCFNetwork 
			WHERE strNetwork = @strNetworkId
			
			IF (@intNetworkId = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strItemCode,'Unable to find match for '+ @strNetworkId +' on network list')
				SET @ysnHasError = 1
			END
			ELSE
			BEGIN
				---------------------------------------------------------
				--			      DUPLICATE VEHICLE NUMBER				   --
				---------------------------------------------------------
				SELECT @intDuplicateItem = COUNT(*) FROM tblCFItem WHERE strProductNumber = @strItemCode AND intNetworkId = @intNetworkId 
				IF (@intDuplicateItem > 0)
				BEGIN
					INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
					VALUES (@strItemCode,'Duplicate item for '+ @strItemCode)
					SET @ysnHasError = 1
				END
	
				---------------------------------------------------------
			END
		END
	ELSE
		BEGIN
			SET @intNetworkId = NULL
		END


	--AR Item
	IF (@strARItem != '')
		BEGIN 
			SELECT @strARItem = intItemId  
			FROM tblICItem
			WHERE strItemNo = @strARItem
			IF (@intARItemId = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strItemCode,'Unable to find match for '+ @strARItem +' on item list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intARItemId = NULL
		END

	---------------------------------------------------------
	
	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--Carry negligible balance
	IF (@strCarryNegligibleBalance = 'N')
		BEGIN 
			SET @ysnCarryNegligibleBalance = 0
		END
	ELSE IF (@strCarryNegligibleBalance = 'Y')
		BEGIN
			SET @ysnCarryNegligibleBalance = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strItemCode,'Invalid carry negligible balance '+ @strCarryNegligibleBalance +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


	--Charge oregon PUC on remotes
	IF (@strChargeOregonP = 'N')
		BEGIN 
			SET @ysnChargeOregonP = 0
		END
	ELSE IF (@strChargeOregonP = 'Y')
		BEGIN
			SET @ysnChargeOregonP = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strItemCode,'Invalid charge oregon PUC on remotes '+ @strChargeOregonP +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


	--Include in quantity discount
	IF (@strIncludeInQuantityDiscount = 'N')
		BEGIN 
			SET @ysnIncludeInQuantityDiscount = 0
		END
	ELSE IF (@strIncludeInQuantityDiscount = 'Y')
		BEGIN
			SET @ysnIncludeInQuantityDiscount = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strItemCode,'Invalid include in quantity discount '+ @strIncludeInQuantityDiscount +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


	--Include in quantity discount
	IF (@strMPGCalculation = 'N')
		BEGIN 
			SET @ysnMPGCalculation = 0
		END
	ELSE IF (@strMPGCalculation = 'Y')
		BEGIN
			SET @ysnMPGCalculation = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strItemCode,'Invalid MPG calculation '+ @strMPGCalculation +'. Value should be Y or N only')
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

			INSERT INTO tblCFItem(
				 intNetworkId
				,intSiteId
				,strProductNumber
				,intARItemId
				,strProductDescription
				,ysnCarryNegligibleBalance
				,ysnIncludeInQuantityDiscount
				,ysnMPGCalculation
				,ysnChargeOregonP
				)
			VALUES(
				  @intNetworkId
				 ,@intSiteId
				 ,@strItemCode
				 ,@intARItemId
				 ,@strDescription
				 ,@ysnCarryNegligibleBalance
				 ,@ysnIncludeInQuantityDiscount
				 ,@ysnMPGCalculation
				 ,@ysnChargeOregonP
				 )

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strItemCode,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
		
END
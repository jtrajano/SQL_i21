CREATE PROCEDURE [dbo].[uspCFInsertItemRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
              
      @strItemCode						NVARCHAR(MAX)	 =	 ''
     ,@strNetworkId						NVARCHAR(MAX)	 =	 ''
     ,@strSite							NVARCHAR(MAX)	 =	 ''
     ,@strARItem						NVARCHAR(MAX)	 =	 ''
     ,@strDescription					NVARCHAR(MAX)	 =	 ''
     ,@strIncludeInQuantityDiscount		NVARCHAR(MAX)	 =	 ''
     ,@strMPGCalculation				NVARCHAR(MAX)	 =	 ''
     ,@strChargeOregonP					NVARCHAR(MAX)	 =	 ''
     ,@strCarryNegligibleBalance		NVARCHAR(MAX)	 =	 ''

AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0

	DECLARE @intDuplicateItem					      INT = 0

	DECLARE @ysnIncludeInQuantityDiscount			  BIT = 0
	DECLARE @ysnMPGCalculation						  BIT = 0
	DECLARE @ysnChargeOregonP						  BIT = 0
	DECLARE @ysnCarryNegligibleBalance				  BIT = 0
	---------------------------------------------------------
	DECLARE @intNetworkId							  INT = 0
	DECLARE @intSiteId								  INT = 0
	DECLARE @intARItem								  INT = 0
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strItemCode = NULL OR @strItemCode = '')
	BEGIN
		SET @strSite = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemCode,'Item is required')
		SET @ysnHasError = 1
	END

	IF(@strNetworkId = NULL OR @strNetworkId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strNetworkId,'Network is required')
		SET @ysnHasError = 1
	END

	IF(@strARItem = NULL OR @strARItem = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strARItem,'AR Item is required')
		SET @ysnHasError = 1
	END

	--IF(@strSite = NULL OR @strSite = '')
	--BEGIN
	--	INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
	--	VALUES (@strSite,'Site number is required')
	--	SET @ysnHasError = 1
	--END
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

	--@strNetworkId
	IF (@strNetworkId != '')
		BEGIN 
			SELECT @intNetworkId = n.intNetworkId
			FROM tblCFNetwork as n
			WHERE strNetwork = @strNetworkId

			IF (ISNULL(@intNetworkId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strItemCode,'Unable to find match for '+ @strNetworkId +' on network list')
				SET @ysnHasError = 1
			END


			SELECT @intSiteId = s.intSiteId
			FROM tblCFSite as s
			WHERE strSiteNumber = @strSite AND intNetworkId = @intNetworkId

			IF (ISNULL(@intSiteId,0) = 0)
			BEGIN
				IF(ISNULL(@strSite,'') != '')
				BEGIN
					INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
					VALUES (@strItemCode,'Unable to find match for '+ @strSite +' on site list')
					SET @ysnHasError = 1
				END
			END


			--ELSE

			--BEGIN

				---------------------------------------------------------
				--			      DUPLICATE VEHICLE NUMBER				   --
				---------------------------------------------------------
				SELECT @intDuplicateItem = COUNT(*) FROM tblCFItem WHERE ISNULL(intSiteId,0) = @intSiteId AND intNetworkId = @intNetworkId AND strProductNumber = @strItemCode
				IF (@intDuplicateItem > 0)
				BEGIN
					INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
					VALUES (@strItemCode,'Duplicate item for '+ @strItemCode)
					SET @ysnHasError = 1
				END
	
				---------------------------------------------------------
			--END
		END
	ELSE
		BEGIN
			SET @intNetworkId = NULL
		END


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	--strARItem
	IF (@strARItem != '')
		BEGIN 
			SELECT @intARItem = intItemId  
			FROM tblICItem
			WHERE strItemNo = @strARItem
			IF (@intARItem = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strItemCode,'Unable to find match for '+ @strARItem +' on AR Item list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intARItem = NULL
		END

	---------------------------------------------------------

	
	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--@Include In Quantity Discount
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
			VALUES (@strItemCode,'Invalid Include In Quantity Discount '+ @strIncludeInQuantityDiscount +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--MPG Calculation
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
			VALUES (@strItemCode,'Invalid MPG Calculation '+ @strMPGCalculation +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Charge Oregon P
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
			VALUES (@strItemCode,'Invalid Charge Oregon P '+ @strChargeOregonP +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Carry Negligible Balance
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
			VALUES (@strItemCode,'Invalid Carry Negligible Balance '+ @strCarryNegligibleBalance +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				INSERT ACCOUNT RECORD			       --		
	---------------------------------------------------------
	BEGIN TRANSACTION
		BEGIN TRY

			IF(@intSiteId = 0)
			BEGIN
				SET @intSiteId = NULL
			END

			INSERT INTO tblCFItem
			(
				 strProductNumber					
				,intNetworkId					
				,intSiteId						
				,intARItemId					
				,strProductDescription				
				,ysnIncludeInQuantityDiscount	
				,ysnMPGCalculation			
				,ysnChargeOregonP				
				,ysnCarryNegligibleBalance	
	        )
			VALUES
			(
				 @strItemCode					
				,@intNetworkId					
				,@intSiteId						
				,@intARItem					
				,@strDescription				
				,@ysnIncludeInQuantityDiscount	
				,@ysnMPGCalculation			
				,@ysnChargeOregonP				
				,@ysnCarryNegligibleBalance	
			)

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
		
			ROLLBACK TRANSACTION

			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strItemCode,'SQL Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			RETURN 0
		END CATCH
		
END
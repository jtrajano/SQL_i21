CREATE PROCEDURE [dbo].[uspCFInsertDiscountScheduleRecord]
	
	-----------------------------------------
	--				PARAMETERS			   --
	-----------------------------------------
	 @strDiscountSchedule			NVARCHAR(MAX)	 =	 ''
	,@strDescription				NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@ysnDiscountOnRemotes			NVARCHAR(MAX)	 =	 ''
	,@ysnDiscountOnExtRemotes		NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@intFromQty					INT				 =    0
	,@intThruQty					INT				 =    0
	,@dblRate						NUMERIC(18,6)	 =    0
	,@ysnShowOnCFInvoice			NVARCHAR(MAX)	 =	 ''

AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicate						      INT = 0
	DECLARE @intId								      INT
	---------------------------------------------------------



	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	IF(@strDiscountSchedule IS NULL OR @strDiscountSchedule = '')
	BEGIN
		SET @strDiscountSchedule = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strDiscountSchedule,'Dicount Code is required')
		SET @ysnHasError = 1
	END

	IF(@strDescription IS NULL OR @strDescription = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strDiscountSchedule,'Description is required')
		SET @ysnHasError = 1
	END

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--Discount on Remote
	IF (@ysnDiscountOnRemotes = 'N')
		BEGIN 
			SET @ysnDiscountOnRemotes = 0
		END
	ELSE IF (@ysnDiscountOnRemotes = 'Y' OR @ysnDiscountOnRemotes IS NULL OR @ysnDiscountOnRemotes = '')
		BEGIN
			SET @ysnDiscountOnRemotes = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strDiscountSchedule,'Invalid discount on remotes value'+ @ysnDiscountOnRemotes +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Discount on Ext Remote
	IF (@ysnDiscountOnExtRemotes = 'N')
		BEGIN 
			SET @ysnDiscountOnExtRemotes = 0
		END
	ELSE IF (@ysnDiscountOnExtRemotes = 'Y' OR @ysnDiscountOnExtRemotes IS NULL OR @ysnDiscountOnExtRemotes = '')
		BEGIN
			SET @ysnDiscountOnExtRemotes = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strDiscountSchedule,'Invalid discount on ext remotes value'+ @ysnDiscountOnExtRemotes +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

		--Discount on Ext Remote
	IF (@ysnShowOnCFInvoice = 'N')
		BEGIN 
			SET @ysnShowOnCFInvoice = 0
		END
	ELSE IF (@ysnShowOnCFInvoice = 'Y' OR @ysnShowOnCFInvoice IS NULL OR @ysnShowOnCFInvoice = '')
		BEGIN
			SET @ysnShowOnCFInvoice = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strDiscountSchedule,'Invalid show on cf invoice value'+ @ysnShowOnCFInvoice +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


		
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END


	SELECT TOP 1 @intId = intDiscountScheduleId 
	FROM tblCFDiscountSchedule 
	WHERE strDiscountSchedule = @strDiscountSchedule

	IF(@intId IS NOT NULL AND @intId > 0)
	BEGIN
		IF (@intFromQty = 0 AND @intThruQty = 0 AND (@dblRate = 0 OR @dblRate = 0.0))
		BEGIN
			RETURN 1
		END
		----------------------------------------------------------
		--				INSERT DISCOUNT SCHEDULE RECORD			--		
		----------------------------------------------------------
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO tblCFDiscountScheduleDetail(
				 intDiscountScheduleId
				,intFromQty
				,intThruQty
				,dblRate
			 )
			VALUES(
				 @intId
				,@intFromQty
				,@intThruQty
				,@dblRate
			 )
			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strDiscountSchedule,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
	END
	ELSE
	BEGIN
		----------------------------------------------------------
		--				INSERT DISCOUNT SCHEDULE RECORD			--		
		----------------------------------------------------------
		BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO tblCFDiscountSchedule(
				 strDiscountSchedule
				,strDescription
				,ysnDiscountOnRemotes
				,ysnDiscountOnExtRemotes
				,ysnShowOnCFInvoice
			 )
			VALUES(
				 @strDiscountSchedule
				,@strDescription
				,@ysnDiscountOnRemotes
				,@ysnDiscountOnExtRemotes
				,@ysnShowOnCFInvoice
			 )

			SET @intId = SCOPE_IDENTITY()

			INSERT INTO tblCFDiscountScheduleDetail(
				intDiscountScheduleId
				,intFromQty
				,intThruQty
				,dblRate
				)
			VALUES(
				@intId
				,@intFromQty
				,@intThruQty
				,@dblRate
				)

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strDiscountSchedule,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
	END
END
GO



CREATE PROCEDURE [dbo].[uspCFInsertFactorTaxGroupXRefRecord]
	
	-----------------------------------------
	--				PARAMETERS			   --
	-----------------------------------------
	 @strCustomerNumber				NVARCHAR(MAX)	 =	 ''
	,@strCategoryId					NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@strSiteId						NVARCHAR(MAX)	 =	 ''
	,@strFactorTaxGroup				NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@strAltAccount					NVARCHAR(MAX)	 =	 ''
	,@strState						NVARCHAR(MAX)	 =	 ''

AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicate						      INT = 0
	DECLARE @intId								      INT
	DECLARE @strGUID								  NVARCHAR(MAX)
	---------------------------------------------------------



	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	SET @strGUID = NEWID()

	IF(@strState IS NULL OR @strState = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strGUID,'State is required')
		SET @ysnHasError = 1
	END
	ELSE
	BEGIN
		SET @strGUID = @strState
	END


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--Customer
	DECLARE @intCustomerId INT
	IF (@strCustomerNumber IS NOT NULL AND @strCustomerNumber != '')
		BEGIN 

			SELECT TOP 1 @intCustomerId = intEntityId FROM vyuARCustomer WHERE strCustomerNumber = @strCustomerNumber 
			IF(ISNULL(@intCustomerId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strGUID,'Unable to find customer number '+ @strCustomerNumber)
				SET @ysnHasError = 1
			END
			
		END


	--Category
	DECLARE @intCategoryId INT
	IF (@strCategoryId IS NOT NULL AND @strCategoryId != '')
		BEGIN 

			SELECT TOP 1 @intCategoryId = intCategoryId FROM tblICCategory WHERE strCategoryCode = @strCategoryId 
			IF(ISNULL(@intCategoryId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strGUID,'Unable to find category '+ @strCategoryId)
				SET @ysnHasError = 1
			END
		END


	--Site
	DECLARE @intSiteId INT
	IF (@strSiteId IS NOT NULL AND @strSiteId != '')
		BEGIN 

			SELECT TOP 1 @intSiteId = intSiteId FROM tblCFSite WHERE strSiteNumber = @strSiteId 
			IF(ISNULL(@intSiteId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strGUID,'Unable to find site number '+ @strSiteId)
				SET @ysnHasError = 1
			END
		END

	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END


	--[intCustomerId]					INT NULL,
	--[intCategoryId]					INT NULL,
	--[intSiteId]						INT NULL,
 --   [strFactorTaxGroup]				NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
 --   [strAltAccount]					NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
 --   [strState]						NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
 --   [intConcurrencyId]				INT            CONSTRAINT [DF_tblCFFactorTaxGroupXRef_intConcurrencyId] DEFAULT ((1)) NULL,


	----------------------------------------------------------
	--				INSERT DISCOUNT SCHEDULE RECORD			--		
	----------------------------------------------------------
	BEGIN TRANSACTION

		BEGIN TRY
			INSERT INTO [tblCFFactorTaxGroupXRef](
				 [intCustomerId]
				,[intCategoryId]
				,[intSiteId]
				,[strFactorTaxGroup]
				,[strAltAccount]
				,[strState]
			 )
			VALUES(
				 @intCustomerId
				,@intCategoryId
				,@intSiteId
				,@strFactorTaxGroup
				,@strAltAccount
				,@strState
			 )
			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strGUID,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			RETURN 0
		END CATCH
	END





CREATE PROCEDURE [dbo].[uspCFInsertNetworkAccountRecord]
	
	-----------------------------------------
	--				PARAMETERS			   --
	-----------------------------------------
	 @strCustomerNumber				NVARCHAR(MAX)	 =	 ''
	,@strNetwork					NVARCHAR(MAX)	 =	 ''
	,@strAccountNumber				NVARCHAR(MAX)	 =	 ''

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

	IF(@strCustomerNumber IS NULL OR @strCustomerNumber = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerNumber,'Customer number is required')
		SET @ysnHasError = 1
	END
	ELSE
	BEGIN
		SET @strGUID = @strCustomerNumber
	END


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--Customer
	DECLARE @intAccountId INT
	IF (@strCustomerNumber IS NOT NULL AND @strCustomerNumber != '')
		BEGIN 

			SELECT TOP 1 @intAccountId = intAccountId FROM vyuCFAccountCustomer WHERE strCustomerNumber = @strCustomerNumber 
			IF(ISNULL(@intAccountId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strGUID,'Unable to find customer number '+ @strCustomerNumber)
				SET @ysnHasError = 1
			END
			
		END


	--@strNetwork
	DECLARE @intNetworkId INT
	IF (@strNetwork IS NOT NULL AND @strNetwork != '')
		BEGIN 

			SELECT TOP 1 @intNetworkId = intNetworkId FROM tblCFNetwork WHERE strNetwork = @strNetwork 
			IF(ISNULL(@intNetworkId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strGUID,'Unable to find network '+ @strNetwork)
				SET @ysnHasError = 1
			END
		END


	----Site
	--DECLARE @intSiteId INT
	--IF (@strSiteId IS NOT NULL AND @strSiteId != '')
	--	BEGIN 

	--		SELECT TOP 1 @intSiteId = intSiteId FROM tblCFSite WHERE strSiteNumber = @strSiteId 
	--		IF(ISNULL(@intSiteId,0) = 0)
	--		BEGIN
	--			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
	--			VALUES (@strGUID,'Unable to find site number '+ @strSiteId)
	--			SET @ysnHasError = 1
	--		END
	--	END

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
			INSERT INTO [tblCFNetworkAccount](
				 intAccountId
				,intNetworkId
				,strNetworkAccountId
			 )
			VALUES(
				 @intAccountId
				,@intNetworkId
				,@strAccountNumber
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


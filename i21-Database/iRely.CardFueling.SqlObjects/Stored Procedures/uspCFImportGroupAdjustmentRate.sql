CREATE PROCEDURE [dbo].[uspCFImportGroupAdjustmentRate]
	@strSiteGroup					NVARCHAR(MAX)	 =	 ''
	,@strItemNumber					NVARCHAR(MAX)	 =	 ''
	,@strPriceRuleGroup				NVARCHAR(MAX)	 =	 ''
	,@dtmDate						DATETIME	     =	 NULL
	,@dblRate					NUMERIC(18,6)	 =	 0
AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	---------------------------------------------------------
	DECLARE @intSiteGroupId							  INT = 0
	DECLARE @intItemId								  INT = 0
	DECLARE @intPriceRuleGroupId					  INT = NULL
	DECLARE @intSiteGroupPriceAdjustmentId			  INT = 0
	DECLARE @intSiteGroupPriceAdjustmentHeaderId		INT = 0
	
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	
	IF(@strSiteGroup = NULL OR @strSiteGroup = '')
	BEGIN
		SET @strSiteGroup = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteGroup,'Site Group is required')
		SET @ysnHasError = 1
	END
	IF(@dtmDate = NULL OR @dtmDate = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteGroup,'Date is required')
		SET @ysnHasError = 1
	END
	IF(@strItemNumber = NULL OR @strItemNumber = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemNumber,'Item Number is required')
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

	--Site Group
	IF (@strSiteGroup != '')
	BEGIN 
		SELECT @intSiteGroupId = intSiteGroupId
		FROM tblCFSiteGroup 
		WHERE strSiteGroup = @strSiteGroup

		IF (ISNULL(@intSiteGroupId,0) = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteGroup,'Unable to find match for '+ @strSiteGroup +' on site group list')
			SET @ysnHasError = 1
		END
	END
	
	--Product
	IF (@strItemNumber != '')
	BEGIN 
		SELECT @intItemId = intItemId
		FROM tblICItem 
		WHERE strItemNo = @strItemNumber

		IF (ISNULL(@intItemId,0) = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteGroup,'Unable to find match for '+ @strItemNumber +' on Item list')
			SET @ysnHasError = 1
		END
	END

	---Price Rule Group
	IF (@strPriceRuleGroup != '')
	BEGIN 
		SELECT @intPriceRuleGroupId = intPriceRuleGroupId
		FROM tblCFPriceRuleGroup 
		WHERE strPriceGroup = @strPriceRuleGroup

		IF (ISNULL(@intPriceRuleGroupId,0) = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteGroup,'Unable to find match for '+ @strPriceRuleGroup +' on Price Rule Group')
			SET @ysnHasError = 1
		END
	END

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	
	----- CHECK for Existing site group price adjustment header
	SELECT TOP 1 @intSiteGroupPriceAdjustmentHeaderId = intSiteGroupPriceAdjustmentHeaderId
	FROM tblCFSiteGroupPriceAdjustmentHeader
	WHERE intSiteGroupId = @intSiteGroupId
		AND DATEADD(dd, DATEDIFF(dd, 0,dtmEffectiveDate), 0) = DATEADD(dd, DATEDIFF(dd, 0,@dtmDate), 0)

	BEGIN TRANSACTION
	BEGIN TRY
		IF(ISNULL(@intSiteGroupPriceAdjustmentHeaderId,0) = 0)
		BEGIN
			-- INSERt HEader record
			INSERT INTO tblCFSiteGroupPriceAdjustmentHeader (
				intSiteGroupId
				,dtmEffectiveDate
			)
			SELECT 
				intSiteGroupId = @intSiteGroupId
				,dtmEffectiveDate = DATEADD(dd, DATEDIFF(dd, 0,@dtmDate), 0)
		
			SET @intSiteGroupPriceAdjustmentHeaderId = @@IDENTITY

			---Insert Detail
			INSERT INTO tblCFSiteGroupPriceAdjustment(
				intSiteGroupPriceAdjustmentHeaderId
				,intPriceGroupId
				,intARItemId
				,dblRate
			)
			SELECT 
				intSiteGroupPriceAdjustmentHeaderId = @intSiteGroupPriceAdjustmentHeaderId
				,intPriceGroupId = @intPriceRuleGroupId
				,intARItemId = @intItemId
				,dblRate = @dblRate
		END
		ELSE
		BEGIN

			----- CHECK for Existing price adjustment
			SELECT TOP 1 @intSiteGroupPriceAdjustmentId = intSiteGroupPriceAdjustmentId
			FROM tblCFSiteGroupPriceAdjustment
			WHERE intSiteGroupPriceAdjustmentHeaderId = @intSiteGroupPriceAdjustmentHeaderId
				AND intARItemId = @intItemId
				AND intPriceGroupId = @intPriceRuleGroupId


			IF(ISNULL(@intSiteGroupPriceAdjustmentId,0) <> 0)
			BEGIN
				UPDATE tblCFSiteGroupPriceAdjustment SET
					dblRate = @dblRate
				WHERE intSiteGroupPriceAdjustmentId = @intSiteGroupPriceAdjustmentId
			END
			ELSE
			BEGIN
				---Insert Detail
				INSERT INTO tblCFSiteGroupPriceAdjustment(
					intSiteGroupPriceAdjustmentHeaderId
					,intPriceGroupId
					,intARItemId
					,dblRate
				)
				SELECT 
					intSiteGroupPriceAdjustmentHeaderId = @intSiteGroupPriceAdjustmentHeaderId
					,intPriceGroupId = @intPriceRuleGroupId
					,intARItemId = @intItemId
					,dblRate = @dblRate
			END
		END
		COMMIT TRANSACTION
		RETURN 1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteGroup,'Internal Error - ' + ERROR_MESSAGE())
		SET @ysnHasError = 1
		RETURN 0
	END CATCH
END

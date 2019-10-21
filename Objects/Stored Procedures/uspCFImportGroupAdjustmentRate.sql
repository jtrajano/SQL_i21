CREATE PROCEDURE [dbo].[uspCFImportGroupAdjustmentRate]
	@intResult						INT				 OUT --- 0 = haserror, 1 = inserted, 2 = skipped, 3= updated
	,@strSiteGroup					NVARCHAR(MAX)	 =	 ''
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
	DECLARE @intSiteGroupPriceAdjustmentIdSameRate			  INT = 0
	DECLARE @dblOldRate									NUMERIC(18,6)	 =	 0
	
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
		SET @intResult = 0
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
		SET @intResult = 0
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

			SET @intResult = 1
		END
		ELSE
		BEGIN


			----- CHECK for Existing price adjustment For same rate
			SELECT TOP 1 @intSiteGroupPriceAdjustmentIdSameRate = intSiteGroupPriceAdjustmentId
			FROM tblCFSiteGroupPriceAdjustment
			WHERE intSiteGroupPriceAdjustmentHeaderId = @intSiteGroupPriceAdjustmentHeaderId
				AND intARItemId = @intItemId
				AND intPriceGroupId = @intPriceRuleGroupId
				AND dblRate = @dblRate
	
			IF(ISNULL(@intSiteGroupPriceAdjustmentIdSameRate,0) <> 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteGroup,'Duplicate record/Same price - Skipped')
				ROLLBACK TRANSACTION
				SET @intResult = 2
				RETURN 
			END
			

			----- CHECK for Existing price adjustment
			SELECT TOP 1 
				@intSiteGroupPriceAdjustmentId = intSiteGroupPriceAdjustmentId
				,@dblOldRate = dblRate
			FROM tblCFSiteGroupPriceAdjustment
			WHERE intSiteGroupPriceAdjustmentHeaderId = @intSiteGroupPriceAdjustmentHeaderId
				AND intARItemId = @intItemId
				AND intPriceGroupId = @intPriceRuleGroupId


			IF(ISNULL(@intSiteGroupPriceAdjustmentId,0) <> 0)
			BEGIN
				UPDATE tblCFSiteGroupPriceAdjustment SET
					dblRate = @dblRate
				WHERE intSiteGroupPriceAdjustmentId = @intSiteGroupPriceAdjustmentId
				SET @intResult = 3

				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteGroup,'Item Rate for - ' + @strItemNumber + ' is changed from ' + CAST(@dblOldRate AS NVARCHAR(30)) + ' to ' + CAST(@dblRate AS NVARCHAR(30)))
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

				SET @intResult = 1
			END
		END
		COMMIT TRANSACTION
		RETURN 
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteGroup,'Internal Error - ' + ERROR_MESSAGE())
		SET @ysnHasError = 1
		RETURN 0
	END CATCH
END

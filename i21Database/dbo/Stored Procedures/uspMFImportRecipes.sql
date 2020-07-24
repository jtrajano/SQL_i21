CREATE PROCEDURE [dbo].[uspMFImportRecipes] @strSessionId NVARCHAR(50) = ''
	,@strImportType NVARCHAR(50)
	,@intUserId INT = 1
	,@ysnMinOneInputItemRequired BIT = 0
AS
DECLARE @intMinId INT
DECLARE @intItemId INT
DECLARE @intVersionNo INT
DECLARE @strRecipeName NVARCHAR(250)
DECLARE @strItemNo NVARCHAR(50)
DECLARE @intLocationId INT
DECLARE @strLocationName NVARCHAR(50)
DECLARE @intRecipeId INT
DECLARE @intRecipeDetailItemId INT
DECLARE @strRecipeDetailItemNo NVARCHAR(50)
DECLARE @intRecipeItemId INT
DECLARE @intRecipeTypeId INT
DECLARE @intSubstituteItemId INT
DECLARE @strSubstituteItemNo NVARCHAR(50)
DECLARE @intRecipeSubstituteItemId INT
DECLARE @intCustomerId INT
DECLARE @strCustomer NVARCHAR(250)
DECLARE @intFarmFieldId INT
DECLARE @strFarmNumber NVARCHAR(250)
DECLARE @intInputItemUOMId INT
DECLARE @intSubstituteItemUOMId INT
DECLARE @dblRecipeDetailCalculatedQty NUMERIC(18, 6)
DECLARE @dblRecipeDetailUpperTolerance NUMERIC(18, 6)
DECLARE @dblRecipeDetailLowerTolerance NUMERIC(18, 6)
	,@strRecipeItemType NVARCHAR(50)

--Recipe Delete
IF @strImportType = 'Recipe Delete'
BEGIN
	SELECT @intMinId = MIN(intRecipeStageId)
	FROM tblMFRecipeStage
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''
		AND strTransactionType = 'RECIPE_DELETE'

	WHILE @intMinId IS NOT NULL
	BEGIN
		SELECT @strRecipeName = NULL
			,@strItemNo = NULL
			,@intVersionNo = NULL
			,@strLocationName = NULL
			,@intItemId = NULL
			,@intLocationId = NULL

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strItemNo
			,@intVersionNo = [strVersionNo]
			,@strLocationName = strLocationName
		FROM tblMFRecipeStage
		WHERE intRecipeStageId = @intMinId

		SELECT @intItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strItemNo

		SELECT @intLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strLocationName

		BEGIN TRY
			IF ISNULL(@strItemNo, '') <> '' --Production Recipe
				DELETE
				FROM tblMFRecipe
				WHERE intItemId = @intItemId
					AND intVersionNo = @intVersionNo
					AND intLocationId = @intLocationId
			ELSE --Virtual Recipe
				DELETE
				FROM tblMFRecipe
				WHERE strName = @strRecipeName
					AND intLocationId = @intLocationId

			UPDATE tblMFRecipeStage
			SET strMessage = 'Success'
			WHERE intRecipeStageId = @intMinId
		END TRY

		BEGIN CATCH
			UPDATE tblMFRecipeStage
			SET strMessage = ERROR_MESSAGE()
			WHERE intRecipeStageId = @intMinId
		END CATCH

		SELECT @intMinId = MIN(intRecipeStageId)
		FROM tblMFRecipeStage
		WHERE intRecipeStageId > @intMinId
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
			AND strTransactionType = 'RECIPE_DELETE'
	END
END

--Recipe Item Delete
IF @strImportType = 'Recipe Item Delete'
BEGIN
	SELECT @intMinId = MIN(intRecipeItemStageId)
	FROM tblMFRecipeItemStage
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''
		AND strRowState = 'D'

	--Delete recipe item
	WHILE @intMinId IS NOT NULL
	BEGIN
		SET @intItemId = NULL
		SET @intVersionNo = NULL
		SET @strRecipeName = ''
		SET @intLocationId = NULL
		SET @intRecipeId = NULL
		SET @intRecipeDetailItemId = NULL
		SET @strRecipeDetailItemNo = ''
		SET @intRecipeItemId = NULL
		SET @intRecipeTypeId = NULL

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strRecipeHeaderItemNo
			,@intVersionNo = [strVersionNo]
			,@strLocationName = strLocationName
			,@strRecipeDetailItemNo = strRecipeItemNo
		FROM tblMFRecipeItemStage
		WHERE intRecipeItemStageId = @intMinId

		SELECT @intItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strItemNo

		SELECT @intLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strLocationName

		SELECT @intRecipeDetailItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strRecipeDetailItemNo

		IF ISNULL(@strItemNo, '') <> '' --Production Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
				,@intRecipeTypeId = intRecipeTypeId
				,@intLocationId = intLocationId
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intVersionNo = @intVersionNo
				AND intLocationId = @intLocationId
		ELSE --Virtual Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
				,@intRecipeTypeId = intRecipeTypeId
				,@intLocationId = intLocationId
			FROM tblMFRecipe
			WHERE strName = @strRecipeName
				AND intLocationId = @intLocationId

		IF @intRecipeId IS NULL
		BEGIN
			UPDATE tblMFRecipeItemStage
			SET strMessage = 'No recipe found to Delete items.'
			WHERE intRecipeItemStageId = @intMinId

			GOTO NEXT_RECIPEITEM_DELETE
		END

		BEGIN TRY
			DELETE
			FROM tblMFRecipeItem
			WHERE intRecipeId = @intRecipeId
				AND intItemId = @intRecipeDetailItemId

			UPDATE tblMFRecipeItemStage
			SET strMessage = 'Success'
			WHERE intRecipeItemStageId = @intMinId
		END TRY

		BEGIN CATCH
			UPDATE tblMFRecipeItemStage
			SET strMessage = ERROR_MESSAGE()
			WHERE intRecipeItemStageId = @intMinId
		END CATCH

		NEXT_RECIPEITEM_DELETE:

		SELECT @intMinId = MIN(intRecipeItemStageId)
		FROM tblMFRecipeItemStage
		WHERE intRecipeItemStageId > @intMinId
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
			AND strRowState = 'D'
	END
END

--Recipe
IF @strImportType = 'Recipe'
BEGIN
	--Recipe Name is required
	UPDATE tblMFRecipeStage
	SET strMessage = 'Recipe Name is required'
	WHERE ISNULL(strRecipeName, '') = ''
		AND ISNULL(strItemNo, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Item
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Item'
	WHERE strItemNo NOT IN (
			SELECT strItemNo
			FROM tblICItem
			)
		AND ISNULL(strItemNo, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Qty
	UPDATE tblMFRecipeStage
	SET strMessage = 'Quantity should be greater than 0'
	WHERE (
			ISNUMERIC(ISNULL([strQuantity], 0)) = 0
			OR ISNULL(CAST([strQuantity] AS NUMERIC(18, 6)), 0) <= 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--UOM is required
	UPDATE tblMFRecipeStage
	SET strMessage = 'UOM is required'
	WHERE ISNULL(strUOM, '') = ''
		AND ISNULL(strItemNo, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid UOM
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid UOM'
	WHERE strUOM NOT IN (
			SELECT strUnitMeasure
			FROM tblICUnitMeasure
			)
		AND ISNULL(strUOM, '') <> ''
		AND ISNULL(strItemNo, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Location is required
	UPDATE tblMFRecipeStage
	SET strMessage = 'Location is required'
	WHERE ISNULL(strLocationName, '') = ''
		AND ISNULL(strItemNo, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Location
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Location'
	WHERE strLocationName NOT IN (
			SELECT strLocationName
			FROM tblSMCompanyLocation
			)
		AND ISNULL(strLocationName, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Version
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Version No'
	WHERE (
			ISNUMERIC(ISNULL([strVersionNo], 0)) = 0
			OR CHARINDEX('.', ISNULL([strVersionNo], 0)) > 0
			OR [strVersionNo] = '0'
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Recipe Type
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Recipe Type'
	WHERE strRecipeType NOT IN (
			SELECT strName
			FROM tblMFRecipeType
			)
		AND ISNULL(strRecipeType, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	UPDATE tblMFRecipeStage
	SET strManufacturingProcess=(Select Top 1 strProcessName  from tblMFManufacturingProcess )
	WHERE strManufacturingProcess NOT IN (
			SELECT strProcessName
			FROM tblMFManufacturingProcess
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Manufacturing Process
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Manufacturing Process'
	WHERE strManufacturingProcess NOT IN (
			SELECT strProcessName
			FROM tblMFManufacturingProcess
			)
		AND ISNULL(strManufacturingProcess, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Customer
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Customer'
	WHERE strCustomer NOT IN (
			SELECT strCustomer
			FROM vyuARCustomer
			)
		AND ISNULL(strCustomer, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Farm
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Farm'
	WHERE strFarm NOT IN (
			SELECT strFarm
			FROM tblEMEntityFarm
			)
		AND ISNULL(strFarm, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Cost Type
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Cost Type'
	WHERE strCostType NOT IN (
			SELECT strName
			FROM tblMFCostType
			)
		AND ISNULL(strCostType, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Margin By
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Margin By'
	WHERE strMarginBy NOT IN (
			SELECT strName
			FROM tblMFMarginBy
			)
		AND ISNULL(strMarginBy, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Margin
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Margin / Margin cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strMargin], 0)) = 0
			OR ISNULL(CAST([strMargin] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Discount
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Discount / Discount cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strDiscount], 0)) = 0
			OR ISNULL(CAST([strDiscount] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid One Line Print
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid One Line Print'
	WHERE strOneLinePrint NOT IN (
			SELECT strName
			FROM tblMFOneLinePrint
			)
		AND ISNULL(strOneLinePrint, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Set Default Values
	--Recipe Name
	UPDATE tblMFRecipeStage
	SET strRecipeName = strItemNo
	WHERE ISNULL(strRecipeName, '') = ''
		AND ISNULL(strItemNo, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Recipe Type
	UPDATE tblMFRecipeStage
	SET strRecipeType = 'By Quantity'
	WHERE ISNULL(strRecipeType, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Valid From
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Valid From (YYYY-MM-DD)'
	WHERE ISDATE(ISNULL([strValidFrom], '')) = 0
		AND ISNULL([strValidFrom], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Valid To
	UPDATE tblMFRecipeStage
	SET strMessage = 'Invalid Valid To (YYYY-MM-DD)'
	WHERE ISDATE(ISNULL([strValidTo], '')) = 0
		AND ISNULL([strValidTo], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	IF @ysnMinOneInputItemRequired = 1
	BEGIN
		--Invalid Detail Item
		UPDATE tblMFRecipeItemStage
		SET strMessage = 'Invalid Recipe Detail Item'
		WHERE ISNULL(strRecipeItemNo, '') NOT IN (
				SELECT strItemNo
				FROM tblICItem
				)
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''

		UPDATE R
		SET R.strMessage = 'Minimum one input item is required to create a recipe.'
		From tblMFRecipeStage R
		WHERE R.strSessionId = @strSessionId
			AND ISNULL(R.strMessage, '') = ''
			AND NOT EXISTS (
				SELECT *
				FROM tblMFRecipeItemStage RI
				WHERE RI.strSessionId = @strSessionId
					AND ISNULL(RI.strMessage, '') = ''
					AND RI.strRecipeItemType = 'INPUT'
					AND R.strRecipeName = RI.strRecipeName
					AND R.strVersionNo = RI.strVersionNo
					AND R.strLocationName = RI.strLocationName
					AND R.strItemNo  = RI.strRecipeHeaderItemNo 
				)
	END

	SELECT @intMinId = MIN(intRecipeStageId)
	FROM tblMFRecipeStage
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Insert/Update recipe
	WHILE (@intMinId IS NOT NULL)
	BEGIN
		SET @intItemId = NULL
		SET @intVersionNo = NULL
		SET @strRecipeName = ''
		SET @intLocationId = NULL
		SET @strLocationName = ''
		SET @intRecipeId = NULL
		SET @strCustomer = NULL
		SET @intCustomerId = NULL
		SET @strFarmNumber = NULL
		SET @intFarmFieldId = NULL

		--Margin By
		UPDATE tblMFRecipeStage
		SET strMarginBy = 'Amount'
		WHERE ISNULL(strMarginBy, '') = ''
			AND ISNULL(CAST([strMargin] AS NUMERIC(18, 6)), 0) > 0
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
			AND intRecipeStageId = @intMinId

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strItemNo
			,@intVersionNo = [strVersionNo]
			,@strLocationName = strLocationName
			,@strCustomer = strCustomer
			,@strFarmNumber = strFarm
		FROM tblMFRecipeStage
		WHERE intRecipeStageId = @intMinId

		SELECT @intItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strItemNo

		SELECT @intLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strLocationName

		SELECT TOP 1 @intCustomerId = intEntityId
		FROM vyuARCustomer
		WHERE strName = @strCustomer

		SELECT TOP 1 @intFarmFieldId = intFarmFieldId
		FROM tblEMEntityFarm
		WHERE intEntityId = @intCustomerId
			AND strFarmNumber = @strFarmNumber

		IF ISNULL(@strFarmNumber, '') <> ''
			AND @intFarmFieldId IS NULL
		BEGIN
			UPDATE tblMFRecipeStage
			SET strMessage = 'Farm does not belong to customer.'
			WHERE intRecipeStageId = @intMinId

			GOTO NEXT_RECIPE
		END

		IF ISNULL(@strItemNo, '') <> '' --Production Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intVersionNo = @intVersionNo
				AND intLocationId = @intLocationId
		ELSE --Virtual Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
			FROM tblMFRecipe
			WHERE strName = @strRecipeName

		IF @intRecipeId IS NULL --insert
		BEGIN
			INSERT INTO tblMFRecipe (
				strName
				,intItemId
				,dblQuantity
				,intItemUOMId
				,intLocationId
				,intVersionNo
				,intRecipeTypeId
				,intManufacturingProcessId
				,ysnActive
				,intCustomerId
				,intFarmId
				,intCostTypeId
				,intMarginById
				,dblMargin
				,dblDiscount
				,intMarginUOMId
				,intOneLinePrintId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,dtmValidFrom
				,dtmValidTo
				)
			SELECT TOP 1 s.strRecipeName
				,i.intItemId
				,s.[strQuantity]
				,iu.intItemUOMId
				,cl.intCompanyLocationId
				,s.[strVersionNo]
				,rt.intRecipeTypeId
				,mp.intManufacturingProcessId
				,0
				,@intCustomerId
				,@intFarmFieldId
				,ct.intCostTypeId
				,m.intMarginById
				,s.[strMargin]
				,s.[strDiscount]
				,um.intUnitMeasureId
				,p.intOneLinePrintId
				,@intUserId
				,GETDATE()
				,@intUserId
				,GETDATE()
				,s.strValidFrom
				,s.strValidTo
			FROM tblMFRecipeStage s
			LEFT JOIN tblICItem i ON s.strItemNo = i.strItemNo
			LEFT JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
				AND iu.ysnStockUnit = 1
			LEFT JOIN tblSMCompanyLocation cl ON s.strLocationName = cl.strLocationName
			LEFT JOIN tblMFRecipeType rt ON s.strRecipeType = rt.strName
			LEFT JOIN tblMFManufacturingProcess mp ON s.strManufacturingProcess = mp.strProcessName
			LEFT JOIN tblMFCostType ct ON s.strCostType = ct.strName
			LEFT JOIN tblMFMarginBy m ON s.strMarginBy = m.strName
			LEFT JOIN tblICUnitMeasure um ON s.strUOM = um.strUnitMeasure
			LEFT JOIN tblMFOneLinePrint p ON s.strOneLinePrint = p.strName
			WHERE s.intRecipeStageId = @intMinId

			SELECT @intRecipeId = SCOPE_IDENTITY()

			--Add Default Output Item for production recipe
			IF ISNULL(@strItemNo, '') <> ''
				INSERT INTO tblMFRecipeItem (
					intRecipeId
					,intItemId
					,strDescription
					,dblQuantity
					,dblCalculatedQuantity
					,intItemUOMId
					,intRecipeItemTypeId
					,strItemGroupName
					,dblUpperTolerance
					,dblLowerTolerance
					,dblCalculatedUpperTolerance
					,dblCalculatedLowerTolerance
					,dblShrinkage
					,ysnScaled
					,intConsumptionMethodId
					,intStorageLocationId
					,dtmValidFrom
					,dtmValidTo
					,ysnYearValidationRequired
					,ysnMinorIngredient
					,ysnOutputItemMandatory
					,dblScrap
					,ysnConsumptionRequired
					,dblCostAllocationPercentage
					,intMarginById
					,dblMargin
					,ysnCostAppliedAtInvoice
					,intCommentTypeId
					,strDocumentNo
					,intSequenceNo
					,ysnPartialFillConsumption
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					)
				SELECT TOP 1 @intRecipeId
					,@intItemId
					,''
					,s.[strQuantity]
					,0
					,iu.intItemUOMId
					,2
					,''
					,0
					,0
					,s.[strQuantity]
					,s.[strQuantity]
					,0
					,0
					,NULL
					,NULL
					,NULL
					,NULL
					,0
					,0
					,1
					,0
					,1
					,100
					,NULL
					,0
					,0
					,NULL
					,NULL
					,NULL
					,1
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()
				FROM tblMFRecipeStage s
				LEFT JOIN tblICItem i ON s.strItemNo = i.strItemNo
				LEFT JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
					AND iu.ysnStockUnit = 1
				WHERE s.intRecipeStageId = @intMinId
		END
		ELSE
		BEGIN --update
			UPDATE r
			SET r.strName = t.strRecipeName
				,r.dblQuantity = t.[strQuantity]
				,r.intManufacturingProcessId = t.intManufacturingProcessId
				,r.intCustomerId = @intCustomerId
				,r.intFarmId = @intFarmFieldId
				,r.intCostTypeId = t.intCostTypeId
				,r.intMarginById = t.intMarginById
				,r.dblMargin = t.[strMargin]
				,r.dblDiscount = t.[strDiscount]
				,r.intMarginUOMId = t.intUnitMeasureId
				,r.intOneLinePrintId = t.intOneLinePrintId
				,r.intLastModifiedUserId = @intUserId
				,r.dtmLastModified = GETDATE()
				,r.dtmValidFrom = t.strValidFrom
				,r.dtmValidTo = t.strValidTo
			FROM tblMFRecipe r
			CROSS JOIN (
				SELECT TOP 1 s.strRecipeName
					,i.intItemId
					,s.[strQuantity]
					,iu.intItemUOMId
					,cl.intCompanyLocationId
					,s.[strVersionNo]
					,rt.intRecipeTypeId
					,mp.intManufacturingProcessId
					,ct.intCostTypeId
					,m.intMarginById
					,s.[strMargin]
					,s.[strDiscount]
					,um.intUnitMeasureId
					,p.intOneLinePrintId
					,s.strValidFrom
					,s.strValidTo
				FROM tblMFRecipeStage s
				LEFT JOIN tblICItem i ON s.strItemNo = i.strItemNo
				LEFT JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
					AND iu.ysnStockUnit = 1
				LEFT JOIN tblSMCompanyLocation cl ON s.strLocationName = cl.strLocationName
				LEFT JOIN tblMFRecipeType rt ON s.strRecipeType = rt.strName
				LEFT JOIN tblMFManufacturingProcess mp ON s.strManufacturingProcess = mp.strProcessName
				LEFT JOIN tblMFCostType ct ON s.strCostType = ct.strName
				LEFT JOIN tblMFMarginBy m ON s.strMarginBy = m.strName
				LEFT JOIN tblICUnitMeasure um ON s.strUOM = um.strUnitMeasure
				LEFT JOIN tblMFOneLinePrint p ON s.strOneLinePrint = p.strName
				WHERE s.intRecipeStageId = @intMinId
				) t
			WHERE r.intRecipeId = @intRecipeId
		END

		UPDATE tblMFRecipeStage
		SET strMessage = 'Success'
		WHERE intRecipeStageId = @intMinId

		NEXT_RECIPE:

		SELECT @intMinId = MIN(intRecipeStageId)
		FROM tblMFRecipeStage
		WHERE intRecipeStageId > @intMinId
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
	END

	UPDATE tblMFRecipeStage
	SET strMessage = 'Skipped'
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''
END

--Recipe Item
IF @strImportType = 'Recipe Item'
BEGIN
	--Recipe Name is required
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Recipe Name is required'
	WHERE ISNULL(strRecipeName, '') = ''
		AND ISNULL(strRecipeHeaderItemNo, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Header Item
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Recipe Header Item'
	WHERE strRecipeHeaderItemNo NOT IN (
			SELECT strItemNo
			FROM tblICItem
			)
		AND ISNULL(strRecipeHeaderItemNo, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Version No
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Version No'
	WHERE (
			ISNUMERIC(ISNULL([strVersionNo], 0)) = 0
			OR CHARINDEX('.', ISNULL([strVersionNo], 0)) > 0
			OR [strVersionNo] = '0'
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Detail Item
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Recipe Detail Item'
	WHERE ISNULL(strRecipeItemNo, '') NOT IN (
			SELECT strItemNo
			FROM tblICItem
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Qty
	UPDATE s
	SET s.strMessage = 'Quantity should be greater than 0'
	FROM tblMFRecipeItemStage s
	JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
	WHERE (
			ISNUMERIC(s.[strQuantity]) = 0
			OR ISNULL(CAST(s.[strQuantity] AS NUMERIC(18, 6)), 0) <= 0
			)
		AND i.strType NOT IN (
			'Other Charge'
			,'Comment'
			)
		AND s.strSessionId = @strSessionId
		AND ISNULL(s.strMessage, '') = ''

	--UOM is required
	UPDATE s
	SET s.strMessage = 'UOM is required'
	FROM tblMFRecipeItemStage s
	JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
	WHERE ISNULL(strUOM, '') = ''
		AND i.strType NOT IN (
			'Other Charge'
			,'Comment'
			)
		AND s.strSessionId = @strSessionId
		AND ISNULL(s.strMessage, '') = ''

	--Invalid UOM
	UPDATE s
	SET s.strMessage = 'Invalid UOM'
	FROM tblMFRecipeItemStage s
	JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
	WHERE ISNULL(strUOM, '') <> ''
		AND strUOM NOT IN (
			SELECT strUnitMeasure
			FROM tblICUnitMeasure
			)
		AND i.strType NOT IN (
			'Other Charge'
			,'Comment'
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Recipe Item Type
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Recipe Item Type (Possible values: INPUT,OUTPUT)'
	WHERE strRecipeItemType NOT IN (
			SELECT strName
			FROM tblMFRecipeItemType
			)
		AND ISNULL(strRecipeItemType, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Upper Tolerance
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Upper Tolerance/Upper Tolerance cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strUpperTolerance], 0)) = 0
			OR ISNULL(CAST([strUpperTolerance] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Lower Tolerance
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Lower Tolerance/Lower Tolerance cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strLowerTolerance], 0)) = 0
			OR ISNULL(CAST([strLowerTolerance] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Shrinkage
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Shrinkage/Shrinkage cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strShrinkage], 0)) = 0
			OR ISNULL(CAST([strShrinkage] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Scale
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Scale (Possible values: 1,0)'
	WHERE ISNULL([strScaled], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strScaled], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Consumption Method
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Consumption Method (Possible values: By Lot,By Location,FIFO,None)'
	WHERE strConsumptionMethod NOT IN (
			SELECT strName
			FROM tblMFConsumptionMethod
			)
		AND ISNULL(strConsumptionMethod, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Storage Location
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Storage Location'
	WHERE strStorageLocation NOT IN (
			SELECT strName
			FROM tblICStorageLocation
			)
		AND ISNULL(strStorageLocation, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Valid From
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Valid From (YYYY-MM-DD)'
	WHERE ISDATE(ISNULL([strValidFrom], '')) = 0
		AND ISNULL([strValidFrom], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Valid To
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Valid To (YYYY-MM-DD)'
	WHERE ISDATE(ISNULL([strValidTo], '')) = 0
		AND ISNULL([strValidTo], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Year Validation
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Year Validation (Possible values: 1,0)'
	WHERE ISNULL([strYearValidationRequired], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strYearValidationRequired], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Minor Ingredient
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Minor Ingredient (Possible values: 1,0)'
	WHERE ISNULL([strMinorIngredient], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strMinorIngredient], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Output Item Mandatory
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Output Item Mandatory (Possible values: 1,0)'
	WHERE ISNULL([strOutputItemMandatory], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strOutputItemMandatory], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Scrap
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Scrap / Scrap cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strScrap], 0)) = 0
			OR ISNULL(CAST([strScrap] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Consumption Required
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Consumption Required (Possible values: 1,0)'
	WHERE ISNULL([strConsumptionRequired], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strConsumptionRequired], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Cost Allocation Percentage
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Cost Allocation Percentage / Cost Allocation Percentage cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strCostAllocationPercentage], 0)) = 0
			OR ISNULL(CAST([strCostAllocationPercentage] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Margin By
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Margin By'
	WHERE strMarginBy NOT IN (
			SELECT strName
			FROM tblMFMarginBy
			)
		AND ISNULL(strMarginBy, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Margin
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Margin / Margin cannot be negative'
	WHERE (
			ISNUMERIC(ISNULL([strMargin], 0)) = 0
			OR ISNULL(CAST([strMargin] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Cost Applied At Invoice
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Cost Applied At Invoice (Possible values: 1,0)'
	WHERE ISNULL([strCostAppliedAtInvoice], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strCostAppliedAtInvoice], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Comment Type
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Comment Type'
	WHERE strCommentType NOT IN (
			SELECT strName
			FROM tblMFCommentType
			)
		AND ISNULL(strCommentType, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Partial Fill Consumption
	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Invalid Partial Fill Consumption (Possible values: 1,0)'
	WHERE ISNULL([strPartialFillConsumption], '') NOT IN (
			'1'
			,'0'
			)
		AND ISNULL([strPartialFillConsumption], '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Set Default Values
	--Recipe Item Type
	UPDATE tblMFRecipeItemStage
	SET strRecipeItemType = 'INPUT'
	WHERE ISNULL(strRecipeItemType, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Consumption Method
	UPDATE tblMFRecipeItemStage
	SET strConsumptionMethod = 'By Lot'
	WHERE ISNULL(strConsumptionMethod, '') = ''
		AND strRecipeItemType = 'INPUT'
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Comment Type
	UPDATE s
	SET s.strCommentType = 'General'
	FROM tblMFRecipeItemStage s
	JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
	WHERE ISNULL(strCommentType, '') = ''
		AND i.strType = 'Comment'
		AND s.strSessionId = @strSessionId
		AND ISNULL(s.strMessage, '') = ''

	--Set Comment as Item Desc if empty
	UPDATE s
	SET s.strDescription = i.strDescription
	FROM tblMFRecipeItemStage s
	JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
	WHERE ISNULL(s.strDescription, '') = ''
		AND i.strType = 'Comment'
		AND s.strSessionId = @strSessionId
		AND ISNULL(s.strMessage, '') = ''

	--Quantity=0,UOM=null for Other Charge,Comment items
	UPDATE s
	SET s.[strQuantity] = 0
		,s.strUOM = NULL
	FROM tblMFRecipeItemStage s
	JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
	WHERE i.strType IN (
			'Other Charge'
			,'Comment'
			)
		AND s.strSessionId = @strSessionId
		AND ISNULL(s.strMessage, '') = ''

	SELECT @intMinId = MIN(intRecipeItemStageId)
	FROM tblMFRecipeItemStage
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Insert/Update recipe item
	WHILE (@intMinId IS NOT NULL)
	BEGIN
		SET @intItemId = NULL
		SET @intVersionNo = NULL
		SET @strRecipeName = ''
		SET @intLocationId = NULL
		SET @intRecipeId = NULL
		SET @intRecipeDetailItemId = NULL
		SET @strRecipeDetailItemNo = ''
		SET @intRecipeItemId = NULL
		SET @intRecipeTypeId = NULL

		SELECT @strLocationName = NULL
			,@strRecipeItemType = NULL

		--Margin By
		UPDATE tblMFRecipeItemStage
		SET strMarginBy = 'Amount'
		WHERE ISNULL(strMarginBy, '') = ''
			AND ISNULL(CAST([strMargin] AS NUMERIC(18, 6)), 0) > 0
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
			AND intRecipeItemStageId = @intMinId

		--Valid From
		UPDATE tblMFRecipeItemStage
		SET [strValidFrom] = CONVERT(VARCHAR, YEAR(GETDATE())) + '-01-01'
		WHERE ISNULL([strValidFrom], '') = ''
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
			AND intRecipeItemStageId = @intMinId

		--Valid To
		UPDATE tblMFRecipeItemStage
		SET [strValidTo] = CONVERT(VARCHAR, YEAR(GETDATE())) + '-12-31'
		WHERE ISNULL([strValidTo], '') = ''
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
			AND intRecipeItemStageId = @intMinId

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strRecipeHeaderItemNo
			,@intVersionNo = [strVersionNo]
			,@strLocationName = strLocationName
			,@strRecipeDetailItemNo = strRecipeItemNo
			,@strRecipeItemType = strRecipeItemType
		FROM tblMFRecipeItemStage
		WHERE intRecipeItemStageId = @intMinId

		SELECT @intItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strItemNo

		SELECT @intLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strLocationName

		SELECT @intRecipeDetailItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strRecipeDetailItemNo

		IF ISNULL(@strItemNo, '') <> '' --Production Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
				,@intRecipeTypeId = intRecipeTypeId
				,@intLocationId = intLocationId
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intVersionNo = @intVersionNo
				AND intLocationId = @intLocationId
		ELSE --Virtual Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
				,@intRecipeTypeId = intRecipeTypeId
				,@intLocationId = intLocationId
			FROM tblMFRecipe
			WHERE strName = @strRecipeName
				AND intLocationId = @intLocationId

		IF @intRecipeId IS NULL
		BEGIN
			UPDATE tblMFRecipeItemStage
			SET strMessage = 'No recipe found to add items.'
			WHERE intRecipeItemStageId = @intMinId

			GOTO NEXT_RECIPEITEM
		END

		SELECT TOP 1 @intRecipeItemId = intRecipeItemId
		FROM tblMFRecipeItem
		WHERE intRecipeId = @intRecipeId
			AND intItemId = @intRecipeDetailItemId
			AND intRecipeItemTypeId = (
				CASE 
					WHEN @strRecipeItemType = 'INPUT'
						THEN 1
					ELSE 2
					END
				)

		IF @intRecipeItemId IS NULL --insert
		BEGIN
			INSERT INTO tblMFRecipeItem (
				intRecipeId
				,intItemId
				,strDescription
				,dblQuantity
				,dblCalculatedQuantity
				,intItemUOMId
				,intRecipeItemTypeId
				,strItemGroupName
				,dblUpperTolerance
				,dblLowerTolerance
				,dblCalculatedUpperTolerance
				,dblCalculatedLowerTolerance
				,dblShrinkage
				,ysnScaled
				,intConsumptionMethodId
				,intStorageLocationId
				,dtmValidFrom
				,dtmValidTo
				,ysnYearValidationRequired
				,ysnMinorIngredient
				,ysnOutputItemMandatory
				,dblScrap
				,ysnConsumptionRequired
				,dblCostAllocationPercentage
				,intMarginById
				,dblMargin
				,ysnCostAppliedAtInvoice
				,intCommentTypeId
				,strDocumentNo
				,intSequenceNo
				,ysnPartialFillConsumption
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT @intRecipeId
				,i.intItemId
				,CASE 
					WHEN ct.intCommentTypeId > 0
						THEN s.strDescription
					ELSE ''
					END
				,s.[strQuantity]
				,CASE 
					WHEN s.strRecipeItemType = 'OUTPUT'
						THEN 0
					ELSE dbo.fnMFCalculateRecipeItemQuantity(rt.intRecipeItemTypeId, s.[strQuantity], ISNULL(s.[strShrinkage], 0))
					END
				,iu.intItemUOMId
				,rt.intRecipeItemTypeId
				,s.strItemGroupName
				,IsNULL(s.[strUpperTolerance],0)
				,IsNULL(s.[strLowerTolerance],0)
				,dbo.fnMFCalculateRecipeItemUpperTolerance(@intRecipeTypeId, s.[strQuantity], ISNULL(s.[strShrinkage], 0), ISNULL(s.[strUpperTolerance], 0))
				,dbo.fnMFCalculateRecipeItemLowerTolerance(@intRecipeTypeId, s.[strQuantity], ISNULL(s.[strShrinkage], 0), ISNULL(s.[strLowerTolerance], 0))
				,ISNULL(s.[strShrinkage], 0)
				,ISNULL(s.[strScaled], 1)
				,CASE 
					WHEN i.strType IN (
							'Other Charge'
							,'Comment'
							)
						THEN 4
					ELSE cm.intConsumptionMethodId
					END intConsumptionMethodId
				,sl.intStorageLocationId
				,s.[strValidFrom]
				,s.[strValidTo]
				,ISNULL(s.[strYearValidationRequired], 0)
				,ISNULL(s.[strMinorIngredient], 0)
				,CASE 
					WHEN i.intItemId = @intItemId
						THEN 1
					ELSE ISNULL(s.[strOutputItemMandatory], 0)
					END
				,ISNULL(s.[strScrap], 0)
				,CASE 
					WHEN i.intItemId = @intItemId
						THEN 1
					ELSE ISNULL(s.[strConsumptionRequired], 0)
					END
				,ISNULL(s.[strCostAllocationPercentage], 0)
				,m.intMarginById
				,s.[strMargin]
				,ISNULL(s.[strCostAppliedAtInvoice], 0)
				,ct.intCommentTypeId
				,s.strDocumentNo
				,NULL
				,ISNULL(s.[strPartialFillConsumption], 1)
				,@intUserId
				,GETDATE()
				,@intUserId
				,GETDATE()
			FROM tblMFRecipeItemStage s
			LEFT JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
			LEFT JOIN tblICUnitMeasure um ON um.strUnitMeasure = s.strUOM
			LEFT JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
				AND iu.intUnitMeasureId = um.intUnitMeasureId
			LEFT JOIN tblMFRecipeItemType rt ON s.strRecipeItemType = rt.strName
			LEFT JOIN tblMFConsumptionMethod cm ON s.strConsumptionMethod = cm.strName
			LEFT JOIN tblICStorageLocation sl ON sl.strName = s.strStorageLocation
				AND sl.intLocationId = @intLocationId
			LEFT JOIN tblMFMarginBy m ON s.strMarginBy = m.strName
			LEFT JOIN tblMFCommentType ct ON s.strCommentType = ct.strName
			WHERE s.intRecipeItemStageId = @intMinId
		END
		ELSE
		BEGIN --update
			UPDATE ri
			SET ri.strDescription = t.strDescription
				,ri.dblQuantity = t.[strQuantity]
				,ri.dblCalculatedQuantity = t.dblCalculatedQuantity
				,ri.intItemUOMId = t.intItemUOMId
				,ri.intRecipeItemTypeId = t.intRecipeItemTypeId
				,ri.strItemGroupName = t.strItemGroupName
				,ri.dblUpperTolerance = IsNULL(t.[strUpperTolerance],0)
				,ri.dblLowerTolerance = IsNULL(t.[strLowerTolerance],0)
				,ri.dblCalculatedUpperTolerance = t.dblCalculatedUpperTolerance
				,ri.dblCalculatedLowerTolerance = t.dblCalculatedLowerTolerance
				,ri.dblShrinkage = t.dblShrinkage
				,ri.ysnScaled = t.ysnScaled
				,ri.intConsumptionMethodId = t.intConsumptionMethodId
				,ri.intStorageLocationId = t.intStorageLocationId
				,ri.dtmValidFrom = t.[strValidFrom]
				,ri.dtmValidTo = t.[strValidTo]
				,ri.ysnYearValidationRequired = t.ysnYearValidationRequired
				,ri.ysnMinorIngredient = t.ysnMinorIngredient
				,ri.ysnOutputItemMandatory = t.ysnOutputItemMandatory
				,ri.dblScrap = t.dblScrap
				,ri.ysnConsumptionRequired = t.ysnConsumptionRequired
				,ri.dblCostAllocationPercentage = t.dblCostAllocationPercentage
				,ri.intMarginById = t.intMarginById
				,ri.dblMargin = t.[strMargin]
				,ri.ysnCostAppliedAtInvoice = t.ysnCostAppliedAtInvoice
				,ri.intCommentTypeId = t.intCommentTypeId
				,ri.strDocumentNo = t.strDocumentNo
				,ri.intSequenceNo = t.intSequenceNo
				,ri.ysnPartialFillConsumption = t.ysnPartialFillConsumption
				,ri.intLastModifiedUserId = @intUserId
				,ri.dtmLastModified = GETDATE()
			FROM tblMFRecipeItem ri
			CROSS JOIN (
				SELECT TOP 1 i.intItemId
					,CASE 
						WHEN ct.intCommentTypeId > 0
							THEN s.strDescription
						ELSE ''
						END AS strDescription
					,s.[strQuantity]
					,CASE 
						WHEN s.strRecipeItemType = 'OUTPUT'
							THEN 0
						ELSE dbo.fnMFCalculateRecipeItemQuantity(rt.intRecipeItemTypeId, s.[strQuantity], ISNULL(s.[strShrinkage], 0))
						END dblCalculatedQuantity
					,iu.intItemUOMId
					,rt.intRecipeItemTypeId
					,s.strItemGroupName
					,IsNULL(s.[strUpperTolerance],0) [strUpperTolerance]
					,IsNULL(s.[strLowerTolerance],0) [strLowerTolerance]
					,dbo.fnMFCalculateRecipeItemUpperTolerance(@intRecipeTypeId, s.[strQuantity], ISNULL(s.[strShrinkage], 0), ISNULL(s.[strUpperTolerance], 0)) dblCalculatedUpperTolerance
					,dbo.fnMFCalculateRecipeItemLowerTolerance(@intRecipeTypeId, s.[strQuantity], ISNULL(s.[strShrinkage], 0), ISNULL(s.[strLowerTolerance], 0)) dblCalculatedLowerTolerance
					,ISNULL(s.[strShrinkage], 0) dblShrinkage
					,ISNULL(s.[strScaled], 1) ysnScaled
					,CASE 
						WHEN i.strType IN (
								'Other Charge'
								,'Comment'
								)
							THEN 4
						ELSE cm.intConsumptionMethodId
						END intConsumptionMethodId
					,sl.intStorageLocationId
					,s.[strValidFrom]
					,s.[strValidTo]
					,ISNULL(s.[strYearValidationRequired], 0) ysnYearValidationRequired
					,ISNULL(s.[strMinorIngredient], 0) ysnMinorIngredient
					,CASE 
						WHEN i.intItemId = @intItemId
							THEN 1
						ELSE ISNULL(s.[strOutputItemMandatory], 0)
						END ysnOutputItemMandatory
					,ISNULL(s.[strScrap], 0) dblScrap
					,CASE 
						WHEN i.intItemId = @intItemId
							THEN 1
						ELSE ISNULL(s.[strConsumptionRequired], 0)
						END ysnConsumptionRequired
					,ISNULL(s.[strCostAllocationPercentage], 0) dblCostAllocationPercentage
					,m.intMarginById
					,s.[strMargin]
					,ISNULL(s.[strCostAppliedAtInvoice], 0) ysnCostAppliedAtInvoice
					,ct.intCommentTypeId
					,s.strDocumentNo
					,NULL intSequenceNo
					,ISNULL(s.[strPartialFillConsumption], 1) ysnPartialFillConsumption
				FROM tblMFRecipeItemStage s
				LEFT JOIN tblICItem i ON s.strRecipeItemNo = i.strItemNo
				LEFT JOIN tblICUnitMeasure um ON um.strUnitMeasure = s.strUOM
				LEFT JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
					AND iu.intUnitMeasureId = um.intUnitMeasureId
				LEFT JOIN tblMFRecipeItemType rt ON s.strRecipeItemType = rt.strName
				LEFT JOIN tblMFConsumptionMethod cm ON s.strConsumptionMethod = cm.strName
				LEFT JOIN tblICStorageLocation sl ON sl.strName = s.strStorageLocation
					AND sl.intLocationId = @intLocationId
				LEFT JOIN tblMFMarginBy m ON s.strMarginBy = m.strName
				LEFT JOIN tblMFCommentType ct ON s.strCommentType = ct.strName
				WHERE s.intRecipeItemStageId = @intMinId
				) t
			WHERE ri.intRecipeItemId = @intRecipeItemId
		END

		UPDATE tblMFRecipeItemStage
		SET strMessage = 'Success'
		WHERE intRecipeItemStageId = @intMinId

		--Mark Recipe as Active if it has Input Items
		IF (
				SELECT Count(1)
				FROM tblMFRecipeItem
				WHERE intRecipeId = @intRecipeId
					AND intRecipeItemTypeId = 1
				) > 0 
			AND NOT EXISTS (
					SELECT *
					FROM tblMFRecipe
					WHERE intItemId = @intItemId
						AND ysnActive = 1
						AND intLocationId = @intLocationId
					)

			UPDATE tblMFRecipe
			SET ysnActive = 1
			WHERE intRecipeId = @intRecipeId

		NEXT_RECIPEITEM:

		SELECT @intMinId = MIN(intRecipeItemStageId)
		FROM tblMFRecipeItemStage
		WHERE intRecipeItemStageId > @intMinId
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
	END

	UPDATE tblMFRecipeItemStage
	SET strMessage = 'Skipped'
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''
END

--Recipe Substitute Item
IF @strImportType = 'Recipe Substitute Item'
BEGIN
	--Recipe Name is required
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Recipe Name is required'
	WHERE ISNULL(strRecipeName, '') = ''
		AND ISNULL(strRecipeHeaderItemNo, '') = ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Header Item
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Invalid Recipe Header Item'
	WHERE strRecipeHeaderItemNo NOT IN (
			SELECT strItemNo
			FROM tblICItem
			)
		AND ISNULL(strRecipeHeaderItemNo, '') <> ''
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Version No
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Invalid Version No'
	WHERE (
			ISNUMERIC(ISNULL([strVersionNo], 0)) = 0
			OR CHARINDEX('.', ISNULL([strVersionNo], 0)) > 0
			OR [strVersionNo] = '0'
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Detail Item
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Invalid Recipe Detail Item'
	WHERE ISNULL(strRecipeItemNo, '') NOT IN (
			SELECT strItemNo
			FROM tblICItem
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Substitute Item
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Invalid Substitute Item'
	WHERE ISNULL(strSubstituteItemNo, '') NOT IN (
			SELECT strItemNo
			FROM tblICItem
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Substitute Ratio
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Invalid Substitute Ratio/Substitute Ratio cannot be negative'
	WHERE (
			ISNUMERIC([strSubstituteRatio]) = 0
			OR ISNULL(CAST([strSubstituteRatio] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Invalid Max Substitute Ratio
	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Invalid Max Substitute/Max Substitute Ratio cannot be negative'
	WHERE (
			ISNUMERIC([strMaxSubstituteRatio]) = 0
			OR ISNULL(CAST([strMaxSubstituteRatio] AS NUMERIC(18, 6)), 0) < 0
			)
		AND strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	SELECT @intMinId = MIN(intRecipeSubstituteItemStageId)
	FROM tblMFRecipeSubstituteItemStage
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''

	--Insert/Update recipe sub item
	WHILE (@intMinId IS NOT NULL)
	BEGIN
		SET @intItemId = NULL
		SET @intVersionNo = NULL
		SET @strRecipeName = ''
		SET @intLocationId = NULL
		SET @intRecipeId = NULL
		SET @intRecipeDetailItemId = NULL
		SET @strRecipeDetailItemNo = ''
		SET @intRecipeItemId = NULL
		SET @intRecipeSubstituteItemId = NULL
		SET @intRecipeTypeId = NULL
		SET @intSubstituteItemId = NULL
		SET @strSubstituteItemNo = NULL
		SET @intInputItemUOMId = NULL
		SET @intSubstituteItemUOMId = NULL
		SET @dblRecipeDetailCalculatedQty = NULL
		SET @dblRecipeDetailUpperTolerance = NULL
		SET @dblRecipeDetailLowerTolerance = NULL

		SELECT @strLocationName = NULL

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strRecipeHeaderItemNo
			,@intVersionNo = [strVersionNo]
			,@strLocationName = strLocationName
			,@strRecipeDetailItemNo = strRecipeItemNo
			,@strSubstituteItemNo = strSubstituteItemNo
		FROM tblMFRecipeSubstituteItemStage
		WHERE intRecipeSubstituteItemStageId = @intMinId

		SELECT @intItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strItemNo

		SELECT @intLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strLocationName

		SELECT @intRecipeDetailItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strRecipeDetailItemNo

		SELECT @intSubstituteItemId = intItemId
		FROM tblICItem
		WHERE strItemNo = @strSubstituteItemNo

		IF ISNULL(@strItemNo, '') <> '' --Production Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
				,@intRecipeTypeId = intRecipeTypeId
				,@intLocationId = intLocationId
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intVersionNo = @intVersionNo
				AND intLocationId = @intLocationId
		ELSE --Virtual Recipe
			SELECT TOP 1 @intRecipeId = intRecipeId
				,@intRecipeTypeId = intRecipeTypeId
				,@intLocationId = intLocationId
			FROM tblMFRecipe
			WHERE strName = @strRecipeName
				AND intLocationId = @intLocationId

		IF @intRecipeId IS NULL
		BEGIN
			UPDATE tblMFRecipeSubstituteItemStage
			SET strMessage = 'No recipe found to add items.'
			WHERE intRecipeSubstituteItemStageId = @intMinId

			GOTO NEXT_SUBITEM
		END

		SELECT TOP 1 @intRecipeItemId = intRecipeItemId
			,@intInputItemUOMId = intItemUOMId
			,@dblRecipeDetailCalculatedQty = dblCalculatedQuantity
			,@dblRecipeDetailUpperTolerance = dblUpperTolerance
			,@dblRecipeDetailLowerTolerance = dblLowerTolerance
		FROM tblMFRecipeItem
		WHERE intRecipeId = @intRecipeId
			AND intItemId = @intRecipeDetailItemId

		IF @intRecipeItemId IS NULL
		BEGIN
			UPDATE tblMFRecipeSubstituteItemStage
			SET strMessage = 'No recipe detail item found to add substitute items.'
			WHERE intRecipeSubstituteItemStageId = @intMinId

			GOTO NEXT_SUBITEM
		END

		--Get the Sub Item's Item UOM Id corresponding to the input item
		SELECT TOP 1 @intSubstituteItemUOMId = iu1.intItemUOMId
		FROM tblICItemUOM iu
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblICItemUOM iu1 ON iu1.intUnitMeasureId = iu.intUnitMeasureId
			AND iu1.intItemId = @intSubstituteItemId
		WHERE iu.intItemUOMId = @intInputItemUOMId

		IF @intSubstituteItemUOMId IS NULL
		BEGIN
			UPDATE tblMFRecipeSubstituteItemStage
			SET strMessage = 'UOM not found for substitute items.'
			WHERE intRecipeSubstituteItemStageId = @intMinId

			GOTO NEXT_SUBITEM
		END

		SELECT TOP 1 @intRecipeSubstituteItemId = intRecipeSubstituteItemId
		FROM tblMFRecipeSubstituteItem
		WHERE intRecipeId = @intRecipeId
			AND intRecipeItemId = @intRecipeItemId
			AND intSubstituteItemId = @intSubstituteItemId

		IF @intRecipeSubstituteItemId IS NULL --insert
		BEGIN
			INSERT INTO tblMFRecipeSubstituteItem (
				intRecipeItemId
				,intRecipeId
				,intItemId
				,intSubstituteItemId
				,dblQuantity
				,intItemUOMId
				,dblSubstituteRatio
				,dblMaxSubstituteRatio
				,dblCalculatedUpperTolerance
				,dblCalculatedLowerTolerance
				,intRecipeItemTypeId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT @intRecipeItemId
				,@intRecipeId
				,@intRecipeDetailItemId
				,i.intItemId
				,dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty, s.[strSubstituteRatio], s.[strMaxSubstituteRatio])
				,@intSubstituteItemUOMId
				,s.[strSubstituteRatio]
				,s.[strMaxSubstituteRatio]
				,dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty, s.[strSubstituteRatio], s.[strMaxSubstituteRatio]), @dblRecipeDetailUpperTolerance)
				,dbo.fnMFCalculateRecipeSubItemLowerTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty, s.[strSubstituteRatio], s.[strMaxSubstituteRatio]), @dblRecipeDetailLowerTolerance)
				,1
				,@intUserId
				,GETDATE()
				,@intUserId
				,GETDATE()
			FROM tblMFRecipeSubstituteItemStage s
			LEFT JOIN tblICItem i ON s.strSubstituteItemNo = i.strItemNo
			WHERE s.intRecipeSubstituteItemStageId = @intMinId
		END
		ELSE
		BEGIN --update
			UPDATE rs
			SET rs.dblQuantity = t.dblQuantity
				,rs.dblSubstituteRatio = t.[strSubstituteRatio]
				,rs.dblMaxSubstituteRatio = t.[strMaxSubstituteRatio]
				,rs.dblCalculatedUpperTolerance = t.dblUpperTolerance
				,rs.dblCalculatedLowerTolerance = t.dblLowerTolerance
				,rs.intLastModifiedUserId = @intUserId
				,rs.dtmLastModified = GETDATE()
			FROM tblMFRecipeSubstituteItem rs
			CROSS JOIN (
				SELECT TOP 1 dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty, s.[strSubstituteRatio], s.[strMaxSubstituteRatio]) dblQuantity
					,s.[strSubstituteRatio]
					,s.[strMaxSubstituteRatio]
					,dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty, s.[strSubstituteRatio], s.[strMaxSubstituteRatio]), @dblRecipeDetailUpperTolerance) dblUpperTolerance
					,dbo.fnMFCalculateRecipeSubItemLowerTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty, s.[strSubstituteRatio], s.[strMaxSubstituteRatio]), @dblRecipeDetailLowerTolerance) dblLowerTolerance
				FROM tblMFRecipeSubstituteItemStage s
				WHERE s.intRecipeSubstituteItemStageId = @intMinId
				) t
			WHERE rs.intRecipeSubstituteItemId = @intRecipeSubstituteItemId
		END

		UPDATE tblMFRecipeSubstituteItemStage
		SET strMessage = 'Success'
		WHERE intRecipeSubstituteItemStageId = @intMinId

		NEXT_SUBITEM:

		SELECT @intMinId = MIN(intRecipeSubstituteItemStageId)
		FROM tblMFRecipeSubstituteItemStage
		WHERE intRecipeSubstituteItemStageId > @intMinId
			AND strSessionId = @strSessionId
			AND ISNULL(strMessage, '') = ''
	END

	UPDATE tblMFRecipeSubstituteItemStage
	SET strMessage = 'Skipped'
	WHERE strSessionId = @strSessionId
		AND ISNULL(strMessage, '') = ''
END

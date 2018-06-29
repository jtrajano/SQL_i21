CREATE PROCEDURE [dbo].[uspMFCopyRecipe] (
	@intItemId INT
	,@intLocationId INT
	,@intUserId INT
	,@intWorkOrderId INT
	)
AS
BEGIN TRY
	DECLARE @intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@intRecipeId INT
		,@intAttributeId INT
		,@intManufacturingProcessId INT
		,@strAttributeValue NVARCHAR(50)
		,@dtmExpectedDate DATETIME
	DECLARE @tblMFWorkOrderRecipeItem TABLE (
		intWorkOrderRecipeItemId INT
		,[intWorkOrderId] INT
		,[intRecipeItemId] INT
		,[intRecipeId] INT
		,[intItemId] INT
		,[dblQuantity] NUMERIC(18, 6)
		,[dblCalculatedQuantity] NUMERIC(18, 6)
		,[intItemUOMId] INT
		,[intRecipeItemTypeId] INT
		,[strItemGroupName] NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,[dblUpperTolerance] NUMERIC(18, 6)
		,[dblLowerTolerance] NUMERIC(18, 6)
		,[dblCalculatedUpperTolerance] NUMERIC(18, 6)
		,[dblCalculatedLowerTolerance] NUMERIC(18, 6)
		,[dblShrinkage] NUMERIC(18, 6)
		,[ysnScaled] BIT
		,[intConsumptionMethodId] INT
		,[intStorageLocationId] INT
		,[dtmValidFrom] DATETIME
		,[dtmValidTo] DATETIME
		,[ysnYearValidationRequired] BIT
		,[ysnMinorIngredient] BIT
		,[intReferenceRecipeId] INT
		,[ysnOutputItemMandatory] BIT
		,[dblScrap] NUMERIC(18, 6)
		,[ysnConsumptionRequired] BIT
		,[dblLaborCostPerUnit] NUMERIC(18, 6)
		,[intLaborCostCurrencyId] INT
		,[dblOverheadCostPerUnit] NUMERIC(18, 6)
		,[intOverheadCostCurrencyId] INT
		,[dblPercentage] NUMERIC(18, 6)
		,[intMarginById] [int]
		,[dblMargin] NUMERIC(18, 6)
		,[ysnCostAppliedAtInvoice] BIT
		,ysnPartialFillConsumption BIT
		,[intManufacturingCellId] [int]
		,[intCreatedUserId] [int]
		,[dtmCreated] [datetime]
		,[intLastModifiedUserId] [int]
		,[dtmLastModified] [datetime]
		,[intConcurrencyId] INT
		,[intCostDriverId] [int]
		,[dblCostRate] NUMERIC(18, 6)
		,[ysnLock] BIT
		)
	DECLARE @tblMFWorkOrderRecipeSubstituteItem TABLE (
		intWorkOrderId INT
		,intRecipeSubstituteItemId INT
		,intRecipeItemId INT
		,intRecipeId INT
		,intItemId INT
		,intSubstituteItemId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,dblSubstituteRatio NUMERIC(18, 6)
		,dblMaxSubstituteRatio NUMERIC(18, 6)
		,dblCalculatedUpperTolerance NUMERIC(18, 6)
		,dblCalculatedLowerTolerance NUMERIC(18, 6)
		,intRecipeItemTypeId INT
		,intCreatedUserId INT
		,dtmCreated DATETIME
		,intLastModifiedUserId INT
		,dtmLastModified DATETIME
		,intConcurrencyId INT
		)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@dtmExpectedDate = dtmExpectedDate
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Recipe Item Validity By Due Date'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strAttributeValue = 'False'
		OR @strAttributeValue IS NULL
		SELECT @dtmCurrentDateTime = GETDATE()
	ELSE
		SELECT @dtmCurrentDateTime = @dtmExpectedDate

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	INSERT INTO @tblMFWorkOrderRecipeItem (
		intWorkOrderRecipeItemId
		,intWorkOrderId
		,intRecipeItemId
		,intRecipeId
		,intItemId
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
		,intReferenceRecipeId
		,ysnOutputItemMandatory
		,dblScrap
		,ysnConsumptionRequired
		,dblLaborCostPerUnit
		,intLaborCostCurrencyId
		,dblOverheadCostPerUnit
		,intOverheadCostCurrencyId
		,dblPercentage
		,intMarginById
		,dblMargin
		,ysnCostAppliedAtInvoice
		,ysnPartialFillConsumption
		,intManufacturingCellId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,intCostDriverId
		,dblCostRate
		)
	SELECT intWorkOrderRecipeItemId
		,intWorkOrderId
		,intRecipeItemId
		,intRecipeId
		,intItemId
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
		,intReferenceRecipeId
		,ysnOutputItemMandatory
		,dblScrap
		,ysnConsumptionRequired
		,dblLaborCostPerUnit
		,intLaborCostCurrencyId
		,dblOverheadCostPerUnit
		,intOverheadCostCurrencyId
		,dblPercentage
		,intMarginById
		,dblMargin
		,ysnCostAppliedAtInvoice
		,ysnPartialFillConsumption
		,intManufacturingCellId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,intCostDriverId
		,dblCostRate
	FROM tblMFWorkOrderRecipeItem
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnLock = 1

	INSERT INTO @tblMFWorkOrderRecipeSubstituteItem (
		intWorkOrderId
		,intRecipeSubstituteItemId
		,intRecipeItemId
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
		,intConcurrencyId
		)
	SELECT intWorkOrderId
		,intRecipeSubstituteItemId
		,intRecipeItemId
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
		,intConcurrencyId
	FROM tblMFWorkOrderRecipeSubstituteItem
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnLock = 1

	DELETE
	FROM dbo.tblMFWorkOrderRecipe
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId = intRecipeId
	FROM dbo.tblMFRecipe
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1

	INSERT INTO dbo.tblMFWorkOrderRecipe (
		intRecipeId
		,intItemId
		,dblQuantity
		,[intItemUOMId]
		,intLocationId
		,intVersionNo
		,intRecipeTypeId
		,intManufacturingProcessId
		,ysnActive
		,ysnImportOverride
		,ysnAutoBlend
		,intCustomerId
		,intFarmId
		,intFieldId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	SELECT intRecipeId
		,intItemId
		,dblQuantity
		,[intItemUOMId]
		,intLocationId
		,intVersionNo
		,intRecipeTypeId
		,intManufacturingProcessId
		,ysnActive
		,ysnImportOverride
		,ysnAutoBlend
		,intCustomerId
		,intFarmId
		,intFieldId
		,@intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
	FROM dbo.tblMFRecipe
	WHERE intRecipeId = @intRecipeId

	INSERT INTO tblMFWorkOrderRecipeItem (
		intRecipeItemId
		,intRecipeId
		,intItemId
		,dblQuantity
		,dblCalculatedQuantity
		,[intItemUOMId]
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
		,intReferenceRecipeId
		,ysnOutputItemMandatory
		,dblScrap
		,ysnConsumptionRequired
		,dblPercentage
		,intMarginById
		,dblMargin
		,ysnCostAppliedAtInvoice
		,ysnPartialFillConsumption
		,intManufacturingCellId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,intCostDriverId
		,dblCostRate
		)
	SELECT intRecipeItemId
		,intRecipeId
		,intItemId
		,dblQuantity
		,dblCalculatedQuantity
		,[intItemUOMId]
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
		,intReferenceRecipeId
		,ysnOutputItemMandatory
		,dblScrap
		,ysnConsumptionRequired
		,[dblCostAllocationPercentage]
		,intMarginById
		,dblMargin
		,ysnCostAppliedAtInvoice
		,ysnPartialFillConsumption
		,intManufacturingCellId
		,@intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,intCostDriverId
		,dblCostRate
	FROM dbo.tblMFRecipeItem ri
	WHERE intRecipeId = @intRecipeId
		AND (
			intRecipeItemTypeId = 2
			OR (
				intRecipeItemTypeId = 1
				AND (
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			)

	INSERT INTO tblMFWorkOrderRecipeItem (
		intRecipeItemId
		,intRecipeId
		,intItemId
		,dblQuantity
		,dblCalculatedQuantity
		,[intItemUOMId]
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
		,intReferenceRecipeId
		,ysnOutputItemMandatory
		,dblScrap
		,ysnConsumptionRequired
		,dblPercentage
		,intMarginById
		,dblMargin
		,ysnCostAppliedAtInvoice
		,ysnPartialFillConsumption
		,intManufacturingCellId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,intCostDriverId
		,dblCostRate
		,ysnLock
		)
	SELECT intRecipeItemId
		,intRecipeId
		,intItemId
		,dblQuantity
		,dblCalculatedQuantity
		,[intItemUOMId]
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
		,intReferenceRecipeId
		,ysnOutputItemMandatory
		,dblScrap
		,ysnConsumptionRequired
		,dblPercentage
		,intMarginById
		,dblMargin
		,ysnCostAppliedAtInvoice
		,ysnPartialFillConsumption
		,intManufacturingCellId
		,@intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,intCostDriverId
		,dblCostRate
		,1
	FROM @tblMFWorkOrderRecipeItem ri

	INSERT INTO dbo.tblMFWorkOrderRecipeSubstituteItem (
		intRecipeSubstituteItemId
		,intRecipeItemId
		,intRecipeId
		,intItemId
		,intSubstituteItemId
		,dblQuantity
		,[intItemUOMId]
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		,dblCalculatedUpperTolerance
		,dblCalculatedLowerTolerance
		,intRecipeItemTypeId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId

		)
	SELECT rs.intRecipeSubstituteItemId
		,rs.intRecipeItemId
		,rs.intRecipeId
		,rs.intItemId
		,rs.intSubstituteItemId
		,rs.dblQuantity
		,rs.[intItemUOMId]
		,rs.dblSubstituteRatio
		,rs.dblMaxSubstituteRatio
		,rs.dblCalculatedUpperTolerance
		,rs.dblCalculatedLowerTolerance
		,rs.intRecipeItemTypeId
		,@intWorkOrderId
		,rs.intCreatedUserId
		,rs.dtmCreated
		,rs.intLastModifiedUserId
		,rs.dtmLastModified
		,rs.intConcurrencyId
	FROM dbo.tblMFRecipeSubstituteItem rs
	JOIN dbo.tblMFRecipeItem ri ON ri.intRecipeItemId = rs.intRecipeItemId
	WHERE rs.intRecipeId = @intRecipeId
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)

	INSERT INTO dbo.tblMFWorkOrderRecipeSubstituteItem (
		intRecipeSubstituteItemId
		,intRecipeItemId
		,intRecipeId
		,intItemId
		,intSubstituteItemId
		,dblQuantity
		,[intItemUOMId]
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		,dblCalculatedUpperTolerance
		,dblCalculatedLowerTolerance
		,intRecipeItemTypeId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
				,ysnLock
		)
	SELECT intRecipeSubstituteItemId
		,intRecipeItemId
		,intRecipeId
		,intItemId
		,intSubstituteItemId
		,dblQuantity
		,[intItemUOMId]
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		,dblCalculatedUpperTolerance
		,dblCalculatedLowerTolerance
		,intRecipeItemTypeId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		,1
	FROM @tblMFWorkOrderRecipeSubstituteItem

	INSERT INTO tblMFWorkOrderRecipeCategory (
		intWorkOrderId
		,intRecipeCategoryId
		,intRecipeId
		,intCategoryId
		,intRecipeItemTypeId
		)
	SELECT @intWorkOrderId
		,intRecipeCategoryId
		,intRecipeId
		,intCategoryId
		,intRecipeItemTypeId
	FROM tblMFRecipeCategory
	WHERE intRecipeId = @intRecipeId

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO



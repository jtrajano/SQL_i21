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
		,@intAttributeId int
		,@intManufacturingProcessId int
		,@strAttributeValue nvarchar(50)
		,@dtmExpectedDate DATETIME

	SELECT @intManufacturingProcessId=intManufacturingProcessId
		,@dtmExpectedDate=dtmExpectedDate
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Recipe Item Validity By Due Date'
	
	Select @strAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	IF @strAttributeValue='False' OR @strAttributeValue IS NULL
		SELECT @dtmCurrentDateTime = GETDATE()
	Else 
		SELECT @dtmCurrentDateTime = @dtmExpectedDate

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderRecipe
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		SELECT @intRecipeId = intRecipeId
		FROM dbo.tblMFRecipe
		WHERE intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND ysnActive=1

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
			,intWorkOrderId
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intConcurrencyId
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
			,@intWorkOrderId
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intConcurrencyId
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
	END

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



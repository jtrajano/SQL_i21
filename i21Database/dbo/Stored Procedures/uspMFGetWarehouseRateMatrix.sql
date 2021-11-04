CREATE PROCEDURE uspMFGetWarehouseRateMatrix (
	@intWarehouseRateMatrixHeaderId INT
	,@intWorkOrderId INT
	)
AS
BEGIN
	DECLARE @intLocationId INT
		,@intItemId INT
		,@intSubLocationId INT
		,@intManufacturingCellId INT
		,@intRecipeId INT
		,@strSubLocationName NVARCHAR(50)
		,@ysnRecipeBySite BIT
	DECLARE @tblMFInputOtherChargeItems TABLE (intItemId INT)

	SELECT @ysnRecipeBySite = ISNULL(ysnRecipeBySite, 0)
	FROM tblMFCompanyPreference

	IF @intWorkOrderId > 0
	BEGIN
		SELECT @intLocationId = intLocationId
			,@intItemId = intItemId
			,@intSubLocationId = intSubLocationId
			,@intManufacturingCellId = intManufacturingCellId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		IF @intSubLocationId IS NULL
		BEGIN
			SELECT @intSubLocationId = intSubLocationId
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId
		END

		SELECT @intRecipeId = intRecipeId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		IF @intRecipeId IS NULL
		BEGIN
			IF ISNULL(@ysnRecipeBySite, 0) = 1
			BEGIN
				SELECT @strSubLocationName = LEFT(strSubLocationName, 2)
				FROM tblSMCompanyLocationSubLocation
				WHERE intCompanyLocationSubLocationId = @intSubLocationId

				SELECT @intSubLocationId = intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation
				WHERE strSubLocationName = @strSubLocationName

				SELECT @intRecipeId = intRecipeId
				FROM dbo.tblMFRecipe
				WHERE intItemId = @intItemId
					AND intLocationId = @intLocationId
					AND ysnActive = 1
					AND intSubLocationId = @intSubLocationId
			END
			ELSE
			BEGIN
				SELECT @intRecipeId = intRecipeId
				FROM dbo.tblMFRecipe
				WHERE intItemId = @intItemId
					AND intLocationId = @intLocationId
					AND ysnActive = 1
					AND intSubLocationId = @intSubLocationId
			END

			IF @intRecipeId IS NULL
			BEGIN
				SELECT @intRecipeId = intRecipeId
				FROM dbo.tblMFRecipe
				WHERE intItemId = @intItemId
					AND intLocationId = @intLocationId
					AND ysnActive = 1
					AND intSubLocationId IS NULL
			END
		END

		DELETE
		FROM @tblMFInputOtherChargeItems

		INSERT INTO @tblMFInputOtherChargeItems (intItemId)
		SELECT DISTINCT RI.intItemId
		FROM dbo.tblMFRecipeItem RI
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND I.strType = 'Other Charge'
		WHERE RI.intRecipeId = @intRecipeId
			AND RI.intRecipeItemTypeId = 1

		SELECT WMD.intWarehouseRateMatrixDetailId
			,WMD.strCategory
			,WMD.strActivity
			,WMD.intType
			,WMD.intSort
			,WMD.dblUnitRate
			,WMD.[intItemUOMId]
			,WMD.ysnPrint
			,WMD.strComments
			,WMD.intItemId
			,WMD.intCalculateQty
			,strCalculateQty = CASE WMD.intCalculateQty
				WHEN 1
					THEN 'By Shipped Net Wt'
				WHEN 2
					THEN 'By Shipped Gross Wt'
				WHEN 3
					THEN 'By Received Net Wt'
				WHEN 4
					THEN 'By Received Gross Wt'
				WHEN 5
					THEN 'By Delivered Net Wt'
				WHEN 6
					THEN 'By Delivered Gross Wt'
				WHEN 7
					THEN 'By Quantity'
				WHEN 8
					THEN 'Manual Entry'
				END COLLATE Latin1_General_CI_AS
			,Item.strItemNo
			,WMH.intWarehouseRateMatrixHeaderId
			,WMH.strServiceContractNo
			,WMH.dtmContractDate
			,WMH.intCompanyLocationId
			,WMH.intCommodityId
			,WMH.intCompanyLocationSubLocationId
			,WMH.intVendorEntityId
			,WMH.dtmValidityFrom
			,WMH.dtmValidityTo
			,WMH.ysnActive
			,WMH.intCurrencyId
			,UOM.intUnitMeasureId
			,UOM.strUnitMeasure
			,UOM.strUnitType
			,Currency.strCurrency
		FROM tblLGWarehouseRateMatrixDetail WMD
		JOIN tblLGWarehouseRateMatrixHeader WMH ON WMH.intWarehouseRateMatrixHeaderId = WMD.intWarehouseRateMatrixHeaderId
			AND WMD.intType = 4
			AND WMD.intWarehouseRateMatrixHeaderId = @intWarehouseRateMatrixHeaderId
		JOIN @tblMFInputOtherChargeItems OCI ON OCI.intItemId = WMD.intItemId
		LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = WMD.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = WMH.intCurrencyId
		LEFT JOIN tblICItem Item ON Item.intItemId = WMD.intItemId
		ORDER BY WMD.intSort
	END
END

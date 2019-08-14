CREATE PROCEDURE [dbo].[uspCTInventoryPlan_Generate] @intInvPlngReportMasterID INT
	,@ExistingDataXML NVARCHAR(MAX)
	,@MaterialKeyXML NVARCHAR(MAX)
	,@intMonthsToView INT
	,@ysnIncludeInventory BIT
	,@intCompanyLocationId INT
	,@intUnitMeasureId INT
	,@intDemandHeaderId INT
	,@ysnTest BIT
	,@ysnAllItem BIT
	,@intCategoryId INT
	,@PlannedPurchasesXML VARCHAR(MAX)
	,@WeeksOfSupplyTargetXML VARCHAR(MAX)
	,@ForecastedConsumptionXML VARCHAR(MAX)
	,@OpenPurchaseXML VARCHAR(MAX)
	,@ysnCalculatePlannedPurchases BIT
	,@ysnCalculateEndInventory BIT
	,@ysnRefreshContract BIT
	,@ysnRefreshStock BIT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ysnDemandViewForBlend BIT

	SELECT @ysnDemandViewForBlend = ysnDemandViewForBlend
	FROM tblCTCompanyPreference

	IF @ysnDemandViewForBlend = 0
		BEGIN
			EXEC [dbo].[uspCTInventoryPlan_GenerateForItem]
				@intInvPlngReportMasterID
				,@ExistingDataXML
				,@MaterialKeyXML
				,@intMonthsToView
				,@ysnIncludeInventory
				,@intCompanyLocationId
				,@intUnitMeasureId
				,@intDemandHeaderId
				,@PlannedPurchasesXML
				,@WeeksOfSupplyTargetXML
				,@ForecastedConsumptionXML
				,@ysnCalculatePlannedPurchases
				,@ysnRefreshContract
				,@ysnRefreshStock
		END
	ELSE
		BEGIN
			EXEC [dbo].[uspCTInventoryPlan_GenerateForBlend]
				@intInvPlngReportMasterID
				,@ExistingDataXML
				,@MaterialKeyXML
				,@intMonthsToView
				,@ysnIncludeInventory
				,@intCompanyLocationId
				,@intUnitMeasureId
				,@intDemandHeaderId
				,@PlannedPurchasesXML
				,@WeeksOfSupplyTargetXML
				,@ForecastedConsumptionXML
				,@ysnCalculatePlannedPurchases
				,@ysnRefreshContract
				,@ysnRefreshStock
		END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH

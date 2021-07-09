CREATE PROCEDURE [dbo].[uspLGAddUpdateFreightFromBatchLoad]
	@intLoadId AS INT
	,@dblFreightRate AS NUMERIC(18, 6) = NULL
	,@dblSurcharge AS NUMERIC(18, 6) = NULL
	,@intUserId AS INT = NULL
AS

DECLARE @intDefaultFreightItem INT
DECLARE @intDefaultSurchargeItem INT
DECLARE @intFreightLoadCostId INT
DECLARE @intSurchargeLoadCostId INT

--Check if Freight item is configured
IF NOT EXISTS(SELECT TOP 1 1 FROM tblLGCompanyPreference WHERE intDefaultFreightItemId IS NOT NULL)
RETURN;

SELECT TOP 1 
	@intDefaultFreightItem = intDefaultFreightItemId
	,@intDefaultSurchargeItem = intDefaultSurchargeItemId
FROM tblLGCompanyPreference

IF (@dblFreightRate IS NOT NULL AND @dblFreightRate <> 0)
BEGIN
	SELECT TOP 1 @intFreightLoadCostId = intLoadCostId FROM tblLGLoadCost 
	WHERE intLoadId = @intLoadId AND intItemId = @intDefaultFreightItem AND intBillId IS NULL

	IF @intFreightLoadCostId IS NOT NULL
	BEGIN
		--Update if exists
		UPDATE LC 
			SET dblRate = @dblFreightRate
				,dblAmount = CASE WHEN (intFreightUOMId IS NULL) THEN @dblFreightRate 
							ELSE IsNull(dbo.[fnCalculateCostBetweenUOM](intFreightUOMId,FUOM.intItemUOMId,@dblFreightRate),0.0) * dblUnitsPerLoad END
				,strCostMethod = CASE WHEN (intFreightUOMId IS NULL) THEN 'Amount' ELSE 'Per Unit' END
				,intItemUOMId = BL.intFreightUOMId
				,intCurrencyId = BL.intFreightCurrencyId
				,intConcurrencyId = LC.intConcurrencyId + 1
		FROM tblLGLoadCost LC
			INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			INNER JOIN tblLGGenerateLoad BL ON BL.intGenerateLoadId = L.intGenerateLoadId
			OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM 
						WHERE intItemId = @intDefaultFreightItem AND intUnitMeasureId = BL.intUnitMeasureId) FUOM
		WHERE intLoadCostId = @intFreightLoadCostId
	END
	ELSE
	BEGIN
		--Add if not exists
		INSERT INTO tblLGLoadCost(
			intLoadId
			,intItemId
			,intVendorId
			,strEntityType
			,strCostMethod
			,intCurrencyId
			,dblRate
			,dblAmount
			,dblFX
			,intItemUOMId
			,ysnAccrue
			,ysnMTM
			,ysnPrice
			,intBillId
			,intLoadCostRefId
			,intConcurrencyId)
		SELECT
			intLoadId = @intLoadId
			,intItemId = @intDefaultFreightItem
			,intVendorId = L.intHaulerEntityId
			,strEntityType = 'Vendor'
			,strCostMethod = CASE WHEN (intFreightUOMId IS NULL) THEN 'Amount' ELSE 'Per Unit' END
			,intCurrencyId = intFreightCurrencyId
			,dblRate = @dblFreightRate
			,dblAmount = CASE WHEN (intFreightUOMId IS NULL) THEN @dblFreightRate 
							ELSE dbo.fnMultiply(IsNull(dbo.[fnCalculateCostBetweenUOM](intFreightUOMId,FUOM.intItemUOMId,@dblFreightRate),0.0), dblUnitsPerLoad) END
			,dblFX = 1
			,intItemUOMId = intFreightUOMId
			,ysnAccrue = CASE WHEN (L.intTransUsedBy = 2) THEN 1 ELSE 0 END
			,ysnMTM = 0
			,ysnPrice = 0
			,intBillId = NULL
			,intLoadCostRefId = NULL
			,intConcurrencyId = 1
		FROM tblLGLoad L
			INNER JOIN tblLGGenerateLoad BL ON BL.intGenerateLoadId = L.intGenerateLoadId
			OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM 
						WHERE intItemId = @intDefaultFreightItem AND intUnitMeasureId = BL.intUnitMeasureId) FUOM
		WHERE L.intLoadId = @intLoadId
	END
END

--Check if Surcharge is configured
IF NOT EXISTS(SELECT TOP 1 1 FROM tblLGCompanyPreference WHERE intDefaultSurchargeItemId IS NOT NULL)
RETURN;

IF (@dblSurcharge IS NOT NULL AND @dblSurcharge <> 0)
BEGIN
	SELECT TOP 1 @intSurchargeLoadCostId = intLoadCostId FROM tblLGLoadCost 
	WHERE intLoadId = @intLoadId AND intItemId = @intDefaultSurchargeItem AND intBillId IS NULL

	IF @intSurchargeLoadCostId IS NOT NULL
	BEGIN
		--Update if exists
		UPDATE LC 
			SET dblRate = @dblSurcharge
				,dblAmount = dbo.fnMultiply(
								CASE WHEN (@dblFreightRate IS NOT NULL) THEN 
									CASE WHEN (intFreightUOMId IS NULL) THEN @dblFreightRate 
									ELSE dbo.fnMultiply(IsNull(dbo.[fnCalculateCostBetweenUOM](intFreightUOMId,FUOM.intItemUOMId,@dblFreightRate),0.0), dblUnitsPerLoad) END
								 ELSE 
									FA.dblAmount
								 END
							,(dbo.fnDivide(@dblSurcharge, 100)))
				,intConcurrencyId = LC.intConcurrencyId + 1
		FROM tblLGLoadCost LC
			INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			INNER JOIN tblLGGenerateLoad BL ON BL.intGenerateLoadId = L.intGenerateLoadId
			OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = @intDefaultFreightItem AND intUnitMeasureId = BL.intUnitMeasureId) FUOM
			OUTER APPLY (SELECT TOP 1 dblAmount FROM tblLGLoadCost WHERE intLoadId = @intLoadId AND intItemId = @intDefaultFreightItem) FA
		WHERE intLoadCostId = @intSurchargeLoadCostId
	END
	ELSE
	BEGIN
		--Add if not exists
		INSERT INTO tblLGLoadCost(
			intLoadId
			,intItemId
			,intVendorId
			,strEntityType
			,strCostMethod
			,intCurrencyId
			,dblRate
			,dblAmount
			,dblFX
			,intItemUOMId
			,ysnAccrue
			,ysnMTM
			,ysnPrice
			,intBillId
			,intLoadCostRefId
			,intConcurrencyId)
		SELECT
			intLoadId = @intLoadId
			,intItemId = @intDefaultSurchargeItem
			,intVendorId = L.intHaulerEntityId
			,strEntityType = 'Vendor'
			,strCostMethod = 'Percentage'
			,intCurrencyId = intFreightCurrencyId
			,dblRate = @dblSurcharge
			,dblAmount = dbo.fnMultiply(
								CASE WHEN (@dblFreightRate IS NOT NULL) THEN 
									CASE WHEN (intFreightUOMId IS NULL) THEN @dblFreightRate 
									ELSE dbo.fnMultiply(IsNull(dbo.[fnCalculateCostBetweenUOM](intFreightUOMId,FUOM.intItemUOMId,@dblFreightRate),0.0), dblUnitsPerLoad) END
								 ELSE 
									FA.dblAmount
								 END
							,(dbo.fnDivide(@dblSurcharge, 100)))
			,dblFX = 1
			,intItemUOMId = NULL
			,ysnAccrue = CASE WHEN (L.intTransUsedBy = 2) THEN 1 ELSE 0 END
			,ysnMTM = 0
			,ysnPrice = 0
			,intBillId = NULL
			,intLoadCostRefId = NULL
			,intConcurrencyId = 1
		FROM tblLGLoad L
			INNER JOIN tblLGGenerateLoad BL ON BL.intGenerateLoadId = L.intGenerateLoadId
			OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = @intDefaultFreightItem AND intUnitMeasureId = BL.intUnitMeasureId) FUOM
			OUTER APPLY (SELECT TOP 1 dblAmount FROM tblLGLoadCost WHERE intLoadId = @intLoadId AND intItemId = @intDefaultFreightItem) FA
		WHERE L.intLoadId = @intLoadId
	END
END

GO
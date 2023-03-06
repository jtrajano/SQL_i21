CREATE PROCEDURE [dbo].[uspLGGenerateLoadDetail]
	@intLoadId INT,
	@intContractDetailId INT,
	@dblQty NUMERIC(18,6),
	@intItemUOMId INT,
	@intEntityUserId INT,
	@intLoadDetailId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	
	DECLARE @intPurchaseSale INT

	SELECT @intPurchaseSale = L.intPurchaseSale
	FROM tblLGLoad L
	WHERE L.intLoadId = @intLoadId

	IF @intPurchaseSale = 1
	BEGIN
		-- Insert Load Detail
		INSERT INTO tblLGLoadDetail (
			[intConcurrencyId]
			,[intLoadId]
			,[intPCompanyLocationId]
			,[intVendorEntityId]
			,[intVendorEntityLocationId]
			,[intPContractDetailId]
			,[dblUnitPrice]
			,[intPriceUOMId]
			,[intPriceCurrencyId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblGross]
			,[dblTare]
			,[dblNet]
			,[dblDeliveredQuantity]
			,[dblDeliveredGross]
			,[dblDeliveredNet]
			,[dblDeliveredTare]
			,[intWeightItemUOMId]
			,[strScheduleInfoMsg]
			,[strLoadDirectionMsg]
			,[ysnPrintLoadDirections]
			,[ysnPrintScheduleInfo]
			,[dblAmount]
		)
		SELECT
			[intConcurrencyId]					= 1
			,[intLoadId]						= @intLoadId
			,[intPCompanyLocationId]			= CD.intCompanyLocationId
			,[intVendorEntityId]				= CH.intEntityId
			,[intVendorEntityLocationId]		= V.intDefaultLocationId
			,[intPContractDetailId]				= CD.intContractDetailId
			,[dblUnitPrice]						= CD.dblCashPrice
			,[intPriceUOMId]					= CD.intPriceItemUOMId
			,[intPriceCurrencyId]				= CD.intCurrencyId
			,[intItemId]						= CD.intItemId
			,[intItemUOMId]						= @intItemUOMId
			,[dblQuantity]						= @dblQty
			,[dblGross]							= @dblQty * W.dblWeightUnitQty
			,[dblTare]							= 0
			,[dblNet]							= @dblQty * W.dblWeightUnitQty
			,[dblDeliveredQuantity]				= 0
			,[dblDeliveredGross]				= 0
			,[dblDeliveredNet]					= 0
			,[dblDeliveredTare]					= 0
			,[intWeightItemUOMId]				= WIUOM.intItemUOMId
			,[strScheduleInfoMsg]				= LSM.strMessage
			,[strLoadDirectionMsg]				= LDM.strMessage
			,[ysnPrintLoadDirections]			= 1
			,[ysnPrintScheduleInfo]				= 1
			,[dblAmount]						= @dblQty * CD.dblCashPrice * (ISNULL(dbo.fnCalculateCostBetweenUOM(CD.intPriceItemUOMId, @intItemUOMId, 1), 0))
													/ CASE WHEN C.ysnSubCurrency = 1 THEN 100 ELSE 1 END
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblLGLoad L ON L.intLoadId = @intLoadId
		INNER JOIN tblICItemUOM WIUOM ON WIUOM.intItemId = CD.intItemId AND WIUOM.intUnitMeasureId = L.intWeightUnitMeasureId
		INNER JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId
		LEFT JOIN vyuAPVendor V ON V.intEntityId = CH.intEntityId
		OUTER APPLY (
			SELECT [dblWeightUnitQty] = ISNULL(dbo.fnLGGetItemUnitConversion(CD.intItemId, @intItemUOMId, L.intWeightUnitMeasureId), 0)
		) W
		OUTER APPLY (
			SELECT TOP 1 strMessage
			FROM tblEMEntityMessage EM
			WHERE EM.intEntityId = CH.intEntityId
			AND strMessageType = 'Load Scheduling'
		) LSM
		OUTER APPLY (
			SELECT TOP 1 strMessage
			FROM tblEMEntityMessage EM
			WHERE EM.intEntityId = CH.intEntityId
			AND strMessageType = 'Load Directions'
		) LDM
		WHERE CD.intContractDetailId = @intContractDetailId

		SELECT @intLoadDetailId = SCOPE_IDENTITY()

		-- Schedule load contract qty
        EXEC uspCTUpdateScheduleQuantityUsingUOM
			@intContractDetailId
			,@dblQty
			,@intEntityUserId
			,@intLoadDetailId
			,'Load Schedule'
			,@intItemUOMId

		-- Audit log
        -- TODO: Upgrade implementation of audit log with the new method in higher versions
        DECLARE @details NVARCHAR(MAX)

        SELECT @details = '{"change": "tblLGLoadDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Created", "change": "Created - Record: ' + V.strName + ' (P.Contract: ' + CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR(4)) + ')", "keyValue": ' + CAST(@intLoadDetailId as varchar(15)) + ', "iconCls": "small-new-plus", "leaf": true}]}'
        FROM tblLGLoadDetail LD
        INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
        INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
        INNER JOIN tblEMEntity V ON V.intEntityId = CH.intEntityId
        WHERE LD.intLoadDetailId = @intLoadDetailId

        EXEC uspSMAuditLog
            @screenName = 'Logistics.view.ShipmentSchedule',
            @entityId = @intEntityUserId,
            @actionType = 'Updated',
            @actionIcon = 'small-tree-modified',
            @keyValue = @intLoadId,
            @details = @details
	END

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text
		@ErrorSeverity, -- Severity
		@ErrorState -- State
	);
END CATCH
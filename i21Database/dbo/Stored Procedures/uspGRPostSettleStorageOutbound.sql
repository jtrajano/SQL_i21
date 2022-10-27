﻿CREATE PROCEDURE [dbo].[uspGRPostSettleStorageOutbound]
(
	@intSettleStorageId INT
	,@dtmClientPostDate DATETIME = NULL
)
AS
BEGIN TRY
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @StorageHistoryData AS StorageHistoryStagingTable

	/****START: VALIDATE FIRST IF NO OVERSETTLEMENT SHALL HAPPEN****/
	DECLARE @customerStorageIds AS Id
	DECLARE @ysnOverSettled BIT

	INSERT INTO @customerStorageIds
	SELECT intCustomerStorageId
	FROM tblGRSettleStorageTicket
	WHERE intSettleStorageId = @intSettleStorageId

	SELECT @ysnOverSettled = CAST(CASE WHEN SUM(dblHistoryTotal) < SUM(dblSettleTotal) THEN 1 ELSE 0 END AS BIT)
	FROM (
		SELECT intCustomerStorageId
			,dblHistoryTotal = SUM(CASE 
								WHEN (strType = 'Settlement' OR strType ='Reduced By Inventory Shipment') AND dblUnits > 0 THEN - dblUnits 
								ELSE dblUnits 
							END)
			,dblSettleTotal = 0
		FROM tblGRStorageHistory SH
		INNER JOIN @customerStorageIds CS
			ON CS.intId = SH.intCustomerStorageId
		WHERE intTransactionTypeId NOT IN (2,6)
		GROUP BY intCustomerStorageId
		UNION ALL
		SELECT SST.intCustomerStorageId
			,0
			,dblSettleTotal = SUM(SST.dblUnits)
		FROM tblGRSettleStorageTicket SST
		INNER JOIN @customerStorageIds CS
			ON CS.intId = SST.intCustomerStorageId
		GROUP BY SST.intCustomerStorageId
	) A
	GROUP BY intCustomerStorageId

	IF @ysnOverSettled = 1
	BEGIN
		RAISERROR('Unable to settle storage. Please check the storage and try again.',16,1,1)
		GOTO Exit_post;
	END
	/****END: VALIDATE FIRST IF NO OVERSETTLEMENT SHALL HAPPEN****/

	--create STR-
	EXEC uspGRCreateSettleStorage @intSettleStorageId

	DECLARE @createdSettleStorages AS Id
	DECLARE @intId INT --STR id
	DECLARE @SettleStorages AS TABLE (
		intCnt INT IDENTITY(1,1)
		,intSettleStorageId INT
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,intInventoryShipmentItemId INT
		,strSettlementType NVARCHAR(10) COLLATE Latin1_General_CI_AS--Spot or Contract
		,intCommodityId INT
		,intInventoryItemId INT
		,dblUnits DECIMAL(18,6)
		,dblUnitsInGross DECIMAL(18,6)
		,dblPrice DECIMAL(18,6)
		,intItemUOMId INT
		,intCommodityStockUomId INT
		,intUnitMeasureId INT
		,intContractHeaderId INT
		,intContractDetailId INT NULL
		,intDPContractDetailId INT
		,strStorageAdjustment NVARCHAR(20) COLLATE Latin1_General_CI_AS
		,dtmStorageChargeDate DATE
		,intUserId INT
	)
	DECLARE @SettlementItemsForInvoice AS TABLE (
		intCnt INT IDENTITY(1,1)
		,intSettleStorageId INT
		,intCustomerStorageId INT
		,intInventoryShipmentItemId INT
		,intItemId INT
		,strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS--Spot or Contract
		,intItemUOMId INT
		,intUnitMeasureId INT
		,strSettlementType NVARCHAR(10) COLLATE Latin1_General_CI_AS--Spot or Contract
		,dblUnits DECIMAL(18,6)
		,dblPrice DECIMAL(18,6)		
		,intContractHeaderId INT
		,intContractDetailId INT NULL
		,intItemTypeId INT
	)
	DECLARE @intCnt INT
	DECLARE @intSettleStorageTicketId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @intInventoryShipmentItemId INT
	DECLARE @strStorageTicketNumber NVARCHAR(40)
	DECLARE @intCompanyLocationId INT
	DECLARE @intCompanyLocationSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intCurrencyId INT
	DECLARE @strSettlementType NVARCHAR(10)
	DECLARE @intContractHeaderId INT
	DECLARE @intContractDetailId INT
	DECLARE @intDPContractDetailId INT
	DECLARE @intCommodityId INT
	DECLARE @intInventoryItemId INT
	DECLARE @dblUnits DECIMAL(18,6)
	DECLARE @dblUnitsInGross DECIMAL(18,6)
	DECLARE @dblPrice DECIMAL(18,6)
	DECLARE @intItemUOMId INT
	DECLARE @intCommodityStockUomId INT
	DECLARE @intUnitMeasureId INT
	DECLARE @intUserId INT

	DECLARE @CreatedInvoices NVARCHAR(MAX)
	DECLARE @intHistoryStorageId INT

	/*	intItemTypeId
		-------------
		1-Inventory
		2-Storage Charge
		3-Discount
		4-Fee
   */

	--STORAGE CHARGE
	DECLARE @strStorageAdjustment NVARCHAR(20)
	DECLARE @strProcessType NVARCHAR(20)
	DECLARE @dtmStorageChargeDate DATE
	DECLARE @dblStorageDuePerUnit DECIMAL(24,10)
	DECLARE @dblStorageDueAmount DECIMAL(24,10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24,10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24,10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24,10)
	DECLARE @dblStorageBilledAmount DECIMAL(24,10)
	DECLARE @dblFlatFeeTotal DECIMAL(24,10)
	DECLARE @dblAdjustPerUnit DECIMAL(24,10)
	DECLARE @dblTicketStorageDue DECIMAL(24,10)

	INSERT INTO @createdSettleStorages
	SELECT intSettleStorageId
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId = @intSettleStorageId

	SELECT @intId = MIN(intId) FROM @createdSettleStorages
	
	WHILE ISNULL(@intId,0) > 0
	BEGIN
		DELETE FROM @SettlementItemsForInvoice

		--store units and settlement type in @SettleStorages
		DELETE FROM @SettleStorages
		INSERT INTO @SettleStorages
		--SPOT
		SELECT @intId
			,SST.intSettleStorageTicketId
			,CS.intCustomerStorageId
			,DP.intInventoryShipmentItemId
			,strSettlementType		= CASE WHEN ISNULL(dblSpotUnits,0) > 0 THEN 'Spot' ELSE 'Contract' END
			,CS.intCommodityId
			,CS.intItemId
			,dblUnits				= SS.dblSpotUnits
			,dblUnitsInGross		= ROUND((SS.dblSpotUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity, 6)
			,dblPrice				= SS.dblCashPrice			
			,intItemUOMId			= SS.intItemUOMId
			,intCommodityStockUomId	= SS.intCommodityStockUomId
			,intUnitMeasureId		= UOM.intUnitMeasureId
			,NULL
			,NULL
			,DP.intContractDetailId
			,SS.strStorageAdjustment
			,SS.dtmCalculateStorageThrough
			,SS.intCreatedUserId
		FROM tblGRSettleStorage SS
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = SST.intCustomerStorageId
		INNER JOIN tblICItemUOM UOM
			ON UOM.intItemUOMId = CS.intItemUOMId
		OUTER APPLY (
			SELECT CD.intContractDetailId
				,IS_Item.intInventoryShipmentItemId
			FROM tblGRStorageHistory SH
			INNER JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = SH.intContractHeaderId
			INNER JOIN tblICInventoryShipmentItem IS_Item
				ON IS_Item.intInventoryShipmentId = SH.intInventoryShipmentId
					AND IS_Item.intOrderId = SH.intContractHeaderId
			WHERE intCustomerStorageId = CS.intCustomerStorageId 
				AND intTransactionTypeId = 1 --From Scale
		) DP
		WHERE SS.intSettleStorageId = @intId
			AND ISNULL(SS.dblSpotUnits,0) > 0
		UNION ALL
		--CONTRACT
		SELECT @intId
			,SST.intSettleStorageTicketId
			,CS.intCustomerStorageId
			,DP.intInventoryShipmentItemId
			,strSettlementType		= 'Contract'
			,CS.intCommodityId
			,CS.intItemId
			,dblUnits				= SC.dblUnits
			,dblUnitsInGross		= ROUND((SC.dblUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity, 6)
			,dblPrice				= CD.dblCashPrice
			,intItemUOMId			= CS.intItemUOMId
			,intCommodityStockUomId	= SS.intCommodityStockUomId
			,intUnitMeasureId		= UOM.intUnitMeasureId
			,CD.intContractHeaderId
			,SC.intContractDetailId
			,DP.intContractDetailId
			,SS.strStorageAdjustment
			,SS.dtmCalculateStorageThrough
			,SS.intCreatedUserId
		FROM tblGRSettleStorage SS
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = SST.intCustomerStorageId
		INNER JOIN tblICItemUOM UOM
			ON UOM.intItemUOMId = CS.intItemUOMId
		INNER JOIN tblGRSettleContract SC
			ON SC.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SC.intContractDetailId
		OUTER APPLY (
			SELECT CD.intContractDetailId
				,IS_Item.intInventoryShipmentItemId
			FROM tblGRStorageHistory SH
			INNER JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = SH.intContractHeaderId
			INNER JOIN tblICInventoryShipmentItem IS_Item
				ON IS_Item.intInventoryShipmentId = SH.intInventoryShipmentId
					AND IS_Item.intOrderId = SH.intContractHeaderId
			WHERE intCustomerStorageId = CS.intCustomerStorageId 
				AND intTransactionTypeId = 1 --From Scale
		) DP
		WHERE SS.intSettleStorageId = @intId
		select '@SettleStorages',* from @SettleStorages
		--calculate storage charges which will be deducted to the invoice
		--build the settlement items for invoice
		SELECT @intCnt = MIN(intCnt) FROM @SettleStorages

		WHILE ISNULL(@intCnt,0) > 0
		BEGIN
			SET @intSettleStorageTicketId = NULL
			SET @intCustomerStorageId = NULL
			SET @intInventoryShipmentItemId = NULL
			SET @strSettlementType = NULL
			SET @intInventoryItemId = NULL
			SET @dblUnits = NULL
			SET @dblUnitsInGross = NULL
			SET @dblPrice = NULL
			SET @intItemUOMId = NULL
			SET @intCommodityStockUomId = NULL
			SET @intUnitMeasureId = NULL
			SET @intContractHeaderId = NULL
			SET @intContractDetailId = NULL
			SET @intDPContractDetailId = NULL
			SET @strStorageAdjustment = NULL
			SET @dtmStorageChargeDate = NULL
			SET @intUserId = NULL			

			SET @strProcessType = NULL
			SET @dblStorageDuePerUnit = 0
			SET @dblStorageDueAmount = 0
			SET @dblStorageDueTotalPerUnit = 0
			SET @dblStorageDueTotalAmount = 0
			SET @dblStorageBilledPerUnit = 0
			SET @dblStorageBilledAmount = 0
			SET @dblFlatFeeTotal = 0

			SELECT @intSettleStorageTicketId	= intSettleStorageTicketId
				,@intCustomerStorageId			= intCustomerStorageId
				,@intInventoryShipmentItemId	= intInventoryShipmentItemId
				,@strSettlementType				= strSettlementType
				,@intInventoryItemId			= intInventoryItemId
				,@dblUnits						= dblUnits
				,@dblUnitsInGross				= dblUnitsInGross
				,@dblPrice						= dblPrice
				,@intItemUOMId					= intItemUOMId
				,@intCommodityStockUomId		= intCommodityStockUomId
				,@intUnitMeasureId				= intUnitMeasureId
				,@intContractHeaderId			= intContractHeaderId
				,@intContractDetailId			= intContractDetailId
				,@intDPContractDetailId			= intDPContractDetailId
				,@strStorageAdjustment			= strStorageAdjustment
				,@dtmStorageChargeDate			= dtmStorageChargeDate
				,@intUserId						= intUserId
			FROM @SettleStorages
			WHERE intCnt = @intCnt

			/**********START: STORAGE CHARGE**********/
			SET @strProcessType = CASE WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid' ELSE 'calculate' END
			
			EXEC uspGRCalculateStorageCharge 
				@strProcessType
				,'estimate' --strUpdateType
				,@intCustomerStorageId
				,NULL
				,NULL
				,@dblUnits
				,@dtmStorageChargeDate
				,@intUserId
				,0
				,NULL	
				,@dblStorageDuePerUnit OUTPUT
				,@dblStorageDueAmount OUTPUT
				,@dblStorageDueTotalPerUnit OUTPUT
				,@dblStorageDueTotalAmount OUTPUT
				,@dblStorageBilledPerUnit OUTPUT
				,@dblStorageBilledAmount OUTPUT
				,@dblFlatFeeTotal OUTPUT

			IF @strStorageAdjustment = 'Override'
				SET @dblTicketStorageDue = @dblAdjustPerUnit + @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit
			ELSE
				SET @dblTicketStorageDue = @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit

			IF ISNULL(@dblTicketStorageDue,0) > 0
			BEGIN
				INSERT INTO @SettlementItemsForInvoice
				(
					intSettleStorageId
					,intCustomerStorageId
					,intInventoryShipmentItemId
					,intItemId
					,strItemNo
					,intItemUOMId
					,intUnitMeasureId
					,strSettlementType
					,dblUnits
					,dblPrice
					,intContractHeaderId
					,intContractDetailId
					,intItemTypeId
				)
				SELECT TOP 1
					intSettleStorageId			= @intId
					,intCustomerStorageId		= @intCustomerStorageId
					,intInventoryShipmentItemId	= NULL
					,intItemId					= IC.intItemId
					,strItemNo					= IC.strItemNo
					,intItemUOMId				= UOM.intItemUOMId
					,intUnitMeasureId			= @intUnitMeasureId
					,strSettlementType			= @strSettlementType
					,dblUnits					= @dblUnits
					,dblPrice					= -@dblTicketStorageDue -(ISNULL(@dblFlatFeeTotal,0)/@dblUnits)
					,intContractHeaderId		= @intContractHeaderId
					,intContractDetailId		= @intContractDetailId
					,intItemTypeId				= 2
				FROM tblICItem IC
				INNER JOIN tblICItemUOM UOM
					ON UOM.intItemId = IC.intItemId
						AND UOM.intUnitMeasureId = @intUnitMeasureId
				WHERE strType = 'Other Charge' 
					AND strCostType = 'Storage Charge' 
					AND (intCommodityId = @intCommodityId OR intCommodityId IS NULL)

				UPDATE SS
				SET dblStorageDue = ROUND(ABS(SF.dblUnits * SF.dblPrice),6)
				FROM tblGRSettleStorage SS
				OUTER APPLY (
					SELECT dblUnits
						,dblPrice
					FROM @SettlementItemsForInvoice
				) SF
				WHERE SS.intSettleStorageId = @intId
			END
			/**********END: STORAGE CHARGE**********/

			/**********START: DISCOUNTS**********/
			INSERT INTO @SettlementItemsForInvoice
			(
				intSettleStorageId
				,intCustomerStorageId
				,intInventoryShipmentItemId
				,intItemId
				,strItemNo
				,intItemUOMId
				,intUnitMeasureId
				,strSettlementType
				,dblUnits
				,dblPrice
				,intContractHeaderId
				,intContractDetailId
				,intItemTypeId
			)
			SELECT 
				intSettleStorageId			= @intId
				,intCustomerStorageId		= @intCustomerStorageId
				,intInventoryShipmentItemId	= NULL
				,intItemId					= DItem.intItemId
				,strItemNo					= DItem.strItemNo
				,intItemUOMId				= UOM.intItemUOMId
				,intUnitMeasureId			= @intUnitMeasureId
				,strSettlementType			= @strSettlementType
				,dblUnits					= 1 --@dblUnits
				,dblPrice					= (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, @intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) -
												dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, @intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
											) *
											(
												(CASE WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN @dblUnitsInGross ELSE @dblUnits END)
												*
												(CASE WHEN QM.strDiscountChargeType = 'Percent' THEN @dblPrice ELSE 1 END)
											)
				,intContractHeaderId		= @intContractHeaderId
				,intContractDetailId		= @intContractDetailId
				,intItemType				= 3
			FROM tblGRCustomerStorage CS
			JOIN tblQMTicketDiscount QM 
				ON QM.intTicketFileId = CS.intCustomerStorageId 
					AND QM.strSourceType = 'Storage'				
			LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
				ON QMII.intTicketDiscountId = QM.intTicketDiscountId
			INNER JOIN tblGRDiscountScheduleCode DSC
				ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
			INNER JOIN tblGRDiscountCalculationOption DCO
				ON DCO.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
			INNER JOIN tblICItem DItem 
				ON DItem.intItemId = DSC.intItemId
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemId = DItem.intItemId
					AND UOM.intUnitMeasureId = @intUnitMeasureId
			WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
				AND CS.intCustomerStorageId = @intCustomerStorageId
			/**********END: DISCOUNTS**********/
			
			/**********START: INVENTORY ITEM**********/
			IF NOT EXISTS(
				SELECT 1 
				FROM @SettlementItemsForInvoice 
				WHERE intItemId = @intInventoryItemId 
					AND (strSettlementType = 'Spot' 
						OR (strSettlementType = 'Contract' AND intContractDetailId = @intContractDetailId))
			)
			BEGIN
				INSERT INTO @SettlementItemsForInvoice
				(
					intSettleStorageId
					,intCustomerStorageId
					,intInventoryShipmentItemId
					,intItemId
					,strItemNo
					,intItemUOMId
					,intUnitMeasureId
					,strSettlementType
					,dblUnits
					,dblPrice
					,intContractHeaderId
					,intContractDetailId
					,intItemTypeId
				)
				SELECT
					intSettleStorageId			= @intId
					,intCustomerStorageId		= @intCustomerStorageId
					,intInventoryShipmentItemId	= @intInventoryShipmentItemId
					,intItemId					= @intInventoryItemId
					,strItemNo					= strItemNo
					,intItemUOMId				= @intItemUOMId					
					,intUnitMeasureId			= @intUnitMeasureId
					,strSettlementType			= @strSettlementType
					,dblUnits					= @dblUnits
					,dblPrice					= @dblPrice
					,intContractHeaderId		= @intContractHeaderId
					,intContractDetailId		= @intContractDetailId
					,intItemTypeId = 1
				FROM tblICItem
				WHERE intItemId = @intInventoryItemId
			END
			/**********END: INVENTORY ITEM**********/

			/**********START: REDUCE CONTRACTS**********/	
			IF ISNULL(@intDPContractDetailId,0) > 0
			BEGIN
				SET @dblUnits = @dblUnits * -1
				EXEC uspCTUpdateSequenceQuantityUsingUOM 
					@intContractDetailId	= @intDPContractDetailId
					,@dblQuantityToUpdate	= @dblUnits
					,@intUserId				= @intUserId
					,@intExternalId			= @intSettleStorageTicketId
					,@strScreenName			= 'Settle Storage'
					,@intSourceItemUOMId	= @intCommodityStockUomId
			END
			
			IF ISNULL(@intContractDetailId,0) > 0
			BEGIN
				SET @dblUnits = @dblUnits * -1
				EXEC uspCTUpdateSequenceBalance 
					@intContractDetailId	= @intContractDetailId
					,@dblQuantityToUpdate	= @dblUnits
					,@intUserId				= @intUserId
					,@intExternalId			= @intSettleStorageTicketId
					,@strScreenName			= 'Settle Storage'
			END
			/**********END: REDUCE CONTRACT**********/

			--UPDATE OPEN BALANCE
			UPDATE tblGRCustomerStorage SET dblOpenBalance = dblOpenBalance - (@dblUnits * -1) WHERE intCustomerStorageId = @intCustomerStorageId

			SELECT @intCnt = MIN(intCnt) FROM @SettleStorages WHERE intCnt <> @intCnt
		END
		--update tblGLAccount set intAccountGroupId = 5 where strDescription like '%STORAGE EXPENSE%'
		--SELECT '@SettlementItemsForInvoice',* FROM @SettlementItemsForInvoice
		--calculate discounts which will be deducted to the invoice
		--create invoice
		INSERT INTO @EntriesForInvoice (
			[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[intCustomerStorageId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[dtmDate]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intEntityId]
			,[ysnResetDetails]
			,[intItemId]
			,[strItemDescription]
			,[intOrderUOMId]
			,[intItemUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblPrice]
			,[ysnRefreshPrice]
			,[intTaxGroupId]
			,[ysnRecomputeTax]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intTicketId]
			,[intDestinationGradeId]
			,[intDestinationWeightId]
			--,[intInventoryShipmentId]
			,[intInventoryShipmentItemId]
			--,[intAccountId]
		)
		SELECT 
			[strTransactionType]			= 'Invoice'
			,[strType]						= 'Standard'
			,[strSourceTransaction]			= 'Settle Storage'
			,[intSourceId]					= @intId
			,[intCustomerStorageId]			= SI.intCustomerStorageId
			,[strSourceId]					= SS.strStorageTicket
			,[intInvoiceId]					= NULL --NULL Value will create new invoice
			,[intEntityCustomerId]			= CS.intEntityId
			,[intCompanyLocationId]			= CS.intCompanyLocationId
			,[intCurrencyId]				= CS.intCurrencyId
			,[intTermId]					= EM.intTermsId
			,[dtmDate]						= SS.dtmCreated
			,[ysnTemplate]					= 0
			,[ysnForgiven]					= 0
			,[ysnCalculated]				= 0
			,[ysnSplitted]					= 0
			,[intEntityId]					= @intUserId
			,[ysnResetDetails]				= 0
			,[intItemId]					= SI.intItemId
			,[strItemDescription]			= SI.strItemNo
			,[intOrderUOMId]				= SI.intItemUOMId
			,[intItemUOMId]					= SI.intItemUOMId
			,[dblQtyOrdered]				= SI.dblUnits
			,[dblQtyShipped]				= SI.dblUnits
			,[dblDiscount]					= 0
			,[dblPrice]						= SI.dblPrice
			,[ysnRefreshPrice]				= 0
			--,[intTaxGroupId]				= dbo.fnGetTaxGroupIdForVendor(CS.intEntityId,CS.intCompanyLocationId,SI.intItemId,EM.intEntityLocationId,EM.intFreightTermId,default)
			,[intTaxGroupId]				= dbo.fnGetTaxGroupIdForCustomer(CS.intEntityId,CS.intCompanyLocationId,SI.intItemId,EM.intEntityLocationId,NULL,EM.intFreightTermId,default)
			,[ysnRecomputeTax]				= 1
			,[intContractHeaderId]			= SI.intContractHeaderId
			,[intContractDetailId]			= SI.intContractDetailId
			,[intTicketId]					= CS.intTicketId
			,[intDestinationGradeId]		= NULL
			,[intDestinationWeightId]		= NULL
			,[intInventoryShipmentItemId]	= CASE WHEN SI.intItemTypeId = 1 THEN SI.intInventoryShipmentItemId ELSE NULL END
			--,[intAccountId]					= CASE 
			--									WHEN SI.intItemTypeId = 2 THEN [dbo].[fnGetItemGLAccount](SI.intItemId,IL.intItemLocationId, 'Other Charge Expense')
			--									ELSE NULL
			--								END
		FROM @SettlementItemsForInvoice SI
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = SI.intCustomerStorageId
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
				AND SST.intSettleStorageId = SI.intSettleStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SS.intSettleStorageId = SI.intSettleStorageId
		LEFT JOIN tblARCustomer AR 
			ON AR.intEntityId = CS.intEntityId
		LEFT JOIN tblEMEntityLocation EM 
			ON EM.intEntityId = CS.intEntityId 
				AND EM.intEntityLocationId = AR.intShipToId
		LEFT JOIN tblICItemLocation IL
			ON IL.intItemId = SI.intItemId
				AND IL.intLocationId = CS.intCompanyLocationId
		--OUTER APPLY (
		--	SELECT intItemLocationId
		--	FROM tblICItemLocation
		--	WHERE intItemId = SI.intItemId
		--		AND intLocationId = CS.intCompanyLocationId
		--		AND SI.intItemTypeId = 1
		--) IL

				select '@EntriesForInvoice',* from @EntriesForInvoice
		EXEC [dbo].[uspARProcessInvoices] 
			@InvoiceEntries = @EntriesForInvoice
			,@LineItemTaxEntries = @TaxDetails
			,@UserId = @intUserId
			,@GroupingOption = 2
			,@RaiseError = 1
			,@ErrorMessage = @ErrMsg OUTPUT
			,@CreatedIvoices = @CreatedInvoices OUTPUT

		IF @ErrMsg IS NULL
		BEGIN
			DELETE FROM @StorageHistoryData
			INSERT INTO @StorageHistoryData
			(							 
				[intCustomerStorageId]
				,[intInvoiceId]
				,[intSettleStorageId]
				,[strSettleTicket]
				,[intContractHeaderId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[dblPaidAmount]
				,[ysnPost]
				,[intTransactionTypeId]
				,[strType]
				,[intUserId]
			)
			SELECT 
				[intCustomerStorageId]		= ARD.intCustomerStorageId														
				,[intInvoiceId]				= AR.intInvoiceId
				,[intSettleStorageId]		= @intId
				,[strSettleTicket]			= ARD.strDocumentNumber
				,[intContractHeaderId]		= ARD.intContractHeaderId
				,[dblUnits]					= ARD.dblQtyOrdered
				,[dtmHistoryDate]			= @dtmStorageChargeDate
				,[dblPaidAmount]			= ARD.dblPrice
				,[ysnPost]					= 1
				,[intTransactionTypeId]		= 4
				,[strType]					= 'Settlement'
				,[intUserId]				= @intUserId
			FROM tblARInvoice AR
			INNER JOIN tblARInvoiceDetail ARD 
				ON ARD.intInvoiceId = AR.intInvoiceId
			INNER JOIN tblICItem IC
				ON IC.intItemId = ARD.intItemId
					AND IC.strType = 'Inventory'
			INNER JOIN dbo.fnCommaSeparatedValueToTable(@CreatedInvoices) SI
				ON SI.value = AR.intInvoiceId
						
			EXEC uspGRInsertStorageHistoryRecord @StorageHistoryData, @intHistoryStorageId, ''
		END
		
		--get the next intSettleStorageId
		SELECT @intId = MIN(intId) FROM @createdSettleStorages WHERE intId <> @intId
	END

	UPDATE tblGRSettleStorage SET ysnPosted = 1 WHERE intSettleStorageId = @intSettleStorageId

	Exit_post:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
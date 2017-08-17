﻿CREATE PROCEDURE [dbo].[uspCTValidateContractDetail]

	@XML		NVARCHAR(MAX),
	@RowState	NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE @SQL						NVARCHAR(MAX) = '',
			@ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblNewQuantity				NUMERIC(18,6),
			@intNewItemUOMId			INT,
			@dblOldQuantity				NUMERIC(18,6),
			@intOldItemUOMId			INT,
			@dblNewQuantityInOldUOM		NUMERIC(18,6),
			@dblQuantityUsed			NUMERIC(18,6),
			@idoc						INT,
			@strNumber					NVARCHAR(100),
			@intContractSeq				INT,
			@intContractHeaderId		INT,
			@intNewStatusId				INT,
			@intOldStatusId				INT,
			@intContractTypeId			INT,
			@intOldItemId				INT,
			@intOldQtyUnitMeasureId		INT,
			@dblOldBalance				NUMERIC(18,6),
			@dblOldScheduleQty			NUMERIC(18,6),
			@intOldNoOfLoad				INT,

			@intNewCompanyLocationId	INT,
			@dtmNewStartDate			DATETIME,
			@dtmNewEndDate				DATETIME,
			@intCreatedById				INT,
			@dtmCreated					DATETIME,
			@intConcurrencyId			INT,
			@intNewItemId				INT,
			@intNewPricingTypeId		INT,
			@intNewScheduleRuleId		INT,
			@intNewSubLocationId		INT,
			@intNewItemContractId		INT,
			@intNewFutureMonthId		INT,
			@intNewProducerId			INT,
			@strSubLocationName			NVARCHAR(100),
			@strItemNo					NVARCHAR(100),
			@dblNewBalance				NUMERIC(18,6),
			@dblNewScheduleQty			NUMERIC(18,6),
			@intNewNoOfLoad				INT,
			@ysnLoad					BIT,
			@ysnSlice					BIT,
			@intNewShipperId			INT,
			@intNewShippingLineId		INT

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	@intContractHeaderId		=	intContractHeaderId,
			@intContractDetailId		=	intContractDetailId,
			@intContractSeq				=	intContractSeq,

			@dblNewQuantity				=	dblQuantity,
			@intNewItemId				=	intItemId,
			@intNewItemUOMId			=	intItemUOMId,
			@intNewStatusId				=	intContractStatusId,
			@intNewCompanyLocationId	=	intCompanyLocationId,
			@dtmNewStartDate			=	dtmStartDate,
			@dtmNewEndDate				=	dtmEndDate,
			@intCreatedById				=	intCreatedById,
			@dtmCreated					=	dtmCreated,
			@intConcurrencyId			=	intConcurrencyId,
			@intNewPricingTypeId		=	intPricingTypeId,
			@intNewScheduleRuleId		=	intStorageScheduleRuleId,
			@intNewSubLocationId		=	intSubLocationId,
			@dblNewBalance				=	dblBalance,
			@dblNewScheduleQty			=	dblScheduleQty,
			@intNewNoOfLoad				=	intNoOfLoads,
			@intNewItemContractId		=	intItemContractId,
			@intNewFutureMonthId		=	intFutureMonthId,
			@intNewProducerId			=	intProducerId,
			@ysnSlice					=	ysnSlice,
			@intNewShipperId			=	intShipperId,
			@intNewShippingLineId		=	intShippingLineId

	FROM	OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail',2)
	WITH
	(
			intContractDetailId			INT,
			dblQuantity					NUMERIC(18,6),
			intItemUOMId				INT,
			intContractHeaderId			INT,
			intContractStatusId			INT,

			intContractSeq				INT,
			intCompanyLocationId		INT,
			dtmStartDate				DATETIME,
			dtmEndDate					DATETIME,
			intCreatedById				INT,
			dtmCreated					DATETIME,
			intConcurrencyId			INT,
			intItemId					INT,
			intPricingTypeId			INT,
			intStorageScheduleRuleId	INT,
			intSubLocationId			INT,
			dblBalance					NUMERIC(18,6),
			dblScheduleQty				NUMERIC(18,6),
			intNoOfLoads				INT,
			intItemContractId			INT,
			intFutureMonthId			INT,
			intProducerId				INT,
			ysnSlice					BIT,
			intShipperId				INT,
			intShippingLineId			INT
	)  

	IF @RowState  <> 'Added'
	BEGIN
		SELECT	@dblOldQuantity			=	CD.dblQuantity,
				@intOldItemUOMId		=	CD.intItemUOMId,
				@intContractSeq			=	CD.intContractSeq,
				@intOldStatusId			=	CD.intContractStatusId,
				@intContractTypeId		=	CH.intContractTypeId,
				@intOldItemId			=	CD.intItemId,
				@intOldQtyUnitMeasureId	=	IU.intUnitMeasureId,
				@dblOldBalance			=	CD.dblBalance,
				@dblOldScheduleQty		=	CD.dblScheduleQty,
				@intOldNoOfLoad			=	CD.intNoOfLoad,

				@dblNewQuantity			=	ISNULL(@dblNewQuantity,CD.dblQuantity),
				@intNewItemUOMId		=	ISNULL(@intNewItemUOMId,CD.intItemUOMId),
				@intContractHeaderId	=	ISNULL(@intContractHeaderId,CD.intContractHeaderId),
				@intNewStatusId			=	ISNULL(@intNewStatusId,CD.intContractStatusId),
				@dblNewBalance			=	ISNULL(@dblNewBalance,CD.dblBalance),
				@dblNewScheduleQty		=	ISNULL(@dblNewScheduleQty,CD.dblScheduleQty),
				@intNewNoOfLoad			=	ISNULL(@intNewNoOfLoad,CD.intNoOfLoad),

				@ysnLoad				=	ysnLoad

		FROM	tblCTContractDetail	CD
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
		JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intItemUOMId
		WHERE	intContractDetailId	=	ISNULL(@intContractDetailId,0)
	END

	SELECT @strSubLocationName = strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intNewSubLocationId
	SELECT @strItemNo = strItemNo FROM tblICItem WHERE intItemId = @intNewItemId
	SELECT @dblNewQuantityInOldUOM = dbo.fnCTConvertQtyToTargetItemUOM(@intNewItemUOMId,@intOldItemUOMId,@dblNewQuantity)

	IF @RowState  = 'Added'
	BEGIN
		--IF NOT EXISTS(SELECT * FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId)
		--BEGIN
		--	SET @ErrMsg = 'Concurrency Id is missing while creating contract.'
		--	RAISERROR(@ErrMsg,16,1)
		--END
		IF	@intConcurrencyId IS NULL
		BEGIN
			SET @ErrMsg = 'Concurrency Id is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intNewStatusId IS NULL
		BEGIN
			SET @ErrMsg = 'Contract status is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intContractSeq IS NULL
		BEGIN
			SET @ErrMsg = 'Sequence number is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intNewCompanyLocationId IS NULL
		BEGIN
			SET @ErrMsg = 'Location is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@dtmNewStartDate IS NULL
		BEGIN
			SET @ErrMsg = 'Start date is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@dtmNewEndDate IS NULL
		BEGIN
			SET @ErrMsg = 'End date is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intNewItemId IS NULL
		BEGIN
			SET @ErrMsg = 'Item is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intNewItemUOMId IS NULL
		BEGIN
			SET @ErrMsg = 'UOM is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF NOT EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = @intNewItemId AND intItemUOMId = @intNewItemUOMId)
		BEGIN
			SET @ErrMsg = 'Combination of item id and UOM id is not matching.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@dblNewQuantity IS NULL
		BEGIN
			SET @ErrMsg = 'Quantity is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intNewPricingTypeId IS NULL
		BEGIN
			SET @ErrMsg = 'Pricing type is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intNewPricingTypeId = 5 AND @intNewScheduleRuleId IS NULL
		BEGIN
			SET @ErrMsg = 'Storage Schedule is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intCreatedById IS NULL
		BEGIN
			SET @ErrMsg = 'Created by is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@dtmCreated IS NULL
		BEGIN
			SET @ErrMsg = 'Created date is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END

		--Active check
		IF ISNULL(@ysnSlice,0) = 0
		BEGIN
			IF	@intNewItemId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblICItem WHERE intItemId = @intNewItemId AND strStatus = 'Active')
			BEGIN
				SELECT @ErrMsg = strItemNo FROM tblICItem WHERE intItemId = @intNewItemId
				SET @ErrMsg = 'Item ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
				RAISERROR(@ErrMsg,16,1)
			END

			IF	@intNewItemContractId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTItemContractView WHERE intItemContractId = @intNewItemContractId AND strStatus = 'Active' AND intLocationId = @intNewCompanyLocationId)
			BEGIN
				SELECT @ErrMsg = strContractItemName FROM tblICItemContract WHERE intItemContractId = @intNewItemContractId
				SET @ErrMsg = REPLACE(@ErrMsg,'%','%%')
				SET @ErrMsg = 'Contract Item ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
				RAISERROR(@ErrMsg,16,1)
			END

			IF	@intNewFutureMonthId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE intFutureMonthId = @intNewFutureMonthId AND ISNULL(ysnExpired,0) = 0)
			BEGIN
				SELECT @ErrMsg = strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId = @intNewFutureMonthId
				SET @ErrMsg = 'Future Month ' + ISNULL(@ErrMsg,'selected') + ' is expired.'
				RAISERROR(@ErrMsg,16,1)
			END

			IF	@intNewProducerId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intNewProducerId AND strEntityType = 'Producer' AND ysnActive = 1)
			BEGIN
				SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intNewProducerId
				SET @ErrMsg = 'Producer ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
				RAISERROR(@ErrMsg,16,1)
			END

			IF	@intNewShipperId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intNewShipperId AND strEntityType = 'Vendor' AND ysnActive = 1)
			BEGIN
				SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intNewShipperId
				SET @ErrMsg = 'Shipper ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
				RAISERROR(@ErrMsg,16,1)
			END

			IF	@intNewShippingLineId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intNewShippingLineId AND strEntityType = 'Vendor' AND ysnActive = 1)
			BEGIN
				SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intNewShippingLineId
				SET @ErrMsg = 'Shipping Line ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
				RAISERROR(@ErrMsg,16,1)
			END
		END
		--End Active check
	END

	IF @RowState  = 'Modified'
	BEGIN
		--SELECT @dblQuantityUsed = SUM(dblQuantity) FROM tblLGShippingInstructionContractQty WHERE intContractDetailId = @intContractDetailId
		--IF @dblQuantityUsed > @dblNewQuantityInOldUOM
		--BEGIN
		--	SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in shipping instruction.'
		--	RAISERROR(@ErrMsg,16,1) 
		--END

		--SELECT @dblQuantityUsed = SUM(dblQuantity) FROM tblLGShipmentContractQty WHERE intContractDetailId = @intContractDetailId
		--IF @dblQuantityUsed > @dblNewQuantityInOldUOM
		--BEGIN
		--	SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in Inbound shipments.'
		--	RAISERROR(@ErrMsg,16,1) 
		--END

		IF @intContractTypeId = 1
		BEGIN
			SELECT	@dblQuantityUsed = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intOldItemId,intPUnitMeasureId,@intOldQtyUnitMeasureId,dblPAllocatedQty)) 
			FROM	tblLGAllocationDetail WHERE intPContractDetailId = @intContractDetailId
			IF @dblQuantityUsed > @dblNewQuantityInOldUOM
			BEGIN
				SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in Allocation.'
				RAISERROR(@ErrMsg,16,1) 
			END
		END

		IF @intContractTypeId = 2
		BEGIN
			SELECT	@dblQuantityUsed = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intOldItemId,intSUnitMeasureId,@intOldQtyUnitMeasureId,dblPAllocatedQty)) 
			FROM	tblLGAllocationDetail WHERE intSContractDetailId = @intContractDetailId
			IF @dblQuantityUsed > @dblNewQuantityInOldUOM
			BEGIN
				SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in Allocation.'
				RAISERROR(@ErrMsg,16,1) 
			END
		END

		SELECT @dblQuantityUsed = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intOldItemId,intUnitMeasureId,@intOldQtyUnitMeasureId,dblReservedQuantity)) FROM tblLGReservation WHERE intContractDetailId = @intContractDetailId
		IF @dblQuantityUsed > @dblNewQuantityInOldUOM
		BEGIN
			SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in Reservation.'
			RAISERROR(@ErrMsg,16,1) 
		END

		IF @intNewStatusId IN (2,3,5) AND @intOldStatusId NOT IN (2,3,5) AND dbo.fnAPContractHasUnappliedPrepaid(@intContractHeaderId) = 1
		BEGIN
			SELECT	@strNumber = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId	=	@intNewStatusId
			SET @ErrMsg = 'Cannot change status of Sequence '+LTRIM(@intContractSeq)+' to '+@strNumber+' as prepaid balance is associated with the contract.'
			RAISERROR(@ErrMsg,16,1) 
		END

		IF @intNewStatusId IN (3) AND @intOldStatusId NOT IN (3) AND 
		EXISTS(	SELECT * FROM tblLGLoadDetail LD JOIN tblLGLoad LO ON LO.intLoadId = LD.intLoadId 
				WHERE (LD.intPContractDetailId = @intContractDetailId OR intSContractDetailId = @intContractDetailId) AND ISNULL(LO.ysnCancelled,0) <> 1)
		BEGIN
			SELECT	@strNumber = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId	=	@intNewStatusId
			SET @ErrMsg = 'Cannot change status of Sequence '+LTRIM(@intContractSeq)+' to '+@strNumber+' as loads are associated with the sequence.'
			RAISERROR(@ErrMsg,16,1) 
		END

		IF @ysnLoad = 1
        BEGIN
            IF (@intNewNoOfLoad < @intOldNoOfLoad - @dblOldBalance + @dblOldScheduleQty)
			BEGIN
				SET @ErrMsg = 'No. of Loads for Sequence ' + LTRIM(@intContractSeq) + ' cannot be reduced below ' + LTRIM(@intOldNoOfLoad - @dblOldBalance + @dblOldScheduleQty) + '. As current no. of load is ' + LTRIM(@intOldNoOfLoad) + ' and no. of load in use is ' + LTRIM(@intOldNoOfLoad - @dblOldBalance + @dblOldScheduleQty) + '.'
				RAISERROR(@ErrMsg,16,1) 
			END
			
        END
		ELSE
		BEGIN
			IF (@dblNewQuantity < @dblOldQuantity - @dblOldBalance + @dblOldScheduleQty)
			BEGIN
				SET @ErrMsg = 'Sequence ' + LTRIM(@intContractSeq) + ' quantity cannot be reduced below ' + LTRIM(@dblOldQuantity - @dblOldBalance + @dblOldScheduleQty) + '. As current contract quantity is ' +  LTRIM(@dblOldQuantity) + ' and quantity in use is ' + LTRIM(@dblOldQuantity - @dblOldBalance + @dblOldScheduleQty) + '.'
				RAISERROR(@ErrMsg,16,1) 
			END
		END
	END

	IF @RowState  = 'Delete'
	BEGIN
		IF EXISTS	(	
						SELECT * FROM tblICInventoryReceipt IR
						JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = IR.intInventoryReceiptId
						WHERE IR.strReceiptType = 'Purchase Contract' AND RI.intLineNo = @intContractDetailId
					)
		BEGIN
			SELECT	@strNumber = IR.strReceiptNumber 
			FROM	tblICInventoryReceipt		IR
			JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptId = IR.intInventoryReceiptId
			WHERE	IR.strReceiptType = 'Purchase Contract' AND RI.intLineNo = @intContractDetailId

			SET @ErrMsg = 'Cannot delete Sequence '+LTRIM(@intContractSeq)+'. As it used in the Inventory Receipt '+@strNumber+'.'
			RAISERROR(@ErrMsg,16,1) 
		END

		IF EXISTS	(	
						SELECT * FROM tblICInventoryShipment SH
						JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = SH.intInventoryShipmentId
						WHERE SH.intOrderType = 4 AND SI.intLineNo = @intContractDetailId
					)
		BEGIN
			SELECT	@strNumber = SH.strShipmentNumber  
			FROM	tblICInventoryShipment		SH
			JOIN	tblICInventoryShipmentItem	SI ON SI.intInventoryShipmentId = SH.intInventoryShipmentId
			WHERE	SH.intOrderType = 4 AND SI.intLineNo = @intContractDetailId

			SET @ErrMsg = 'Cannot delete Sequence '+LTRIM(@intContractSeq)+'. As it used in the Inventory Shipment '+@strNumber+'.'
			RAISERROR(@ErrMsg,16,1) 
		END
	END

	IF EXISTS(
			SELECT	* 
			FROM	tblICItemSubLocation	SL
			JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId	=	SL.intItemLocationId	
			JOIN	tblSMCompanyLocationSubLocation CS	ON CS.intCompanyLocationSubLocationId = SL.intSubLocationId
			WHERE	IL.intItemId = @intNewItemId AND CS.intCompanyLocationId = @intNewCompanyLocationId 
	) AND ISNULL(@intNewSubLocationId,0) <> 0
	BEGIN
		IF NOT EXISTS(
			SELECT	* 
			FROM	tblICItemSubLocation	SL
			JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId	=	SL.intItemLocationId	
			JOIN	tblSMCompanyLocationSubLocation CS	ON CS.intCompanyLocationSubLocationId = SL.intSubLocationId
			WHERE	IL.intItemId = @intNewItemId AND CS.intCompanyLocationId = @intNewCompanyLocationId AND SL.intSubLocationId = @intNewSubLocationId
		)
		BEGIN
			SET @ErrMsg = @strSubLocationName + ' is not configured for Item '+@strItemNo+'.'
			RAISERROR(@ErrMsg,16,1) 
		END
	END

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	SET @ErrMsg = REPLACE(@ErrMsg,'%','%%')
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
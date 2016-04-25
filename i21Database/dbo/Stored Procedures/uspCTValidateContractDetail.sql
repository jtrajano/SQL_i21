CREATE PROCEDURE [dbo].[uspCTValidateContractDetail]

	@XML		NVARCHAR(MAX),
	@RowState	NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE @SQL					NVARCHAR(MAX) = '',
			@ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@dblNewQuantity			NUMERIC(18,6),
			@intNewItemUOMId		INT,
			@dblOldQuantity			NUMERIC(18,6),
			@intOldItemUOMId		INT,
			@dblNewQuantityInOldUOM	NUMERIC(18,6),
			@dblQuantityUsed		NUMERIC(18,6),
			@idoc					INT,
			@strNumber				NVARCHAR(100),
			@intContractSeq			INT,
			@intContractHeaderId	INT,
			@intNewStatusId			INT,
			@intOldStatusId			INT,
			@intContractTypeId		INT,
			@intOldItemId			INT,
			@intOldQtyUnitMeasureId	INT

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	@intContractDetailId	=	intContractDetailId,
			@dblNewQuantity			=	dblQuantity,
			@intNewItemUOMId		=	intItemUOMId,
			@intContractHeaderId	=	intContractHeaderId,
			@intNewStatusId			=	intContractStatusId

	FROM	OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail',2)
	WITH
	(
			intContractDetailId		INT,
			dblQuantity				NUMERIC(18,6),
			intItemUOMId			INT,
			intContractHeaderId		INT,
			intContractStatusId		INT
	)  

	SELECT	@dblOldQuantity			=	CD.dblQuantity,
			@intOldItemUOMId		=	CD.intItemUOMId,
			@intContractSeq			=	CD.intContractSeq,
			@intOldStatusId			=	CD.intContractStatusId,
			@intContractTypeId		=	CH.intContractTypeId,
			@intOldItemId			=	CD.intItemId,
			@intOldQtyUnitMeasureId	=	IU.intUnitMeasureId,

			@dblNewQuantity			=	ISNULL(@dblNewQuantity,CD.dblQuantity),
			@intNewItemUOMId		=	ISNULL(@intNewItemUOMId,CD.intItemUOMId),
			@intContractHeaderId	=	ISNULL(@intContractHeaderId,CD.intContractHeaderId),
			@intNewStatusId			=	ISNULL(@intNewStatusId,CD.intContractStatusId)

	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intItemUOMId
	WHERE	intContractDetailId	=	@intContractDetailId

	SELECT @dblNewQuantityInOldUOM = dbo.fnCTConvertQtyToTargetItemUOM(@intNewItemUOMId,@intOldItemUOMId,@dblNewQuantity)

	IF @RowState  = 'Modified'
	BEGIN
		SELECT @dblQuantityUsed = SUM(dblQuantity) FROM tblLGShippingInstructionContractQty WHERE intContractDetailId = @intContractDetailId
		IF @dblQuantityUsed > @dblNewQuantityInOldUOM
		BEGIN
			SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in shipping instruction.'
			RAISERROR(@ErrMsg,16,1) 
		END

		SELECT @dblQuantityUsed = SUM(dblQuantity) FROM tblLGShipmentContractQty WHERE intContractDetailId = @intContractDetailId
		IF @dblQuantityUsed > @dblNewQuantityInOldUOM
		BEGIN
			SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblQuantityUsed)+' as it is used in Inbound shipments.'
			RAISERROR(@ErrMsg,16,1) 
		END

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
			SET @ErrMsg = 'Cannot change status of Sequence '+LTRIM(@intContractSeq)+' to '+@strNumber+'. As prepaid balance is associated with the contract.'
			RAISERROR(@ErrMsg,16,1) 
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

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
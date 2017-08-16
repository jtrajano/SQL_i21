﻿CREATE PROCEDURE uspLGUpdateCompanyLocation 
	@intContractDetailId INT
AS
BEGIN TRY
	
	DECLARE @ErrMsg	NVARCHAR(MAX)
	DECLARE @ysnUpdateCompanyLocation BIT = 0
	DECLARE @intCountSILoads INT = 0 
	DECLARE @intCountSALoads INT = 0 
	DECLARE @strContractNumber NVARCHAR(100)
	DECLARE @intContractSeq INT
	DECLARE @dblTotalSIQty NUMERIC(18,6)
	DECLARE @dblTotalSAQty NUMERIC(18,6)
	DECLARE @dblSeqQty NUMERIC(18,6)
	DECLARE @strErrMsg NVARCHAR(MAX)

	SELECT @ysnUpdateCompanyLocation = ISNULL(ysnUpdateCompanyLocation, 0)
	FROM tblLGCompanyPreference	

	IF (@ysnUpdateCompanyLocation = 1)
	BEGIN

		IF EXISTS(	SELECT	1 
					FROM	tblICInventoryReceiptItem	RI														
					JOIN	tblICInventoryReceipt		IR	ON	IR.intInventoryReceiptId	=	RI.intInventoryReceiptId 
															AND IR.strReceiptType	IN	('Purchase Contract','Inventory Return')
					JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId = RI.intLineNo
					WHERE	CD.intCompanyLocationId  <> IR.intLocationId AND	RI.intLineNo	=	@intContractDetailId)
		BEGIN
			RAISERROR('Cannot change location of sequence as it is used in inventory receipt.',16,1)
		END

		UPDATE LD
		SET intPCompanyLocationId = CD.intCompanyLocationId,
			intPSubLocationId = CD.intSubLocationId
		FROM tblLGLoadDetail  LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		WHERE CD.intContractDetailId = @intContractDetailId

		UPDATE LW
		SET intSubLocationId = CD.intSubLocationId,
			intStorageLocationId = CD.intStorageLocationId		
		FROM tblLGLoadDetail LD
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		WHERE CD.intContractDetailId = @intContractDetailId
	END

	SELECT @strContractNumber = CH.strContractNumber
		,@intContractSeq = CD.intContractSeq
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE CD.intContractDetailId = @intContractDetailId

	SELECT @intCountSILoads = COUNT(*)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE LD.intPContractDetailId = @intContractDetailId
		AND intShipmentType = 2 
		AND ISNULL(L.ysnCancelled,0) =0

	SELECT @intCountSALoads = COUNT(*)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE LD.intPContractDetailId = @intContractDetailId
		AND intShipmentType = 1
		AND ISNULL(L.ysnCancelled,0) =0

	SELECT @dblTotalSIQty = SUM(LD.dblQuantity)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE LD.intPContractDetailId = @intContractDetailId
		AND intShipmentType = 2 
		AND ISNULL(L.ysnCancelled,0) =0

	SELECT @dblTotalSAQty = SUM(LD.dblQuantity)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE LD.intPContractDetailId = @intContractDetailId
		AND intShipmentType = 1
		AND ISNULL(L.ysnCancelled,0) =0

	SELECT @dblSeqQty = dblQuantity FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

	IF(@dblTotalSIQty >= @dblSeqQty)
	BEGIN
		IF (ISNULL(@intCountSILoads, 0) > 1)
		BEGIN
			SET @strErrMsg = 'More than one shipping instruction is available for contract ' + @strContractNumber + ' sequence ' + LTRIM(@intContractSeq) +'. Cannot reduce qty.'
			RAISERROR (@strErrMsg,16,1)
		END
		ELSE 
		BEGIN
			UPDATE LD
				SET dblQuantity = CD.dblQuantity,
					dblNet = dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId,LD.intWeightItemUOMId,LD.dblQuantity),
					dblGross = dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId,LD.intWeightItemUOMId,LD.dblQuantity)
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale IN (1,3) THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
			WHERE CD.intContractDetailId = @intContractDetailId
		END
	END

	IF (ISNULL(@intCountSALoads, 0) > 1)
	BEGIN
		IF(@dblTotalSAQty > @dblSeqQty)
		BEGIN
			SET @strErrMsg = 'Seq qty cannot be less than the total qty of the associated shipping advice(s).'
			RAISERROR (@strErrMsg,16,1)
		END
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
END CATCH
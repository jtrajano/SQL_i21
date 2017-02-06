﻿CREATE PROCEDURE uspLGLoadContractSlice 
	@intContractHeaderId INT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(MAX)
	DECLARE @intLoadId INT 
	DECLARE @intParentContractDetailId INT
	DECLARE @dblOrgContractDetailQty NUMERIC(18,6)
	DECLARE @intOrgContractDetailQtyUOM INT
	DECLARE @intOrgLoadId INT
	DECLARE @intOrgLoadIDetaild INT
	DECLARE @dblOrgLoadDetailQty NUMERIC(18,6)
	DECLARE @intOrgLoadDetailItemUOM INT
	DECLARE @intOrgLoadDetailWeightUOM INT
	DECLARE @intMinLoadRecordId INT
	DECLARE @intCRowNo INT
	DECLARE @intCContractDetailId INT
	DECLARE @intCParentDetailId INT
	DECLARE @dblCQuantity NUMERIC(18, 6)
	DECLARE @intCItemUOMId INT
	DECLARE @intUserId INT

	DECLARE @ContractSliceDetail TABLE (
		 intCRowNo INT IDENTITY(1, 1)
		,intCContractDetailId INT
		,intCParentDetailId INT
		,dblCQuantity NUMERIC(18, 6)
		,intCItemUOMId INT
		)
	DECLARE @ParentLoad TABLE (
		intLoadRecordId INT IDENTITY(1,1)
	   ,intLoadId INT
	   ,strLoadNumber NVARCHAR(100)
	   ,intLoadDetailId INT
	   ,dblLoadDetailQty NUMERIC(18,6)
	   ,intItemUOMId INT
	   ,intWeightUOMId INT)

	-- Only sliced. ie., new contract sequence records only
	INSERT INTO @ContractSliceDetail
	SELECT intContractDetailId
		  ,intParentDetailId
		  ,dblQuantity
		  ,intItemUOMId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 1

	IF ((SELECT COUNT(1) FROM @ContractSliceDetail) < 1)
		RETURN;

	-- Parent contract sequence. ie., from which sequence it sliced
	SELECT TOP 1 @intParentContractDetailId = intCParentDetailId FROM @ContractSliceDetail

	IF EXISTS (SELECT 1
			   FROM tblLGLoad L
			   JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			   WHERE LD.intPContractDetailId = @intParentContractDetailId
					AND L.intShipmentType = 1)
	BEGIN
		RAISERROR ('Shipment exists for the contract sequence. Cannot proceed.',16,1)
	END


	SELECT @intUserId = intLastModifiedById
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intParentContractDetailId

	-- Parent contract sequence Load
	INSERT INTO @ParentLoad 
	SELECT L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,LD.dblQuantity
		,LD.intItemUOMId
		,LD.intWeightItemUOMId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE CASE 
			WHEN L.intPurchaseSale = 1
				THEN LD.intPContractDetailId
			ELSE LD.intSContractDetailId
			END = @intParentContractDetailId AND intShipmentType = 2


	SELECT @intMinLoadRecordId = MIN(intLoadRecordId) FROM @ParentLoad 

	WHILE (@intMinLoadRecordId > 0)
	BEGIN
		SET @intOrgLoadId = NULL
		SET @intOrgLoadIDetaild = NULL
		SET @dblOrgLoadDetailQty = NULL
		SET @dblOrgContractDetailQty = NULL
		SET @intOrgContractDetailQtyUOM = NULL

		SELECT @intOrgLoadId = intLoadId
			  ,@intOrgLoadIDetaild= intLoadDetailId
			  ,@dblOrgLoadDetailQty = dblLoadDetailQty
			  ,@intOrgLoadDetailItemUOM = intItemUOMId
			  ,@intOrgLoadDetailWeightUOM = intWeightUOMId
		FROM @ParentLoad
		WHERE intLoadRecordId = @intMinLoadRecordId

		SELECT @dblOrgContractDetailQty = dblQuantity
			  ,@intOrgContractDetailQtyUOM = intUnitMeasureId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intParentContractDetailId

		IF (@dblOrgLoadDetailQty > @dblOrgContractDetailQty)
		BEGIN
			UPDATE tblLGLoadDetail 
			SET dblQuantity = @dblOrgContractDetailQty
			   ,dblNet = dbo.fnCTConvertQtyToTargetItemUOM(intItemId,intWeightItemUOMId,@dblOrgContractDetailQty)
			   ,dblGross = dbo.fnCTConvertQtyToTargetItemUOM(intItemId,intWeightItemUOMId,@dblOrgContractDetailQty)
			WHERE intLoadDetailId = @intOrgLoadIDetaild

			SET @dblOrgLoadDetailQty = (@dblOrgLoadDetailQty - @dblOrgContractDetailQty)
			
			-- Create contract sequence samples for the remaining representing qty
			SELECT @intCRowNo = MIN(intCRowNo)
			FROM @ContractSliceDetail

			WHILE (@intCRowNo > 0 AND @dblOrgLoadDetailQty > 0)
			BEGIN
				DECLARE @dblNewLoadDetailQty NUMERIC(18,6)

				SELECT @intCRowNo = intCRowNo
					,@intCContractDetailId = intCContractDetailId
					,@dblCQuantity = dblCQuantity
					,@intCItemUOMId = intCItemUOMId
				FROM @ContractSliceDetail
				WHERE intCRowNo = @intCRowNo

				IF (@dblOrgLoadDetailQty > @dblCQuantity)
					SET @dblNewLoadDetailQty = @dblCQuantity
				ELSE
					SET @dblNewLoadDetailQty = @dblOrgLoadDetailQty

				-- Create new sample for seq @intCContractDetailId, @dblNewRepresentingQty, @intNewRepresentingUOMId. Take other values from existing sample @intSSampleId
				EXEC uspLGLoadContractCopy @intOldLoadDetailId = @intOrgLoadIDetaild
										  ,@intNewContractDetailId = @intCContractDetailId
										  ,@dblNewLoadDetailQuantity = @dblNewLoadDetailQty
										  ,@intNewLoadDetailItemUOMId = @intOrgLoadDetailItemUOM
										  ,@intUserId = @intUserId

				SET @dblOrgLoadDetailQty = (@dblOrgLoadDetailQty - @dblNewLoadDetailQty)
								
				SELECT @intCRowNo = MIN(intCRowNo)
				FROM @ContractSliceDetail
				WHERE intCRowNo > @intCRowNo
			END
		END

		SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
		FROM @ParentLoad
		WHERE intLoadRecordId > @intMinLoadRecordId

	END

END TRY
	
BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH
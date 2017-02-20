CREATE PROCEDURE uspLGLoadContractUnSlice 
				 @intContractHeaderId INT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(MAX)
	DECLARE @intLoadId INT
	DECLARE @intParentContractDetailId INT
	DECLARE @dblOrgContractDetailQty NUMERIC(18, 6)
	DECLARE @intOrgContractDetailQtyUOM INT
	DECLARE @intOrgLoadId INT
	DECLARE @intOrgLoadIDetaild INT
	DECLARE @dblOrgLoadDetailQty NUMERIC(18, 6)
	DECLARE @intOrgLoadDetailItemUOM INT
	DECLARE @intOrgLoadDetailWeightUOM INT
	DECLARE @intMinLoadRecordId INT
	DECLARE @intCRowNo INT
	DECLARE @intCContractDetailId INT
	DECLARE @intCParentDetailId INT
	DECLARE @dblCQuantity NUMERIC(18, 6)
	DECLARE @intCItemUOMId INT
	DECLARE @intUserId INT
	DECLARE @intContractDetailId INT
	DECLARE @intMergeContractDetailId INT
	DECLARE @ContractSliceDetail TABLE (
		intCRowNo INT IDENTITY(1, 1)
		,intCContractDetailId INT
		,intCParentDetailId INT
		,dblCQuantity NUMERIC(18, 6)
		,intCUnitMeasureId INT
		)
	DECLARE @ParentLoad TABLE (
		intLoadRecordId INT IDENTITY(1, 1)
		,intLoadId INT
		,strLoadNumber NVARCHAR(100)
		,intLoadDetailId INT
		,dblLoadDetailQty NUMERIC(18, 6)
		,intItemUOMId INT
		,intWeightUOMId INT
		)
	DECLARE @DeleteContractLoad TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractDetailId INT
		,intLoadDetailId INT
		,intLoadId INT
		)

	-- Only Unsliced. ie., existing contract sequence records got merged only (not the parent)
	INSERT INTO @ContractSliceDetail
	SELECT intContractDetailId
		,intParentDetailId
		,dblQuantity
		,intUnitMeasureId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 0

	IF ((SELECT COUNT(1) FROM @ContractSliceDetail ) < 1)
		RETURN;

	-- Parent contract sequence. ie., from which sequence it sliced
	SELECT TOP 1 @intParentContractDetailId = intCParentDetailId
				,@intCContractDetailId = intCContractDetailId
	FROM @ContractSliceDetail

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
			END = @intParentContractDetailId
		AND intShipmentType = 2

	SELECT TOP 1 @intContractDetailId = intCParentDetailId
	FROM @ContractSliceDetail

	SELECT @intCRowNo = MIN(intCRowNo)
	FROM @ContractSliceDetail

	IF ((SELECT COUNT(1) FROM @ParentLoad ) < 1)
	BEGIN
		RETURN;
	END

	SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
	FROM @ParentLoad

	WHILE (@intCRowNo > 0)
	BEGIN
		SELECT @intMergeContractDetailId = intCContractDetailId
		FROM @ContractSliceDetail
		WHERE intCRowNo = @intCRowNo

		SET @intOrgLoadId = NULL
		SET @intOrgLoadIDetaild = NULL
		SET @dblOrgLoadDetailQty = NULL
		SET @dblOrgContractDetailQty = NULL
		SET @intOrgContractDetailQtyUOM = NULL

		INSERT INTO @DeleteContractLoad
		SELECT intContractDetailId
			,LD.intLoadDetailId
			,L.intLoadId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		WHERE LD.intPContractDetailId = @intMergeContractDetailId

		SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
		FROM @ParentLoad

		WHILE (@intMinLoadRecordId > 0)
		BEGIN
			SET @intOrgLoadId = NULL
			SET @intOrgLoadIDetaild = NULL
			SET @dblOrgLoadDetailQty = NULL
			SET @dblOrgContractDetailQty = NULL
			SET @intOrgContractDetailQtyUOM = NULL

			SELECT @intOrgLoadId = intLoadId
				  ,@intOrgLoadIDetaild = intLoadDetailId
				  ,@dblOrgLoadDetailQty = dblLoadDetailQty
				  ,@intOrgLoadDetailItemUOM = intItemUOMId
				  ,@intOrgLoadDetailWeightUOM = intWeightUOMId
			FROM @ParentLoad
			WHERE intLoadRecordId = @intMinLoadRecordId

			SELECT @dblOrgContractDetailQty = dblQuantity
				  ,@intOrgContractDetailQtyUOM = intUnitMeasureId
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intParentContractDetailId

			IF (@dblOrgLoadDetailQty <= @dblOrgContractDetailQty)
			BEGIN
				-- Update sample representing qty for the original parent contract sequence
				UPDATE tblLGLoadDetail
				SET dblQuantity += @dblOrgContractDetailQty
				   ,dblNet += dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId, intWeightItemUOMId, @dblOrgContractDetailQty)
				   ,dblGross += dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId, intWeightItemUOMId, @dblOrgContractDetailQty)
				WHERE intLoadDetailId = @intOrgLoadIDetaild
			END

			SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
			FROM @ParentLoad
			WHERE intLoadRecordId > @intMinLoadRecordId
		END

		SELECT @intCRowNo = MIN(intCRowNo)
		FROM @ContractSliceDetail
		WHERE intCRowNo > @intCRowNo

		-- Delete contract sequence samples for the merged sequences
		DELETE L
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		WHERE LD.intLoadId IN (
				SELECT intLoadId
				FROM @DeleteContractLoad
				)
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH

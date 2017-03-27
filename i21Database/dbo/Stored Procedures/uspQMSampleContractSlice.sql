--EXEC uspQMSampleContractSlice 1
CREATE PROCEDURE uspQMSampleContractSlice @intContractHeaderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strSampleNumber NVARCHAR(30)
		,@strSampleId NVARCHAR(MAX)
	DECLARE @intCRowNo INT
		,@intCContractDetailId INT
		,@intCParentDetailId INT
		,@dblCQuantity NUMERIC(18, 6)
		,@intCUnitMeasureId INT
		,@intSRowNo INT
		,@intSSampleId INT
		,@intSContractDetailId INT
		,@dblSRepresentingQty NUMERIC(18, 6)
		,@intSRepresentingUOMId INT
		,@intOrgParentDetailId INT
		,@dblOrgQuantity NUMERIC(18, 6)
		,@intOrgUnitMeasureId INT
	DECLARE @ContractSliceDetail TABLE (
		intCRowNo INT IDENTITY(1, 1)
		,intCContractDetailId INT
		,intCParentDetailId INT
		,dblCQuantity NUMERIC(18, 6)
		,intCUnitMeasureId INT
		)
	DECLARE @ParentContractSample TABLE (
		intSRowNo INT IDENTITY(1, 1)
		,intSSampleId INT
		,intSContractDetailId INT
		,dblSRepresentingQty NUMERIC(18, 6)
		,intSRepresentingUOMId INT
		)

	-- Only sliced. ie., new contract sequence records only
	INSERT INTO @ContractSliceDetail
	SELECT intContractDetailId
		,intParentDetailId
		,dblQuantity
		,intUnitMeasureId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 1

	IF (
			(
				SELECT COUNT(1)
				FROM @ContractSliceDetail
				) < 1
			)
		RETURN;

	-- Parent contract sequence. ie., from which sequence it sliced
	SELECT TOP 1 @intOrgParentDetailId = intCParentDetailId
	FROM @ContractSliceDetail

	-- Parent contract sequence samples
	INSERT INTO @ParentContractSample
	SELECT intSampleId
		,intContractDetailId
		,dblRepresentingQty
		,intRepresentingUOMId
	FROM tblQMSample
	WHERE intProductTypeId = 8
		AND intProductValueId = @intOrgParentDetailId
	ORDER BY intSampleId DESC

	IF (
			(
				SELECT COUNT(1)
				FROM @ParentContractSample
				) < 1
			)
		RETURN;

	SELECT @intSRowNo = MIN(intSRowNo)
	FROM @ParentContractSample

	WHILE (@intSRowNo > 0)
	BEGIN
		SELECT @intSRowNo = intSRowNo
			,@intSSampleId = intSSampleId
			,@intSContractDetailId = intSContractDetailId
			,@dblSRepresentingQty = dblSRepresentingQty
			,@intSRepresentingUOMId = intSRepresentingUOMId
		FROM @ParentContractSample
		WHERE intSRowNo = @intSRowNo

		--SELECT @dblOrgQuantity = dblQuantity
		SELECT @dblOrgQuantity = dbo.fnCTConvertQuantityToTargetItemUOM(intItemId, intUnitMeasureId, @intSRepresentingUOMId, dblQuantity)
			,@intOrgUnitMeasureId = intUnitMeasureId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intOrgParentDetailId

		IF (@dblSRepresentingQty > @dblOrgQuantity)
		BEGIN
			-- Update sample representing qty for the original parent contract sequence
			UPDATE tblQMSample
			SET dblRepresentingQty = @dblOrgQuantity
				--,intRepresentingUOMId = @intOrgUnitMeasureId
				,intConcurrencyId = (intConcurrencyId + 1)
			WHERE intSampleId = @intSSampleId

			SELECT @strSampleId = CONVERT(NVARCHAR, @intSSampleId)

			IF (LEN(@strSampleId) > 0)
			BEGIN
				DECLARE @strDetails NVARCHAR(MAX)
				DECLARE @intUserId INT

				SET @strDetails = '{"change":"dblRepresentingQty","iconCls":"small-gear","from":"' + LTRIM(@dblSRepresentingQty) + '","to":"' + LTRIM(@dblOrgQuantity) + '","leaf":true}'

				SELECT @intUserId = intLastModifiedById
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intOrgParentDetailId

				EXEC uspSMAuditLog @keyValue = @strSampleId
					,@screenName = 'Quality.view.QualitySample'
					,@entityId = @intUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END

			SET @dblSRepresentingQty = (@dblSRepresentingQty - @dblOrgQuantity)

			-- Create contract sequence samples for the remaining representing qty
			SELECT @intCRowNo = MIN(intCRowNo)
			FROM @ContractSliceDetail

			WHILE (
					@intCRowNo > 0
					AND @dblSRepresentingQty > 0
					)
			BEGIN
				DECLARE @dblNewRepresentingQty NUMERIC(18, 6)
					,@intNewRepresentingUOMId INT

				SELECT @intCRowNo = intCRowNo
					,@intCContractDetailId = intCContractDetailId
					--,@dblCQuantity = dblCQuantity
					,@dblCQuantity = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, intCUnitMeasureId, @intSRepresentingUOMId, dblCQuantity)
					,@intCUnitMeasureId = intCUnitMeasureId
					,@intNewRepresentingUOMId = @intSRepresentingUOMId
				FROM @ContractSliceDetail CSD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = CSD.intCContractDetailId
				WHERE intCRowNo = @intCRowNo

				IF (@dblSRepresentingQty > @dblCQuantity)
					SET @dblNewRepresentingQty = @dblCQuantity
				ELSE
					SET @dblNewRepresentingQty = @dblSRepresentingQty

				-- Create new sample for seq @intCContractDetailId, @dblNewRepresentingQty, @intNewRepresentingUOMId. Take other values from existing sample @intSSampleId
				EXEC uspQMSampleContractCopy @intOldSampleId = @intSSampleId
					,@intNewContractDetailId = @intCContractDetailId
					,@dblNewRepresentingQuantity = @dblNewRepresentingQty
					,@intNewRepresentingUOMId = @intNewRepresentingUOMId
					,@intUserId = @intUserId

				SET @dblSRepresentingQty = (@dblSRepresentingQty - @dblNewRepresentingQty)

				SELECT @intCRowNo = MIN(intCRowNo)
				FROM @ContractSliceDetail
				WHERE intCRowNo > @intCRowNo
			END
		END

		SELECT @intSRowNo = MIN(intSRowNo)
		FROM @ParentContractSample
		WHERE intSRowNo > @intSRowNo
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

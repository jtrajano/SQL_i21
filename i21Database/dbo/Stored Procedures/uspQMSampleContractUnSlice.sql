--EXEC uspQMSampleContractUnSlice 1,2
CREATE PROCEDURE uspQMSampleContractUnSlice @intContractHeaderId INT
	,@intUserId INT
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
		,@strDetails NVARCHAR(MAX)
	DECLARE @ContractSliceDetail TABLE (
		intCRowNo INT IDENTITY(1, 1)
		,intCContractDetailId INT
		,intCParentDetailId INT
		,dblCQuantity NUMERIC(18, 6)
		,intCUnitMeasureId INT
		)
	DECLARE @ParentContractSample TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractDetailId INT
		,intSampleId INT
		,intSampleTypeId INT
		,intSampleStatusId INT
		,dblRepresentingQty NUMERIC(18, 6)
		,intRepresentingUOMId INT
		)
	DECLARE @DeleteContractSample TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractDetailId INT
		,intSampleId INT
		,intSampleTypeId INT
		,intSampleStatusId INT
		,dblRepresentingQty NUMERIC(18, 6)
		,intRepresentingUOMId INT
		)
	DECLARE @intSampleId INT
		,@intContractDetailId INT
		,@dblRepresentingQty NUMERIC(18, 6)
		,@intRepresentingUOMId INT
		,@intSampleTypeId INT
		,@intSampleStatusId INT
		,@intMergeContractDetailId INT
	DECLARE @intParentRowNo INT
		,@intDeleteRowNum INT
		,@intDelContractDetailId INT
		,@intDelSampleId INT
		,@dblDelRepresentingQty NUMERIC(18, 6)
		,@intDelRepresentingUOMId INT
		,@intParentContractDetailId INT
	DECLARE @intCRowNo INT

	-- Only Unsliced. ie., existing contract sequence records got merged only (not the parent)
	INSERT INTO @ContractSliceDetail
	SELECT intContractDetailId
		,intParentDetailId
		,dblQuantity
		,intUnitMeasureId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 0

	IF (
			(
				SELECT COUNT(1)
				FROM @ContractSliceDetail
				) < 1
			)
		RETURN;

	-- Parent contract sequence. ie., from which sequence it sliced
	SELECT TOP 1 @intContractDetailId = intCParentDetailId
	FROM @ContractSliceDetail

	SELECT @intCRowNo = MIN(intCRowNo)
	FROM @ContractSliceDetail

	WHILE (@intCRowNo > 0)
	BEGIN
		SELECT @intMergeContractDetailId = intCContractDetailId
		FROM @ContractSliceDetail
		WHERE intCRowNo = @intCRowNo

		DELETE
		FROM @ParentContractSample

		-- Parent contract sequence samples
		INSERT INTO @ParentContractSample
		SELECT intContractDetailId
			,intSampleId
			,intSampleTypeId
			,intSampleStatusId
			,dblRepresentingQty
			,intRepresentingUOMId
		FROM tblQMSample
		WHERE intProductTypeId = 8
			AND intProductValueId = @intContractDetailId
		ORDER BY intSampleId DESC

		DELETE
		FROM @DeleteContractSample

		INSERT INTO @DeleteContractSample
		SELECT intContractDetailId
			,intSampleId
			,intSampleTypeId
			,intSampleStatusId
			,dblRepresentingQty
			,intRepresentingUOMId
		FROM tblQMSample
		WHERE intProductTypeId = 8
			AND intProductValueId = @intMergeContractDetailId

		SELECT @intParentRowNo = MIN(intRowNo)
		FROM @ParentContractSample

		WHILE ISNULL(@intParentRowNo, 0) > 0
		BEGIN
			DECLARE @intItemId INT

			SELECT @intItemId = NULL

			SELECT @intSampleId = intSampleId
				,@intSampleTypeId = intSampleTypeId
				,@intSampleStatusId = intSampleStatusId
				,@dblRepresentingQty = dblRepresentingQty
				,@intRepresentingUOMId = intRepresentingUOMId
				,@intItemId = CD.intItemId
				,@intParentContractDetailId = PCS.intContractDetailId
			FROM @ParentContractSample PCS
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = PCS.intContractDetailId
			WHERE intRowNo = @intParentRowNo

			SELECT @dblDelRepresentingQty = NULL

			SELECT @intDelContractDetailId = intContractDetailId
				,@intDelSampleId = intSampleId
				--,@dblDelRepresentingQty = dblRepresentingQty
				,@dblDelRepresentingQty = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, intRepresentingUOMId, @intRepresentingUOMId, dblRepresentingQty)
				,@intDelRepresentingUOMId = intRepresentingUOMId
			FROM @DeleteContractSample
			WHERE intSampleTypeId = @intSampleTypeId
				AND intSampleStatusId = @intSampleStatusId

			IF NOT EXISTS (
					SELECT 1
					FROM tblCTContractDetail CD
					JOIN tblICItemUOM IUOM ON IUOM.intItemId = CD.intItemId
					WHERE CD.intContractDetailId = @intParentContractDetailId
						AND IUOM.intUnitMeasureId = @intDelRepresentingUOMId
					)
			BEGIN
				DECLARE @strItemNo NVARCHAR(50)
				DECLARE @strUnitMeasure NVARCHAR(50)

				SELECT @strItemNo = I.strItemNo
				FROM tblCTContractDetail CD
				JOIN tblICItem I ON I.intItemId = CD.intItemId
				WHERE CD.intContractDetailId = @intParentContractDetailId

				SELECT @strUnitMeasure = strUnitMeasure
				FROM tblICUnitMeasure
				WHERE intUnitMeasureId = @intDelRepresentingUOMId

				SET @ErrMsg = '''' + @strUnitMeasure + ''' unit of measure is not configured for the item ''' + @strItemNo + '''.'

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END

			UPDATE tblQMSample
			SET dblRepresentingQty += ISNULL(@dblDelRepresentingQty, 0)
			WHERE intSampleId = @intSampleId

			DELETE tblQMSample
			WHERE intSampleId = @intDelSampleId

			IF (
					@intSampleId > 0
					AND ISNULL(@dblDelRepresentingQty, 0) > 0
					)
			BEGIN
				SET @strDetails = '{"change":"dblRepresentingQty","iconCls":"small-gear","from":"' + LTRIM(@dblRepresentingQty) + '","to":"' + LTRIM(@dblRepresentingQty + @dblDelRepresentingQty) + '","leaf":true}'

				EXEC uspSMAuditLog @keyValue = @intSampleId
					,@screenName = 'Quality.view.QualitySample'
					,@entityId = @intUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END

			SELECT @intParentRowNo = MIN(intRowNo)
			FROM @ParentContractSample
			WHERE intRowNo > @intParentRowNo
		END

		DECLARE @OldSampleDetail TABLE (intSampleId INT)

		INSERT INTO @OldSampleDetail
		SELECT intSampleId
		FROM tblQMSample
		WHERE intContractDetailId = @intMergeContractDetailId

		-- Contract Available Places
		UPDATE tblQMSample
		SET intContractDetailId = @intContractDetailId
			,intConcurrencyId = (intConcurrencyId + 1)
		WHERE intContractDetailId = @intMergeContractDetailId

		-- Contract Samples
		UPDATE tblQMSample
		SET intProductValueId = @intContractDetailId
		WHERE intProductTypeId = 8
			AND intProductValueId = @intMergeContractDetailId

		UPDATE tblQMTestResult
		SET intProductValueId = @intContractDetailId
			,intConcurrencyId = (intConcurrencyId + 1)
		WHERE intProductTypeId = 8
			AND intProductValueId = @intMergeContractDetailId

		SELECT @strSampleId = COALESCE(@strSampleId + ',', '') + CONVERT(NVARCHAR, intSampleId)
		FROM @OldSampleDetail

		IF (LEN(@strSampleId) > 0)
		BEGIN
			SET @strDetails = '{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intMergeContractDetailId) + '","to":"' + LTRIM(@intContractDetailId) + '","leaf":true}'

			EXEC uspSMAuditLog @keyValue = @strSampleId
				,@screenName = 'Quality.view.QualitySample'
				,@entityId = @intUserId
				,@actionType = 'Updated'
				,@actionIcon = 'small-tree-modified'
				,@details = @strDetails
		END

		SELECT @intCRowNo = MIN(intCRowNo)
		FROM @ContractSliceDetail
		WHERE intCRowNo > @intCRowNo
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

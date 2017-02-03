--EXEC uspQMSampleContractUnSlice 4
CREATE PROCEDURE uspQMSampleContractUnSlice @intContractHeaderId INT
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
		,@intUserId INT
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
	SELECT TOP 1 @intOrgParentDetailId = intCParentDetailId
	FROM @ContractSliceDetail
	
	SELECT @intUserId = intLastModifiedById
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intOrgParentDetailId

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
	BEGIN
		-- Move child sequence samples to parent sequence no
		SELECT @intCRowNo = MIN(intCRowNo)
		FROM @ContractSliceDetail

		WHILE (@intCRowNo > 0)
		BEGIN
			SELECT @intCRowNo = intCRowNo
				,@intCContractDetailId = intCContractDetailId
			FROM @ContractSliceDetail
			WHERE intCRowNo = @intCRowNo

			SELECT @dblOrgQuantity = dblQuantity
				,@intOrgUnitMeasureId = intUnitMeasureId
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intOrgParentDetailId

			DECLARE @OldSampleDetail TABLE (intSampleId INT)

			INSERT INTO @OldSampleDetail
			SELECT intSampleId
			FROM tblQMSample
			WHERE intContractDetailId = @intCContractDetailId

			-- Contract Available Places
			UPDATE tblQMSample
			SET intContractDetailId = @intOrgParentDetailId
				,intConcurrencyId = (intConcurrencyId + 1)
				,intRepresentingUOMId = @intOrgUnitMeasureId
			WHERE intContractDetailId = @intCContractDetailId

			-- Contract Samples
			UPDATE tblQMSample
			SET intProductValueId = @intOrgParentDetailId
			WHERE intProductTypeId = 8
				AND intProductValueId = @intCContractDetailId

			UPDATE tblQMTestResult
			SET intProductValueId = @intOrgParentDetailId
				,intConcurrencyId = (intConcurrencyId + 1)
			WHERE intProductTypeId = 8
				AND intProductValueId = @intCContractDetailId

			SELECT @strSampleId = COALESCE(@strSampleId + ',', '') + CONVERT(NVARCHAR, intSampleId)
			FROM @OldSampleDetail

			IF (LEN(@strSampleId) > 0)
			BEGIN
				SET @strDetails += '{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intCContractDetailId) + '","to":"' + LTRIM(@intOrgParentDetailId) + '","leaf":true}'

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
	END
	ELSE
	BEGIN
		-- Delete contract sequence samples for the merged sequences
		DELETE
		FROM tblQMSample
		WHERE intContractDetailId IN (
				SELECT intCContractDetailId
				FROM @ContractSliceDetail
				)

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

			SELECT @dblOrgQuantity = dblQuantity
				,@intOrgUnitMeasureId = intUnitMeasureId
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intOrgParentDetailId

			IF (@dblSRepresentingQty < @dblOrgQuantity)
			BEGIN
				-- Update sample representing qty for the original parent contract sequence
				UPDATE tblQMSample
				SET dblRepresentingQty = @dblOrgQuantity
					,intRepresentingUOMId = @intOrgUnitMeasureId
					,intConcurrencyId = (intConcurrencyId + 1)
				WHERE intSampleId = @intSSampleId

				SELECT @strSampleId = CONVERT(NVARCHAR, @intSSampleId)

				IF (LEN(@strSampleId) > 0)
				BEGIN
					SET @strDetails = '{"change":"dblRepresentingQty","iconCls":"small-gear","from":"' + LTRIM(@dblSRepresentingQty) + '","to":"' + LTRIM(@dblOrgQuantity) + '","leaf":true}'

					EXEC uspSMAuditLog @keyValue = @strSampleId
						,@screenName = 'Quality.view.QualitySample'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END
			END

			SELECT @intSRowNo = MIN(intSRowNo)
			FROM @ParentContractSample
			WHERE intSRowNo > @intSRowNo
		END
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

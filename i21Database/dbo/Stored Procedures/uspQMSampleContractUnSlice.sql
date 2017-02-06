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
		,@intSampleId INT
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
				SET @strDetails = '{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intCContractDetailId) + '","to":"' + LTRIM(@intOrgParentDetailId) + '","leaf":true}'

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
		SELECT @intOrgUnitMeasureId = intUnitMeasureId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intOrgParentDetailId

		DECLARE @MergedSampleDetail TABLE (
			intSampleId INT
			,intContractDetailId INT
			)

		INSERT INTO @MergedSampleDetail
		SELECT intSampleId
			,intContractDetailId
		FROM tblQMSample
		WHERE intContractDetailId IN (
				SELECT intCContractDetailId
				FROM @ContractSliceDetail
				)

		-- Contract Available Places
		UPDATE tblQMSample
		SET intContractDetailId = @intOrgParentDetailId
			,intConcurrencyId = (intConcurrencyId + 1)
			,intRepresentingUOMId = @intOrgUnitMeasureId
		WHERE intContractDetailId IN (
				SELECT intCContractDetailId
				FROM @ContractSliceDetail
				)

		-- Contract Samples
		UPDATE tblQMSample
		SET intProductValueId = @intOrgParentDetailId
		WHERE intProductTypeId = 8
			AND intProductValueId IN (
				SELECT intCContractDetailId
				FROM @ContractSliceDetail
				)

		UPDATE tblQMTestResult
		SET intProductValueId = @intOrgParentDetailId
			,intConcurrencyId = (intConcurrencyId + 1)
		WHERE intProductTypeId = 8
			AND intProductValueId IN (
				SELECT intCContractDetailId
				FROM @ContractSliceDetail
				)

		-- Audit Log
		SELECT @intSampleId = MIN(intSampleId)
		FROM @MergedSampleDetail

		WHILE (@intSampleId > 0)
		BEGIN
			SELECT @intCContractDetailId = intContractDetailId
			FROM @MergedSampleDetail
			WHERE intSampleId = @intSampleId

			IF (@intSampleId > 0)
			BEGIN
				SET @strDetails = '{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intCContractDetailId) + '","to":"' + LTRIM(@intOrgParentDetailId) + '","leaf":true}'

				EXEC uspSMAuditLog @keyValue = @intSampleId
					,@screenName = 'Quality.view.QualitySample'
					,@entityId = @intUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END

			SELECT @intSampleId = MIN(intSampleId)
			FROM @MergedSampleDetail
			WHERE intSampleId > @intSampleId
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

CREATE PROCEDURE uspQMSampleContractSliceByStatus @intContractHeaderId INT
	,@intSampleStatusId INT
	,@ysnMatch BIT = 0
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
		,@intCRowNo1 INT
		,@intCContractDetailId1 INT
		,@intCParentDetailId1 INT
		,@dblCQuantity1 NUMERIC(18, 6)
		,@intCUnitMeasureId1 INT
		,@intOrgParentDetailId INT
		,@ysnSkipQty BIT = 0
	DECLARE @dblNewRepresentingQty NUMERIC(18, 6)
		,@intNewRepresentingUOMId INT
	DECLARE @strDetails NVARCHAR(MAX) = ''
		,@intUserId INT
	DECLARE @dblNewSRepresentingQty NUMERIC(18, 6)
		,@dblTotCQuantity NUMERIC(18, 6)
		,@dblTotSRepresentingQty NUMERIC(18, 6)
	DECLARE @ContractDetail TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractDetailId INT
		,intParentDetailId INT
		,dblQuantity NUMERIC(18, 6)
		,intUnitMeasureId INT
		,ysnParent BIT
		)
	DECLARE @SampleData TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intSampleId INT
		,intContractDetailId INT
		,dblRepresentingQty NUMERIC(18, 6)
		,intRepresentingUOMId INT
		)

	-- Parent contract sequence. ie., from which sequence it sliced
	SELECT TOP 1 @intOrgParentDetailId = intParentDetailId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 1

	-- Parent sequence record only
	INSERT INTO @ContractDetail
	SELECT intContractDetailId
		,intParentDetailId
		,dblQuantity
		,intUnitMeasureId
		,1
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intOrgParentDetailId

	-- Only sliced. ie., new contract sequence records only. After insert, It will have both parent and sliced records
	INSERT INTO @ContractDetail
	SELECT intContractDetailId
		,intParentDetailId
		,dblQuantity
		,intUnitMeasureId
		,0
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 1
	ORDER BY intContractDetailId ASC

	IF (
			(
				SELECT COUNT(1)
				FROM @ContractDetail
				) < 2
			)
		RETURN;

	IF @ysnMatch = 1
	BEGIN
		INSERT INTO @SampleData
		SELECT intSampleId
			,intContractDetailId
			,dblRepresentingQty
			,intRepresentingUOMId
		FROM tblQMSample
		WHERE intProductTypeId = 8
			AND intProductValueId = @intOrgParentDetailId
			AND intSampleStatusId = @intSampleStatusId -- Taking rejected status
		ORDER BY intSampleId ASC
	END
	ELSE
	BEGIN
		INSERT INTO @SampleData
		SELECT intSampleId
			,intContractDetailId
			,dblRepresentingQty
			,intRepresentingUOMId
		FROM tblQMSample
		WHERE intProductTypeId = 8
			AND intProductValueId = @intOrgParentDetailId
			AND intSampleStatusId <> @intSampleStatusId -- Taking except rejected status
		ORDER BY intSampleId ASC
	END

	IF (
			(
				SELECT COUNT(1)
				FROM @SampleData
				) < 1
			)
		RETURN;

	SELECT @intCRowNo = MIN(intRowNo)
	FROM @ContractDetail

	WHILE (ISNULL(@intCRowNo, 0) > 0)
	BEGIN
		SELECT @intCContractDetailId = intContractDetailId
		FROM @ContractDetail
		WHERE intRowNo = @intCRowNo

		SELECT @intSRowNo = MIN(intRowNo)
		FROM @SampleData

		WHILE (ISNULL(@intSRowNo, 0) > 0)
		BEGIN
			SELECT @intSSampleId = NULL
				,@intSContractDetailId = NULL
				,@dblSRepresentingQty = NULL
				,@intSRepresentingUOMId = NULL

			SELECT @intSSampleId = intSampleId
				,@intSContractDetailId = intContractDetailId
				,@dblSRepresentingQty = dblRepresentingQty
				,@intSRepresentingUOMId = intRepresentingUOMId
			FROM @SampleData
			WHERE intRowNo = @intSRowNo

			IF (@ysnSkipQty = 0)
			BEGIN
				SELECT @dblCQuantity = NULL
					,@intCContractDetailId = NULL

				SELECT @dblCQuantity = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, CD.intUnitMeasureId, @intSRepresentingUOMId, CD.dblQuantity)
					,@intCContractDetailId = CD.intContractDetailId
				FROM @ContractDetail CSD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = CSD.intContractDetailId
				WHERE intRowNo = @intCRowNo

				IF (@intCContractDetailId <> @intOrgParentDetailId)
				BEGIN
					SELECT @dblNewSRepresentingQty = NULL
						,@dblTotCQuantity = NULL
						,@dblTotSRepresentingQty = NULL

					-- If Sample Qty exceeds Sequence Qty. Skip the logic. Prateek should confirm this what to do.
					SELECT @dblTotCQuantity = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, CD.intUnitMeasureId, @intSRepresentingUOMId, CD.dblQuantity), 0))
					FROM @ContractDetail CSD
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = CSD.intContractDetailId

					SELECT @dblTotSRepresentingQty = SUM(ISNULL(dblRepresentingQty, 0))
					FROM @SampleData
					WHERE intRowNo < @intSRowNo

					IF (@dblTotSRepresentingQty >= @dblTotCQuantity)
					BEGIN
						SELECT @intSRowNo = MIN(intRowNo)
						FROM @SampleData
						WHERE intRowNo > @intSRowNo

						CONTINUE
					END

					IF @ysnMatch = 1
					BEGIN
						SELECT @dblNewSRepresentingQty = SUM(ISNULL(dblRepresentingQty, 0))
						FROM tblQMSample
						WHERE intProductTypeId = 8
							AND intProductValueId = @intCContractDetailId
							AND intSampleStatusId = @intSampleStatusId -- Taking except rejected status
					END
					ELSE
					BEGIN
						SELECT @dblNewSRepresentingQty = SUM(ISNULL(dblRepresentingQty, 0))
						FROM tblQMSample
						WHERE intProductTypeId = 8
							AND intProductValueId = @intCContractDetailId
							AND intSampleStatusId <> @intSampleStatusId -- Taking except rejected status
					END

					SELECT @dblCQuantity = (ISNULL(@dblCQuantity, 0) - ISNULL(@dblNewSRepresentingQty, 0))
				END
			END

			IF (@dblSRepresentingQty >= @dblCQuantity)
			BEGIN
				-- Update sample representing qty for the original parent contract sequence
				UPDATE tblQMSample
				SET dblRepresentingQty = @dblCQuantity
					,intContractDetailId = @intCContractDetailId
					,intProductValueId = @intCContractDetailId
					,intConcurrencyId = (intConcurrencyId + 1)
				WHERE intSampleId = @intSSampleId

				UPDATE tblQMTestResult
				SET intProductValueId = @intCContractDetailId
					,intConcurrencyId = (intConcurrencyId + 1)
				WHERE intSampleId = @intSSampleId

				SELECT @strSampleId = CONVERT(NVARCHAR, @intSSampleId)

				-- Audit Log
				IF (LEN(@strSampleId) > 0)
				BEGIN
					SELECT @intUserId = NULL

					SELECT @strDetails = '{"change":"dblRepresentingQty","iconCls":"small-gear","from":"' + LTRIM(@dblSRepresentingQty) + '","to":"' + LTRIM(@dblCQuantity) + '","leaf":true}'

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

				SELECT @dblSRepresentingQty = (ISNULL(@dblSRepresentingQty, 0) - ISNULL(@dblCQuantity, 0))

				SELECT @ysnSkipQty = 0

				IF (@dblSRepresentingQty = 0)
				BEGIN
					SELECT @intCRowNo = MIN(intRowNo)
					FROM @ContractDetail
					WHERE intRowNo > @intCRowNo
				END

				-- Create contract sequence samples for the remaining representing qty & should ignore parent seq while taking
				SELECT @intCRowNo1 = MIN(intRowNo)
				FROM @ContractDetail
				WHERE intRowNo > @intCRowNo

				WHILE (
						ISNULL(@intCRowNo1, 0) > 0
						AND @dblSRepresentingQty > 0
						)
				BEGIN
					SELECT @dblNewRepresentingQty = NULL
						,@intNewRepresentingUOMId = NULL

					SELECT @intCContractDetailId1 = NULL
						,@dblCQuantity1 = NULL
						,@intCUnitMeasureId1 = NULL
						,@intNewRepresentingUOMId = NULL

					SELECT @intCContractDetailId1 = CD.intContractDetailId
						,@dblCQuantity1 = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, CD.intUnitMeasureId, @intSRepresentingUOMId, CD.dblQuantity)
						,@intCUnitMeasureId1 = CD.intUnitMeasureId
						,@intNewRepresentingUOMId = @intSRepresentingUOMId
					FROM @ContractDetail CSD
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = CSD.intContractDetailId
					WHERE intRowNo = @intCRowNo1

					IF (@dblSRepresentingQty > @dblCQuantity1)
						SELECT @dblNewRepresentingQty = @dblCQuantity1
					ELSE
						SELECT @dblNewRepresentingQty = @dblSRepresentingQty

					-- Create new sample for seq @intCContractDetailId1, @dblNewRepresentingQty, @intNewRepresentingUOMId. Take other values from existing sample @intSSampleId
					EXEC uspQMSampleContractCopy @intOldSampleId = @intSSampleId
						,@intNewContractDetailId = @intCContractDetailId1
						,@dblNewRepresentingQuantity = @dblNewRepresentingQty
						,@intNewRepresentingUOMId = @intNewRepresentingUOMId
						,@intUserId = @intUserId

					--IF (@dblSRepresentingQty >= @dblCQuantity1)
					--	SELECT @intCRowNo1 = MIN(intRowNo)
					--	FROM @ContractDetail
					--	WHERE intRowNo > @intCRowNo1
					--ELSE
					--	SELECT @intCRowNo = @intCRowNo1
					SELECT @dblSRepresentingQty = (ISNULL(@dblSRepresentingQty, 0) - ISNULL(@dblNewRepresentingQty, 0))

					SELECT @intCRowNo = @intCRowNo1

					SELECT @intCRowNo1 = MIN(intRowNo)
					FROM @ContractDetail
					WHERE intRowNo > @intCRowNo1
				END
			END
			ELSE
			BEGIN
				SELECT @ysnSkipQty = 1

				SELECT @dblCQuantity = (ISNULL(@dblCQuantity, 0) - ISNULL(@dblSRepresentingQty, 0))

				IF (@intCContractDetailId <> @intOrgParentDetailId)
				BEGIN
					-- Contract Available Places
					UPDATE tblQMSample
					SET intContractDetailId = @intCContractDetailId
						,intProductValueId = @intCContractDetailId
						,intConcurrencyId = (intConcurrencyId + 1)
					WHERE intSampleId = @intSSampleId

					UPDATE tblQMTestResult
					SET intProductValueId = @intCContractDetailId
						,intConcurrencyId = (intConcurrencyId + 1)
					WHERE intSampleId = @intSSampleId

					SELECT @strSampleId = CONVERT(NVARCHAR, @intSSampleId)

					-- Audit Log
					IF (LEN(@strSampleId) > 0)
					BEGIN
						SELECT @intUserId = NULL

						SELECT @strDetails = '{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intOrgParentDetailId) + '","to":"' + LTRIM(@intCContractDetailId) + '","leaf":true}'

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
				END
			END

			SELECT @intSRowNo = MIN(intRowNo)
			FROM @SampleData
			WHERE intRowNo > @intSRowNo
		END

		SELECT @intCRowNo = 0
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

CREATE PROCEDURE uspIPUpdatePlannedAvailabilityDate
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @intContractDetailId INT
		,@intContractHeaderId INT
		,@intShippingInstructionId INT
		,@intShipmentId INT
		,@intLoadId INT
		,@intType INT
		,@intShipmentType INT
		,@intLeadTime INT
		,@dtmPlannedAvailabilityDate DATETIME
		,@dtmETAPOD DATETIME
		,@dtmCalculatedAvailabilityDate DATETIME
		,@ysnPosted BIT
		,@ysnUpdateShipment BIT
		,@ysnUpdateContract BIT
		,@intEntityId INT
	DECLARE @ContractShipmentDetail TABLE (
		intContractDetailId INT
		,intContractHeaderId INT
		,intShippingInstructionId INT
		,intShipmentId INT
		,intType INT
		)

	DELETE
	FROM @ContractShipmentDetail

	-- Contract Sequence without LSI and LS
	INSERT INTO @ContractShipmentDetail (
		intContractDetailId
		,intContractHeaderId
		,intShippingInstructionId
		,intShipmentId
		,intType
		)
	SELECT DISTINCT intContractDetailId = CD.intContractDetailId
		,intContractHeaderId = CD.intContractHeaderId
		,intShippingInstructionId = NULL
		,intShipmentId = NULL
		,intType = 1
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		AND LOWER(CO.strCommodityCode) = 'coffee'
	LEFT JOIN tblLGLoadDetail L ON L.intPContractDetailId = CD.intContractDetailId
	WHERE CD.intContractStatusId IN (
			1
			,2
			,4
			)
		AND L.intLoadDetailId IS NULL

	-- Contract Sequence with only LSI (Shipping Instruction) - Shipping Instruction Created & Booked
	INSERT INTO @ContractShipmentDetail (
		intContractDetailId
		,intContractHeaderId
		,intShippingInstructionId
		,intShipmentId
		,intType
		)
	SELECT DISTINCT intContractDetailId = CD.intContractDetailId
		,intContractHeaderId = CD.intContractHeaderId
		,intShippingInstructionId = LSI.intLoadId
		,intShipmentId = NULL
		,intType = 2
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		AND LOWER(CO.strCommodityCode) = 'coffee'
	OUTER APPLY (
		SELECT LSI.intLoadId
		FROM tblLGLoadDetail LSID
		JOIN tblLGLoad LSI ON LSI.intLoadId = LSID.intLoadId
		WHERE LSID.intPContractDetailId = CD.intContractDetailId
			AND LSI.intShipmentType = 2
			AND LSI.intShipmentStatus IN (7) -- Shipping Instruction Created & Booked
		) LSI
	OUTER APPLY (
		SELECT LS.intLoadId
		FROM tblLGLoadDetail LSD
		JOIN tblLGLoad LS ON LS.intLoadId = LSD.intLoadId
		WHERE LSD.intPContractDetailId = CD.intContractDetailId
			AND LS.intShipmentType = 1
			AND LS.intShipmentStatus IN (
				1
				,3
				) -- Scheduled & Inbound Transit
		) LS
	WHERE CD.intContractStatusId IN (
			1
			,2
			,4
			)
		AND LSI.intLoadId IS NOT NULL
		AND LS.intLoadId IS NULL

	-- Contract Sequence with both LSI & LS - Scheduled & Inbound Transit
	INSERT INTO @ContractShipmentDetail (
		intContractDetailId
		,intContractHeaderId
		,intShippingInstructionId
		,intShipmentId
		,intType
		)
	SELECT DISTINCT intContractDetailId = CD.intContractDetailId
		,intContractHeaderId = CD.intContractHeaderId
		,intShippingInstructionId = LSI.intLoadId
		,intShipmentId = LS.intLoadId
		,intType = 3
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		AND LOWER(CO.strCommodityCode) = 'coffee'
	OUTER APPLY (
		SELECT LSI.intLoadId
		FROM tblLGLoadDetail LSID
		JOIN tblLGLoad LSI ON LSI.intLoadId = LSID.intLoadId
		WHERE LSID.intPContractDetailId = CD.intContractDetailId
			AND LSI.intShipmentType = 2
			AND LSI.intShipmentStatus IN (
				1
				,7
				) -- Scheduled & Shipping Instruction Created & Booked
		) LSI
	OUTER APPLY (
		SELECT LS.intLoadId
		FROM tblLGLoadDetail LSD
		JOIN tblLGLoad LS ON LS.intLoadId = LSD.intLoadId
		WHERE LSD.intPContractDetailId = CD.intContractDetailId
			AND LS.intShipmentType = 1
			AND LS.intShipmentStatus IN (
				1
				,3
				) -- Scheduled & Inbound Transit
		) LS
	WHERE CD.intContractStatusId IN (
			1
			,2
			,4
			)
		AND LSI.intLoadId IS NOT NULL
		AND LS.intLoadId IS NOT NULL

	SELECT @intContractDetailId = MIN(intContractDetailId)
	FROM @ContractShipmentDetail

	IF @intContractDetailId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intContractDetailId IS NOT NULL
	BEGIN
		BEGIN TRY
			BEGIN TRAN

			SELECT @intContractHeaderId = NULL
				,@intShippingInstructionId = NULL
				,@intShipmentId = NULL
				,@intLoadId = NULL
				,@intType = NULL
				,@intShipmentType = NULL
				,@intLeadTime = NULL
				,@dtmPlannedAvailabilityDate = NULL
				,@dtmETAPOD = NULL
				,@dtmCalculatedAvailabilityDate = NULL
				,@ysnPosted = NULL
				,@ysnUpdateShipment = 0
				,@ysnUpdateContract = 0

			SELECT @intContractHeaderId = intContractHeaderId
				,@intShippingInstructionId = intShippingInstructionId
				,@intShipmentId = intShipmentId
				,@intType = intType
			FROM @ContractShipmentDetail
			WHERE intContractDetailId = @intContractDetailId

			IF @intType = 3
			BEGIN
				SELECT @intLoadId = @intShipmentId

				SELECT @dtmETAPOD = L.dtmETAPOD
				FROM tblLGLoad L
				WHERE L.intLoadId = @intLoadId

				IF @dtmETAPOD IS NOT NULL
					SELECT @ysnUpdateShipment = 1
				ELSE
				BEGIN
					SELECT @intLoadId = @intShippingInstructionId

					SELECT @dtmETAPOD = L.dtmETAPOD
					FROM tblLGLoad L
					WHERE L.intLoadId = @intLoadId

					IF @dtmETAPOD IS NOT NULL
						SELECT @ysnUpdateShipment = 1
					ELSE
						SELECT @ysnUpdateContract = 1
				END
			END
			ELSE IF @intType = 2
			BEGIN
				SELECT @intLoadId = @intShippingInstructionId

				SELECT @dtmETAPOD = L.dtmETAPOD
				FROM tblLGLoad L
				WHERE L.intLoadId = @intLoadId

				IF @dtmETAPOD IS NOT NULL
					SELECT @ysnUpdateShipment = 1
				ELSE
					SELECT @ysnUpdateContract = 1
			END
			ELSE IF @intType = 1
			BEGIN
				SELECT @ysnUpdateContract = 1
			END

			IF @ysnUpdateContract = 1
			BEGIN
				-- To set Contract Planned Availability Date and send Contract feed to SAP
				EXEC uspCTUpdatePlannedAvailabilityDate @intContractHeaderId = @intContractHeaderId
					,@intContractDetailId = @intContractDetailId
			END
			ELSE IF @ysnUpdateShipment = 1
			BEGIN
				IF @intType <> 1
				BEGIN
					SELECT @intLeadTime = ISNULL(DPort.intLeadTime, 0)
						,@dtmPlannedAvailabilityDate = L.dtmPlannedAvailabilityDate
						,@dtmETAPOD = L.dtmETAPOD
						,@intShipmentType = L.intShipmentType
						,@ysnPosted = ISNULL(L.ysnPosted, 0)
					FROM tblLGLoad L
					OUTER APPLY (
						SELECT TOP 1 intLeadTime
						FROM tblSMCity DPort
						WHERE DPort.strCity = L.strDestinationPort
							AND DPort.ysnPort = 1
						) DPort
					WHERE L.intLoadId = @intLoadId

					SELECT @dtmCalculatedAvailabilityDate = DATEADD(DD, ISNULL(@intLeadTime, 0), @dtmETAPOD)

					IF @dtmCalculatedAvailabilityDate <> @dtmPlannedAvailabilityDate
					BEGIN
						UPDATE tblLGLoad
						SET dtmPlannedAvailabilityDate = @dtmCalculatedAvailabilityDate
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intLoadId = @intLoadId

						-- Audit Log
						SELECT @intEntityId = intEntityId
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'IRELYADMIN'

						EXEC dbo.uspSMAuditLog @keyValue = @intLoadId 
							,@screenName = 'Logistics.view.ShipmentSchedule'
							,@entityId = @intEntityId
							,@actionType = 'Updated (from Scheduler)'
							,@actionIcon = 'small-tree-modified'
							,@changeDescription = 'Planned Availability Date'
							,@fromValue = @dtmPlannedAvailabilityDate
							,@toValue = @dtmCalculatedAvailabilityDate

						-- To set Contract Planned Availability Date and send Contract feed to SAP
						-- Also it sends Shipment feed to SAP only for LS
						EXEC uspLGCreateLoadIntegrationLog @intLoadId = @intLoadId
							,@strRowState = 'Modified'
							,@intShipmentType = @intShipmentType -- 1(LS), 2(LSI)

						IF @intShipmentType = 1 -- LS
						BEGIN
							EXEC uspLGProcessIntegrationLogData
						END

						-- Sends LSP Shipment feed to SAP only for Posted LS
						IF ISNULL(@ysnPosted, 0) = 1
							AND @intShipmentType = 1
						BEGIN
							EXEC uspLGCreateLoadIntegrationLSPLog @intLoadId = @intLoadId
								,@strRowState = 'Modified'
								,@intShipmentType = 1 -- LS
						END
					END
				END
			END

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg
		END CATCH

		SELECT @intContractDetailId = MIN(intContractDetailId)
		FROM @ContractShipmentDetail
		WHERE intContractDetailId > @intContractDetailId
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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

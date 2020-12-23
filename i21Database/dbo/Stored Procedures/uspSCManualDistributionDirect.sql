CREATE PROCEDURE [dbo].[uspSCManualDistributionDirect]
	@DistributeContract ScaleManualDistributeContractTable READONLY
	,@DistributeLoad ScaleManualDistributeLoadTable READONLY
	,@DistributeSpot ScaleManualDistributeSpotTable READONLY
	,@DistributeStorage ScaleManualDistributeStorageTable READONLY
	,@intTicketId AS INT
	,@intUserId AS INT

AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @total AS INT
	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @strTicketStatus NVARCHAR(1)
	DECLARE @strTicketInOutFlag NVARCHAR(1)
	DECLARE @strTicketWhereFinalizedWeight NVARCHAR(15)
	DECLARE	@strTicketWhereFinalizedGrade NVARCHAR(15)
	DECLARE	@intTicketEntityId INT
	DECLARE @intTicketItemUOMId INT
	DECLARE @intTicketContractDetailId INT
	DECLARE @intTicketStorageScheduleTypeId INT
	DECLARE @dblTicketScheduleQty NUMERIC(18,6)
	DECLARE @intTicketLoadDetailId INT

	DECLARE @intBillId INT
	DECLARE @ysnBillPosted BIT 

	DECLARE @_intContractDetailId INT
	DECLARE @_intLoadDetailId INT
	DECLARE @_intTicketContractUsedId INT
	DECLARE @_dblUsedQuantity NUMERIC(18,6)
	DECLARE @_dblFinalUsedQuantity NUMERIC(18,6)
	DECLARE @_intTicketLoadUsedId NUMERIC(18,6)
	DECLARE @_dblLoadQuantity NUMERIC(18,6)
	DECLARE @_dblContractAvailable NUMERIC(18,6)
	DECLARE @_dblContractSchedule NUMERIC(18,6)
	DECLARE @_ysnContractLoadBase BIT
	DECLARE @_dblUsedScheduleQtyDiff NUMERIC(18,6)
	

	BEGIN TRY
		--Get Ticket Information
		BEGIN
			SELECT TOP 1
				@strTicketStatus = A.strTicketStatus
				,@strTicketInOutFlag = A.strInOutFlag
				,@strTicketWhereFinalizedWeight = ISNULL(CTWG1.strWhereFinalized,'Origin')
				,@strTicketWhereFinalizedGrade = ISNULL(CTWG2.strWhereFinalized,'Origin')
				,@intTicketEntityId = A.intEntityId
				,@intTicketItemUOMId = A.intItemUOMIdTo
				,@intTicketContractDetailId = intContractId
				,@intTicketStorageScheduleTypeId = intStorageScheduleTypeId
				,@dblTicketScheduleQty = dblScheduleQty
				,@intTicketLoadDetailId = intLoadDetailId
			FROM tblSCTicket A
			LEFT JOIN tblCTWeightGrade CTWG1
				ON A.intWeightId = CTWG1.intWeightGradeId 
			LEFT JOIN tblCTWeightGrade CTWG2
				ON A.intGradeId = CTWG2.intWeightGradeId 
			WHERE A.intTicketId = @intTicketId
		END


		--CONTRACT
		BEGIN
			INSERT INTO tblSCTicketContractUsed(
				intTicketId
				,intContractDetailId
				,intEntityId
				,dblScheduleQty
			)
			SELECT 
				intTicketId
				,intContractDetailId
				,intEntityId
				,dblScheduleQty = dblQty
			FROM 
				@DistributeContract

			---Schedule non-ticket contracts
			BEGIN
				SELECT TOP 1 
					@_intContractDetailId = intContractDetailId
					,@_intTicketContractUsedId = intTicketContractUsed
					,@_dblUsedQuantity = dblScheduleQty
				FROM tblSCTicketContractUsed
				WHERE intTicketId = @intTicketId
					AND intContractDetailId <> @intTicketContractDetailId
				ORDER BY intTicketContractUsed ASC

				WHILE (ISNULL(@_intTicketContractUsedId,0) > 0)
				BEGIN
					SET @_dblFinalUsedQuantity = @_dblUsedQuantity
					EXEC uspCTUpdateScheduleQuantityUsingUOM 
									@intContractDetailId	=	@_intContractDetailId
									,@dblQuantityToUpdate	=	@_dblFinalUsedQuantity
									,@intUserId				=	@intUserId
									,@intExternalId			=	@intTicketId
									,@strScreenName			=   'Auto - Scale'
									,@intSourceItemUOMId	=	@intTicketItemUOMId
					--- LOOP Iterator
					BEGIN
						IF EXISTS (SELECT TOP 1 1 FROM tblSCTicketContractUsed WHERE intTicketId = @intTicketId AND intTicketContractUsed > @_intTicketContractUsedId AND intContractDetailId <> @intTicketContractDetailId)
						BEGIN
							SELECT TOP 1 
								@_intContractDetailId = intContractDetailId
								,@_intTicketContractUsedId = intTicketContractUsed
								,@_dblUsedQuantity = dblScheduleQty
							FROM tblSCTicketContractUsed
							WHERE intTicketId = @intTicketId
								AND intTicketContractUsed > @_intTicketContractUsedId
								AND intContractDetailId <> @intTicketContractDetailId
							ORDER BY intTicketContractUsed ASC
						END
						ELSE
						BEGIN
							SET @_intTicketContractUsedId = NULL
						END
					END
				END
			END

			---Adjust ticket contract schedule
			BEGIN
				--Contract Distribution
				IF @intTicketStorageScheduleTypeId = -2 AND ISNULL(@intTicketContractDetailId,0) > 0 
				BEGIN
					SET @_dblUsedQuantity = 0
					SELECT TOP 1 
						@_dblUsedQuantity = dblScheduleQty
					FROM tblSCTicketContractUsed
					WHERE intTicketId = @intTicketId
						AND intContractDetailId = @intTicketContractDetailId

				
					SET @_dblFinalUsedQuantity = (@dblTicketScheduleQty - @_dblUsedQuantity) * -1
					IF @_dblFinalUsedQuantity <> 0
					BEGIN
						EXEC uspCTUpdateScheduleQuantityUsingUOM 
							@intContractDetailId	=	@intTicketContractDetailId
							,@dblQuantityToUpdate	=	@_dblFinalUsedQuantity
							,@intUserId				=	@intUserId
							,@intExternalId			=	@intTicketId
							,@strScreenName			=   'Auto - Scale'
							,@intSourceItemUOMId	=	@intTicketItemUOMId
					END
				END
			END

			
		END

		--LOAD
		BEGIN
			INSERT INTO tblSCTicketLoadUsed(
				intTicketId
				,intLoadDetailId
				,intEntityId
				,dblQty
			)
			SELECT 
				intTicketId
				,intLoadDetailId
				,intEntityId
				,dblQty
			FROM 
				@DistributeLoad


			---Adjust Schedule 
			BEGIN
				SET @_intTicketLoadUsedId = NULL

				

				--Get Load and Contract Information
				BEGIN
					IF OBJECT_ID (N'tempdb.dbo.#tmpLoadContractTable') IS NOT NULL
						DROP TABLE #tmpLoadContractTable

					SELECT 
						dblLoadQuantity = B.dblQuantity
						,dblContractScheduleQty = C.dblScheduleQty
						,ysnContractLoadBased = CAST(ISNULL(D.ysnLoad,0) AS BIT)
						,dblcontractAvailable = ISNULL(C.dblBalance,0)		-	ISNULL(C.dblScheduleQty,0)
						,A.intTicketLoadUsedId
						,A.dblQty
						,dblQtyContractUOM = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, C.intItemUOMId, A.dblQty)
						,A.intLoadDetailId
					INTO #tmpLoadContractTable
					FROM tblSCTicketLoadUsed A
					INNER JOIN tblLGLoadDetail B
						ON A.intLoadDetailId = B.intLoadDetailId
					INNER JOIN tblCTContractDetail C
						ON C.intContractDetailId = CASE WHEN @strTicketInOutFlag = 'I' THEN B.intPContractDetailId WHEN @strTicketInOutFlag = 'O' THEN B.intSContractDetailId END
					INNER JOIN tblCTContractHeader D	
						ON C.intContractHeaderId = D.intContractHeaderId
					WHERE A.intTicketId = @intTicketId 
					ORDER BY A.intTicketLoadUsedId ASC
					
				END

				SELECT TOP 1 
					@_intLoadDetailId = intLoadDetailId
					,@_intTicketLoadUsedId = intTicketLoadUsedId
					,@_dblUsedQuantity = dblQtyContractUOM
					,@_dblContractAvailable = dblcontractAvailable
					,@_dblContractSchedule = dblContractScheduleQty
					,@_ysnContractLoadBase = ysnContractLoadBased
				FROM #tmpLoadContractTable
				ORDER BY intTicketLoadUsedId ASC


				WHILE (ISNULL(@_intTicketLoadUsedId,0) > 0)
				BEGIN
					SET @_dblFinalUsedQuantity = 0
					SET @_dblUsedScheduleQtyDiff = 0

					--Non Load based Contract
					IF(ISNULL(@_ysnContractLoadBase,0) = 0)
					BEGIN
						--Check if load quantity is not the same as the allocated units then adjust schedule
						IF(@_dblLoadQuantity <> @_dblUsedQuantity)
						BEGIN
							IF(@_dblLoadQuantity > @_dblUsedQuantity)
							BEGIN
								SET @_dblUsedScheduleQtyDiff = @_dblUsedQuantity - @_dblLoadQuantity
							END
							ELSE
							BEGIN
								SET @_dblUsedScheduleQtyDiff = @_dblLoadQuantity - @_dblUsedQuantity
							END
						END

						IF @_dblContractSchedule >= @_dblUsedQuantity
						BEGIN
							IF @_dblUsedScheduleQtyDiff <> 0
							BEGIN
								SET @_dblFinalUsedQuantity = @_dblUsedScheduleQtyDiff
							END
						END
						ELSE
						BEGIN
							SET  @_dblFinalUsedQuantity = @_dblUsedQuantity - @_dblContractSchedule + @_dblUsedScheduleQtyDiff
						END

						IF 	@_dblFinalUsedQuantity <> 0	
						BEGIN				
							EXEC uspCTUpdateScheduleQuantity
								@intContractDetailId	=	@_intContractDetailId
								,@dblQuantityToUpdate	=	@_dblFinalUsedQuantity
								,@intUserId				=	@intUserId
								,@intExternalId			=	@intTicketId
								,@strScreenName			=   'Auto - Scale'
						END
					END

					--- LOOP Iterator
					BEGIN
						IF EXISTS (SELECT TOP 1 1 FROM #tmpLoadContractTable WHERE intTicketLoadUsedId > @_intTicketLoadUsedId)
						BEGIN
							SELECT TOP 1 
								@_intLoadDetailId = intLoadDetailId
								,@_intTicketLoadUsedId = intTicketLoadUsedId
								,@_dblUsedQuantity = dblQtyContractUOM
								,@_dblContractAvailable = dblcontractAvailable
								,@_dblContractSchedule = dblContractScheduleQty
								,@_ysnContractLoadBase = ysnContractLoadBased
							FROM #tblLoadContractTable
							WHERE intTicketLoadUsedId > @_intTicketLoadUsedId
							ORDER BY intTicketLoadUsedId ASC
						END
						ELSE
						BEGIN
							SET @_intTicketLoadUsedId = NULL
						END
					END
				END
			END

			---Adjust ticket contract schedule
			BEGIN
				--Contract Distribution
				IF @intTicketStorageScheduleTypeId = -6 AND ISNULL(@intTicketContractDetailId,0) > 0 
				BEGIN
					SET @_dblUsedQuantity = 0
					SELECT TOP 1 
						@_dblUsedQuantity = dblQty
					FROM tblSCTicketLoadUsed
					WHERE intTicketId = @intTicketId
						AND intLoadDetailId = @intTicketLoadDetailId

				
					SET @_dblFinalUsedQuantity = (@dblTicketScheduleQty - @_dblUsedQuantity) * -1
					IF @_dblFinalUsedQuantity <> 0
					BEGIN
						EXEC uspCTUpdateScheduleQuantityUsingUOM 
							@intContractDetailId	=	@intTicketContractDetailId
							,@dblQuantityToUpdate	=	@_dblFinalUsedQuantity
							,@intUserId				=	@intUserId
							,@intExternalId			=	@intTicketId
							,@strScreenName			=   'Auto - Scale'
							,@intSourceItemUOMId	=	@intTicketItemUOMId
					END
				END
			END

		END

		--SPOT
		BEGIN
			INSERT INTO tblSCTicketSpotUsed(
				intTicketId
				,dblBasis
				,dblFuture
				,intEntityId
				,dblQty
			)
			SELECT 
				intTicketId
				,dblBasis
				,dblFuture
				,intEntityId
				,dblQty
			FROM 
				@DistributeSpot
		END


		--Storage
		BEGIN
			INSERT INTO tblSCTicketStorageUsed(
				intTicketId
				,intStorageTypeId
				,intStorageScheduleId
				,intEntityId
				,dblQty
			)
			SELECT 
				intTicketId
				,intStorageTypeId
				,intStorageScheduleId
				,intEntityId
				,dblQty
			FROM 
				@DistributeStorage
		END


		---Direct In
		IF @strTicketInOutFlag = 'I'
		BEGIN
			----VALIDATION
			BEGIN
				IF @strTicketStatus = 'C' OR  @strTicketStatus = 'V'
				BEGIN
					RAISERROR('Cannot distribute closed ticket.', 11, 1);
				END

				---Check existing IS and Invoice
				-- if isnull(@ysnSkipValidation, 0) = 0
				-- begin
				-- 	SELECT TOP 1 
				-- 		@_strReceiptNumber = ISNULL(B.strReceiptNumber,'')
				-- 	FROM tblICInventoryReceiptItem A
				-- 	INNER JOIN tblICInventoryReceipt B
				-- 		ON A.intInventoryReceiptId = B.intInventoryReceiptId
				-- 	WHERE B.intSourceType = 1
				-- 		AND A.intSourceId = @intTicketId

				-- 	IF ISNULL(@_strReceiptNumber,'') <> ''
				-- 	BEGIN
				-- 		SET @ErrMsg  = 'Cannot distribute ticket. Ticket already have a receipt ' + @_strReceiptNumber + '.'
				-- 		RAISERROR(@ErrMsg, 11, 1);
				-- 	END
				-- end
			END

			IF LOWER(ISNULL(@strTicketWhereFinalizedWeight,'Origin')) <> 'destination' AND LOWER(ISNULL(@strTicketWhereFinalizedGrade,'Origin')) <> 'destination'
			BEGIN

				EXEC uspSCDirectCreateVoucher 
					@intTicketId = @intTicketId
					,@intUserId = @intUserId
					,@ysnManualDistribution = 1
					,@intBillId = @intBillId OUT
					,@ysnBillPosted  = @ysnBillPosted OUT

				IF(@intBillId > 0)
				BEGIN
					---Update contract Balance and schedule Base on contract Used
					BEGIN
						--CONTRACT
						BEGIN
							SELECT TOP 1 
								@_intContractDetailId = intContractDetailId
								,@_intTicketContractUsedId = intTicketContractUsed
								,@_dblUsedQuantity = dblScheduleQty
							FROM tblSCTicketContractUsed
							WHERE intTicketId = @intTicketId
							ORDER BY intTicketContractUsed ASC

							WHILE (ISNULL(@_intTicketContractUsedId,0) > 0)
							BEGIN
								
								SELECT TOP 1
									@_dblFinalUsedQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, B.intItemUOMId, A.dblScheduleQty) 
								FROM tblSCTicketContractUsed A
								INNER JOIN tblCTContractDetail B
									ON A.intContractDetailId = B.intContractDetailId
								WHERE intTicketContractUsed = @_intTicketContractUsedId

								SET @_dblFinalUsedQuantity = @_dblFinalUsedQuantity * -1
								EXEC uspCTUpdateScheduleQuantityUsingUOM 
												@intContractDetailId	=	@_intContractDetailId
												,@dblQuantityToUpdate	=	@_dblFinalUsedQuantity
												,@intUserId				=	@intUserId
												,@intExternalId			=	@intBillId
												,@strScreenName			=   'Voucher'	
												,@intSourceItemUOMId	=	@intTicketItemUOMId
								SET @_dblFinalUsedQuantity = @_dblFinalUsedQuantity * -1
								EXEC uspCTUpdateSequenceBalance @_intContractDetailId, @_dblFinalUsedQuantity, @intUserId, @intBillId, 'Voucher'

								--- LOOP Iterator
								BEGIN
									IF EXISTS (SELECT TOP 1 1 FROM tblSCTicketContractUsed WHERE intTicketId = @intTicketId AND intTicketContractUsed > @_intTicketContractUsedId)
									BEGIN
										SELECT TOP 1 
											@_intContractDetailId = intContractDetailId
											,@_intTicketContractUsedId = intTicketContractUsed
											,@_dblUsedQuantity = dblScheduleQty
										FROM tblSCTicketContractUsed
										WHERE intTicketId = @intTicketId
											AND intTicketContractUsed > @_intTicketContractUsedId
										ORDER BY intTicketContractUsed ASC
									END
									ELSE
									BEGIN
										SET @_intTicketContractUsedId = NULL
									END
								END
							END
						END

						--LOAD
						BEGIN
							SET @_intTicketLoadUsedId = NULL

							SELECT TOP 1 
								@_intLoadDetailId = A.intLoadDetailId
								,@_intTicketLoadUsedId = A.intTicketLoadUsedId
								,@_dblUsedQuantity = A.dblQty
								,@_intContractDetailId = CNT.intContractDetailId
							FROM tblSCTicketLoadUsed A
							INNER JOIN tblLGLoadDetail LGD
								ON A.intLoadDetailId = LGD.intLoadDetailId
							INNER JOIN tblCTContractDetail CNT
									ON CNT.intContractDetailId = ISNULL(intPContractDetailId,0)
							WHERE intTicketId = @intTicketId
							ORDER BY intTicketLoadUsedId ASC

							WHILE (ISNULL(@_intTicketLoadUsedId,0) > 0)
							BEGIN
								
								IF(ISNULL(@_intContractDetailId,0) > 0)
								BEGIN
									SELECT TOP 1
										@_dblFinalUsedQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, CNT.intItemUOMId, A.dblQty) 
									FROM tblSCTicketLoadUsed A
									INNER JOIN tblLGLoadDetail LGD
										ON A.intLoadDetailId = LGD.intLoadDetailId
									INNER JOIN tblCTContractDetail CNT
											ON CNT.intContractDetailId = ISNULL(intPContractDetailId,0)
									WHERE A.intTicketId = @intTicketId
										AND A.intTicketLoadUsedId = @_intTicketLoadUsedId

									SET @_dblFinalUsedQuantity = @_dblFinalUsedQuantity * -1
									EXEC uspCTUpdateScheduleQuantityUsingUOM 
													@intContractDetailId	=	@_intContractDetailId
													,@dblQuantityToUpdate	=	@_dblFinalUsedQuantity
													,@intUserId				=	@intUserId
													,@intExternalId			=	@intBillId
													,@strScreenName			=   'Voucher'	
													,@intSourceItemUOMId	=	@intTicketItemUOMId
									SET @_dblFinalUsedQuantity = @_dblFinalUsedQuantity * -1
									EXEC uspCTUpdateSequenceBalance @_intContractDetailId, @_dblFinalUsedQuantity, @intUserId, @intBillId, 'Voucher'
								END

								--- LOOP Iterator
								BEGIN
									IF EXISTS (SELECT TOP 1 1 FROM tblSCTicketLoadUsed WHERE intTicketId = @intTicketId AND intTicketLoadUsedId > @_intTicketLoadUsedId)
									BEGIN
										SELECT TOP 1 
											@_intLoadDetailId = A.intLoadDetailId
											,@_intTicketLoadUsedId = A.intTicketLoadUsedId
											,@_dblUsedQuantity = A.dblQty
											,@_intContractDetailId = CNT.intContractDetailId
										FROM tblSCTicketLoadUsed A
										INNER JOIN tblLGLoadDetail LGD
											ON A.intLoadDetailId = LGD.intLoadDetailId
										INNER JOIN tblCTContractDetail CNT
												ON CNT.intContractDetailId = ISNULL(intPContractDetailId,0)
										WHERE A.intTicketId = @intTicketId
											AND A.intTicketLoadUsedId > @_intTicketLoadUsedId
										ORDER BY intTicketLoadUsedId ASC
									END
									ELSE
									BEGIN
										SET @_intTicketLoadUsedId = NULL
									END
								END
							END
						END
					END
				END
			END

		END

		---Direct Out
		ELSE
		BEGIN
			----VALIDATION
			BEGIN
				IF @strTicketStatus = 'C' OR  @strTicketStatus = 'V'
				BEGIN
					RAISERROR('Cannot distribute closed ticket.', 11, 1);
				END
			END
		END

		-- Update Ticket Status
		UPDATE tblSCTicket
		SET strTicketStatus = 'C'
		WHERE intTicketId = @intTicketId

	
		
		_Exit:

	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END CATCH
END
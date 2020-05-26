CREATE PROCEDURE [dbo].[uspSCProcessDirectShipment]
	@intTicketId INT,
	@intEntityId INT,
	@intLocationId INT,
	@dtmScaleDate DATETIME,
	@intUserId INT,
	@strInOutFlag NVARCHAR(5),
	@intMatchTicketId INT = 0,
	@strTicketType NVARCHAR(10) = '',
	@ysnPostDestinationWeight BIT = 0,
	@intInvoiceId AS INT = NULL OUTPUT,
	@intBillId AS INT = NULL OUTPUT
	,@dtmClientDate DATETIME = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg NVARCHAR(MAX);

DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
		,@strWhereFinalizedWeight NVARCHAR(20)
		,@strWhereFinalizedGrade NVARCHAR(20)
		,@strWhereFinalizedMatchWeight NVARCHAR(20)
		,@strWhereFinalizedMatchGrade NVARCHAR(20)
		,@intMatchTicketEntityId INT
		,@intMatchTicketLocationId INT
		,@intContractDetailId INT
		,@dblContractUnits NUMERIC(38, 20)
		,@intMatchContractDetailId INT
		,@dblMatchContractUnits NUMERIC(38, 20)
		,@intTicketItemUOMId INT
		,@InventoryShipmentId INT
		,@dblContractAvailableQty NUMERIC(38, 20)
		,@intPricingTypeId INT
		,@dblNetUnits NUMERIC(18,6) = 0
		,@intDirectLoadId INT
DECLARE @ysnTicketMatchContractLoadBased BIT
DECLARE @ysnTicketContractLoadBased BIT
DECLARE @intTicketLoadDetailId BIT
DECLARE @intMatchTicketLoadDetailId BIT
DECLARE @intMatchTicketStorageScheduleTypeId INT
DECLARE @dblMatchTicketScheduleQty NUMERIC(18,6)
DECLARE @_dblAllocatedUnits NUMERIC(38, 20)
DECLARE @_dblLoadQuantity NUMERIC(18,6)
DECLARE @_dblContractScheduleQuantity NUMERIC(18,6)
DECLARE @_dblContractAvailQuantity NUMERIC(18,6)
DECLARE @_dblScheduleAdjustment NUMERIC(18,6)
DECLARE @intTicketContractDetailId INT
DECLARE @intMatchTicketContractDetailId INT
DECLARE @ysnContractLoadBased BIT
DECLARE @intTicketStorageScheduleTypeId INT
DECLARE @dblTicketScheduledQty NUMERIC(38, 20)
DECLARE @dblMatchTicketScheduledQty NUMERIC(18, 6)
DECLARE @_dblMatchTicketScheduledQty NUMERIC(38, 20)
DECLARE @dblLoadUsedQty NUMERIC(38,20)
DECLARE @dblTicketNetUnits NUMERIC(18, 6)
DECLARE @_dblDestinationQuantity NUMERIC(38, 20)
DECLARE @dblContractScheduledQty NUMERIC(18,6)
DECLARE @dblScheduleAdjustment NUMERIC(38, 20)
DECLARE @_dblTicketScheduledQty NUMERIC(38, 20)

BEGIN TRY

	SELECT @strWhereFinalizedWeight = CTWeight.strWhereFinalized
		, @strWhereFinalizedGrade = CTGrade.strWhereFinalized
		, @intContractDetailId = SC.intContractId
		, @intTicketItemUOMId = SC.intItemUOMIdTo
		, @dblContractUnits = SC.dblNetUnits
		,@dblTicketScheduledQty = ISNULL(SC.dblScheduleQty,0)
		,@dblTicketNetUnits = SC.dblNetUnits
		,@intTicketStorageScheduleTypeId = SC.intStorageScheduleTypeId 
		,@intTicketContractDetailId = SC.intContractId
	FROM tblSCTicket SC 
	LEFT JOIN tblCTWeightGrade CTGrade 
		ON CTGrade.intWeightGradeId = SC.intGradeId
	LEFT JOIN tblCTWeightGrade CTWeight 
		ON CTWeight.intWeightGradeId = SC.intWeightId
	WHERE intTicketId = @intTicketId

	SELECT @strWhereFinalizedMatchWeight = CTWeight.strWhereFinalized
		, @strWhereFinalizedMatchGrade = CTGrade.strWhereFinalized
		, @intMatchTicketEntityId = SC.intEntityId
		, @intMatchTicketLocationId = SC.intProcessingLocationId
		, @dtmScaleDate = SC.dtmTicketDateTime 
		, @intMatchTicketContractDetailId = SC.intContractId
		, @dblMatchContractUnits = SC.dblNetUnits
		, @intMatchTicketStorageScheduleTypeId = SC.intStorageScheduleTypeId
		,@dblMatchTicketScheduledQty = ISNULL(SC.dblScheduleQty,0)
	FROM tblSCTicket SC  
	LEFT JOIN tblCTWeightGrade CTGrade 
		ON CTGrade.intWeightGradeId = SC.intGradeId
	LEFT JOIN tblCTWeightGrade CTWeight 
		ON CTWeight.intWeightGradeId = SC.intWeightId
	WHERE intTicketId = @intMatchTicketId 


	IF ISNULL(@ysnPostDestinationWeight, 0) = 1
	BEGIN
		IF @strTicketType = 'Direct'
		BEGIN

			IF ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Destination'
			BEGIN
				UPDATE	MatchTicket SET
					MatchTicket.dblGrossWeight = SC.dblGrossWeight
					,MatchTicket.dblGrossWeight1 = SC.dblGrossWeight1
					,MatchTicket.dblGrossWeight2 = SC.dblGrossWeight2
					,MatchTicket.dblTareWeight = SC.dblTareWeight
					,MatchTicket.dblTareWeight1 = SC.dblTareWeight1
					,MatchTicket.dblTareWeight2 = SC.dblTareWeight2
					,MatchTicket.dblGrossUnits = SC.dblGrossUnits
					,MatchTicket.dblShrink = SC.dblShrink
					,MatchTicket.dblNetUnits = SC.dblNetUnits
					
					FROM dbo.tblSCTicket SC 
					OUTER APPLY(
						SELECT dblGrossWeight
						,dblGrossWeight1
						,dblGrossWeight2
						,dblTareWeight
						,dblTareWeight1
						,dblTareWeight2
						,dblGrossUnits
						,dblShrink
						,dblNetUnits 
						,dblScheduleQty
						FROM tblSCTicket where intTicketId = SC.intMatchTicketId
					) MatchTicket
				WHERE SC.intTicketId = @intTicketId
			END

			IF ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Destination'
			BEGIN
				DELETE FROM tblQMTicketDiscount
				WHERE intTicketId = @intMatchTicketId AND strSourceType = 'Scale'

				UPDATE tblSCTicket
				SET intDiscountId = A.intDiscountId
					,intDiscountSchedule = A.intDiscountSchedule
				FROM (SELECT TOP 1 intDiscountId 
							,intDiscountSchedule
						FROM tblSCTicket
						WHERE intTicketId  = @intTicketId) A
				WHERE intTicketId = @intMatchTicketId

				INSERT INTO tblQMTicketDiscount (
					dblGradeReading
					,strCalcMethod
					,strShrinkWhat
					,dblShrinkPercent
					,dblDiscountAmount
					,dblDiscountDue
					,dblDiscountPaid
					,ysnGraderAutoEntry
					,intDiscountScheduleCodeId
					,dtmDiscountPaidDate
					,intTicketId
					,intTicketFileId
					,strSourceType
					,intSort
					,strDiscountChargeType
					,intConcurrencyId
				)
				SELECT 
					dblGradeReading
					,strCalcMethod
					,strShrinkWhat
					,dblShrinkPercent
					,dblDiscountAmount
					,dblDiscountDue
					,dblDiscountPaid
					,ysnGraderAutoEntry
					,intDiscountScheduleCodeId
					,dtmDiscountPaidDate
					,intTicketId = @intMatchTicketId
					,intTicketFileId
					,strSourceType
					,intSort
					,strDiscountChargeType
					,intConcurrencyId = 0
				FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strSourceType = 'Scale'
			END

			IF ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Destination'
			BEGIN

				IF ISNULL(@strWhereFinalizedMatchWeight, 'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedMatchGrade, 'Origin') = 'Destination'
				BEGIN
					EXEC uspSCDirectCreateVoucher @intMatchTicketId,@intMatchTicketEntityId,@intMatchTicketLocationId,@dtmScaleDate,@intUserId

					IF ISNULL(@intMatchTicketContractDetailId,0) != 0
					BEGIN
						---Contract Details
						SELECT TOP 1
							@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
							,@dblContractAvailableQty = ISNULL(A.dblBalance,0) - ISNULL(A.dblScheduleQty,0)
							,@dblContractScheduledQty = ISNULL(A.dblScheduleQty,0)
						FROM tblCTContractDetail A
						INNER JOIN tblCTContractHeader B
							ON A.intContractHeaderId = B.intContractHeaderId
						WHERE A.intContractDetailId = @intMatchTicketContractDetailId 

						SELECT @_dblMatchTicketScheduledQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblMatchTicketScheduledQty) FROM tblCTContractDetail WHERE intContractDetailId = @intMatchTicketContractDetailId
						SELECT @_dblDestinationQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketNetUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intMatchTicketContractDetailId

						IF(@intMatchTicketStorageScheduleTypeId = -2) ---Contract Distribution
						BEGIN
							SET @dblScheduleAdjustment = 0;
							IF(@_dblMatchTicketScheduledQty <> @_dblDestinationQuantity)
							BEGIN
								SET @dblScheduleAdjustment  = @_dblDestinationQuantity - @_dblMatchTicketScheduledQty 

								IF @dblScheduleAdjustment > 0
								BEGIN
									IF(@dblContractScheduledQty >= @_dblMatchTicketScheduledQty)
									BEGIN
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
									ELSE
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
								END
								ELSE IF @dblScheduleAdjustment < 0
								BEGIN
									IF(@dblContractScheduledQty < @_dblMatchTicketScheduledQty)
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
								END
							END
							
							
							UPDATE tblSCTicket
							SET dblScheduleQty = @dblTicketNetUnits
							WHERE intContractId = @intMatchTicketId
							
						END

						EXEC uspCTUpdateSequenceBalance @intMatchContractDetailId, @dblContractAvailableQty, @intUserId, @intMatchTicketId, 'Scale'
						SET @dblContractAvailableQty = @dblContractAvailableQty * -1
						IF(@intMatchTicketStorageScheduleTypeId = -6) ---Load Distribution
						BEGIN
							SET @dblScheduleAdjustment = 0;
							IF(@_dblMatchTicketScheduledQty <> @_dblDestinationQuantity)
							BEGIN
								SET @dblScheduleAdjustment  = @_dblDestinationQuantity - @_dblMatchTicketScheduledQty 

								IF(@dblScheduleAdjustment > 0)
								BEGIN
									IF(@dblContractScheduledQty < @_dblDestinationQuantity)
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
									ELSE
									BEGIN
										SET @dblScheduleAdjustment = 0
									END
								END
								ELSE IF(@dblScheduleAdjustment < 0)
								BEGIN
									IF(@dblContractScheduledQty < ABS(@dblScheduleAdjustment))
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty 
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
									
								END
								
							END
						END

						IF(ISNULL(@ysnContractLoadBased,0) = 1)
						BEGIN
							SET @dblScheduleAdjustment = 0
						END

						IF(@dblScheduleAdjustment <> 0)
						BEGIN
							EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intMatchTicketContractDetailId,
									@dblQuantityToUpdate	=	@dblScheduleAdjustment,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intMatchTicketId,
									@strScreenName			=   'Auto - Scale'	
						END

						
						IF(ISNULL(@ysnContractLoadBased,0) = 1)
						BEGIN
							SET @_dblDestinationQuantity = 1
						END
						

						EXEC uspCTUpdateSequenceBalance @intMatchTicketContractDetailId, @_dblDestinationQuantity, @intUserId, @intMatchTicketId, 'Scale'
						SET @dblLoadUsedQty = @_dblDestinationQuantity * -1
						EXEC uspCTUpdateScheduleQuantity
										@intContractDetailId	=	@intMatchTicketContractDetailId,
										@dblQuantityToUpdate	=	@dblLoadUsedQty,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intMatchTicketId,
										@strScreenName			=   'Scale'	
					END

					DELETE FROM @ItemsToIncreaseInTransitDirect
					INSERT INTO @ItemsToIncreaseInTransitDirect(
						[intItemId]
						,[intItemLocationId]
						,[intItemUOMId]
						,[intLotId]
						,[intSubLocationId]
						,[intStorageLocationId]
						,[dblQty]
						,[intTransactionId]
						,[strTransactionId]
						,[intTransactionTypeId]
						,[intFOBPointId]
					)
					SELECT 
						intItemId = SC.intItemId
						,intItemLocationId = ICIL.intItemLocationId
						,intItemUOMId = SC.intItemUOMIdTo
						,intLotId = SC.intLotId
						,intSubLocationId = SC.intSubLocationId
						,intStorageLocationId = SC.intStorageLocationId
						,dblQty = SC.dblNetUnits
						,intTransactionId = 1
						,strTransactionId = SC.strTicketNumber
						,intTransactionTypeId = 1
						,intFOBPointId = NULL
					FROM tblSCTicket SC 
					INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
					WHERE SC.intTicketId = @intMatchTicketId
					EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;
				END

				IF ISNULL(@intTicketContractDetailId,0) > 0
				BEGIN
					---Contract Details
					SELECT TOP 1
						@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
						,@dblContractAvailableQty = ISNULL(A.dblBalance,0) - ISNULL(A.dblScheduleQty,0)
						,@dblContractScheduledQty = ISNULL(A.dblScheduleQty,0)
					FROM tblCTContractDetail A
					INNER JOIN tblCTContractHeader B
						ON A.intContractHeaderId = B.intContractHeaderId
					WHERE A.intContractDetailId = @intTicketContractDetailId 

					SELECT @_dblTicketScheduledQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketScheduledQty) FROM tblCTContractDetail WHERE intContractDetailId = @intTicketContractDetailId
					SELECT @_dblDestinationQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketNetUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intTicketContractDetailId

					IF(@intTicketStorageScheduleTypeId = -2) ---Contract Distribution
					BEGIN
						SET @dblScheduleAdjustment = 0;
						IF(@_dblTicketScheduledQty <> @_dblDestinationQuantity)
						BEGIN
							SET @dblScheduleAdjustment  = @_dblDestinationQuantity - @_dblTicketScheduledQty 

							IF @dblScheduleAdjustment > 0
							BEGIN
								IF(@dblContractScheduledQty >= @_dblTicketScheduledQty)
								BEGIN
									IF(@dblContractAvailableQty < @dblScheduleAdjustment)
									BEGIN
										RAISERROR('Sales contract balance is not enough to process transaction.', 11, 1);
									END
								END
								ELSE 
								BEGIN
									SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
									IF(@dblContractAvailableQty < @dblScheduleAdjustment)
									BEGIN
										RAISERROR('Sales contract balance is not enough to process transaction.', 11, 1);
									END
								END
							END
							ELSE IF(@dblScheduleAdjustment < 0)
							BEGIN
								IF(@dblContractScheduledQty < @_dblTicketScheduledQty)
								BEGIN
									SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
									IF(@dblContractAvailableQty < @dblScheduleAdjustment)
									BEGIN
										RAISERROR('Sales contract balance is not enough to process transaction.', 11, 1);
									END
								END
							END

							UPDATE tblSCTicket
							SET dblScheduleQty = @_dblDestinationQuantity
							WHERE intTicketId = @intTicketId
						END
						
						
					END

					IF(@intTicketStorageScheduleTypeId = -6) ---Load Distribution
					BEGIN
						SET @dblScheduleAdjustment = 0;
						-- IF(@_dblTicketScheduledQty <> @_dblDestinationQuantity)
						-- BEGIN
						-- 	SET @dblScheduleAdjustment  = @_dblDestinationQuantity - @_dblTicketScheduledQty 

						-- 	IF(@dblScheduleAdjustment > 0)
						-- 	BEGIN
						-- 		IF(@dblContractScheduledQty < @_dblDestinationQuantity)
						-- 		BEGIN
						-- 			SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
						-- 			IF(@dblContractAvailableQty < @dblScheduleAdjustment)
						-- 			BEGIN
						-- 				RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
						-- 			END
						-- 		END
						-- 	END
						-- 	ELSE IF(@dblScheduleAdjustment < 0)
						-- 	BEGIN
						-- 		IF(@dblContractScheduledQty < ABS(@dblScheduleAdjustment))
						-- 		BEGIN
						-- 			SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty 
						-- 			IF(@dblContractAvailableQty < @dblScheduleAdjustment)
						-- 			BEGIN
						-- 				RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
						-- 			END
						-- 			SET @dblScheduleAdjustment = 0; --Already handled in invoice.
						-- 		END
						-- 	END
						-- END
					END

					IF(@dblScheduleAdjustment <> 0)
					BEGIN
						EXEC uspCTUpdateScheduleQuantity
								@intContractDetailId	=	@intTicketContractDetailId,
								@dblQuantityToUpdate	=	@dblScheduleAdjustment,
								@intUserId				=	@intUserId,
								@intExternalId			=	@intTicketId,
								@strScreenName			=   'Auto - Scale'	
					END
				
				
				END

				DECLARE @dblPricedContractQty AS DECIMAL(18,6)

				SELECT @dblPricedContractQty = ISNULL(SUM(CTP.dblQuantity),0) FROM vyuCTPriceContractFixationDetail CTP
				INNER JOIN tblCTPriceFixation CPX
					ON CPX.intPriceFixationId = CTP.intPriceFixationId
				INNER JOIN tblCTContractDetail CT
					ON CPX.intContractDetailId = CT.intContractDetailId
				INNER JOIN tblSCTicket SC
					ON SC.intContractId = CT.intContractDetailId
				WHERE  SC.intTicketId = @intTicketId

				IF(@dblPricedContractQty > 0 OR (NOT EXISTS (SELECT TOP 1 1 FROM vyuCTPriceContractFixationDetail CTP
				INNER JOIN tblCTPriceFixation CPX
					ON CPX.intPriceFixationId = CTP.intPriceFixationId
				INNER JOIN tblCTContractDetail CT
					ON CPX.intContractDetailId = CT.intContractDetailId
				INNER JOIN tblSCTicket SC
					ON SC.intContractId = CT.intContractDetailId
				WHERE  SC.intTicketId = @intTicketId) AND (SELECT intPricingTypeId FROM tblCTContractDetail CD INNER JOIN tblSCTicket SC ON SC.intContractId = CD.intContractDetailId WHERE intTicketId = @intTicketId) != 2))
				BEGIN
					EXEC uspSCDirectCreateInvoice @intTicketId,@intEntityId,@intLocationId,@intUserId

					IF(ISNULL(@intMatchTicketId,0) > 0)
					DELETE FROM @ItemsToIncreaseInTransitDirect
					INSERT INTO @ItemsToIncreaseInTransitDirect(
						[intItemId]
						,[intItemLocationId]
						,[intItemUOMId]
						,[intLotId]
						,[intSubLocationId]
						,[intStorageLocationId]
						,[dblQty]
						,[intTransactionId]
						,[strTransactionId]
						,[intTransactionTypeId]
						,[intFOBPointId]
					)
					SELECT 
						intItemId = SC.intItemId
						,intItemLocationId = ICIL.intItemLocationId
						,intItemUOMId = SC.intItemUOMIdTo
						,intLotId = SC.intLotId
						,intSubLocationId = SC.intSubLocationId
						,intStorageLocationId = SC.intStorageLocationId
						,dblQty = SC.dblNetUnits * -1
						,intTransactionId = 1
						,strTransactionId = SC.strTicketNumber
						,intTransactionTypeId = 1
						,intFOBPointId = NULL
					FROM tblSCTicket SC 
					INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
					WHERE SC.intTicketId = @intMatchTicketId
					EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;
				END
			END
		END
		ELSE
		BEGIN
			EXEC dbo.uspSCInsertDestinationInventoryShipment @intTicketId, @intUserId, 1

			SELECT TOP 1 
				@InventoryShipmentId = intInventoryShipmentId 
			FROM vyuICGetInventoryShipmentItem 
			WHERE intSourceId = @intTicketId 
				AND strSourceType = 'Scale'

			SELECT 
				@intPricingTypeId = intPricingTypeId 
				,@intTicketItemUOMId = intItemUOMIdTo
				,@dblNetUnits = dblNetUnits
			FROM tblSCTicket SC
			LEFT JOIN tblCTContractDetail CTD 
				ON CTD.intContractDetailId = SC.intContractId
			WHERE SC.intTicketId = @intTicketId

			IF ISNULL(@InventoryShipmentId, 0) != 0 
			BEGIN
				EXEC uspSCProcessShipmentToInvoice 
					@intTicketId = @intTicketId
					,@intInventoryShipmentId = @InventoryShipmentId
					,@intUserId = @intUserId
					,@intInvoiceId = @intInvoiceId OUTPUT 
					,@dtmClientDate = @dtmClientDate
				

				IF(@intInvoiceId IS NOT NULL and @dblNetUnits > (SELECT CAST(SUM(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId,@intTicketItemUOMId,ISI.dblQuantity)) AS DECIMAL(18,6))  FROM tblICInventoryShipment ICIS
					INNER JOIN tblICInventoryShipmentItem ISI ON ICIS.intInventoryShipmentId = ISI.intInventoryShipmentId
					WHERE intSourceId = @intTicketId))
				BEGIN
					EXEC dbo.uspARUpdateOverageContracts @intInvoiceId,@intTicketItemUOMId,@intUserId,@dblNetUnits,0,@intTicketId

					declare @InAdj as InventoryAdjustmentIntegrationId
					insert into @InAdj(intInventoryShipmentId, intTicketId, intInvoiceId)
					select @InventoryShipmentId, @intTicketId, @intInvoiceId
					Exec uspICInventoryAdjustmentUpdateLinkingId @LinkingData = @InAdj, @ysnShipment = 1
				END
			END

			
		END
	END
	ELSE
	BEGIN
		SELECT @strWhereFinalizedWeight = strWeightFinalized
			,@strWhereFinalizedGrade = strGradeFinalized
			,@intContractDetailId = intContractId
			,@intTicketItemUOMId = intItemUOMIdTo
			,@dblContractUnits = dblNetUnits
			,@intDirectLoadId = intLoadId
		FROM vyuSCTicketScreenView WHERE intTicketId = @intTicketId

		IF @strInOutFlag = 'I'
		BEGIN
			IF ISNULL(@strWhereFinalizedWeight,'Origin') <> 'Destination' AND ISNULL(@strWhereFinalizedGrade,'Origin') <> 'Destination'
			BEGIN
				EXEC uspSCDirectCreateVoucher @intTicketId,@intEntityId,@intLocationId,@dtmScaleDate,@intUserId, @intBillId OUT

				BEGIN
					IF ISNULL(@intTicketContractDetailId,0) != 0
					BEGIN
						---Contract Details
						SELECT TOP 1
							@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
							,@dblContractAvailableQty = ISNULL(A.dblBalance,0) - ISNULL(A.dblScheduleQty,0)
							,@dblContractScheduledQty = ISNULL(A.dblScheduleQty,0)
						FROM tblCTContractDetail A
						INNER JOIN tblCTContractHeader B
							ON A.intContractHeaderId = B.intContractHeaderId
						WHERE A.intContractDetailId = @intTicketContractDetailId 

						SELECT @_dblTicketScheduledQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketScheduledQty) FROM tblCTContractDetail WHERE intContractDetailId = @intTicketContractDetailId
						SELECT @_dblDestinationQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketNetUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intTicketContractDetailId

						IF(@intTicketStorageScheduleTypeId = -2) ---Contract Distribution
						BEGIN
							SET @dblScheduleAdjustment = 0;
							IF(@_dblTicketScheduledQty <> @_dblDestinationQuantity)
							BEGIN
								SET @dblScheduleAdjustment  = @_dblDestinationQuantity - @_dblTicketScheduledQty 

								IF @dblScheduleAdjustment > 0
								BEGIN
									IF(@dblContractScheduledQty >= @_dblTicketScheduledQty)
									BEGIN
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
									ELSE
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
								END
								ELSE IF @dblScheduleAdjustment < 0
								BEGIN
									IF(@dblContractScheduledQty < @_dblTicketScheduledQty)
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
								END
							END
							
						
							
						END

						IF(@intTicketStorageScheduleTypeId = -6) ---Load Distribution
						BEGIN
							SET @dblScheduleAdjustment = 0;
							IF(@_dblTicketScheduledQty <> @_dblDestinationQuantity)
							BEGIN
								SET @dblScheduleAdjustment  = @_dblDestinationQuantity - @_dblTicketScheduledQty 

								IF(@dblScheduleAdjustment > 0)
								BEGIN
									IF(@dblContractScheduledQty < @_dblDestinationQuantity)
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
									ELSE
									BEGIN
										SET @dblScheduleAdjustment = 0
									END
								END
								ELSE IF(@dblScheduleAdjustment < 0)
								BEGIN
									IF(@dblContractScheduledQty < ABS(@dblScheduleAdjustment))
									BEGIN
										SET @dblScheduleAdjustment = @_dblDestinationQuantity - @dblContractScheduledQty 
										IF(@dblContractAvailableQty < @dblScheduleAdjustment)
										BEGIN
											RAISERROR('Purchase contract balance is not enough to process transaction.', 11, 1);
										END
									END
									
								END
								
							END
						END

						IF(ISNULL(@ysnContractLoadBased,0) = 1)
						BEGIN
							SET @dblScheduleAdjustment = 0
						END

						IF(@dblScheduleAdjustment <> 0)
						BEGIN
							EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intTicketContractDetailId,
									@dblQuantityToUpdate	=	@dblScheduleAdjustment,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=   'Auto - Scale'	
						END

						
						IF(ISNULL(@ysnContractLoadBased,0) = 1)
						BEGIN
							SET @_dblDestinationQuantity = 1
						END
						
						
						EXEC uspCTUpdateSequenceBalance @intTicketContractDetailId, @_dblDestinationQuantity, @intUserId, @intTicketId, 'Scale'
						SET @dblLoadUsedQty = @_dblDestinationQuantity * -1
						EXEC uspCTUpdateScheduleQuantity
										@intContractDetailId	=	@intTicketContractDetailId,
										@dblQuantityToUpdate	=	@dblLoadUsedQty,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intTicketId,
										@strScreenName			=   'Scale'	
					END
				END
				
			END
			
			DELETE FROM @ItemsToIncreaseInTransitDirect
			INSERT INTO @ItemsToIncreaseInTransitDirect(
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQty]
				,[intTransactionId]
				,[strTransactionId]
				,[intTransactionTypeId]
				,[intFOBPointId]
			)
			SELECT 
				intItemId = SC.intItemId
				,intItemLocationId = ICIL.intItemLocationId
				,intItemUOMId = SC.intItemUOMIdTo
				,intLotId = SC.intLotId
				,intSubLocationId = SC.intSubLocationId
				,intStorageLocationId = SC.intStorageLocationId
				,dblQty = SC.dblNetUnits
				,intTransactionId = 1
				,strTransactionId = SC.strTicketNumber
				,intTransactionTypeId = 1
				,intFOBPointId = NULL
			FROM tblSCTicket SC 
			INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
			WHERE SC.intTicketId = @intTicketId
			EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;
			
		END
		ELSE
		BEGIN
			IF ISNULL(@strWhereFinalizedWeight,'Origin') <> 'Destination' AND ISNULL(@strWhereFinalizedGrade,'Origin') <> 'Destination'
			BEGIN
				SELECT @dblPricedContractQty = SUM(CTP.dblQuantity) FROM vyuCTPriceContractFixationDetail CTP
				INNER JOIN tblCTPriceFixation CPX
					ON CPX.intPriceFixationId = CTP.intPriceFixationId
				INNER JOIN tblCTContractDetail CT
					ON CPX.intContractDetailId = CT.intContractDetailId
				INNER JOIN tblSCTicket SC
					ON SC.intContractId = CT.intContractDetailId
				WHERE CT.intContractDetailId = @intTicketId

				IF(@dblPricedContractQty > 0 OR NOT EXISTS (SELECT TOP 1 1 FROM vyuCTPriceContractFixationDetail CTP
				INNER JOIN tblCTPriceFixation CPX
					ON CPX.intPriceFixationId = CTP.intPriceFixationId
				INNER JOIN tblCTContractDetail CT
					ON CPX.intContractDetailId = CT.intContractDetailId
				INNER JOIN tblSCTicket SC
					ON SC.intContractId = CT.intContractDetailId
				WHERE  SC.intTicketId = @intTicketId))
				BEGIN
					EXEC uspSCDirectCreateInvoice @intTicketId,@intEntityId,@intLocationId,@intUserId,@intInvoiceId OUTPUT

					IF(ISNULL(@intMatchTicketId,0) > 0)
					BEGIN
						DELETE FROM @ItemsToIncreaseInTransitDirect
						INSERT INTO @ItemsToIncreaseInTransitDirect(
							[intItemId]
							,[intItemLocationId]
							,[intItemUOMId]
							,[intLotId]
							,[intSubLocationId]
							,[intStorageLocationId]
							,[dblQty]
							,[intTransactionId]
							,[strTransactionId]
							,[intTransactionTypeId]
							,[intFOBPointId]
						)
						SELECT 
							intItemId = SC.intItemId
							,intItemLocationId = ICIL.intItemLocationId
							,intItemUOMId = SC.intItemUOMIdTo
							,intLotId = SC.intLotId
							,intSubLocationId = SC.intSubLocationId
							,intStorageLocationId = SC.intStorageLocationId
							,dblQty = SC.dblNetUnits * -1
							,intTransactionId = 1
							,strTransactionId = SC.strTicketNumber
							,intTransactionTypeId = 1
							,intFOBPointId = NULL
						FROM tblSCTicket SC 
						INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
						WHERE SC.intTicketId = @intMatchTicketId
						EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;
					END
				END
			END
		END
	END
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
GO

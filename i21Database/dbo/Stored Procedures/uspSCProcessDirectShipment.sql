CREATE PROCEDURE [dbo].[uspSCProcessDirectShipment]
	@ScaleDWGAllocation ScaleDWGAllocation READONLY
	,@intTicketId INT,
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
SET ANSI_WARNINGS ON

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
DECLARE @intTicketLoadDetailId INT
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
DECLARE @intContractPricingType INT


DECLARE @ItemsToIncreaseInTransitInBound AS InTransitTableType 

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
		,@intTicketLoadDetailId = SC.intLoadDetailId
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
					,intDiscountSchedule = A.intDiscountSchedule, dtmDateModifiedUtc = GETUTCDATE()
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
							WHERE intTicketId = @intMatchTicketId
							
						END

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
			EXEC dbo.uspSCInsertDestinationInventoryShipment @ScaleDWGAllocation,@intTicketId, @intUserId, 1

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
					,@ysnDWG = 1
				

				IF(@intInvoiceId IS NOT NULL and @dblNetUnits > (SELECT CAST(SUM(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId,@intTicketItemUOMId,ISI.dblQuantity)) AS DECIMAL(18,6))  FROM tblICInventoryShipment ICIS
					INNER JOIN tblICInventoryShipmentItem ISI ON ICIS.intInventoryShipmentId = ISI.intInventoryShipmentId
					WHERE intSourceId = @intTicketId AND ICIS.intSourceType = 1))
				BEGIN
					

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
		
			
			IF ISNULL(@intTicketContractDetailId,0) != 0
			BEGIN
				---Contract Details
				SELECT TOP 1
					@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
					,@dblContractAvailableQty = ISNULL(A.dblBalance,0) - ISNULL(A.dblScheduleQty,0)
					,@dblContractScheduledQty = ISNULL(A.dblScheduleQty,0)
					,@intContractPricingType = B.intPricingTypeId
				FROM tblCTContractDetail A
				INNER JOIN tblCTContractHeader B
					ON A.intContractHeaderId = B.intContractHeaderId
				WHERE A.intContractDetailId = @intTicketContractDetailId 

				SELECT @_dblTicketScheduledQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketScheduledQty) FROM tblCTContractDetail WHERE intContractDetailId = @intTicketContractDetailId
				SELECT @_dblDestinationQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblTicketNetUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intTicketContractDetailId

				---Contract Distribution
				IF(@intTicketStorageScheduleTypeId = -2) 
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
					
					INSERT INTO tblSCTicketContractUsed (
						[intTicketId]
						,[intContractDetailId] 
						,[intEntityId] 
						,[dblScheduleQty] 
					)
					SELECT
						intTicketId = @intTicketId
						,[intContractDetailId] = @intTicketContractDetailId
						,[intEntityId] = @intEntityId
						,[dblScheduleQty] = @dblTicketNetUnits

					INSERT INTO tblSCTicketDistributionAllocation(
						intTicketId
						,intSourceId
						,intSourceType
					)
					SELECT 
						intTicketId = @intTicketId
						,intSourceId = intTicketContractUsed
						,intSourceType = 1
					FROM tblSCTicketContractUsed
					WHERE intTicketId = @intTicketId
					
				END

				---Load Distribution
				IF(@intTicketStorageScheduleTypeId = -6) 
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

					--REcord the Allocation
					INSERT INTO tblSCTicketLoadUsed (
						[intTicketId]
						,[intLoadDetailId] 
						,[intEntityId] 
						,[dblQty] 
					)
					SELECT
						@intTicketId
						,@intTicketLoadDetailId
						,@intEntityId
						,@dblTicketNetUnits

					INSERT INTO tblSCTicketDistributionAllocation(
						intTicketId
						,intSourceId
						,intSourceType
					)
					SELECT 
						intTicketId = @intTicketId
						,intSourceId = intTicketLoadUsedId
						,intSourceType = 2
					FROM tblSCTicketLoadUsed
					WHERE intTicketId = @intTicketId
					
				END
			END
			ELSE
			BEGIN
				--SPOT DISTRIBUTION
				IF(@intTicketStorageScheduleTypeId = -3)
				BEGIN
					INSERT INTO tblSCTicketSpotUsed(
						intTicketId
						,intEntityId
						,dblUnitFuture
						,dblUnitBasis
						,dblQty
					)
					SELECT 
						intTicketId = @intTicketId
						,intEntityId = @intEntityId
						,dblUnitFuture = dblUnitPrice
						,dblUnitBasis = dblUnitBasis
						,dblQty = dblNetUnits
					FROM tblSCTicket
					WHERE intTicketId = @intTicketId

					INSERT INTO tblSCTicketDistributionAllocation(
						intTicketId
						,intSourceId
						,intSourceType
					)
					SELECT 
						intTicketId = @intTicketId
						,intSourceId = intTicketSpotUsedId
						,intSourceType = 4
					FROM tblSCTicketSpotUsed
					WHERE intTicketId = @intTicketId
				END
				---STORAGE DISTRIBUTION
				ELSE
				BEGIN
					INSERT INTO tblSCTicketStorageUsed(
						intTicketId
						,intEntityId
						,intStorageTypeId
						,intStorageScheduleId
						,dblQty
					)
					SELECT 
						intTicketId = @intTicketId
						,intEntityId = @intEntityId
						,intStorageTypeId = intStorageScheduleTypeId
						,intStorageScheduleId = intStorageScheduleId
						,dblQty = dblNetUnits
					FROM tblSCTicket
					WHERE intTicketId = @intTicketId

					INSERT INTO tblSCTicketDistributionAllocation(
						intTicketId
						,intSourceId
						,intSourceType
					)
					SELECT 
						intTicketId = @intTicketId
						,intSourceId = intTicketStorageUsedId
						,intSourceType = 3
					FROM tblSCTicketStorageUsed
					WHERE intTicketId = @intTicketId
				END
			END

			EXEC uspSCDirectUpdateContractAndLoadUsed
				@intTicketId = @intTicketId
				,@intUserId = @intUserId

			--- INCREASE DIRECT IN-Transit
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
						
				
			

			--CHECK for BASIS/HTA Contract used and insert in tblSCTicketDirectBasisContract
			BEGIN

				--- COntract
				INSERT INTO tblSCTicketDirectBasisContract(
					intTicketId
					,intContractDetailId
					,ysnProcessed
				)
				SELECT 
					A.intTicketId
					,A.intContractDetailId
					,ysnProcessed = 0
				FROM tblSCTicketContractUsed A
				INNER JOIN tblCTContractDetail B
					ON A.intContractDetailId = B.intContractDetailId
				INNER JOIN tblCTContractHeader C
					ON B.intContractHeaderId = C.intContractHeaderId
				WHERE A.intTicketId = @intTicketId
					AND (C.intPricingTypeId = 2 OR C.intPricingTypeId = 3)
				

				--LOAD
				INSERT INTO tblSCTicketDirectBasisContract(
					intTicketId
					,intContractDetailId
					,ysnProcessed
				)
				SELECT 
					A.intTicketId
					,B.intContractDetailId 
					,ysnProcessed = 0
				FROM tblSCTicketLoadUsed A
				INNER JOIN tblLGLoadDetail E
					ON A.intLoadDetailId = E.intLoadDetailId
				INNER JOIN tblCTContractDetail B
					ON E.intPContractDetailId = B.intContractDetailId
				INNER JOIN tblCTContractHeader C
					ON B.intContractHeaderId = C.intContractHeaderId
				WHERE A.intTicketId = @intTicketId
					AND (C.intPricingTypeId = 2 OR C.intPricingTypeId = 3)
			END

			---Create GL Entries
			EXEC uspSCCreateDirectInGLEntries @intTicketId, 1, @intUserId 

			--Create Voucher
			EXEC uspSCDirectCreateVoucher @intTicketId,@intEntityId,@intLocationId,@dtmScaleDate,@intUserId, @intBillId OUT
			

			/*------Increase inventory inbound in transit
				BEGIN
					INSERT INTO @ItemsToIncreaseInTransitInBound(
						[intItemId] 
						,[intItemLocationId] 
						,[intItemUOMId] 
						,[intLotId] 
						,[intSubLocationId] 
						,[intStorageLocationId] 
						,[dblQty] 
						,[intTransactionId] 
						,[strTransactionId] 
						,[dtmTransactionDate] 
						,[intTransactionTypeId] 
						,[intFOBPointId] 
					)
					SELECT
						[intItemId] = SC.intItemId
						,[intItemLocationId] = ICL.intItemLocationId
						,[intItemUOMId] = SC.intItemUOMIdTo
						,[intLotId] = NULL
						,[intSubLocationId] = SC.intSubLocationId
						,[intStorageLocationId] = SC.intStorageLocationId
						,[dblQty] = SC.dblNetUnits
						,[intTransactionId] = SC.intTicketId
						,[strTransactionId] = SC.strTicketNumber
						,[dtmTransactionDate] = GETDATE()
						,[intTransactionTypeId] = 52  -- scale ticket
						,[intFOBPointId] = NULL
					FROM tblSCTicket SC
					INNER JOIN tblICItemLocation ICL
						ON SC.intItemId = ICL.intItemId
							AND SC.intProcessingLocationId = ICL.intLocationId
					WHERE intTicketId = @intTicketId

					EXEC [dbo].[uspICIncreaseInTransitInBoundQty] @ItemsToIncreaseInTransitInBound 
				END*/

			
		
			
		END
		ELSE
		BEGIN

			---RECORD ALLOCATION				
			BEGIN
				IF ISNULL(@intTicketContractDetailId,0) != 0
				BEGIN
					---Contract Distribution
					IF(@intTicketStorageScheduleTypeId = -2) 
					BEGIN
						INSERT INTO tblSCTicketContractUsed (
							[intTicketId]
							,[intContractDetailId] 
							,[intEntityId] 
							,[dblScheduleQty] 
						)
						SELECT
							intTicketId = @intTicketId
							,[intContractDetailId] = @intTicketContractDetailId
							,[intEntityId] = @intEntityId
							,[dblScheduleQty] = @dblTicketNetUnits

						INSERT INTO tblSCTicketDistributionAllocation(
							intTicketId
							,intSourceId
							,intSourceType
						)
						SELECT 
							intTicketId = @intTicketId
							,intSourceId = intTicketContractUsed
							,intSourceType = 1
						FROM tblSCTicketContractUsed
						WHERE intTicketId = @intTicketId
						
					END

					---Load Distribution
					IF(@intTicketStorageScheduleTypeId = -6) 
					BEGIN
						INSERT INTO tblSCTicketLoadUsed (
							[intTicketId]
							,[intLoadDetailId] 
							,[intEntityId] 
							,[dblQty] 
						)
						SELECT
							@intTicketId
							,@intTicketLoadDetailId
							,@intEntityId
							,@dblTicketNetUnits

						INSERT INTO tblSCTicketDistributionAllocation(
							intTicketId
							,intSourceId
							,intSourceType
						)
						SELECT 
							intTicketId = @intTicketId
							,intSourceId = intTicketLoadUsedId
							,intSourceType = 2
						FROM tblSCTicketLoadUsed
						WHERE intTicketId = @intTicketId
						
					END
				END
				ELSE
				BEGIN
					--SPOT DISTRIBUTION
					IF(@intTicketStorageScheduleTypeId = -3)
					BEGIN
						INSERT INTO tblSCTicketSpotUsed(
							intTicketId
							,intEntityId
							,dblUnitFuture
							,dblUnitBasis
							,dblQty
						)
						SELECT 
							intTicketId = @intTicketId
							,intEntityId = @intEntityId
							,dblUnitFuture = dblUnitPrice
							,dblUnitBasis = dblUnitBasis
							,dblQty = dblNetUnits
						FROM tblSCTicket
						WHERE intTicketId = @intTicketId

						INSERT INTO tblSCTicketDistributionAllocation(
							intTicketId
							,intSourceId
							,intSourceType
						)
						SELECT 
							intTicketId = @intTicketId
							,intSourceId = intTicketSpotUsedId
							,intSourceType = 4
						FROM tblSCTicketSpotUsed
						WHERE intTicketId = @intTicketId
					END
					---STORAGE DISTRIBUTION
					ELSE
					BEGIN
						INSERT INTO tblSCTicketStorageUsed(
							intTicketId
							,intEntityId
							,intStorageTypeId
							,intStorageScheduleId
							,dblQty
						)
						SELECT 
							intTicketId = @intTicketId
							,intEntityId = @intEntityId
							,intStorageTypeId = intStorageScheduleTypeId
							,intStorageScheduleId = intStorageScheduleId
							,dblQty = dblNetUnits
						FROM tblSCTicket
						WHERE intTicketId = @intTicketId

						INSERT INTO tblSCTicketDistributionAllocation(
							intTicketId
							,intSourceId
							,intSourceType
						)
						SELECT 
							intTicketId = @intTicketId
							,intSourceId = intTicketStorageUsedId
							,intSourceType = 3
						FROM tblSCTicketStorageUsed
						WHERE intTicketId = @intTicketId
					END
				END
			END
		
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

			--CHECK for BASIS/HTA Contract used and insert in tblSCTicketDirectBasisContract
			BEGIN

				--- COntract
				INSERT INTO tblSCTicketDirectBasisContract(
					intTicketId
					,intContractDetailId
					,ysnProcessed
				)
				SELECT 
					A.intTicketId
					,A.intContractDetailId
					,ysnProcessed = 0
				FROM tblSCTicketContractUsed A
				INNER JOIN tblCTContractDetail B
					ON A.intContractDetailId = B.intContractDetailId
				INNER JOIN tblCTContractHeader C
					ON B.intContractHeaderId = C.intContractHeaderId
				WHERE A.intTicketId = @intTicketId
					AND (C.intPricingTypeId = 2 OR C.intPricingTypeId = 3)
				

				--LOAD
				INSERT INTO tblSCTicketDirectBasisContract(
					intTicketId
					,intContractDetailId
					,ysnProcessed
				)
				SELECT 
					A.intTicketId
					,B.intContractDetailId 
					,ysnProcessed = 0
				FROM tblSCTicketLoadUsed A
				INNER JOIN tblLGLoadDetail E
					ON A.intLoadDetailId = E.intLoadDetailId
				INNER JOIN tblCTContractDetail B
					ON E.intSContractDetailId = B.intContractDetailId
				INNER JOIN tblCTContractHeader C
					ON B.intContractHeaderId = C.intContractHeaderId
				WHERE A.intTicketId = @intTicketId
					AND (C.intPricingTypeId = 2 OR C.intPricingTypeId = 3)
			END

			--CHECK for BASIS/HTA Contract used and insert in tblSCTicketDirectBasisContract
			BEGIN

				--- COntract
				INSERT INTO tblSCTicketDirectBasisContract(
					intTicketId
					,intContractDetailId
					,ysnProcessed
				)
				SELECT 
					A.intTicketId
					,A.intContractDetailId
					,ysnProcessed = 0
				FROM tblSCTicketContractUsed A
				INNER JOIN tblCTContractDetail B
					ON A.intContractDetailId = B.intContractDetailId
				INNER JOIN tblCTContractHeader C
					ON B.intContractHeaderId = C.intContractHeaderId
				WHERE A.intTicketId = @intTicketId
					AND (C.intPricingTypeId = 2 OR C.intPricingTypeId = 3)
				

				--LOAD
				INSERT INTO tblSCTicketDirectBasisContract(
					intTicketId
					,intContractDetailId
					,ysnProcessed
				)
				SELECT 
					A.intTicketId
					,B.intContractDetailId 
					,ysnProcessed = 0
				FROM tblSCTicketLoadUsed A
				INNER JOIN tblLGLoadDetail E
					ON A.intLoadDetailId = E.intLoadDetailId
				INNER JOIN tblCTContractDetail B
					ON E.intSContractDetailId = B.intContractDetailId
				INNER JOIN tblCTContractHeader C
					ON B.intContractHeaderId = C.intContractHeaderId
				WHERE A.intTicketId = @intTicketId
					AND (C.intPricingTypeId = 2 OR C.intPricingTypeId = 3)
			END



			---CREATE INVOICE
			BEGIN
				EXEC uspSCDirectCreateInvoice @intTicketId,@intEntityId,@intLocationId,@intUserId,@intInvoiceId OUTPUT
			END

			---UPDATE DIRECT IN TRANSIT
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

		
			UPDATE tblSCTicket
				SET ysnDestinationWeightGradePost = 1
			WHERE intTicketId = @intTicketId
		
		END
	END

	DECLARE @change_description nvarchar(200)
	DECLARE @from_description nvarchar(200)
	DECLARE @to_description nvarchar(200)
	DECLARE @action_description nvarchar(200)
	select @change_description = case when @ysnPostDestinationWeight = 1 then 'Transaction has been posted.' else  'Transaction has been unposted.' end 	
			,@from_description = case when @ysnPostDestinationWeight = 1 then 'Unposted' else  'Posted' end 
			,@to_description = case when @ysnPostDestinationWeight = 0 then 'Posted' else  'Unposted' end 	
			,@action_description = case when @ysnPostDestinationWeight = 1 then 'Posted' else  'Unposted' end 	

	EXEC dbo.uspSMAuditLog 
			@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= @action_description		-- Action Type
			,@changeDescription	= ''						-- Description
			,@fromValue			= ''								-- Old Value
			,@toValue			= ''								-- New Value
			,@details			= '';

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

	


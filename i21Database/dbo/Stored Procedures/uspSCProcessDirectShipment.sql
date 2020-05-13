﻿CREATE PROCEDURE [dbo].[uspSCProcessDirectShipment]
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
DECLARE @intTicketContractDetailId INT
DECLARE @intMatchTicketContractDetailId INT
DECLARE @ysnContractLoadBased BIT

BEGIN TRY
	IF ISNULL(@ysnPostDestinationWeight, 0) = 1
	BEGIN
		IF @strTicketType = 'Direct'
		BEGIN
			SELECT @strWhereFinalizedWeight = strWeightFinalized
				, @strWhereFinalizedGrade = strGradeFinalized
				, @intContractDetailId = intContractId
				, @intTicketItemUOMId = intItemUOMIdTo
				, @dblContractUnits = dblNetUnits
			FROM vyuSCTicketScreenView WHERE intTicketId = @intTicketId

			SELECT @strWhereFinalizedMatchWeight = strWeightFinalized
				, @strWhereFinalizedMatchGrade = strGradeFinalized
				, @intMatchTicketEntityId = intEntityId
				, @intMatchTicketLocationId = intProcessingLocationId
				, @dtmScaleDate = dtmTicketDateTime 
				, @intMatchContractDetailId = intContractId
				, @dblMatchContractUnits = dblNetUnits
			FROM vyuSCTicketScreenView where intTicketId = @intMatchTicketId 

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
				DECLARE @_strWhereFinalizedWeightIn VARCHAR(MAX)
				DECLARE @_strWhereFinalizedGradeIn VARCHAR(MAX)

				SELECT TOP 1
					 @_strWhereFinalizedWeightIn = strWeightFinalized
					, @_strWhereFinalizedGradeIn = strGradeFinalized
					, @intMatchTicketContractDetailId = intContractId
				FROM vyuSCTicketScreenView WHERE intTicketId = @intMatchTicketId

				IF ISNULL(@_strWhereFinalizedWeightIn, 'Origin') = 'Destination' OR ISNULL(@_strWhereFinalizedGradeIn, 'Origin') = 'Destination'
				BEGIN
					EXEC uspSCDirectCreateVoucher @intMatchTicketId,@intMatchTicketEntityId,@intMatchTicketLocationId,@dtmScaleDate,@intUserId

					IF ISNULL(@intMatchTicketContractDetailId,0) != 0
					BEGIN
						SELECT TOP 1
							@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
						FROM tblCTContractDetail A
						INNER JOIN tblCTContractHeader B
							ON A.intContractHeaderId = B.intContractHeaderId
						WHERE A.intContractDetailId = @intMatchTicketContractDetailId 

						SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblMatchContractUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

						IF(ISNULL(@ysnContractLoadBased,0) = 1)
						BEGIN
							SET @dblContractAvailableQty = 1
						END

						EXEC uspCTUpdateSequenceBalance @intMatchContractDetailId, @dblContractAvailableQty, @intUserId, @intMatchTicketId, 'Scale'
						SET @dblContractAvailableQty = @dblContractAvailableQty * -1
						EXEC uspCTUpdateScheduleQuantity
										@intContractDetailId	=	@intMatchContractDetailId,
										@dblQuantityToUpdate	=	@dblContractAvailableQty,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intMatchTicketId,
										@strScreenName			=   'Scale'	
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
				END
			END
		END
		ELSE
		BEGIN
			EXEC dbo.uspSCInsertDestinationInventoryShipment @intTicketId, @intUserId, 1

			SELECT TOP 1 @InventoryShipmentId = intInventoryShipmentId FROM vyuICGetInventoryShipmentItem where intSourceId = @intTicketId and strSourceType = 'Scale'
			SELECT @intPricingTypeId = intPricingTypeId FROM tblSCTicket SC
			LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = SC.intContractId
			WHERE SC.intTicketId = @intTicketId

			IF ISNULL(@InventoryShipmentId, 0) != 0 AND (ISNULL(@intPricingTypeId,0) <= 1 OR ISNULL(@intPricingTypeId,0) = 6)
			BEGIN
				EXEC dbo.uspARCreateInvoiceFromShipment @InventoryShipmentId, @intUserId, @intInvoiceId OUTPUT, 0, 1;
				SELECT @intTicketItemUOMId = intItemUOMIdTo, @dblNetUnits = dblNetUnits
				FROM vyuSCTicketScreenView WHERE intTicketId = @intTicketId

				IF(@intInvoiceId IS NOT NULL and @dblNetUnits > (SELECT CAST(SUM(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId,@intTicketItemUOMId,ISI.dblQuantity)) AS DECIMAL(18,6))  FROM tblICInventoryShipment ICIS
					INNER JOIN tblICInventoryShipmentItem ISI ON ICIS.intInventoryShipmentId = ISI.intInventoryShipmentId
					WHERE intSourceId = @intTicketId))
				BEGIN
					EXEC dbo.uspARUpdateOverageContracts @intInvoiceId,@intTicketItemUOMId,@intUserId,@dblNetUnits
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
				IF ISNULL(@intContractDetailId,0) != 0
				BEGIN
					SELECT TOP 1
						@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
					FROM tblCTContractDetail A
					INNER JOIN tblCTContractHeader B
						ON A.intContractHeaderId = B.intContractHeaderId
					WHERE A.intContractDetailId = @intContractDetailId 

					SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

					IF(ISNULL(@ysnContractLoadBased,0) = 1)
					BEGIN
						SET @dblContractAvailableQty = 1
					END
					
					-- IF(ISNULL(@intDirectLoadId,0) = 0)
					-- BEGIN
					-- 	EXEC uspCTUpdateScheduleQuantity
					-- 					@intContractDetailId	=	@intContractDetailId,
					-- 					@dblQuantityToUpdate	=	@dblContractAvailableQty,
					-- 					@intUserId				=	@intUserId,
					-- 					@intExternalId			=	@intTicketId,
					-- 					@strScreenName			=	'Scale'	
					-- END

					EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblContractAvailableQty, @intUserId, @intTicketId, 'Scale'
					DECLARE @dblScheduleQty AS DECIMAL(18,6)
					SET @dblScheduleQty = @dblContractAvailableQty * -1 
					EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intContractDetailId,
									@dblQuantityToUpdate	=	@dblScheduleQty,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Scale'	
				END
				EXEC uspSCDirectCreateVoucher @intTicketId,@intEntityId,@intLocationId,@dtmScaleDate,@intUserId, @intBillId OUT
			END
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
				-- IF ISNULL(@intContractDetailId,0) != 0
				-- BEGIN
				-- 	SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

				-- 	DECLARE @dblScheduleQuantityToReduce DECIMAL(18,6);
				-- 	SET @dblScheduleQuantityToReduce = @dblContractAvailableQty *-1
					
				-- 	IF(ISNULL(@intDirectLoadId,0) = 0)
				-- 	BEGIN
				-- 		EXEC uspCTUpdateScheduleQuantity
				-- 						@intContractDetailId	=	@intContractDetailId,
				-- 						@dblQuantityToUpdate	=	@dblContractAvailableQty,
				-- 						@intUserId				=	@intUserId,
				-- 						@intExternalId			=	@intTicketId,
				-- 						@strScreenName			=	'Scale'	
				-- 	END


				-- 	EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblContractAvailableQty, @intUserId, @intTicketId, 'Scale'
				-- 	EXEC uspCTUpdateScheduleQuantity
				-- 					@intContractDetailId	=	@intContractDetailId,
				-- 					@dblQuantityToUpdate	=	@dblScheduleQuantityToReduce,
				-- 					@intUserId				=	@intUserId,
				-- 					@intExternalId			=	@intTicketId,
				-- 					@strScreenName			=	'Scale'	
				-- END
					
				--EXEC uspSCDirectCreateInvoice @intTicketId,@intEntityId,@intLocationId,@intUserId
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
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
				UPDATE	MatchDiscount SET
					MatchDiscount.dblShrinkPercent = QM.dblShrinkPercent
					,MatchDiscount.dblDiscountAmount = QM.dblDiscountAmount
					,MatchDiscount.dblGradeReading = QM.dblGradeReading
					FROM dbo.tblSCTicket SC 
					INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intTicketId AND QM.strSourceType = 'Scale'
					OUTER APPLY(
						SELECT dblShrinkPercent, dblDiscountAmount, dblGradeReading
						FROM tblQMTicketDiscount
						where intTicketId = SC.intMatchTicketId AND intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
						 AND strSourceType = 'Scale'
					) MatchDiscount
				WHERE SC.intTicketId = @intTicketId
				IF EXISTS (SELECT intDiscountScheduleCodeId FROM tblQMTicketDiscount WHERE intTicketId = @intMatchTicketId AND strSourceType = 'Scale'
				AND intDiscountScheduleCodeId NOT IN(SELECT intDiscountScheduleCodeId FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId))
				BEGIN
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
						,intTicketId
						,intTicketFileId
						,strSourceType
						,intSort
						,strDiscountChargeType
					FROM tblQMTicketDiscount WHERE intTicketId = @intMatchTicketId AND strSourceType = 'Scale'
					AND intDiscountScheduleCodeId NOT IN(SELECT intDiscountScheduleCodeId FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId)
				END
			END

			IF ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Destination'
			BEGIN
				DECLARE @_strWhereFinalizedWeightIn VARCHAR(MAX)
				DECLARE @_strWhereFinalizedGradeIn VARCHAR(MAX)

				SELECT @_strWhereFinalizedWeightIn = strWeightFinalized, @_strWhereFinalizedGradeIn = strGradeFinalized
				FROM vyuSCTicketScreenView WHERE intTicketId = @intMatchTicketId

				IF ISNULL(@_strWhereFinalizedWeightIn, 'Origin') = 'Destination' OR ISNULL(@_strWhereFinalizedGradeIn, 'Origin') = 'Destination'
				BEGIN
					EXEC uspSCDirectCreateVoucher @intMatchTicketId,@intMatchTicketEntityId,@intMatchTicketLocationId,@dtmScaleDate,@intUserId

					IF ISNULL(@intContractDetailId,0) != 0
					BEGIN
						SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblMatchContractUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
						EXEC uspCTUpdateSequenceBalance @intMatchContractDetailId, @dblContractAvailableQty, @intUserId, @intMatchTicketId, 'Scale'
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

				IF ISNULL(@intContractDetailId,0) != 0
				BEGIN
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
				ELSE
				BEGIN
					EXEC uspSCDirectCreateInvoice @intTicketId,@intEntityId,@intLocationId,@intUserId
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
			IF ISNULL(@strWhereFinalizedWeight,'Origin') = 'Origin' AND ISNULL(@strWhereFinalizedGrade,'Origin') = 'Origin'
			BEGIN
				IF ISNULL(@intContractDetailId,0) != 0
				BEGIN
					SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
					
					IF(ISNULL(@intDirectLoadId,0) = 0)
					BEGIN
						EXEC uspCTUpdateScheduleQuantity
										@intContractDetailId	=	@intContractDetailId,
										@dblQuantityToUpdate	=	@dblContractAvailableQty,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intTicketId,
										@strScreenName			=	'Scale'	
					END

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
			IF ISNULL(@strWhereFinalizedWeight,'Origin') = 'Origin' AND ISNULL(@strWhereFinalizedGrade,'Origin') = 'Origin'
			BEGIN
				IF ISNULL(@intContractDetailId,0) != 0
				BEGIN
					SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractUnits) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

					DECLARE @dblScheduleQuantityToReduce DECIMAL(18,6);
					SET @dblScheduleQuantityToReduce = @dblContractAvailableQty *-1
					
					IF(ISNULL(@intDirectLoadId,0) = 0)
					BEGIN
						EXEC uspCTUpdateScheduleQuantity
										@intContractDetailId	=	@intContractDetailId,
										@dblQuantityToUpdate	=	@dblContractAvailableQty,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intTicketId,
										@strScreenName			=	'Scale'	
					END


					EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblContractAvailableQty, @intUserId, @intTicketId, 'Scale'
					EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intContractDetailId,
									@dblQuantityToUpdate	=	@dblScheduleQuantityToReduce,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Scale'	
				END
					
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
GO
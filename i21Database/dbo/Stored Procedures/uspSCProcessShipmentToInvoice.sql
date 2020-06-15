CREATE PROCEDURE [dbo].uspSCProcessShipmentToInvoice
    @intTicketId INT
	,@intInventoryShipmentId INT
	,@intUserId INT
	,@intInvoiceId AS INT OUTPUT
	,@dtmClientDate DATETIME = NULL
	,@ysnDWG BIT = 0
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
	
	DECLARE @strWhereFinalizedWeight NVARCHAR(20)
	DECLARE @strWhereFinalizedGrade NVARCHAR(20)
	DECLARE @_intContractDetailId INT 
	DECLARE @ysnTicketDestinationWGPosted BIT
	DECLARE @intTicketContractDetailId INT
	DECLARE @intTicketItemUOMId INT
	DECLARE @dblNetUnits NUMERIC(18,6)


	BEGIN TRY
		BEGIN
			SELECT 
				@ysnTicketDestinationWGPosted = ysnDestinationWeightGradePost
				,@strWhereFinalizedGrade = CTGrade.strWhereFinalized
				,@strWhereFinalizedWeight = CTWeight.strWhereFinalized
				,@intTicketContractDetailId = intContractId
				,@intTicketItemUOMId = A.intItemUOMIdTo
				, @dblNetUnits = A.dblNetUnits
			FROM tblSCTicket A
			LEFT JOIN tblCTContractDetail B
				ON A.intContractId = B.intContractDetailId
			LEFT JOIN tblCTWeightGrade CTGrade 
				ON ISNULL(CTGrade.intWeightGradeId,0) = ISNULL(A.intGradeId,0)
			LEFT JOIN tblCTWeightGrade CTWeight 
				ON ISNULL(CTWeight.intWeightGradeId,0) = ISNULL(A.intWeightId,0)
			WHERE intTicketId = @intTicketId
			
			IF((ISNULL(@strWhereFinalizedWeight, 'Origin') <> 'Destination' AND ISNULL(@strWhereFinalizedGrade, 'Origin') <> 'Destination') 
				OR ((ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Destination') AND @ysnTicketDestinationWGPosted = 1)
			)
			BEGIN
				IF ISNULL(@intInventoryShipmentId, 0) != 0 AND  EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipmentItem WHERE intInventoryShipmentId = @intInventoryShipmentId AND ysnAllowInvoice = 1)
				BEGIN
					EXEC @intInvoiceId = dbo.uspARCreateInvoiceFromShipment @intInventoryShipmentId, @intUserId, @intInvoiceId , 0, 1 ,@dtmShipmentDate = @dtmClientDate;

					IF(ISNULL(@intInvoiceId,0) <> 0 AND @ysnDWG = 1)
					BEGIN
						EXEC dbo.uspARUpdateOverageContracts @intInvoiceId,@intTicketItemUOMId,@intUserId,@dblNetUnits,0,@intTicketId
					END
				END

				SELECT 
					@_intContractDetailId = MIN(si.intLineNo)
				FROM tblICInventoryShipment s 
				JOIN tblICInventoryShipmentItem si 
					ON si.intInventoryShipmentId = s.intInventoryShipmentId
				WHERE si.intInventoryShipmentId = @intInventoryShipmentId 


				WHILE ISNULL(@_intContractDetailId,0) > 0
				BEGIN

					IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @_intContractDetailId)
					BEGIN
						EXEC uspCTCreateVoucherInvoiceForPartialPricing @_intContractDetailId, @intUserId
					END
					---loop iterator
					BEGIN
						SET @_intContractDetailId = ISNULL((
									SELECT 
										MIN(ISNULL(si.intLineNo,0))
									FROM tblICInventoryShipment s 
									JOIN tblICInventoryShipmentItem si 
										ON si.intInventoryShipmentId = s.intInventoryShipmentId
									WHERE si.intInventoryShipmentId = @intInventoryShipmentId 
										AND intLineNo > @_intContractDetailId
								),0)
						
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
END
GO
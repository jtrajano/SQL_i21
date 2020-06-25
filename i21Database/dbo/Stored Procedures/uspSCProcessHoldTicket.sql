CREATE PROCEDURE [dbo].[uspSCProcessHoldTicket]
	@intTicketId AS INT
	,@intEntityId AS INT
	,@dblNetUnits AS NUMERIC (38,20)
	,@intUserId AS INT
	,@strInOutFlag AS NVARCHAR(2)
	,@ysnPost AS BIT
	,@ysnDeliverySheet AS BIT = 0
	,@intDeliverySheetId AS INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @SummaryLogs AS RKSummaryLog

DECLARE @ErrMsg	NVARCHAR(MAX)
	,@InTransitTableType AS InTransitTableType
	,@ItemsForInTransitCosting AS ItemInTransitCostingTableType
	,@ItemReservationTableType AS ItemReservationTableType
	,@intLocationId INT
	,@intTransactionId INT
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(40)
	,@strDistributionOption NVARCHAR(40);

SELECT @strDistributionOption = strDistributionOption FROM tblSCTicket WHERE intTicketId = @intTicketId
BEGIN
	IF @ysnDeliverySheet = 0
	BEGIN
		IF(@strInOutFlag = 'O' AND @strDistributionOption = 'HLD')
			BEGIN
				INSERT INTO @ItemReservationTableType (
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
				)
				SELECT	[intItemId]				= SC.intItemId
						,[intItemLocationId]	= ICIL.intItemLocationId
						,[intItemUOMId]			= SC.intItemUOMIdTo
						,[intLotId]				= NULL
						,[intSubLocationId]		= SC.intSubLocationId
						,[intStorageLocationId]	= SC.intStorageLocationId
						,[dblQty]				= CASE WHEN @ysnPost = 1 THEN SC.dblNetUnits ELSE SC.dblNetUnits*-1  END
						,[intTransactionId]		= @intTicketId
						,[strTransactionId]		= SC.strTicketNumber
						,[intTransactionTypeId] = 52
				FROM	tblSCTicket SC
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
				WHERE SC.intTicketId = @intTicketId
			END
		ELSE
			BEGIN
				INSERT INTO @InTransitTableType (
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
				)
				SELECT	[intItemId]				= SC.intItemId
						,[intItemLocationId]	= ICIL.intItemLocationId
						,[intItemUOMId]			= SC.intItemUOMIdTo
						,[intLotId]				= NULL
						,[intSubLocationId]		= SC.intSubLocationId
						,[intStorageLocationId]	= SC.intStorageLocationId
						,[dblQty]				= CASE WHEN @ysnPost = 1 THEN SC.dblNetUnits ELSE SC.dblNetUnits * -1 END
						,[intTransactionId]		= @intTicketId
						,[strTransactionId]		= SC.strTicketNumber
						,[intTransactionTypeId] = 52
				FROM	tblSCTicket SC
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
				WHERE SC.intTicketId = @intTicketId

				INSERT INTO @ItemsForInTransitCosting (
					[intItemId]
					,[intItemLocationId]
					,[intItemUOMId]
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty]
					,[dblCost]
					,[intCurrencyId]
					,[intTransactionId]
					,[intTransactionDetailId]
					,[strTransactionId]
					,[intSourceTransactionId]
					,[intSourceTransactionDetailId]
					,[strSourceTransactionId]
					,[intInTransitSourceLocationId]
					,[intTransactionTypeId]
				)
				SELECT
					[intItemId]							= SC.intItemId
					,[intItemLocationId]				= ICIL.intItemLocationId
					,[intItemUOMId]						= SC.intItemUOMIdTo
					,[dtmDate]							= SC.dtmTicketDateTime
					,[dblQty]							= SC.dblNetUnits
					,[dblUOMQty]						= SC.dblConvertedUOMQty
					,[dblCost]							= 0
					,[intCurrencyId]					= SC.intCurrencyId
					,[intTransactionId]					= SC.intTicketId
					,[intTransactionDetailId]			= NULL
					,[strTransactionId]					= SC.strTicketNumber
					,[intSourceTransactionId]			= SC.intTicketId
					,[intSourceTransactionDetailId]		= NULL
					,[strSourceTransactionId]			= SC.strTicketNumber
					,[intInTransitSourceLocationId]		= ICIL.intItemLocationId
					,[intTransactionTypeId]				= 52
				FROM vyuSCTicketScreenView SC
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
				WHERE SC.intTicketId = @intTicketId
			END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT intDeliverySheetId FROM tblSCDeliverySheet WHERE intDeliverySheetId = @intDeliverySheetId AND ysnPost = 1)
		BEGIN
			IF ISNULL(@ysnPost , 0) = 1
			BEGIN
				RAISERROR('Unable to distribute, Delivery Sheet already posted.', 11, 1);
				RETURN;
			END
			ELSE
			BEGIN
				RAISERROR('Undistribute the delivery sheet first to undistribute this ticket', 11, 1);
				RETURN;
			END

		END
		IF(@strInOutFlag = 'O' AND @strDistributionOption = 'HLD')
			BEGIN
				INSERT INTO @ItemReservationTableType (
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
				)
				SELECT DISTINCT
					[intItemId]				= SC.intItemId
					,[intItemLocationId]	= ICIL.intItemLocationId
					,[intItemUOMId]			= SC.intItemUOMIdTo
					,[intLotId]				= NULL
					,[intSubLocationId]		= SC.intSubLocationId
					,[intStorageLocationId]	= SC.intStorageLocationId
					,[dblQty]				= CASE WHEN @ysnPost = 1 THEN SC.dblNetUnits ELSE SC.dblNetUnits* -1 END
					,[intTransactionId]		= SCD.intDeliverySheetId
					,[strTransactionId]		= SCD.strDeliverySheetNumber
					,[intTransactionTypeId] = 52
				FROM tblSCDeliverySheet SCD
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SCD.intItemId AND ICIL.intLocationId = SCD.intCompanyLocationId
				INNER JOIN tblSCTicket SC ON SC.intDeliverySheetId = SCD.intDeliverySheetId
				WHERE  SC.intDeliverySheetId = @intDeliverySheetId AND SC.intTicketId = @intTicketId
			END
		ELSE
			BEGIN
				INSERT INTO @InTransitTableType (
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
				)
				SELECT DISTINCT
					[intItemId]				= SC.intItemId
					,[intItemLocationId]	= ICIL.intItemLocationId
					,[intItemUOMId]			= SC.intItemUOMIdTo
					,[intLotId]				= NULL
					,[intSubLocationId]		= SC.intSubLocationId
					,[intStorageLocationId]	= SC.intStorageLocationId
					,[dblQty]				= CASE WHEN @ysnPost = 1 THEN SC.dblNetUnits ELSE SC.dblNetUnits * -1 END
					,[intTransactionId]		= SCD.intDeliverySheetId
					,[strTransactionId]		= SCD.strDeliverySheetNumber
					,[intTransactionTypeId] = 1
				FROM tblSCDeliverySheet SCD
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SCD.intItemId AND ICIL.intLocationId = SCD.intCompanyLocationId
				INNER JOIN tblSCTicket SC ON SC.intDeliverySheetId = SCD.intDeliverySheetId
				WHERE  SC.intDeliverySheetId = @intDeliverySheetId AND SC.intTicketId = @intTicketId


				INSERT INTO @ItemsForInTransitCosting (
					[intItemId]
					,[intItemLocationId]
					,[intItemUOMId]
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty]
					,[dblCost]
					,[intCurrencyId]
					,[intTransactionId]
					,[intTransactionDetailId]
					,[strTransactionId]
					,[intSourceTransactionId]
					,[intSourceTransactionDetailId]
					,[strSourceTransactionId]
					,[intInTransitSourceLocationId]
					,[intTransactionTypeId]
				)
				SELECT
					[intItemId]							= SC.intItemId
					,[intItemLocationId]				= ICIL.intItemLocationId
					,[intItemUOMId]						= SC.intItemUOMIdTo
					,[dtmDate]							= SC.dtmTicketDateTime
					,[dblQty]							= SC.dblNetUnits
					,[dblUOMQty]						= SC.dblConvertedUOMQty
					,[dblCost]							= 0
					,[intCurrencyId]					= SC.intCurrencyId
					,[intTransactionId]					= SC.intDeliverySheetId
					,[intTransactionDetailId]			= NULL
					,[strTransactionId]					= SC.strDeliverySheetNumber
					,[intSourceTransactionId]			= SC.intDeliverySheetId
					,[intSourceTransactionDetailId]		= NULL
					,[strSourceTransactionId]			= SC.strDeliverySheetNumber
					,[intInTransitSourceLocationId]		= ICIL.intItemLocationId
					,[intTransactionTypeId]				= 53
				FROM vyuSCTicketScreenView SC
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
				WHERE SC.intDeliverySheetId = @intDeliverySheetId AND SC.intTicketId = @intTicketId
			END

	END
END

BEGIN TRY
	BEGIN
		DECLARE @intTransctionTypeId AS VARCHAR(MAX)
		SELECT TOP 1 @intTransctionTypeId = intTransactionTypeId,@intTransactionId = intTransactionId FROM @ItemReservationTableType
		IF(@strInOutFlag = 'O' and @strDistributionOption = 'HLD')
			BEGIN
				UPDATE @ItemReservationTableType
				SET dblQty = dblQty * CASE WHEN @ysnPost = 1 THEN 1 ELSE 0 END

				EXEC dbo.uspICCreateStockReservation @ItemReservationTableType,@intTransactionId,@intTransctionTypeId
			END
		ELSE
			BEGIN
				EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransitTableType;
			END


		EXEC dbo.uspSMGetStartingNumber 3, @strBatchId OUTPUT, @intLocationId

		IF(@strInOutFlag = 'O' and @strDistributionOption = 'HLD' and @ysnPost = 0)
			BEGIN
				SELECT TOP 1 @intTransctionTypeId = intTransactionTypeId, @intTransactionId = intTransactionId  FROM @ItemReservationTableType
				EXEC dbo.uspICPostStockReservation @intTransactionId,@intTransctionTypeId, 1
			END
		ELSE
			BEGIN
				IF ISNULL(@ysnPost , 0) = 1
				BEGIN
					EXEC dbo.uspICPostInTransitCosting @ItemsForInTransitCosting, @strBatchId, NULL, @intUserId
				END

				IF @ysnPost = 0
				BEGIN
					SELECT @strTransactionId = strTransactionId, @intTransactionId = intTransactionId FROM @ItemsForInTransitCosting
					EXEC dbo.uspICUnpostCosting @intTransactionId, @strTransactionId , @strBatchId, NULL, @intUserId
					UPDATE tblSCTicket SET strTicketStatus = 'R' WHERE intTicketId = @intTicketId
				END
			END

		INSERT INTO @SummaryLogs (    
            strBatchId
            ,strBucketType
            ,strTransactionType
            ,intTransactionRecordId 
            ,intTransactionRecordHeaderId
            ,strDistributionType
            ,strTransactionNumber 
            ,dtmTransactionDate 
            ,intContractDetailId 
            ,intContractHeaderId 
            ,intTicketId 
            ,intCommodityId 
            ,intCommodityUOMId 
            ,intItemId 
            ,intBookId 
            ,intSubBookId 
            ,intLocationId 
            ,intFutureMarketId 
            ,intFutureMonthId 
            ,dblNoOfLots 
            ,dblQty 
            ,dblPrice 
            ,intEntityId 
            ,ysnDelete 
            ,intUserId 
            ,strNotes     
        )
         SELECT
            strBatchId = NULL
            ,strBucketType = 'On Hold'
            ,strTransactionType = 'Scale Ticket'
            ,intTransactionRecordId = intTicketId
            ,intTransactionRecordHeaderId = intTicketId
            ,strDistributionType = strStorageTypeDescription
            ,strTransactionNumber = strTicketNumber
            ,dtmTransactionDate  = dtmTicketDateTime
            ,intContractDetailId = intContractId
            ,intContractHeaderId = intContractSequence
            ,intTicketId  = intTicketId
            ,intCommodityId  = TV.intCommodityId
            ,intCommodityUOMId  = CUM.intCommodityUnitMeasureId
            ,intItemId = TV.intItemId
            ,intBookId = NULL
            ,intSubBookId = NULL
            ,intLocationId = intProcessingLocationId
            ,intFutureMarketId = NULL
            ,intFutureMonthId = NULL
            ,dblNoOfLots = 0
            ,dblQty = CASE WHEN @ysnPost = 1
						THEN 
							(CASE WHEN strInOutFlag = 'I' THEN dblNetUnits ELSE dblNetUnits * -1 END )
						ELSE
							(CASE WHEN strInOutFlag = 'I' THEN dblNetUnits * -1 ELSE dblNetUnits END )
						END

            ,dblPrice = dblUnitPrice
            ,intEntityId 
            ,ysnDelete = 0
            ,intUserId = @intUserId
            ,strNotes = strTicketComment
        FROM tblSCTicket TV
        LEFT JOIN tblGRStorageType ST on ST.intStorageScheduleTypeId = TV.intStorageScheduleTypeId 
        LEFT JOIN tblICItemUOM IUM ON IUM.intItemUOMId = TV.intItemUOMIdTo
        LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = IUM.intUnitMeasureId AND CUM.intCommodityId = TV.intCommodityId
        WHERE TV.intTicketId = @intTicketId

		EXEC uspRKLogRiskPosition @SummaryLogs
	END
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

CREATE PROCEDURE [dbo].[uspSCProcessDeliverySheetSummaryToTicket]
	@intDeliverySheetId INT
	,@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX)


DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
		,@currencyDecimal			INT
		,@intTicketId				INT
		,@intEntityId				INT
		,@intCustomerStorageId		INT
		,@dblNetUnits				NUMERIC (38,20)
		,@dblCost					NUMERIC (38,20)
		,@strDistributionOption		NVARCHAR(3)
		,@intStorageScheduleId		INT
		,@intSplitEntityId			INT
		,@dblSplitPercent			NUMERIC (38,20)
		,@dblTempSplitQty			NUMERIC (38,20)
		,@dblFinalSplitQty			NUMERIC (38,20)
		,@intInventoryReceiptId		INT
		,@strFreightCostMethod		NVARCHAR(40)
		,@strFeesCostMethod			NVARCHAR(40)
		,@intBillId					INT
DECLARE @dblInitialSplitQty			NUMERIC (38,20)
DECLARE @_intInventoryReceiptId  	INT
DECLARE @_intStorageHistoryId  		INT

BEGIN TRY
	-- SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference
	SET @currencyDecimal = 20
	DECLARE @splitTable TABLE(
		[intTicketId] INT NOT NULL, 
		[intEntityId] INT NOT NULL, 
		[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
		[intStorageScheduleTypeId] INT NULL,
		[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
		[intStorageScheduleId] INT NULL,
		[intConcurrencyId] INT NULL
	);
	DECLARE @processTicket TABLE(
		cntId INT IDENTITY(1,1)
		,[intTicketId] INT
		,[intDeliverySheetId] INT
		,[intEntityId] INT
		,[dblNetUnits] NUMERIC(38,20)
		,[dblFreight] NUMERIC(38,20) NULL
		,[dblFees] NUMERIC(38,20) NULL
	)
	declare @skipValidation bit
	declare @processedTicket Table(
		[intTicketId] INT
	)

	DECLARE @dsSplitTable TABLE(
		[intEntityId] INT NOT NULL, 
		[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
		[intStorageScheduleTypeId] INT NULL,
		[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
		[intStorageScheduleId] INT NULL,
		[intConcurrencyId] INT NULL
	);

	DECLARE @TicketCurrentRowCount INT
	DECLARE @TicketRowMaxCount INT

	INSERT INTO @processTicket(
		[intTicketId]
		,[intDeliverySheetId]
		,[intEntityId]
		,[dblNetUnits]
		,[dblFreight] 
		,[dblFees] 
	)
	SELECT 
		[intTicketId]			= intTicketId
		,[intDeliverySheetId]	= intDeliverySheetId
		,[intEntityId]			= intEntityId
		,[dblNetUnits]			= dblNetUnits
		,[dblFreight]			= dblFreightRate
		,[dblFees]				= dblTicketFees
	FROM tblSCTicket 
	WHERE intDeliverySheetId = @intDeliverySheetId AND strTicketStatus = 'C'


	SET @TicketCurrentRowCount = 1
	SELECT @TicketRowMaxCount = COUNT(1) FROM @processTicket

	WHILE (@TicketCurrentRowCount <= @TicketRowMaxCount)
	BEGIN
		SELECT TOP 1 @intTicketId = intTicketId 
		FROM @processTicket
		WHERE cntId = @TicketCurrentRowCount

		EXEC [dbo].[uspSCUndistributeTicket] @intTicketId, @intUserId, @intEntityId, 'I', 0, 0, 1	
		UPDATE tblSCTicket SET strTicketStatus = 'R' WHERE intTicketId = @intTicketId
	
		SET @TicketCurrentRowCount = @TicketCurrentRowCount + 1
	END

	-- UPDATE tblGRCustomerStorage
	-- SET dblOriginalBalance = 0 
	-- 	,dblOpenBalance = 0
	-- WHERE intDeliverySheetId = @intDeliverySheetId


	---SUMMARY LOG 
	BEGIN
		IF OBJECT_ID (N'tempdb.dbo.#SCReceiptIds') IS NOT NULL
			DROP TABLE #SCReceiptIds

		SELECT DISTINCT
			B.intInventoryReceiptId
		INTO #SCReceiptIds
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN tblSCTicket C
			ON A.intSourceId = C.intTicketId
		INNER JOIN tblSCDeliverySheet D
			ON C.intDeliverySheetId = C.intDeliverySheetId
		WHERE B.intSourceType = 1

		SET @_intInventoryReceiptId = ISNULL((SELECT MIN(intInventoryReceiptId) FROM #SCReceiptIds),0)

		WHILE (ISNULL(@_intInventoryReceiptId,0) > 0)
		BEGIN

			IF OBJECT_ID (N'tempdb.dbo.#tmpSCStorageHistory') IS NOT NULL
				DROP TABLE #tmpSCStorageHistory

			SELECT 
				*
			INTO #tmpSCStorageHistory
			FROM tblGRStorageHistory 
			WHERE intInventoryReceiptId = @_intInventoryReceiptId 
			ORDER BY intStorageHistoryId

			SET @_intStorageHistoryId = ISNULL((SELECT TOP 1 MIN(intStorageHistoryId) 
												FROM #tmpSCStorageHistory 
												WHERE intInventoryReceiptId = @_intInventoryReceiptId 
												ORDER BY intInventoryReceiptId),0)
		
			WHILE ISNULL(@_intStorageHistoryId,0) > 0
			BEGIN
				IF(@_intStorageHistoryId > 0)
				BEGIN
					EXEC [dbo].[uspGRRiskSummaryLog]
						@intStorageHistoryId = @_intStorageHistoryId
						,@strAction = 'UNPOST'
				END

				--LOOP Iterator
				BEGIN
					SET @_intStorageHistoryId = ISNULL((SELECT TOP 1 ISNULL(intStorageHistoryId,0) 
														FROM #tmpSCStorageHistory 
														WHERE intInventoryReceiptId = @_intInventoryReceiptId 
															AND intStorageHistoryId > @_intStorageHistoryId
														ORDER BY intStorageHistoryId),0)
				END
			END
			--loop iterator
			BEGIN
				SET @_intInventoryReceiptId = ISNULL((SELECT TOP 1 intInventoryReceiptId 
													FROM #SCReceiptIds 
													WHERE intInventoryReceiptId > @_intInventoryReceiptId
													ORDER BY intInventoryReceiptId),0)
			END
		END

	END

	DELETE FROM tblGRCustomerStorage
	WHERE intDeliverySheetId = @intDeliverySheetId

	DELETE FROM @splitTable
		
	INSERT INTO @splitTable(
		[intTicketId]
		,[intEntityId]
		,[dblSplitPercent]
		,[intStorageScheduleTypeId]
		,[strDistributionOption]
		,[intStorageScheduleId]
		,[intConcurrencyId]
	)
	SELECT  
		[intTicketId]					= SC.intTicketId
		,[intEntityId]					= SDS.intEntityId
		,[dblSplitPercent]				= SDS.dblSplitPercent
		,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
		,[strDistributionOption]		= SDS.strDistributionOption
		,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
		,[intConcurrencyId]				= 1
	FROM tblSCDeliverySheetSplit SDS
	INNER JOIN tblSCTicket SC
		ON SDS.intDeliverySheetId = SC.intDeliverySheetId
	WHERE SDS.intDeliverySheetId = @intDeliverySheetId 

	--REset All Ticket Splits
	DELETE FROM tblSCTicketSplit 
	WHERE intTicketId IN (SELECT intTicketId FROM tblSCTicket WHERE intDeliverySheetId = @intDeliverySheetId)

	IF EXISTS(SELECT NULL FROM @splitTable)
	BEGIN
		INSERT INTO tblSCTicketSplit
		SELECT * FROM @splitTable
	END


	DELETE FROM @dsSplitTable

	INSERT INTO @dsSplitTable(
		[intEntityId]
		,[dblSplitPercent]
		,[intStorageScheduleTypeId]
		,[strDistributionOption]
		,[intStorageScheduleId]
		,[intConcurrencyId]
	)
	SELECT 
		intEntityId
		, dblSplitPercent
		, [intStorageScheduleTypeId]
		,[strDistributionOption]
		, intStorageScheduleId = intStorageScheduleRuleId 
		, 1
	FROM tblSCDeliverySheetSplit 
	WHERE intDeliverySheetId = @intDeliverySheetId


	DECLARE ticketCursor CURSOR FOR SELECT intTicketId,intEntityId,dblNetUnits FROM @processTicket  
	OPEN ticketCursor;  
	FETCH NEXT FROM ticketCursor INTO @intTicketId, @intEntityId, @dblNetUnits;  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @dblTempSplitQty = @dblNetUnits;
		
	

		DECLARE splitCursor CURSOR FOR SELECT intEntityId, dblSplitPercent, strDistributionOption, intStorageScheduleId FROM @dsSplitTable
		OPEN splitCursor;  
		FETCH NEXT FROM splitCursor INTO @intSplitEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId;  
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @dblInitialSplitQty	= @dblNetUnits * @dblSplitPercent
			SET @dblFinalSplitQty =  ROUND(@dblInitialSplitQty / 100, @currencyDecimal);
			IF @dblTempSplitQty > @dblFinalSplitQty
				SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
			ELSE
				SET @dblFinalSplitQty = @dblTempSplitQty
			
			set @skipValidation = 0
			if exists(select top 1 1 from @processedTicket where intTicketId = @intTicketId)
			begin
				set @skipValidation = 1
			end

			EXEC [dbo].[uspSCProcessToItemReceipt] @intTicketId, @intUserId, @dblFinalSplitQty, 0, @intSplitEntityId, 0 , @strDistributionOption, @intStorageScheduleId, @intInventoryReceiptId OUTPUT, @intBillId OUTPUT, @skipValidation			

			
			if not exists(select top 1 1 from @processedTicket where intTicketId = @intTicketId)
			begin
				insert into @processedTicket values (@intTicketId)
			end



			FETCH NEXT FROM splitCursor INTO @intSplitEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId;
		END
		CLOSE splitCursor;  
		DEALLOCATE splitCursor;

		UPDATE SC  
		SET SC.strTicketStatus = 'C' 
		,SC.intStorageScheduleTypeId = CASE WHEN StagingTable.splitCount > 1 THEN -4 ELSE StagingTable.intStorageScheduleTypeId END
		,SC.strDistributionOption = CASE WHEN StagingTable.splitCount > 1 THEN 'SPL' ELSE StagingTable.strDistributionOption END
		,SC.intStorageScheduleId = CASE WHEN StagingTable.splitCount > 1 THEN NULL ELSE StagingTable.intStorageScheduleId END
		FROM tblSCTicket SC
		OUTER APPLY(
			SELECT (SELECT COUNT(intTicketId) FROM @splitTable) AS splitCount,intStorageScheduleTypeId,intStorageScheduleId,strDistributionOption
			FROM @splitTable WHERE intTicketId = @intTicketId
		) StagingTable
		WHERE SC.intTicketId = @intTicketId

		FETCH NEXT FROM ticketCursor INTO @intTicketId, @intEntityId, @dblNetUnits;
	END
	CLOSE ticketCursor;  
	DEALLOCATE ticketCursor;

	SELECT TOP 1 @strFeesCostMethod = ICFee.strCostMethod, @strFreightCostMethod = SC.strCostMethod 
	FROM tblSCTicket SC
	INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
	LEFT JOIN tblICItem ICFee ON ICFee.intItemId = SCS.intDefaultFeeItemId
	WHERE intDeliverySheetId = @intDeliverySheetId

	UPDATE CS
	SET  CS.dblFeesDue=SC.dblFeesPerUnit,CS.dblFreightDueRate=SC.dblFreightPerUnit
	FROM tblGRCustomerStorage CS
	OUTER APPLY (
		SELECT 
		CASE WHEN @strFeesCostMethod = 'Amount' THEN (SUM(dblFees)/SUM(dblNetUnits)) ELSE SUM(dblFees) END AS dblFeesPerUnit 
		,CASE WHEN @strFreightCostMethod = 'Amount' THEN (SUM(dblFreight)/SUM(dblNetUnits)) ELSE SUM(dblFreight) END AS dblFreightPerUnit 
		FROM @processTicket WHERE intDeliverySheetId = @intDeliverySheetId
	) SC

END TRY

BEGIN CATCH
BEGIN
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
	END
END CATCH
GO

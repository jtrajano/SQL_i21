﻿CREATE PROCEDURE [dbo].[uspSCPostDeliverySheet]
	@intDeliverySheetId INT
	,@intUserId INT
	,@dblNetUnits NUMERIC(38,20)
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
		,@currencyDecimal				INT
		,@intEntityId					INT
		,@intCustomerStorageId			INT
		,@strDistributionOption			NVARCHAR(3)
		,@intStorageScheduleId			INT
		,@dblSplitPercent				NUMERIC (38,20)
		,@dblTempSplitQty				NUMERIC (38,20)
		,@dblFinalSplitQty				NUMERIC (38,20)
		,@intInventoryReceiptId			INT
		,@intItemId						INT
		,@dtmDate						DATETIME 
		,@intLocationId					INT	
		,@intSubLocationId				INT	
		,@intStorageLocationId			INT	
		,@strLotNumber					NVARCHAR(50)		
		,@intItemUOMId					INT 
		,@newBalance					NUMERIC (38,20)
		,@intInventoryAdjustmentId		INT
		,@dblAdjustByQuantity			NUMERIC (38,20)
		,@intOwnershipType				INT;
		
DECLARE @splitTable TABLE(
	[intEntityId] INT NOT NULL, 
	[intItemId] INT NULL,
	[intCompanyLocationId] INT NULL,
	[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
	[intStorageScheduleTypeId] INT NULL,
	[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[intStorageScheduleId] INT NULL
);

DECLARE @processTicket TABLE(
	[intItemId]					INT
	,[dtmDate]						DATETIME 
	,[intLocationId]				INT	
	,[intSubLocationId]				INT	
	,[intStorageLocationId]			INT	
	,[strLotNumber]					NVARCHAR(50)		
	-- Parameters for the new values: 
	,[dblAdjustByQuantity]			NUMERIC(38,20)
	,[dblNewUnitCost]				NUMERIC(38,20)
	,[intItemUOMId]					INT 
	-- Parameters used for linking or FK (foreign key) relationships
	,[intOwnershipType]				INT
);

BEGIN TRY
	SET @dblTempSplitQty = @dblNetUnits;

	SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	INSERT INTO @splitTable(
		[intEntityId]
		,[intItemId]
		,[intCompanyLocationId]
		,[dblSplitPercent]
		,[intStorageScheduleTypeId]
		,[strDistributionOption]
		,[intStorageScheduleId]
	)
	SELECT  
		[intEntityId]					= SDS.intEntityId
		,[intItemId]					= SCD.intItemId
		,[intCompanyLocationId]			= SCD.intCompanyLocationId
		,[dblSplitPercent]				= SDS.dblSplitPercent
		,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
		,[strDistributionOption]		= SDS.strDistributionOption
		,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
	FROM tblSCDeliverySheetSplit SDS
	INNER JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = SDS.intDeliverySheetId
	WHERE SDS.intDeliverySheetId = @intDeliverySheetId
	
	DECLARE splitCursor CURSOR FOR SELECT intEntityId, dblSplitPercent, strDistributionOption, intStorageScheduleId FROM @splitTable
	OPEN splitCursor;  
	FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId;  
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		SET @dblFinalSplitQty =  ROUND((@dblNetUnits * @dblSplitPercent) / 100, @currencyDecimal);
		IF @dblTempSplitQty > @dblFinalSplitQty
			SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
		ELSE
			SET @dblFinalSplitQty = @dblTempSplitQty

		SELECT @intCustomerStorageId = intCustomerStorageId FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId

		UPDATE tblGRCustomerStorage SET dblOpenBalance = 0 , dblOriginalBalance = 0 WHERE intCustomerStorageId = @intCustomerStorageId

		EXEC uspGRCustomerStorageBalance
				@intEntityId = NULL
				,@intItemId = NULL
				,@intLocationId = NULL
				,@intDeliverySheetId = NULL
				,@intCustomerStorageId = @intCustomerStorageId
				,@dblBalance = @dblFinalSplitQty
				,@ysnDistribute = 1
				,@newBalance = @newBalance OUT

		FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId;
	END
	CLOSE splitCursor;  
	DEALLOCATE splitCursor;

	INSERT INTO @processTicket(
		[intItemId]
		,[dtmDate]
		,[intLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[strLotNumber]
		,[dblAdjustByQuantity]
		,[dblNewUnitCost]
		,[intItemUOMId]
		,[intOwnershipType]
	)
	SELECT 
		[intItemId]							= SCD.intItemId
		,[dtmDate]							= dbo.fnRemoveTimeOnDate(GETDATE())
		,[intLocationId]					= SCD.intCompanyLocationId
		,[intSubLocationId]					= SC.intSubLocationId
		,[intStorageLocationId]				= SC.intStorageLocationId
		,[strLotNumber]						= ''
		,[dblAdjustByQuantity]				= CASE WHEN @dblNetUnits > SC.dblNetUnits THEN SC.dblNetUnits - ((SC.dblNetUnits / SCD.dblGross) * @dblNetUnits) ELSE ((SC.dblNetUnits / SCD.dblGross) * @dblNetUnits) - SC.dblNetUnits END
		,[dblNewUnitCost]					= 0
		,[intItemUOMId]						= SC.intItemUOMIdTo
		,[intOwnershipType]					= 2
	FROM 
	tblSCDeliverySheet SCD
	CROSS APPLY(
		SELECT intSubLocationId
		,intStorageLocationId
		,intItemUOMIdTo
		,SUM(dblGrossUnits) AS dblGrossUnits
		,SUM(dblNetUnits) AS dblNetUnits
		FROM tblSCTicket WHERE intDeliverySheetId = SCD.intDeliverySheetId AND strTicketStatus = 'C'
		GROUP BY intSubLocationId, intStorageLocationId, intItemUOMIdTo
	) SC
	WHERE SCD.intDeliverySheetId = @intDeliverySheetId

	DECLARE ticketCursor CURSOR FOR SELECT intItemId,dtmDate,intLocationId,intSubLocationId,intStorageLocationId,strLotNumber,dblAdjustByQuantity,intItemUOMId,intOwnershipType
	FROM @processTicket
	OPEN ticketCursor;  
	FETCH NEXT FROM ticketCursor INTO  @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dblAdjustByQuantity 
			,@intItemUOMId
			,@intOwnershipType
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		EXEC [dbo].[uspICInventoryAdjustment_CreatePostQtyChange]
			@intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@intOwnershipType
			,@dblAdjustByQuantity 
			,0
			,@intItemUOMId
			,@intDeliverySheetId --delivery sheet id
			,53 --Delivery Sheet inventory transaction id
			,@intUserId
			,@intInventoryAdjustmentId OUTPUT
			,'Delivery Sheet Posting'

		FETCH NEXT FROM ticketCursor INTO @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dblAdjustByQuantity 
			,@intItemUOMId
			,@intOwnershipType;
	END
	CLOSE ticketCursor;  
	DEALLOCATE ticketCursor;

	INSERT INTO [dbo].[tblQMTicketDiscount]
        ([intConcurrencyId]         
        ,[dblGradeReading]
        ,[strCalcMethod]
        ,[strShrinkWhat]
        ,[dblShrinkPercent]
        ,[dblDiscountAmount]
        ,[dblDiscountDue]
        ,[dblDiscountPaid]
        ,[ysnGraderAutoEntry]
        ,[intDiscountScheduleCodeId]
        ,[dtmDiscountPaidDate]
        ,[intTicketId]
        ,[intTicketFileId]
        ,[strSourceType]
		,[intSort]
		,[strDiscountChargeType])
	SELECT
		[intConcurrencyId]= 1       
        ,[dblGradeReading]= SD.[dblGradeReading]
        ,[strCalcMethod]= SD.[strCalcMethod]
        ,[strShrinkWhat]= SD.[strShrinkWhat]			
        ,[dblShrinkPercent]= SD.[dblShrinkPercent]
        ,[dblDiscountAmount]= SD.[dblDiscountAmount]
        ,[dblDiscountDue]= SD.[dblDiscountAmount]
        ,[dblDiscountPaid]= ISNULL(SD.[dblDiscountPaid],0)
        ,[ysnGraderAutoEntry]= SD.[ysnGraderAutoEntry]
        ,[intDiscountScheduleCodeId]= SD.[intDiscountScheduleCodeId]
        ,[dtmDiscountPaidDate]= SD.[dtmDiscountPaidDate]
        ,[intTicketId]= NULL
        ,[intTicketFileId]= GR.intCustomerStorageId
        ,[strSourceType]= 'Storage'
		,[intSort]=SD.[intSort]
		,[strDiscountChargeType]=SD.[strDiscountChargeType]
	FROM dbo.[tblQMTicketDiscount] SD
	INNER JOIN tblGRCustomerStorage GR ON GR.intDeliverySheetId = SD.intTicketFileId
	WHERE SD.intTicketFileId = @intDeliverySheetId 
	AND SD.strSourceType = 'Delivery Sheet'
		
	UPDATE CS
	SET  CS.dblDiscountsDue=QM.dblDiscountsDue
		,CS.dblDiscountsPaid=QM.dblDiscountsPaid
	FROM tblGRCustomerStorage CS
	OUTER APPLY (
		SELECT SUM(dblDiscountDue) dblDiscountsDue ,SUM(dblDiscountPaid)dblDiscountsPaid FROM dbo.[tblQMTicketDiscount] WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage' AND strDiscountChargeType = 'Dollar'
	) QM
	WHERE CS.intCustomerStorageId = @intCustomerStorageId

	EXEC [dbo].[uspSCUpdateDeliverySheetStatus] @intDeliverySheetId, 0;

	EXEC dbo.uspSMAuditLog 
		@keyValue			= @intDeliverySheetId				-- Primary Key Value of the Ticket. 
		,@screenName		= 'Grain.view.DeliverySheet'		-- Screen Namespace
		,@entityId			= @intUserId						-- Entity Id.
		,@actionType		= 'Post'							-- Action Type
		,@changeDescription	= 'Delivery Sheet Status'			-- Description
		,@fromValue			= 'Unpost'							-- Old Value
		,@toValue			= 'Posted'							-- New Value
		,@details			= '';

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
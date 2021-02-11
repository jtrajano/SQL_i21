CREATE PROCEDURE [dbo].[uspSCPostDeliverySheet]
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


DECLARE @CustomerStorageStagingTable	AS CustomerStorageStagingTable
		,@storageHistoryData			AS StorageHistoryStagingTable
		,@currencyDecimal				INT
		,@intEntityId					INT
		,@intCustomerStorageId			INT
		,@strDistributionOption			NVARCHAR(3)
		,@intStorageScheduleTypeId		INT
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
		,@dblOrigQuantity				NUMERIC (38,20)
		,@dblAdjustByQuantity			NUMERIC (38,20)
		,@dblFinalQuantity				NUMERIC (38,20)
		,@strTransactionId				NVARCHAR(40)
		,@strDescription				NVARCHAR(100)
		,@intOwnershipType				INT
		,@strFreightCostMethod			NVARCHAR(40)
		,@strFeesCostMethod				NVARCHAR(40)
		,@dblTempAdjustByQuantity		NUMERIC (38,20)
		,@shipFromEntityId				INT
		,@shipFrom						INT;
DECLARE @ysnLoopIsDP					BIT;
DECLARE @intLoopDPContractDetailId		INT
DECLARE @dblLoopPDContractAdjustment	NUMERIC (38,20)
DECLARE @intDSLocationId				INT
DECLARE @intDSItemId					INT
DECLARE @dblDSShrink					NUMERIC (18,6)


DECLARE @_intLoopEntityId				INT
DECLARE @_dblLoopSplitPercentage		NUMERIC(18,6)
DECLARE @_intLoopCurrentEntityId		INT
DECLARE	@dtmDeliverySheetDate			DATETIME
DECLARE @_dblCompanyOwnedPercentage		NUMERIC(18,6)
DECLARE @intTicketScaleSetupId			INT
		
DECLARE @splitTable TABLE(
	[intEntityId] INT NOT NULL, 
	[intItemId] INT NULL,
	[intCompanyLocationId] INT NULL,
	[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
	[intStorageScheduleTypeId] INT NULL,
	[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[intStorageScheduleId] INT NULL,
	[intShipFromEntityId] INT NULL,
	[intShipFrom] INT NULL
);

DECLARE @processTicket TABLE(
	[intItemId]					INT
	,[dtmDate]						DATETIME 
	,[intLocationId]				INT	
	,[intSubLocationId]				INT	
	,[intStorageLocationId]			INT	
	,[strLotNumber]					NVARCHAR(50)		
	-- Parameters for the new values: 
	,[dblOrigQuantity]				NUMERIC(38,20)
	,[dblAdjustByQuantity]			NUMERIC(38,20)
	,[dblNewUnitCost]				NUMERIC(38,20)
	,[intItemUOMId]					INT 
	-- Parameters used for linking or FK (foreign key) relationships
	,[intOwnershipType]				INT
);

BEGIN TRY
	SET @dblTempSplitQty = @dblNetUnits;


	SELECT TOP 1 
		@intDSLocationId = intCompanyLocationId
		,@intDSItemId	= intItemId
		,@dblDSShrink	= dblShrink
		,@dtmDeliverySheetDate = dtmDeliverySheetDate
	FROM tblSCDeliverySheet
	WHERE intDeliverySheetId = @intDeliverySheetId

	-- SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference
	SET @currencyDecimal = 20

	INSERT INTO @splitTable(
		[intEntityId]
		,[intItemId]
		,[intCompanyLocationId]
		,[dblSplitPercent]
		,[intStorageScheduleTypeId]
		,[strDistributionOption]
		,[intStorageScheduleId]
		,[intShipFromEntityId]
		,[intShipFrom]
	)
	SELECT  
		[intEntityId]					= SDS.intEntityId
		,[intItemId]					= SCD.intItemId
		,[intCompanyLocationId]			= SCD.intCompanyLocationId
		,[dblSplitPercent]				= SDS.dblSplitPercent
		,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
		,[strDistributionOption]		= SDS.strDistributionOption
		,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
		,[intShipFromEntityId]			= SCD.intEntityId
		,[intShipFrom]					= COALESCE(SCD.intFarmFieldId, VND.intShipFromId, VNDL.intEntityLocationId)
	FROM tblSCDeliverySheetSplit SDS
	INNER JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = SDS.intDeliverySheetId
	LEFT JOIN tblEMEntityLocation FRM
		ON SCD.intFarmFieldId = FRM.intEntityLocationId
	LEFT JOIN tblAPVendor VND
		ON SCD.intEntityId = VND.intEntityId
	LEFT JOIN tblEMEntityLocation VNDL
		ON VND.intEntityId = VNDL.intEntityId
			AND VNDL.ysnDefaultLocation = 1
	WHERE SDS.intDeliverySheetId = @intDeliverySheetId
	

	-----------------------------------------------------------------------------------------------
	------------------------------ Customer Storage Update
	-----------------------------------------------------------------------------------------------
	/*BEGIN
		DECLARE splitCursor CURSOR FOR SELECT intEntityId, dblSplitPercent, strDistributionOption, intStorageScheduleId, intItemId, intCompanyLocationId, intStorageScheduleTypeId, intShipFromEntityId, intShipFrom FROM @splitTable
		OPEN splitCursor;  
		FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId, @intItemId, @intLocationId, @intStorageScheduleTypeId, @shipFromEntityId, @shipFrom;  
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @dblFinalSplitQty =  ROUND((@dblNetUnits * @dblSplitPercent) / 100, @currencyDecimal);
			IF @dblTempSplitQty > @dblFinalSplitQty
				SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
			ELSE
				SET @dblFinalSplitQty = @dblTempSplitQty

			SELECT TOP 1
				@intCustomerStorageId = intCustomerStorageId  
			FROM tblGRCustomerStorage 
			WHERE intEntityId = @intEntityId 
				AND intItemId = @intItemId 
				AND intCompanyLocationId = @intLocationId 
				AND intDeliverySheetId = @intDeliverySheetId
				AND intStorageTypeId = @intStorageScheduleTypeId
				AND ISNULL(ysnTransferStorage,0) = 0

			SET @dblFinalSplitQty =  ROUND((@dblNetUnits * @dblSplitPercent) / 100, @currencyDecimal);
			SET @dblFinalSplitQty = (SELECT dbo.fnGRCalculateStorageUnits(@intCustomerStorageId))
			IF @dblTempSplitQty > @dblFinalSplitQty
				SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
			ELSE
				SET @dblFinalSplitQty = @dblTempSplitQty

			UPDATE tblGRCustomerStorage SET dblOpenBalance = 0 , dblOriginalBalance = 0 WHERE intCustomerStorageId = @intCustomerStorageId

			EXEC uspGRCustomerStorageBalance NULL,NULL,NULL,NULL,@intCustomerStorageId,@dblFinalSplitQty,@intStorageScheduleTypeId,@intStorageScheduleId,1,@shipFrom,@shipFromEntityId,@newBalance OUT

			FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId, @intItemId, @intLocationId, @intStorageScheduleTypeId, @shipFromEntityId, @shipFrom;
		END
		CLOSE splitCursor;  
		DEALLOCATE splitCursor;
	END
*/
	----------------------------------------------------------------------------------------------------------



	DECLARE @ysnDPOwned as BIT = 0;
	SELECT @ysnDPOwned = CASE WHEN CD.intPricingTypeId = 5 AND ISNULL(GR.strOwnedPhysicalStock, 'Company') = 'Company' THEN 1 ELSE 0 END 
	FROM tblSCTicket SC
	INNER JOIN tblSCDeliverySheet SDS
		ON SDS.intDeliverySheetId = SC.intDeliverySheetId
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractId
	OUTER APPLY(
					SELECT strOwnedPhysicalStock FROM tblGRStorageType WHERE strStorageTypeCode = @strDistributionOption
				) GR
	WHERE SDS.intDeliverySheetId = @intDeliverySheetId

	DECLARE @splitCustomerCompany TABLE(
		cntId INT IDENTITY(1,1)
		,intDeliverySheetId INT
		,ysnCompanyOwned BIT
		,dblPercent NUMERIC(18,6)
	)

	DECLARE @splitPerEntityBasedOnCustomerCompany TABLE(
		cntId INT IDENTITY(1,1)
		,intEntityId INT
		,ysnCompanyOwned BIT
		,dblPercent NUMERIC(36,20)
	)


	--- get the company and customer owned split percentage
	BEGIN
		INSERT INTO @splitCustomerCompany
		SELECT
			intDeliverySheetId
			,ysnCompanyOwned = CASE WHEN ISNULL(GR.strOwnedPhysicalStock, 'Company') = 'Company' THEN 1 ELSE 0 END 
			,dblPercent = SUM(DSS.dblSplitPercent)
		FROM tblSCDeliverySheetSplit DSS
		INNER JOIN tblGRStorageType GR
			ON DSS.intStorageScheduleTypeId = GR.intStorageScheduleTypeId
		WHERE intDeliverySheetId = @intDeliverySheetId
		GROUP BY intDeliverySheetId,ISNULL(GR.strOwnedPhysicalStock, 'Company')
	END

	----GET per Entity split % based on company or Customer owned
	BEGIN
		INSERT INTO @splitPerEntityBasedOnCustomerCompany
		SELECT 
			intEntityId = DSS.intEntityId
			,ysnCompanyOwned = A.ysnCompanyOwned
			,dblPercent = DSS.dblSplitPercent/A.dblPercent * 100
		FROM tblSCDeliverySheetSplit DSS
		INNER JOIN tblGRStorageType ST
			ON DSS.intStorageScheduleTypeId = ST.intStorageScheduleTypeId
		INNER JOIN @splitCustomerCompany A
			ON A.ysnCompanyOwned = CASE WHEN ISNULL(ST.strOwnedPhysicalStock, 'Company') = 'Company' THEN 1 ELSE 0 END 
		WHERE DSS.intDeliverySheetId = @intDeliverySheetId
	END
	

	INSERT INTO @processTicket(
		[intItemId]
		,[dtmDate]
		,[intLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[strLotNumber]
		,[dblOrigQuantity]
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
		,[dblOrigQuantity]					= SC.dblNetUnits * SPL.dblPercent /100
		,[dblAdjustByQuantity]				= ROUND((((SC.dblNetUnits / SCD.dblGross) * @dblNetUnits) - SC.dblNetUnits) * SPL.dblPercent / 100, @currencyDecimal)
		,[dblNewUnitCost]					= 0
		,[intItemUOMId]						= SC.intItemUOMIdTo
		,[intOwnershipType]					= CASE WHEN SPL.ysnCompanyOwned = 1 THEN 1 ELSE 2 END
	FROM 
	tblSCDeliverySheet SCD
	INNER JOIN @splitCustomerCompany SPL
		ON SCD.intDeliverySheetId = SPL.intDeliverySheetId
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

	
	DECLARE ticketCursor CURSOR FOR SELECT intItemId,dtmDate,intLocationId,intSubLocationId,intStorageLocationId,strLotNumber,dblOrigQuantity,dblAdjustByQuantity,intItemUOMId,intOwnershipType
	FROM @processTicket
	OPEN ticketCursor;  
	FETCH NEXT FROM ticketCursor INTO  @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dblOrigQuantity
			,@dblAdjustByQuantity 
			,@intItemUOMId
			,@intOwnershipType
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		IF ISNULL(@dblAdjustByQuantity,0) != 0
		BEGIN
			DECLARE @strAdjustmentDescription  VARCHAR(MAX) = 'Delivery Sheet Posting';
			SELECT @strAdjustmentDescription += CASE WHEN ISNULL(strDeliverySheetNumber, '') != '' THEN  '- ' + strDeliverySheetNumber ELSE '' END FROM tblSCDeliverySheet WHERE intDeliverySheetId = @intDeliverySheetId
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
				,@strAdjustmentDescription;
		
			SELECT @strDescription =  'Quantity Adjustment : ' + strAdjustmentNo, @strTransactionId = strAdjustmentNo  
			FROM tblICInventoryAdjustment WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

			SET @dblFinalQuantity = @dblOrigQuantity + @dblAdjustByQuantity;
			EXEC dbo.uspSMAuditLog 
			@keyValue			= @intDeliverySheetId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.DeliverySheet'		-- Screen Namespace
			,@entityId			= @intUserId						-- Entity Id.
			,@actionType		= 'Post'							-- Action Type
			,@changeDescription	= @strDescription					-- Description
			,@fromValue			= @dblOrigQuantity					-- Old Value
			,@toValue			= @dblFinalQuantity					-- New Value
			,@details			= '';
			SET @dblTempSplitQty = CASE WHEN @dblAdjustByQuantity  < 0 THEN @dblAdjustByQuantity * -1 ELSE @dblAdjustByQuantity END;
			SET @dblTempAdjustByQuantity = CASE WHEN @dblAdjustByQuantity  < 0 THEN @dblAdjustByQuantity * -1 ELSE @dblAdjustByQuantity END;
			DELETE FROM @storageHistoryData

			DECLARE splitCursor CURSOR FOR SELECT intEntityId, dblPercent, ysnCompanyOwned FROM @splitPerEntityBasedOnCustomerCompany
			OPEN splitCursor;  
			FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @ysnLoopIsDP;  
			WHILE @@FETCH_STATUS = 0  
			BEGIN
				SET @dblFinalSplitQty = ROUND((@dblTempAdjustByQuantity * @dblSplitPercent) / 100, @currencyDecimal);
				--IF @dblTempSplitQty > @dblFinalSplitQty
				--	SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
				--ELSE
				--	SET @dblFinalSplitQty = @dblTempSplitQty

					INSERT INTO @storageHistoryData(
						[intCustomerStorageId]
						,[intTicketId]
						,[intDeliverySheetId]
						,[intInventoryAdjustmentId]
						,[dblUnits]
						,[dtmHistoryDate]
						,[dblCurrencyRate]
						,[strPaidDescription]
						,[intTransactionTypeId]
						,[intUserId]
						,[strType]
						,[ysnPost]
						,[strTransactionId]
					)
					SELECT 	
						[intCustomerStorageId]				= GR.intCustomerStorageId				
						,[intTicketId]						= NULL
						,[intDeliverySheetId]				= GR.intDeliverySheetId
						,[intInventoryAdjustmentId]			= @intInventoryAdjustmentId
						,[dblUnits]							= (@dblFinalSplitQty * -1)
						,[dtmHistoryDate]					= dbo.fnRemoveTimeOnDate(@dtmDate)
						,[dblCurrencyRate]					= 1
						,[strPaidDescription]				= 'Quantity Adjustment From Delivery Sheet'
						,[intTransactionTypeId]				= 9
						,[intUserId]						= @intUserId
						,[strType]							= 'From Inventory Adjustment'
						,[ysnPost]							= 1
						,[strTransactionId]					= @strTransactionId
					FROM tblGRCustomerStorage GR
					INNER JOIN tblGRStorageType ST
						ON GR.intStorageTypeId = ST.intStorageScheduleTypeId
							AND CASE WHEN ISNULL(ST.strOwnedPhysicalStock, 'Company') = 'Company' THEN 1 ELSE 2 END = @intOwnershipType
					WHERE GR.intDeliverySheetId = @intDeliverySheetId AND intEntityId = @intEntityId
					
					

					SET @ysnLoopIsDP = NULL
					SET @intLoopDPContractDetailId = NULL 
				FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent,@ysnLoopIsDP;
			END
			CLOSE splitCursor;  
			DEALLOCATE splitCursor;
			
			EXEC uspGRInsertStorageHistoryRecord @storageHistoryData, 0
		END

		FETCH NEXT FROM ticketCursor INTO @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dblOrigQuantity
			,@dblAdjustByQuantity 
			,@intItemUOMId
			,@intOwnershipType;
	END
	CLOSE ticketCursor;  
	DEALLOCATE ticketCursor;


	--- Check for DP storage and adjust the DP contract 
	BEGIN


		SELECT TOP 1 
			@intItemUOMId = intItemUOMId
		FROM @processTicket

		SELECT TOP 1
			@intTicketScaleSetupId = intScaleSetupId
		FROM tblSCTicket
		WHERE intDeliverySheetId = @intDeliverySheetId

		SELECT TOP 1 
			@_dblCompanyOwnedPercentage = dblPercent
		FROM @splitCustomerCompany
		WHERE ysnCompanyOwned = 1

		SELECT TOP 1 
			@_intLoopEntityId = intEntityId
			,@_dblLoopSplitPercentage = SUM(dblPercent)
			,@_intLoopCurrentEntityId = intEntityId
		FROM @splitPerEntityBasedOnCustomerCompany
		WHERE ysnCompanyOwned = 1
		GROUP BY intEntityId
		ORDER BY intEntityId ASC 

		SET @dblDSShrink = (@dblDSShrink * @_dblCompanyOwnedPercentage) / 100

		WHILE (ISNULL(@_intLoopEntityId,0) > 0)
		BEGIN
		
			SET @intLoopDPContractDetailId = NULL

			IF(ISNULL((SELECT TOP 1 intAllowOtherLocationContracts FROM tblSCScaleSetup WHERE intScaleSetupId = @intTicketScaleSetupId),0) = 2)
			BEGIN
				SELECT	TOP	1	@intLoopDPContractDetailId	=	intContractDetailId
				FROM [fnSCGetDPContract](@intDSLocationId,@_intLoopEntityId,@intDSItemId, 'I',@dtmDeliverySheetDate)
			END
			ELSE
			BEGIN
				SELECT	TOP	1	@intLoopDPContractDetailId	=	intContractDetailId
				FROM [fnSCGetDPContract](NULL,@_intLoopEntityId,@intDSItemId, 'I',@dtmDeliverySheetDate)
			END
			

			IF(ISNULL(@intLoopDPContractDetailId,0) <> 0)
			BEGIN 
				SET @dblFinalSplitQty = (@dblDSShrink * @_dblLoopSplitPercentage) / 100
				SET @dblLoopPDContractAdjustment = @dblFinalSplitQty * -1

				EXEC uspCTUpdateSequenceQuantityUsingUOM @intLoopDPContractDetailId, @dblLoopPDContractAdjustment, @intUserId, @intDeliverySheetId, 'Delivery Sheet',@intItemUOMId

				INSERT INTO [tblSCDeliverySheetContractAdjustment]
				(
					[intDeliverySheetId]
					,[intContractDetailId]
					,[intEntityId]
					,[dblQuantity]
					,[intItemUOMId]
				)
				SELECT
					[intDeliverySheetId]						= @intDeliverySheetId
					,[intContractDetailId]						= @intLoopDPContractDetailId
					,[intEntityId]								= @_intLoopEntityId
					,[dblQuantity]								= @dblLoopPDContractAdjustment					
					,[intItemUOMId]								= @intItemUOMId
							
			END

			SET @_intLoopEntityId = NULL

			SELECT TOP 1 
				@_intLoopEntityId = intEntityId
				,@_dblLoopSplitPercentage = SUM(dblPercent)
				,@_intLoopCurrentEntityId = intEntityId
			FROM @splitPerEntityBasedOnCustomerCompany
			WHERE ysnCompanyOwned = 1
				AND intEntityId > @_intLoopCurrentEntityId
			GROUP BY intEntityId
			ORDER BY intEntityId ASC
		END
	END

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
	
	SELECT TOP 1 @strFeesCostMethod = ICFee.strCostMethod, @strFreightCostMethod = SC.strCostMethod 
	FROM tblSCTicket SC
	INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
	LEFT JOIN tblICItem ICFee ON ICFee.intItemId = SCS.intDefaultFeeItemId
	WHERE intDeliverySheetId = @intDeliverySheetId

	UPDATE CS
	SET  CS.dblDiscountsDue=QM.dblDiscountsDue
		,CS.dblDiscountsPaid=QM.dblDiscountsPaid
		,CS.dblFeesDue=SC.dblFeesPerUnit
		,CS.dblFreightDueRate=SC.dblFreightPerUnit
	FROM tblGRCustomerStorage CS
	OUTER APPLY (
		SELECT SUM(dblDiscountDue) dblDiscountsDue ,SUM(dblDiscountPaid)dblDiscountsPaid FROM dbo.[tblQMTicketDiscount] WHERE intTicketFileId = CS.intCustomerStorageId AND strSourceType = 'Storage' AND strDiscountChargeType = 'Dollar'
	) QM
	OUTER APPLY (
		SELECT 
		CASE WHEN @strFeesCostMethod = 'Amount' THEN (SUM(dblTicketFees)/@dblNetUnits) ELSE SUM(dblTicketFees) END AS dblFeesPerUnit
		,CASE WHEN @strFreightCostMethod = 'Amount' THEN (SUM(dblFreightRate)/@dblNetUnits) ELSE SUM(dblFreightRate) END AS dblFreightPerUnit
		FROM tblSCTicket WHERE intDeliverySheetId = @intDeliverySheetId AND strTicketStatus = 'C'
	) SC
	WHERE CS.intDeliverySheetId = @intDeliverySheetId
		AND CS.ysnTransferStorage = 0
		
	UPDATE A
	SET dblOpenBalance = B.dblQty
		,dblOriginalBalance = B.dblQty
	FROM tblGRCustomerStorage A
	OUTER APPLY (SELECT dblQty = dbo.fnGRCalculateStorageUnits(A.intCustomerStorageId)) B
	WHERE intDeliverySheetId = @intDeliverySheetId 
		AND A.ysnTransferStorage = 0


	UPDATE GRS SET GRS.dblGrossQuantity = ((GRS.dblOpenBalance / SCD.dblNet) * SCD.dblGross)
	FROM tblSCDeliverySheet SCD
	INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
	INNER JOIN tblGRCustomerStorage GRS ON GRS.intDeliverySheetId = SCDS.intDeliverySheetId 
	AND SCDS.intEntityId = GRS.intEntityId
	AND SCDS.intStorageScheduleTypeId = GRS.intStorageTypeId  
	where SCDS.intDeliverySheetId = @intDeliverySheetId and GRS.ysnTransferStorage = 0
		AND GRS.ysnTransferStorage = 0

	

	EXEC uspGRUpdateStorageShipDetails @intDeliverySheetId 


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




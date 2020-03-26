CREATE PROCEDURE [dbo].[uspSCPostDestinationWeightsAndGradesReversalProcess]
	@TicketDestinationWeightGrade AS SCTicketDestinationWeightsAndGradesPosting READONLY
	,@DiscountDestinationWeightGrade AS SCDiscountDestinationWeightsAndGradesPosting READONLY
	,@intUserId INT
	,@intNewTicketId INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX);



DECLARE @intTicketId INT
DECLARE @TicketReceiptShipmentIds Id
DECLARE @intRecordCounter INT
DECLARE @intDuplicateTicketId INT
DECLARE @dblDuplicateTicketNetUnits NUMERIC(18,6)
DECLARE @intDuplicateTicketEntityid INT
DECLARE @intDuplicateTicketContractDetailId INT
DECLARE @strDuplicateTicketDistributionOption NVARCHAR(3)
DECLARE @intDuplicateTicketShipmentId INT
DECLARE @intDuplicateTicketInvoiceId INT
DECLARE @dblDuplicateTicketCost NUMERIC(18,6)
DECLARE @strInOutFlag NVARCHAR(1)
DECLARE @_intInventoryReceiptShipmentId INT
DECLARE @_intReversalReceiptShipmentId INT
dECLARE @_strReceiptShipmentNumber NVARCHAR(50)
DECLARE @strTicketStatus NVARCHAR(1)
DECLARE @strTicketNumber NVARCHAR(50)
DECLARE @strReversalTicketNumber NVARCHAR(50)
DECLARE @intTicketPoolId INT
DECLARE @intTicketType INT
DECLARE @intProcessingLocationId INT
DECLARE @intCustomerStorageId INT
DECLARE @intDeliverySheetId INT
dECLARE @strDistributionOption NVARCHAR
DECLARE @intTicketContractDetailId INT
DECLARE @_intInventoryReceiptShipmentEntityId INT
DECLARE @_ysnLoadBaseContract BIT
dECLARE @_dblLoadUsedQty NUMERIC(18,6)
DECLARE @_ysnReceiptShipmetContainTicketContract BIT
DECLARE @_dblContractAvailableQty NUMERIC(18,6)
DECLARE @dblTicketScheduledQty NUMERIC(18,6)
DECLARE @intTicketItemUOMId INT
DECLARE @intTicketLoadDetailId INT
DECLARE @_intInventoryReceiptShipmentItemId INT
DECLARE @intMatchTicketId INT
DECLARE @strMatchTicketStatus NVARCHAR(1)
dECLARE @intMatchLoadDetailId INT
DECLARE @TransferEntries AS InventoryTransferStagingTable
DECLARE @intTicketItemId INT
DECLARE @intLotType INT
DECLARE @_intInventoryTransfer INT
DECLARE @_strInventoryTransferNumber NVARCHAR(50)
DECLARE @intTicketInvoiceId INT
DECLARE @intInvoiceDetailCount INT
DECLARE @_intInvoiceDetail INT
DECLARE @strInvoiceDetailIds NVARCHAR(500)
DECLARE @ysnPost BIT
DECLARE @intTicketStorageScheduleTypeId INT
DECLARE @intTicketBillId INT
DECLARE @intReversedBillId INT
DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
dECLARE @dblTicketNetUnits NUMERIC(18,6)
DECLARE @dblQtyUpdate NUMERIC(18,6)
DECLARE @strMatchTicketNumber NVARCHAR(50)
DECLARE @intNewInvoiceId INT
DECLARE @dblTicketGrossUnits NUMERIC(18,6)
DECLARE @ysnDeliverySheetPosted BIT
DECLARE @dtmTransactionDate DATETIME
DECLARE @strLogDescription NVARCHAR(MAX)
DECLARE @strDeliverySheetNumber NVARCHAR(50)
DECLARE @ItemReservationTableType AS ItemReservationTableType
DECLARE @InTransitTableType AS InTransitTableType
DECLARE @ItemsForInTransitCosting AS ItemInTransitCostingTableType
DECLARE @_intTransctionTypeId INT
DECLARE @_intTransactionId INT
DECLARE @_strTransactionId INT
DECLARE @_strBatchId NVARCHAR(100)


BEGIN TRY
	
	SET @dtmTransactionDate = GETDATE()

	SELECT TOP 1
		@intTicketId = intTicketId
	FROM @TicketDestinationWeightGrade

	--- get ticket informantion
	SELECT TOP 1 
		@strTicketNumber = strTicketNumber
		,@intTicketPoolId = intTicketPoolId
		,@intTicketType = intTicketType
		,@strInOutFlag = strInOutFlag
		,@intProcessingLocationId =	intProcessingLocationId	
		,@strTicketStatus = strTicketStatus
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId

	--Validation
		IF(@strTicketStatus = 'V')
		BEGIN
			SET @ErrorMessage = 'Cannot process ticket. Ticket is already voided.';
			RAISERROR(@ErrorMessage, 11, 1);
			GOTO _Exit
		END



	--GEt all IS for the ticket that don't have reversals
	BEGIN
		INSERT INTO @TicketReceiptShipmentIds
		SELECT DISTINCT
			A.intInventoryShipmentId
		FROM tblICInventoryShipment A
		INNER JOIN tblICInventoryShipmentItem B
			ON A.intInventoryShipmentId = B.intInventoryShipmentId
		WHERE A.intSourceType = 1
			AND B.intSourceId = @intTicketId
			AND ISNULL(A.strDataSource,'') <> 'Reversal'
			AND NOT EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intSourceInventoryShipmentId = A.intInventoryShipmentId)
		ORDER BY A.intInventoryShipmentId ASC
	END

	SELECT TOP 1 
		@_intInventoryReceiptShipmentId = MIN(intId)
	FROM @TicketReceiptShipmentIds
	
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpSCCheckInvoiceForTicketResult'))
	BEGIN
		CREATE TABLE #tmpSCCheckInvoiceForTicketResult (
			intTicketId INT
			,intInventoryShipmentId INT
			,intInvoiceId INT
			,intCreditMemoId INT
		)
	END

	---Create IS and invoice reversal 
	WHILE ISNULL(@_intInventoryReceiptShipmentId,0) > 0
	BEGIN

		---Check for Invoices and reverse those invoice 
		EXEC uspSCReverseInventoryShipmentInvoice @intTicketId,@intUserId,@_intInventoryReceiptShipmentId

		---Reversal IS
		SET @_intReversalReceiptShipmentId = 0
		EXEC uspICReverseInventoryShipment NULL,@_intInventoryReceiptShipmentId, @intUserId, NULL, @_intReversalReceiptShipmentId OUT

		IF ISNULL(@_intReversalReceiptShipmentId,0) > 0
		BEGIN
			SELECT TOP 1 
				@_strReceiptShipmentNumber = strShipmentNumber
			FROM tblICInventoryShipment
			WHERE intInventoryShipmentId = @_intReversalReceiptShipmentId

			EXEC dbo.uspICPostInventoryShipment 1, 0, @_strReceiptShipmentNumber, @intUserId;

		
			---- Update contract schedule if ticket Distribution type is load and link it to reversal IS
			BEGIN
				SET @_ysnReceiptShipmetContainTicketContract = 0 
				SET @_intInventoryReceiptShipmentItemId = 0

				SELECT TOP 1 
						@_intInventoryReceiptShipmentItemId = B.intInventoryShipmentItemId
				FROM tblICInventoryShipmentItem A
				INNER JOIN tblICInventoryShipmentItem B
					ON A.intInventoryShipmentId = B.intInventoryShipmentId
				WHERE A.intInventoryShipmentId = @_intInventoryReceiptShipmentId
					AND B.intLineNo  = @intTicketContractDetailId
				
				IF(ISNULL(@_intInventoryReceiptShipmentItemId,0) > 0)		
				BEGIN
					SET @_ysnReceiptShipmetContainTicketContract = 1  
				END

				IF(@strDistributionOption = 'LOD')
				BEGIN
					--- check if the current loop IS have the selected contract in ticket
					IF(@_ysnReceiptShipmetContainTicketContract = 1)							
					BEGIN

						SET @_ysnLoadBaseContract = 0
						SELECT TOP 1 
							@_ysnLoadBaseContract = ysnLoad
						FROM tblCTContractHeader A
						INNER JOIN tblCTContractDetail B
							ON A.intContractHeaderId = B.intContractHeaderId
						WHERE intContractDetailId = @intTicketContractDetailId

						SET @_ysnLoadBaseContract = ISNULL(@_ysnLoadBaseContract,0)

						--NON Load based contract
						IF(@_ysnLoadBaseContract = 0)
						BEGIN
							SET @_dblLoadUsedQty = 0
							SELECT TOP 1 
								@_dblLoadUsedQty = dblQty
							FROM tblSCTicketLoadUsed
							WHERE intTicketId = @intTicketId
								AND intLoadDetailId = @intTicketLoadDetailId
								AND intEntityId = @_intInventoryReceiptShipmentEntityId

							SET @_dblContractAvailableQty = 0
							SELECT TOP 1 
								@_dblContractAvailableQty = ISNULL(dblAvailableQtyInItemStockUOM,0)
							FROM vyuCTContractDetailView
							WHERE intContractDetailId = @intTicketContractDetailId

							IF @dblTicketScheduledQty <= @_dblContractAvailableQty
							BEGIN
								SET @_dblLoadUsedQty = @dblTicketScheduledQty
							END
							ELSE
							BEGIN
								SET @_dblLoadUsedQty = @_dblContractAvailableQty
							END

							IF @_dblLoadUsedQty <> 0
							BEGIN
					
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @_dblLoadUsedQty, @intUserId, @_intInventoryReceiptShipmentItemId, 'Inventory Shipment', @intTicketItemUOMId
							END
						END
						ELSE ---Load based contract
						BEGIN
							EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, 1, @intUserId, @_intInventoryReceiptShipmentItemId, 'Inventory Shipment', @intTicketItemUOMId
						END
					END
				END
			END
			
			---Audit Log Entry
			BEGIN
				--- Duplicate Ticket
				SET @strLogDescription = 'Inventory Shipment'
					EXEC dbo.uspSMAuditLog 
						@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
						,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
						,@entityId			= @intUserId						-- Entity Id.
						,@actionType		= 'Updated'						-- Action Type
						,@changeDescription	= @strLogDescription				-- Description
						,@fromValue			= ''								-- Old Value
						,@toValue			= @_strReceiptShipmentNumber								-- New Value
						,@details			= '';
			END
		END

		-------------------------- Loop Iterator
		IF NOT EXISTS (SELECT TOP 1 1 FROM @TicketReceiptShipmentIds WHERE intId > @_intInventoryReceiptShipmentId)
		BEGIN
			SET @_intInventoryReceiptShipmentId = 0
		END
		ELSE
		BEGIN
			SELECT TOP 1 
				@_intInventoryReceiptShipmentId = MIN(intId)
			FROM @TicketReceiptShipmentIds
			WHERE intId > @_intInventoryReceiptShipmentId
			
		END
	END

	--- Generate reversal ticket number
	BEGIN
		SET @intRecordCounter = 1
		SET @strReversalTicketNumber = @strTicketNumber + '-R'
		WHILE EXISTS(	SELECT TOP 1 1
						FROM tblSCTicket 
						WHERE strTicketNumber = @strReversalTicketNumber
							AND [intTicketPoolId] = @intTicketPoolId
							AND [intTicketType] = @intTicketType
							AND [strInOutFlag] = @strInOutFlag
							AND [intProcessingLocationId] = @intProcessingLocationId)
		BEGIN
			SET @strReversalTicketNumber = @strTicketNumber + '-R' + CAST(@intRecordCounter AS NVARCHAR)
			SET @intRecordCounter = @intRecordCounter + 1
		END
	END

	--Mark the ticket as void and reversed and ysnDestinationWeightPost
	BEGIN
		UPDATE tblSCTicket
		SET strTicketStatus = 'V'
			,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
			,dtmTicketVoidDateTime = @dtmTransactionDate
			,ysnReversed = 1
			,strTicketNumber = @strReversalTicketNumber 
			,ysnDestinationWeightGradePost = (CASE WHEN ISNULL(ysnDestinationWeightGradePost,0) = 1 THEN 0 ELSE 1 END)
		WHERE intTicketId = @intTicketId
	END

	--Duplicate Ticket
	BEGIN
		--tblSCTicket
		INSERT INTO [dbo].[tblSCTicket]
				([strTicketStatus]
				,[strTicketNumber]
				,[strOriginalTicketNumber]
				,[intScaleSetupId]
				,[intTicketPoolId]
				,[intTicketLocationId]
				,[intTicketType]
				,[strInOutFlag]
				,[dtmTicketDateTime]
				,[dtmTicketTransferDateTime]
				,[dtmTicketVoidDateTime]
				,[dtmTransactionDateTime]
				,[intProcessingLocationId]
				,[intTransferLocationId]
				,[strScaleOperatorUser]
				,[intEntityScaleOperatorId]
				,[strTruckName]
				,[strDriverName]
				,[ysnDriverOff]
				,[ysnSplitWeightTicket]
				,[ysnGrossManual]
				,[ysnGross1Manual]
				,[ysnGross2Manual]
				,[dblGrossWeight]
				,[dblGrossWeight1]
				,[dblGrossWeight2]
				,[dblGrossWeightOriginal]
				,[dblGrossWeightSplit1]
				,[dblGrossWeightSplit2]
				,[dtmGrossDateTime]
				,[dtmGrossDateTime1]
				,[dtmGrossDateTime2]
				,[intGrossUserId]
				,[ysnTareManual]
				,[ysnTare1Manual]
				,[ysnTare2Manual]
				,[dblTareWeight]
				,[dblTareWeight1]
				,[dblTareWeight2]
				,[dblTareWeightOriginal]
				,[dblTareWeightSplit1]
				,[dblTareWeightSplit2]
				,[dtmTareDateTime]
				,[dtmTareDateTime1]
				,[dtmTareDateTime2]
				,[intTareUserId]
				,[dblGrossUnits]
				,[dblShrink]
				,[dblNetUnits]
				,[strItemUOM]
				,[intCustomerId]
				,[intSplitId]
				,[strDistributionOption]
				,[intDiscountSchedule]
				,[strDiscountLocation]
				,[dtmDeferDate]
				,[strContractNumber]
				,[intContractSequence]
				,[strContractLocation]
				,[dblUnitPrice]
				,[dblUnitBasis]
				,[dblTicketFees]
				,[intCurrencyId]
				,[dblCurrencyRate]
				,[strTicketComment]
				,[strCustomerReference]
				,[ysnTicketPrinted]
				,[ysnPlantTicketPrinted]
				,[ysnGradingTagPrinted]
				,[intHaulerId]
				,[intFreightCarrierId]
				,[dblFreightRate]
				,[dblFreightAdjustment]
				,[intFreightCurrencyId]
				,[dblFreightCurrencyRate]
				,[strFreightCContractNumber]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[strLoadNumber]
				,[intLoadLocationId]
				,[intAxleCount]
				,[intAxleCount1]
				,[intAxleCount2]
				,[strPitNumber]
				,[intGradingFactor]
				,[strVarietyType]
				,[strFarmNumber]
				,[strFieldNumber]
				,[strDiscountComment]
				,[intCommodityId]
				,[intDiscountId]
				,[intContractId]
				,[intContractCostId]
				,[intDiscountLocationId]
				,[intItemId]
				,[intEntityId]
				,[intLoadId]
				,[intMatchTicketId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intSubLocationToId]
				,[intStorageLocationToId]
				,[intFarmFieldId]
				,[intDistributionMethod]
				,[intSplitInvoiceOption]
				,[intDriverEntityId]
				,[intStorageScheduleId]
				,[intConcurrencyId]
				,[dblNetWeightDestination]
				,[ysnHasGeneratedTicketNumber]
				,[intInventoryTransferId]
				,[intInventoryReceiptId]
				,[intInventoryShipmentId]
				,[intInventoryAdjustmentId]
				,[dblScheduleQty]
				,[dblConvertedUOMQty]
				,[dblContractCostConvertedUOM]
				,[intItemUOMIdFrom]
				,[intItemUOMIdTo]
				,[intTicketTypeId]
				,[intStorageScheduleTypeId]
				,[strFreightSettlement]
				,[strCostMethod]
				,[intGradeId]
				,[intWeightId]
				,[intDeliverySheetId]
				,[intCommodityAttributeId]
				,[strElevatorReceiptNumber]
				,[ysnRailCar]
				,[ysnDeliverySheetPost]
				,[intLotId]
				,[strLotNumber]
				,[intSalesOrderId]
				,[intTicketLVStagingId]
				,[intBillId]
				,[intInvoiceId]
				,[intCompanyId]
				,[intEntityContactId]
				,[strPlateNumber]
				,[blbPlateNumber]
				,[ysnDestinationWeightGradePost]
				,[strSourceType]
				,[ysnReadyToTransfer]
				,[ysnExport]
				,[dtmImportedDate]
				,[strUberStatusCode]
				,[intEntityShipViaTrailerId]
				,[intLoadDetailId]
				,[intCropYearId]
				,[ysnHasSpecialDiscount]
				,[ysnSpecialGradePosted]
				,[intItemContractDetailId]
				,[ysnCertOfAnalysisPosted]
				,[ysnExportRailXML]
				,[strTrailerId]
				,[intParentTicketId]
				,[intTicketTransactionType]
				,[ysnReversed])
		SELECT 	[strTicketStatus] = 'O'
				,[strTicketNumber]	= @strTicketNumber
				,A.[strOriginalTicketNumber]
				,A.[intScaleSetupId]
				,A.[intTicketPoolId]
				,A.[intTicketLocationId]
				,A.[intTicketType]
				,A.[strInOutFlag]
				,[dtmTicketDateTime] = @dtmTransactionDate
				,[dtmTicketTransferDateTime] = NULL
				,[dtmTicketVoidDateTime] = NULL
				,A.[dtmTransactionDateTime]
				,A.[intProcessingLocationId]
				,A.[intTransferLocationId]
				,A.[strScaleOperatorUser]
				,A.[intEntityScaleOperatorId]
				,A.[strTruckName]
				,A.[strDriverName]
				,A.[ysnDriverOff]
				,A.[ysnSplitWeightTicket]
				,A.[ysnGrossManual]
				,A.[ysnGross1Manual]
				,A.[ysnGross2Manual]
				,dblGrossWeight = B.[dblGrossWeight]
				,dblGrossWeight1 = B.[dblGrossWeight1]
				,dblGrossWeight2 = B.[dblGrossWeight2]
				,A.[dblGrossWeightOriginal]
				,A.[dblGrossWeightSplit1]
				,A.[dblGrossWeightSplit2]
				,A.[dtmGrossDateTime]
				,A.[dtmGrossDateTime1]
				,A.[dtmGrossDateTime2]
				,A.[intGrossUserId]
				,A.[ysnTareManual]
				,A.[ysnTare1Manual]
				,A.[ysnTare2Manual]
				,dblTareWeight = B.[dblTareWeight]
				,dblTareWeight1 = B.[dblTareWeight1]
				,dblTareWeight2 = B.[dblTareWeight2]
				,A.[dblTareWeightOriginal]
				,A.[dblTareWeightSplit1]
				,A.[dblTareWeightSplit2]
				,A.[dtmTareDateTime]
				,A.[dtmTareDateTime1]
				,A.[dtmTareDateTime2]
				,A.[intTareUserId]
				,dblGrossUnits = B.[dblGrossUnits]
				,dblShrink = B.[dblShrink]
				,[dblNetUnits] = B.dblNetUnits
				,A.[strItemUOM]
				,A.[intCustomerId]
				,A.[intSplitId]
				,A.[strDistributionOption]
				,A.[intDiscountSchedule]
				,A.[strDiscountLocation]
				,A.[dtmDeferDate]
				,A.[strContractNumber]
				,A.[intContractSequence]
				,A.[strContractLocation]
				,A.[dblUnitPrice]
				,A.[dblUnitBasis]
				,A.[dblTicketFees]
				,A.[intCurrencyId]
				,A.[dblCurrencyRate]
				,A.[strTicketComment]
				,A.[strCustomerReference]
				,A.[ysnTicketPrinted]
				,A.[ysnPlantTicketPrinted]
				,A.[ysnGradingTagPrinted]
				,A.[intHaulerId]
				,A.[intFreightCarrierId]
				,A.[dblFreightRate]
				,A.[dblFreightAdjustment]
				,A.[intFreightCurrencyId]
				,A.[dblFreightCurrencyRate]
				,A.[strFreightCContractNumber]
				,A.[ysnFarmerPaysFreight]
				,A.[ysnCusVenPaysFees]
				,A.[strLoadNumber]
				,A.[intLoadLocationId]
				,A.[intAxleCount]
				,A.[intAxleCount1]
				,A.[intAxleCount2]
				,A.[strPitNumber]
				,A.[intGradingFactor]
				,A.[strVarietyType]
				,A.[strFarmNumber]
				,A.[strFieldNumber]
				,A.[strDiscountComment]
				,A.[intCommodityId]
				,intDiscountId = B.[intDiscountId]
				,A.[intContractId]
				,A.[intContractCostId]
				,A.[intDiscountLocationId]
				,A.[intItemId]
				,A.[intEntityId]
				,A.[intLoadId]
				,A.[intMatchTicketId]
				,A.[intSubLocationId]
				,A.[intStorageLocationId]
				,A.[intSubLocationToId]
				,A.[intStorageLocationToId]
				,A.[intFarmFieldId]
				,A.[intDistributionMethod]
				,A.[intSplitInvoiceOption]
				,A.[intDriverEntityId]
				,A.[intStorageScheduleId]
				,[intConcurrencyId] = 1
				,A.[dblNetWeightDestination]
				,A.[ysnHasGeneratedTicketNumber]
				,[intInventoryTransferId] = NULL
				,[intInventoryReceiptId] = NULL
				,[intInventoryShipmentId] = NULL
				,[intInventoryAdjustmentId] = NULL
				,A.[dblScheduleQty]
				,A.[dblConvertedUOMQty]
				,A.[dblContractCostConvertedUOM]
				,A.[intItemUOMIdFrom]
				,A.[intItemUOMIdTo]
				,A.[intTicketTypeId]
				,A.[intStorageScheduleTypeId]
				,A.[strFreightSettlement]
				,A.[strCostMethod]
				,A.[intGradeId]
				,A.[intWeightId]
				,A.[intDeliverySheetId]
				,A.[intCommodityAttributeId]
				,A.[strElevatorReceiptNumber]
				,A.[ysnRailCar]
				,[ysnDeliverySheetPost] = 0
				,A.[intLotId]
				,A.[strLotNumber]
				,A.[intSalesOrderId]
				,A.[intTicketLVStagingId]
				,A.[intBillId]
				,A.[intInvoiceId]
				,A.[intCompanyId]
				,A.[intEntityContactId]
				,A.[strPlateNumber]
				,A.[blbPlateNumber]
				,[ysnDestinationWeightGradePost] = 1
				,A.[strSourceType]
				,A.[ysnReadyToTransfer]
				,[ysnExport] = 0
				,[dtmImportedDate] = NULL
				,A.[strUberStatusCode]
				,A.[intEntityShipViaTrailerId]
				,A.[intLoadDetailId]
				,A.[intCropYearId]
				,A.[ysnHasSpecialDiscount]
				,A.[ysnSpecialGradePosted] 
				,A.[intItemContractDetailId]
				,A.[ysnCertOfAnalysisPosted] 
				,A.[ysnExportRailXML]
				,A.[strTrailerId]
				,[intParentTicketId] = @intTicketId
				,A.[intTicketTransactionType]
				,[ysnReversed] = 0
		FROM tblSCTicket A, (SELECT TOP 1 * FROM @TicketDestinationWeightGrade) B
		WHERE A.intTicketId = @intTicketId
	
		SET @intDuplicateTicketId = SCOPE_IDENTITY()
		SET @intNewTicketId = @intDuplicateTicketId
				
		--Discount
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
				,[intTicketId]
				,[intTicketFileId]
				,[strSourceType]
				,[intSort]
				,[strDiscountChargeType])
		SELECT 	[intConcurrencyId] = 1
				,[dblGradeReading]
				,[strCalcMethod]
				,[strShrinkWhat]
				,[dblShrinkPercent]
				,[dblDiscountAmount]
				,[dblDiscountDue]
				,[dblDiscountPaid]
				,[ysnGraderAutoEntry]
				,[intDiscountScheduleCodeId]
				,[intTicketId] = @intDuplicateTicketId 
				,[intTicketFileId] = @intDuplicateTicketId   
				,[strSourceType] = 'Scale'
				,[intSort]
				,[strDiscountChargeType]
		FROM @DiscountDestinationWeightGrade
		

		--Split
		INSERT INTO [dbo].[tblSCTicketSplit]
			([intTicketId]
			,[intCustomerId]
			,[dblSplitPercent]
			,[intStorageScheduleTypeId]
			,[strDistributionOption]
			,[intStorageScheduleId]
			,[intConcurrencyId])
		SELECT 
			[intTicketId] = @intDuplicateTicketId 
			,[intCustomerId]
			,[dblSplitPercent]
			,[intStorageScheduleTypeId]
			,[strDistributionOption]
			,[intStorageScheduleId]
			,[intConcurrencyId] = 1
		FROM tblSCTicketSplit 
		WHERE intTicketId = @intTicketId

		--SealNumber
		INSERT INTO [dbo].[tblSCTicketSealNumber]
			([intTicketId]
			,[intSealNumberId]
			,[intTruckDriverReferenceId]
			,[intUserId]
			,[intConcurrencyId])
		SELECT 
			[intTicketId] = @intDuplicateTicketId 
			,[intSealNumberId]
			,[intTruckDriverReferenceId]
			,[intUserId]
			,[intConcurrencyId] = 1
		FROM tblSCTicketSealNumber
		WHERE intTicketId = @intTicketId

		--CofA
		INSERT INTO [dbo].[tblSCTicketCertificateOfAnalysis]
			([intTicketId]
			,[dblReading]
			,[intCertificateOfAnalysisId]
			,[intEnteredByUserId]
			,[dtmDateEntered]
			,[intConcurrencyId])
		SELECT [intTicketId] = @intDuplicateTicketId 
			,[dblReading]
			,[intCertificateOfAnalysisId]
			,[intEnteredByUserId]
			,[dtmDateEntered]
			,[intConcurrencyId]
		FROM tblSCTicketCertificateOfAnalysis

	END

	--AuditLog
	BEGIN
		--- Duplicate Ticket
		SET @strLogDescription = 'Created during Posting of Destination W&G for Ticket: ' + @strReversalTicketNumber
			EXEC dbo.uspSMAuditLog 
				@keyValue			= @intDuplicateTicketId				-- Primary Key Value of the Ticket. 
				,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
				,@entityId			= @intUserId						-- Entity Id.
				,@actionType		= 'Updated'						-- Action Type
				,@changeDescription	= @strLogDescription				-- Description
				,@fromValue			= ''								-- Old Value
				,@toValue			= ''								-- New Value
				,@details			= '';
	END

	--Distribute new Ticket
	BEGIN
		--GET duplicate ticket Details
		SELECT TOP 1
			@dblDuplicateTicketNetUnits = dblNetUnits
			,@intDuplicateTicketEntityid = intEntityId
			,@intDuplicateTicketContractDetailId = intContractId
			,@strDuplicateTicketDistributionOption = strDistributionOption
			,@dblDuplicateTicketCost = ISNULL(dblUnitPrice,0) + ISNULL(dblUnitBasis,0)
		FROM tblSCTicket
		WHERE intTicketId = @intDuplicateTicketId

		

		EXEC uspSCProcessToInventoryShipment 
			@intDuplicateTicketId
			, 'SalesOrder'
			, @intUserId
			, @dblDuplicateTicketNetUnits
			, @dblDuplicateTicketCost
			, @intDuplicateTicketEntityid
			, @intDuplicateTicketContractDetailId
			, @strDuplicateTicketDistributionOption
			, NULL -- storage schedule
			, @intDuplicateTicketShipmentId  OUT
			, @intDuplicateTicketInvoiceId  OUT


		
	END

	---Update the duplicate ticket
	UPDATE tblSCTicket
	SET intInventoryShipmentId = @intDuplicateTicketShipmentId
		,intInvoiceId = @intDuplicateTicketInvoiceId
		,strTicketStatus = 'C'
		,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
	WHERE intTicketId = @intDuplicateTicketId


	--Audit Log Entry
	BEGIN
	
		
		-- Orignal Ticket
			SET @strLogDescription = 'Posting of Destination W&G for Ticket: ' + @strTicketNumber
		
			EXEC dbo.uspSMAuditLog 
				@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
				,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
				,@entityId			= @intUserId						-- Entity Id.
				,@actionType		= 'Updated'							-- Action Type
				,@changeDescription	= @strLogDescription				-- Description
				,@fromValue			= ''								-- Old Value
				,@toValue			= ''								-- New Value
				,@details			= '';

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
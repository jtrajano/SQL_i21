CREATE PROCEDURE [dbo].[uspSCManualDistributionDirect]
	@UnitAllocation ScaleManualDistributionAllocation READONLY
	,@intTicketId AS INT 
	,@intUserId AS INT
	,@intEntityId AS INT
	,@intBillInvoiceId AS INT OUTPUT
	,@ysnSkipValidation as BIT = NULL
	,@ysnOutBound AS BIT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;


BEGIN TRY
	DECLARE @intId INT;
	DECLARE @ysnDPStorage AS BIT;
	DECLARE @intLoopContractId INT;
	DECLARE @dblLoopContractUnits NUMERIC(38, 20);
	DECLARE @intLoadContractDetailId INT
	DECLARE @intTickeLoadDetailId INT
	DECLARE @intTicketItemUOMIdTo INT
	DECLARE @strTicketStatus NVARCHAR(10)
	DECLARE @_intLoadContractDetailId INT
	DECLARE @_dblLoadQuantity NUMERIC(38,20)
	DECLARE @_intLoadItemUOMId INT
	DECLARE @_intContractItemUOMId INT
	DECLARE @_dblContractAvailableQuantity NUMERIC(38,20)
	DECLARE @_dblContractScheduleQuantity NUMERIC(38,20)
	DECLARE @_dblLoadContractUOMQuantity NUMERIC(38,20)
	DECLARE @_ysnLoopContractLoadBase BIT
	DECLARE @intTicketProcessingLocationId INT
	DECLARE @dtmTicketDate DATETIME
	DECLARE @intTicketScaleSetupId INT
	DECLARE @intAllowOtherLocationContracts INT
	DECLARE @intTicketItemId INT
	DECLARE @intDirectOutTicketId INT
	DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
	DECLARE @ysnDropShip BIT
	DECLARE @intMatchTicketId INT
	DECLARE @intTicketFreightCostUOMId INT
	
	DECLARE @_intLoopLoadDetailId INT
	DECLARE @_intLoopContractDetailId INT
	DECLARE @_dblLoopQuantity NUMERIC(38,20)
	DECLARE @_dblLoopContractUpdateQuantity NUMERIC(38,20)


	

	
	SET @ysnDropShip = 0

	---GET TICKET DETAILS
	SELECT TOP 1
		@intTickeLoadDetailId = ISNULL(A.intLoadDetailId,0)
		,@intTicketItemUOMIdTo = A.intItemUOMIdTo
		,@strTicketStatus = A.strTicketStatus
		,@dtmTicketDate = A.dtmTicketDateTime
		,@intTicketProcessingLocationId = A.intProcessingLocationId
		,@intTicketScaleSetupId = A.intScaleSetupId
		,@intAllowOtherLocationContracts = intAllowOtherLocationContracts
		,@intTicketItemId = intItemId
		,@intMatchTicketId = intMatchTicketId
		,@intTicketFreightCostUOMId = A.intFreightCostUOMId
	FROM tblSCTicket A
	INNER JOIN tblSCScaleSetup B
		ON A.intScaleSetupId = B.intScaleSetupId
	WHERE intTicketId = @intTicketId

	--Validation
	BEGIN
		IF @strTicketStatus = 'C' OR  @strTicketStatus = 'V'
		BEGIN
			RAISERROR('Cannot distribute closed ticket.', 11, 1);
		END
	END

	--------------------------DIREct IN TICKET
	IF(@ysnOutBound = 0)
	BEGIN
		---CREATE Direct out Ticket
		BEGIN
			INSERT INTO tblSCTicket (
				[strTicketStatus]
				,[strTicketNumber] 
				,[intScaleSetupId]
				,[intTicketPoolId]
				,[intTicketLocationId] 
				,[intTicketType] 
				,[strInOutFlag]
				,[dtmTicketDateTime]
				,[dtmTransactionDateTime]
				,[dtmTicketTransferDateTime]
				,[dtmTicketVoidDateTime]
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
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[strLoadNumber] 
				,[intLoadLocationId] 
				,[intAxleCount] 
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
				,[dblNetWeightDestination] 
				,[ysnHasGeneratedTicketNumber]
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
				,[intLotId] 
				,[strLotNumber]
				,[intSalesOrderId] 
				,[strPlateNumber]
				,[blbPlateNumber]
				,[ysnDestinationWeightGradePost]
				,[ysnReadyToTransfer]
				,[ysnExport] 
				,[intConcurrencyId]
				,dtmImportedDate
				,dtmDateCreatedUtc
			)
			SELECT TOP 1 
				A.[strTicketStatus]
				,[strTicketNumber] = (A.strTicketNumber + '-B')
				,A.[intScaleSetupId]
				,A.[intTicketPoolId]
				,A.[intTicketLocationId] 
				,A.[intTicketType] 
				,[strInOutFlag] = 'O'
				,A.[dtmTicketDateTime]
				,A.[dtmTransactionDateTime]
				,A.[dtmTicketTransferDateTime]
				,A.[dtmTicketVoidDateTime]
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
				,A.[dblGrossWeight] 
				,A.[dblGrossWeight1] 
				,A.[dblGrossWeight2] 
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
				,A.[dblTareWeight] 
				,A.[dblTareWeight1] 
				,A.[dblTareWeight2] 
				,A.[dblTareWeightOriginal] 
				,A.[dblTareWeightSplit1] 
				,A.[dblTareWeightSplit2] 
				,A.[dtmTareDateTime]
				,A.[dtmTareDateTime1]
				,A.[dtmTareDateTime2]
				,A.[intTareUserId] 
				,A.[dblGrossUnits] 
				,A.[dblShrink]
				,A.[dblNetUnits] 
				,A.[strItemUOM]
				,A.[intCustomerId] 
				,A.[intSplitId] 
				,A.[strDistributionOption] 
				,A.[intDiscountSchedule] 
				,A.[strDiscountLocation] 
				,A.[dtmDeferDate]
				,[strContractNumber] = ''
				,[intContractSequence] = NULL
				,[strContractLocation] = ''
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
				,intHaulerId = NULL ---A.[intHaulerId] 
				,A.[intFreightCarrierId] 
				,dblFreightRate = 0.0 ----A.[dblFreightRate] 
				,A.[ysnFarmerPaysFreight]
				,A.[ysnCusVenPaysFees]
				,A.[strLoadNumber] 
				,A.[intLoadLocationId] 
				,A.[intAxleCount] 
				,[strPitNumber] = ''
				,A.[intGradingFactor] 
				,A.[strVarietyType] 
				,A.[strFarmNumber] 
				,A.[strFieldNumber] 
				,A.[strDiscountComment]
				,A.[intCommodityId]
				,A.[intDiscountId]
				,[intContractId] = NULL
				,A.[intContractCostId]
				,A.[intDiscountLocationId]
				,A.[intItemId]
				,[intEntityId] = NULL
				,A.[intLoadId]
				,[intMatchTicketId] = @intTicketId
				,A.[intSubLocationId]
				,[intStorageLocationId] = NULL
				,A.[intSubLocationToId]
				,A.[intStorageLocationToId]
				,[intFarmFieldId] = NULL
				,A.[intDistributionMethod] 
				,A.[intSplitInvoiceOption] 
				,A.[intDriverEntityId]
				,A.[intStorageScheduleId]
				,A.[dblNetWeightDestination] 
				,A.[ysnHasGeneratedTicketNumber]
				,[dblScheduleQty] = NULL
				,[dblConvertedUOMQty]
				,A.[dblContractCostConvertedUOM]
				,A.[intItemUOMIdFrom] 
				,A.[intItemUOMIdTo]
				,[intTicketTypeId] = 9 ---Direct out
				,A.[intStorageScheduleTypeId]
				,A.[strFreightSettlement]
				,[strCostMethod] = 'Per Unit'
				,A.[intGradeId]
				,A.[intWeightId]
				,A.[intDeliverySheetId]
				,A.[intCommodityAttributeId]
				,A.[strElevatorReceiptNumber]
				,A.[ysnRailCar]
				,A.[intLotId] 
				,A.[strLotNumber]
				,A.[intSalesOrderId] 
				,A.[strPlateNumber]
				,A.[blbPlateNumber]
				,A.[ysnDestinationWeightGradePost]
				,A.[ysnReadyToTransfer]
				,A.[ysnExport] 
				,A.[intConcurrencyId]
				,dtmImportedDate = GETDATE()
				,dtmDateCreatedUtc = GETDATE()
			FROM tblSCTicket A
			WHERE A.intTicketId = @intTicketId

			SET @intDirectOutTicketId = SCOPE_IDENTITY()

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
				,intTicketId = @intDirectOutTicketId
				,intTicketFileId
				,strSourceType
				,intSort
				,strDiscountChargeType
				,intConcurrencyId = 0
			FROM tblQMTicketDiscount 
			WHERE intTicketId = @intTicketId 
			AND strSourceType = 'Scale'

			----CHECK if ticket is using Load and a dropship type
			IF (ISNULL(@intTickeLoadDetailId,0) > 0)
			BEGIN
				SELECT TOP 1
					@ysnDropShip = CASE WHEN B.intPurchaseSale = 3 THEN 1 ELSE 0 END
				FROM tblLGLoadDetail A
				INNER JOIN tblLGLoad B 
					ON A.intLoadId = B.intLoadId
				WHERE A.intLoadDetailId = @intTickeLoadDetailId


				---APPLY LOAD AND CONTRACT TO the direct out Ticket
				BEGIN
					UPDATE tblSCTicket
						SET intEntityId = D.intEntityId
							,intContractId = C.intContractDetailId
							,strContractNumber = D.strContractNumber
							,intLoadDetailId = B.intLoadDetailId
							,intContractSequence = C.intContractSeq
							,intCurrencyId = ISNULL(C.intInvoiceCurrencyId,C.intCurrencyId)
							,intWeightId = D.intWeightId
							,intGradeId = D.intGradeId
							,intCropYearId = D.intCropYearId
							,strLoadNumber = E.strLoadNumber
							,strCustomerReference = E.strCustomerReference
							,intFreightCostUOMId = @intTicketFreightCostUOMId
					FROM tblSCTicket A
					INNER JOIN tblLGLoadDetail B
						ON B.intLoadDetailId = @intTickeLoadDetailId
					INNER JOIN tblCTContractDetail C
						ON B.intSContractDetailId = C.intContractDetailId
					INNER JOIn tblCTContractHeader D
						ON C.intContractHeaderId = D.intContractHeaderId
					INNER JOIN tblLGLoad E
						ON B.intLoadId = E.intLoadId
					WHERE A.intTicketId = @intDirectOutTicketId
				END		

				--CHECK/ADD Customer reference number to maintenance table
				BEGIN
					IF NOT EXISTS(SELECT TOP 1 1 
							  FROM tblSCTruckDriverReference A	
							  INNER JOIN tblSCTicket B
							  	ON 1=1
							  WHERE intTicketId = @intDirectOutTicketId
							  	AND B.strCustomerReference = A.strData
								AND A.strRecordType = 'R'
								AND A.intEntityId IS NULL)
					BEGIN
						INSERT INTO tblSCTruckDriverReference(
							intEntityId
							,strData
							,strRecordType
						)
						SELECT TOP 1
							intEntityId = NULL
							,strData = strCustomerReference
							,strRecordType = 'R'
						FROM tblSCTicket 
						WHERE intTicketId = @intDirectOutTicketId
					END
				END		
			END
		END
		
		---SAVE the ALLOCATION DETAILS
		BEGIN
			---LOAD
			BEGIN
				--REcord the Allocation
				INSERT INTO tblSCTicketLoadUsed (
					[intTicketId]
					,[intLoadDetailId] 
					,[intEntityId] 
					,[dblQty] 
				)
				SELECT
					@intTicketId
					,intLoadDetailId
					,intEntityId
					,dblQuantity
				FROM @UnitAllocation
				WHERE intAllocationType = 2

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

			---CONTRACT
			BEGIN
				--REcord the Allocation
				INSERT INTO tblSCTicketContractUsed (
					[intTicketId]
					,[intContractDetailId] 
					,[intEntityId] 
					,[dblScheduleQty] 
				)
				SELECT
					@intTicketId
					,intContractDetailId
					,intEntityId
					,dblQuantity
				FROM @UnitAllocation
				WHERE intAllocationType = 1

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

			---STORAGE
			BEGIN

				---NON DP Storage
				INSERT INTO [dbo].[tblSCTicketStorageUsed]
				(
					[intTicketId]
					,[intEntityId]
					,[intStorageTypeId]
					,[intStorageScheduleId]
					,[dblQty]
					,[intContractDetailId]
				)
				SELECT
					@intTicketId
					,A.[intEntityId]
					,A.[intStorageScheduleTypeId]
					,A.[intStorageScheduleId]
					,dblQty = A.dblQuantity
					,[intContractDetailId] = NULL
				FROM @UnitAllocation A
				INNER JOIN tblGRStorageType B
					ON A.intStorageScheduleTypeId = B.intStorageScheduleTypeId
				WHERE intAllocationType = 3
					AND (B.ysnDPOwnedType = 0 OR B.ysnDPOwnedType IS NULL)

				--DP STORAGE
				BEGIN
					INSERT INTO [dbo].[tblSCTicketStorageUsed]
					(
						[intTicketId]
						,[intEntityId]
						,[intStorageTypeId]
						,[intStorageScheduleId]
						,[dblQty]
						,[intContractDetailId]
					)
					SELECT
						@intTicketId
						,A.[intEntityId]
						,A.[intStorageScheduleTypeId]
						,A.[intStorageScheduleId]
						,dblQty = A.dblQuantity
						,[intContractDetailId] = CASE WHEN @intAllowOtherLocationContracts = 2 
													THEN (SELECT TOP 1 intContractDetailId
														FROM dbo.fnSCGetDPContract(@intTicketProcessingLocationId,A.intEntityId,@intTicketItemId,'I',@dtmTicketDate))
													ELSE (SELECT TOP 1 intContractDetailId FROM 
															dbo.fnSCGetDPContract(NULL,A.intEntityId,@intTicketItemId,'I',@dtmTicketDate))
												END
					FROM @UnitAllocation A
					INNER JOIN tblGRStorageType B
						ON A.intStorageScheduleTypeId = B.intStorageScheduleTypeId
					WHERE intAllocationType = 3
						AND B.ysnDPOwnedType = 1 

					
				END

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

			--SPOT
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
					,intEntityId = A.intEntityId
					,dblUnitFuture = A.dblFuture
					,dblUnitBasis = A.dblBasis
					,dblQty = A.dblQuantity
				FROM @UnitAllocation A
				WHERE intAllocationType = 4

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
		END

		--UPdate Contract and LS
		BEGIN
			EXEC uspSCDirectUpdateContractAndLoadUsed
				@intTicketId = @intTicketId
				,@intUserId = @intUserId
		END

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

		--CREATE GL ENTRIES
		EXEC uspSCCreateDirectInGLEntries @intTicketId, 1, @intUserId 

		--Create Voucher
		EXEC uspSCDirectCreateVoucher 
			@intTicketId = @intTicketId
			,@intEntityId = @intEntityId
			,@intLocationId = @intTicketProcessingLocationId
			,@dtmScaleDate = @dtmTicketDate
			,@intUserId = @intUserId 
			,@intBillId = @intBillInvoiceId OUTPUT

		UPDATE tblSCTicket
			SET intMatchTicketId = @intDirectOutTicketId
		WHERE intTicketId = @intTicketId
	END
	--------------------------DIRECT OUT TICKET
	ELSE
	BEGIN
		---SAVE the ALLOCATION DETAILS
		BEGIN
			---LOAD
			BEGIN
				--REcord the Allocation
				INSERT INTO tblSCTicketLoadUsed (
					[intTicketId]
					,[intLoadDetailId] 
					,[intEntityId] 
					,[dblQty] 
				)
				SELECT
					@intTicketId
					,intLoadDetailId
					,intEntityId
					,dblQuantity
				FROM @UnitAllocation
				WHERE intAllocationType = 2

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

			---CONTRACT
			BEGIN
				--REcord the Allocation
				INSERT INTO tblSCTicketContractUsed (
					[intTicketId]
					,[intContractDetailId] 
					,[intEntityId] 
					,[dblScheduleQty] 
				)
				SELECT
					@intTicketId
					,intContractDetailId
					,intEntityId
					,dblQuantity
				FROM @UnitAllocation
				WHERE intAllocationType = 1

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

			---STORAGE
			BEGIN

				---NON DP Storage
				INSERT INTO [dbo].[tblSCTicketStorageUsed]
				(
					[intTicketId]
					,[intEntityId]
					,[intStorageTypeId]
					,[intStorageScheduleId]
					,[dblQty]
					,[intContractDetailId]
				)
				SELECT
					@intTicketId
					,A.[intEntityId]
					,A.[intStorageScheduleTypeId]
					,A.[intStorageScheduleId]
					,dblQty = A.dblQuantity
					,[intContractDetailId] = NULL
				FROM @UnitAllocation A
				INNER JOIN tblGRStorageType B
					ON A.intStorageScheduleTypeId = B.intStorageScheduleTypeId
				WHERE intAllocationType = 3
					AND (B.ysnDPOwnedType = 0 OR B.ysnDPOwnedType IS NULL)

				--DP STORAGE
				BEGIN
					INSERT INTO [dbo].[tblSCTicketStorageUsed]
					(
						[intTicketId]
						,[intEntityId]
						,[intStorageTypeId]
						,[intStorageScheduleId]
						,[dblQty]
						,[intContractDetailId]
					)
					SELECT
						@intTicketId
						,A.[intEntityId]
						,A.[intStorageScheduleTypeId]
						,A.[intStorageScheduleId]
						,dblQty = A.dblQuantity
						,[intContractDetailId] = CASE WHEN @intAllowOtherLocationContracts = 2 
													THEN (SELECT TOP 1 intContractDetailId
														FROM dbo.fnSCGetDPContract(@intTicketProcessingLocationId,A.intEntityId,@intTicketItemId,'O',@dtmTicketDate))
													ELSE (SELECT TOP 1 intContractDetailId FROM 
															dbo.fnSCGetDPContract(NULL,A.intEntityId,@intTicketItemId,'O',@dtmTicketDate))
												END
					FROM @UnitAllocation A
					INNER JOIN tblGRStorageType B
						ON A.intStorageScheduleTypeId = B.intStorageScheduleTypeId
					WHERE intAllocationType = 3
						AND B.ysnDPOwnedType = 1 
				END

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

			--SPOT
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
					,intEntityId = A.intEntityId
					,dblUnitFuture = A.dblFuture
					,dblUnitBasis = A.dblBasis
					,dblQty = A.dblQuantity
				FROM @UnitAllocation A
				WHERE intAllocationType = 4

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

		END

		---CREATE INVOICE
		BEGIN
			EXEC uspSCDirectCreateInvoice 
				@intTicketId = @intTicketId
				,@intEntityId = @intEntityId
				,@intLocationId = @intTicketProcessingLocationId
				,@intUserId = @intUserId 
				,@intInvoiceId = @intBillInvoiceId OUTPUT
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


	END

	-- UPDATE TICKET
	BEGIN
		UPDATE tblSCTicket
		SET strTicketStatus = 'C'
			,ysnDestinationWeightGradePost = 1
			,dtmDateCreatedUtc = GETUTCDATE()
			,dtmDateModifiedUtc = GETUTCDATE()
		WHERE intTicketId = @intTicketId
	END


	EXEC dbo.uspSMAuditLog 
		@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
		,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
		,@entityId			= @intUserId				-- Entity Id.
		,@actionType		= 'Updated'					-- Action Type
		,@changeDescription	= 'Manually Distributed'	--Description
		,@fromValue			= ''						-- Old Value
		,@toValue			= ''						-- New Value
		,@details			= '';

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

CREATE PROCEDURE [dbo].[uspICGenerateStorageCharges]
	@intLocationId AS INT
	,@intSubLocationId AS INT
	,@intCommodity AS INT
	,@dtmBillDateUTC AS DATETIME
AS




SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON


--DECLARE @intLocationId AS INT = 3
--DECLARE @intSubLocationId AS INT = 6
--DECLARE @intCommodity AS INT = 1
--DECLARE @dtmBillDateUTC AS DATETIME = '2022-03-30 16:00:00.000'


DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @dtmBillDate AS DATETIME 
DECLARE @LocalToUTCDiff AS INT
DECLARE @UTCToLocalDiff AS INT
DECLARE @_intLoopId  AS INT = 0
DECLARE @_intItemId  AS INT = 0
DECLARE @_dblRemainingDeliveredQty  NUMERIC(36,20)
DECLARE @_dblQty AS  NUMERIC(36,20)
DECLARE @_intInventoryStockMovementId  AS INT = 0
DECLARE @_intInboundAvailableId AS INT
DECLARE @_dblInboundAvailableQty AS NUMERIC(36,20)
DECLARE @_dblInboundAvailableDeliveredQty AS NUMERIC(36,20)
DECLARE @_dblUsedDeliveredQty AS NUMERIC(36,20)
DECLARE @_dtmInboundAvailableStartDate AS DATETIME

SET @LocalToUTCDiff = (DATEDIFF(HOUR,GETDATE(),GETUTCDATE()))
SET @UTCToLocalDiff = (DATEDIFF(HOUR,GETUTCDATE(),GETDATE()))

SELECT @dtmBillDate = DATEADD(HOUR,@UTCToLocalDiff,@dtmBillDateUTC)


BEGIN TRY


	---GET ALL Plan  (tblICStorageRate)	
	DECLARE @tmpICStorageRate TABLE(
		intStorageRateId INT 
		,intItemId INT
		,strPlanNo NVARCHAR(50)
		,dblRate NUMERIC(18,6)
		,dblNoOfDays NUMERIC(18,6)
		,intCommodityUnitMeasureId INT
		,strRateType NVARCHAR(50)
	)

	IF(ISNULL(@intSubLocationId,0) = 0)
	BEGIN
		INSERT INTO @tmpICStorageRate(
			intStorageRateId 
			,intItemId
			,strPlanNo
			,dblRate
			,dblNoOfDays
			,intCommodityUnitMeasureId
			,strRateType
		)
		SELECT 
			A.intStorageRateId
			,A.intItemId
			,A.strPlanNo
			,B.dblRate
			,B.dblNoOfDays
			,B.intCommodityUnitMeasureId
			,B.strRateType
	
		FROM (
			SELECT TOP 1 
				intStorageRateId
				,intItemId
				,strPlanNo
			FROM tblICStorageRate
			WHERE intCompanyLocationId = @intLocationId
			AND intCommodityId = @intCommodity
			AND dtmStartDateUTC <= @dtmBillDateUTC
			AND dtmEndDateUTC >= @dtmBillDateUTC
			AND ysnActive = 1
		) A
		INNER JOIN tblICStorageRateDetail B
			ON A.intStorageRateId = B.intStorageRateId
		
	END
	ELSE
	BEGIN
		INSERT INTO @tmpICStorageRate(
			intStorageRateId 
			,intItemId
			,strPlanNo
			,dblRate
			,dblNoOfDays
			,intCommodityUnitMeasureId
			,strRateType
		)
		SELECT 
			A.intStorageRateId
			,A.intItemId
			,A.strPlanNo
			,B.dblRate
			,B.dblNoOfDays
			,B.intCommodityUnitMeasureId
			,B.strRateType
	
		FROM (
			SELECT TOP 1 
				intStorageRateId
				,intItemId
				,strPlanNo
			FROM tblICStorageRate
			WHERE intStorageLocationId = @intSubLocationId
			AND intCompanyLocationId = @intLocationId
			AND intCommodityId = @intCommodity
			AND dtmStartDateUTC <= @dtmBillDateUTC
			AND dtmEndDateUTC >= @dtmBillDateUTC
			AND ysnActive = 1
		)A
		INNER JOIN tblICStorageRateDetail B
			ON A.intStorageRateId = B.intStorageRateId
		
	END

	--GEt All Transaction from tblICInventoryStockMovement Based on Params
	DECLARE @tmpICInventoryForStorageCharge TABLE(
		intRecId INT IDENTITY(1,1)
		,intItemId INT
		,intLotId INT
		,intTransactionTypeId INT
		,intTransactionId INT
		,strTransactionId NVARCHAR(100)
		,dtmDate DATETIME
		,dblQty NUMERIC(36,20)
		,intItemUOMId INT
		,intTransactionDetailId INT
		,intStorageLocationId INT
		,intSubLocationId INT
		,intInventoryStockMovementId INT
		,dblDeliveredQuantity NUMERIC(36,20)
		,dtmLastBillDateUTC DATETIME
		,dtmLastFreeWarehouseDateUTC DATETIME
		,dtmLastFreeOutboundDateUTC DATETIME
		
	)

	
	IF(ISNULL(@intSubLocationId,0) = 0)
	BEGIN
		INSERT INTO @tmpICInventoryForStorageCharge(
			intItemId 
			,intLotId 
			,intTransactionTypeId 
			,intTransactionId 
			,strTransactionId 
			,dtmDate 
			,dblQty 
			,intItemUOMId 
			,intTransactionDetailId 
			,intStorageLocationId 
			,intSubLocationId 
			,intInventoryStockMovementId 
			,dblDeliveredQuantity
			,dtmLastFreeWarehouseDateUTC
			,dtmLastBillDateUTC
			
		)
		SELECT 
			A.intItemId
			,intLotId = ISNULL(A.intLotId ,0)
			,A.intTransactionTypeId 
			,A.intTransactionId
			,A.strTransactionId
			,A.dtmDate
			,A.dblQty
			,A.intItemUOMId
			,intTransactionDetailId = ISNULL(A.intTransactionDetailId,0)
			,intStorageLocationId = A.intSubLocationId
			,intSubLocationId = A.intStorageLocationId
			,A.intInventoryStockMovementId
			,dblDeliveredQuantity = 0
			,dtmLastFreeWarehouseDateUTC = NULL
			,dtmLastBillDateUTC = NULL
			
		FROM tblICInventoryStockMovement A
		OUTER APPLY (
			SELECT TOP 1 
				intTransactionId,intTransactionDetailId
			FROM tblICStorageChargeDetail AA
			INNER JOIN  tblICStorageCharge BB
				ON AA.intStorageChargeId = BB.intStorageChargeId
			WHERE AA.intInventoryStockMovementId = A.intInventoryStockMovementId
				--AND BB.dtmBillDateUTC >= @dtmBillDateUTC
				AND BB.ysnPosted = 1
			
		)B
		WHERE A.dtmDate <= @dtmBillDate
			AND A.intCommodityId = @intCommodity
			AND A.intLocationId = @intLocationId
			AND A.ysnIsUnposted = 0
			AND B.intTransactionId IS NULL 
		
		----------Get Details of previously Charged Inbounds
		UNION ALL
		SELECT 
			A.intItemId
			,A.intLotId 
			,A.intTransactionTypeId 
			,A.intTransactionId
			,A.strTransactionId
			,dtmDate = A.dtmTransactionDateUTC
			,dblQty = A.dblReceivedQuantity
			,A.intItemUOMId
			,intTransactionDetailId = ISNULL(A.intTransactionDetailId,0)
			,A.intStorageLocationId
			,intSubLocationId = NULL
			,A.intInventoryStockMovementId
			,dblDeliveredQuantity = A.dblDeliveredQuantity
			,dtmLastFreeWarehouseDateUTC = A.dtmLastFreeWarehouseDateUTC
			,dtmLastBillDateUTC = B.dtmBillDateUTC
			
		FROM tblICStorageChargeDetail A
		INNER JOIN tblICStorageCharge B
			ON A.intStorageChargeId = B.intStorageChargeId
		WHERE B.ysnPosted = 1
			AND A.dblReceivedQuantity - ABS(A.dblDeliveredQuantity) > 0
			AND B.dtmBillDateUTC < @dtmBillDateUTC
			AND B.intCommodityId = @intCommodity
			AND B.intCompanyLocationId = @intLocationId
			AND A.intStorageLocationId IS NULL

		ORDER BY dtmDate ASC, intInventoryStockMovementId ASC

		
	END
	ELSE
	BEGIN
		INSERT INTO @tmpICInventoryForStorageCharge(
			intItemId 
			,intLotId 
			,intTransactionTypeId 
			,intTransactionId 
			,strTransactionId 
			,dtmDate 
			,dblQty 
			,intItemUOMId 
			,intTransactionDetailId 
			,intStorageLocationId 
			,intSubLocationId 
			,intInventoryStockMovementId
			,dblDeliveredQuantity
			,dtmLastFreeWarehouseDateUTC
			,dtmLastBillDateUTC
			
		)
		SELECT 
			A.intItemId
			,intLotId = ISNULL(A.intLotId ,0)
			,A.intTransactionTypeId 
			,A.intTransactionId
			,A.strTransactionId
			,A.dtmDate
			,A.dblQty
			,A.intItemUOMId
			,intTransactionDetailId = ISNULL(A.intTransactionDetailId,0)
			,intStorageLocationId = A.intSubLocationId
			,intSubLocationId = A.intStorageLocationId
			,A.intInventoryStockMovementId
			,dblDeliveredQuantity = 0
			,dtmLastFreeWarehouseDateUTC = NULL
			,dtmLastBillDateUTC = NULL
			
		FROM tblICInventoryStockMovement A
		OUTER APPLY (
			SELECT TOP 1 
				intTransactionId,intTransactionDetailId
			FROM tblICStorageChargeDetail AA
			INNER JOIN  tblICStorageCharge BB
				ON AA.intStorageChargeId = BB.intStorageChargeId
			WHERE AA.intInventoryStockMovementId = A.intInventoryStockMovementId
				--AND BB.dtmBillDateUTC >= @dtmBillDateUTC
				AND BB.ysnPosted = 1
			
		)B
		WHERE A.dtmDate <= @dtmBillDate
			AND A.intCommodityId = @intCommodity
			AND A.intLocationId = @intLocationId
			AND A.intSubLocationId = @intSubLocationId
			AND A.ysnIsUnposted = 0
			AND B.intTransactionId IS NULL 
		
		----------Get Details of previously Charged Inbounds
		UNION ALL
		SELECT 
			A.intItemId
			,A.intLotId 
			,A.intTransactionTypeId 
			,A.intTransactionId
			,A.strTransactionId
			,dtmDate = A.dtmTransactionDateUTC
			,dblQty = A.dblReceivedQuantity
			,A.intItemUOMId
			,intTransactionDetailId = ISNULL(A.intTransactionDetailId,0)
			,A.intStorageLocationId
			,intSubLocationId = NULL
			,A.intInventoryStockMovementId
			,dblDeliveredQuantity = A.dblDeliveredQuantity
			,dtmLastFreeWarehouseDateUTC = A.dtmLastFreeWarehouseDateUTC
			,dtmLastBillDateUTC = B.dtmBillDateUTC
			
		FROM tblICStorageChargeDetail A
		INNER JOIN tblICStorageCharge B
			ON A.intStorageChargeId = B.intStorageChargeId
		WHERE B.ysnPosted = 1
			AND A.dblReceivedQuantity - ABS(A.dblDeliveredQuantity) > 0
			AND B.dtmBillDateUTC < @dtmBillDateUTC
			AND B.intCommodityId = @intCommodity
			AND B.intCompanyLocationId = @intLocationId
			AND A.intStorageLocationId = @intSubLocationId
		ORDER BY dtmDate ASC, intInventoryStockMovementId ASC
	END	--

	

	--DECLARE @tblItemDeliveredQuantity TABLE(
	--	intItemId INT
	--	,dblRemainingQuantityDelivered NUMERIC(36,20)
	--)
	---------------------------------------------------
	--------Compute Delivered quntity for each record
	---------------------------------------------------
	--INSERT INTO @tblItemDeliveredQuantity(
	--	intItemId
	--	,dblRemainingQuantityDelivered
	--)
	--SELECT 
	--	intItemId = intItemId
	--	,dblRemainingQuantityDelivered = SUM(dblQty)
	--FROM @tmpICInventoryForStorageCharge
	--WHERE dblQty < 0
	--GROUP BY intItemId

	DECLARE @finalInventoryForStorageCharge TABLE(
		intRecId INT IDENTITY(1,1)
		,intItemId INT
		,intLotId INT
		,intTransactionTypeId INT
		,intTransactionId INT
		,strTransactionId NVARCHAR(100)
		,dtmDate DATETIME
		,dblQty NUMERIC(36,20)
		,intItemUOMId INT
		,intTransactionDetailId INT
		,intStorageLocationId INT
		,intSubLocationId INT
		,intInventoryStockMovementId INT
		,dblDeliveredQuantity NUMERIC(36,20)
		,dtmStartDateUTC DATETIME
		,dtmEndDateUTC DATETIME
		,dtmLastBillDateUTC DATETIME
		,dtmLastFreeWarehouseDateUTC DATETIME
		,dtmLastFreeOutboundDateUTC DATETIME
		,dblGross NUMERIC(36,20)
		,dblNet NUMERIC(36,20)
		,intWeightUOMId INT
		,strWeightUOMId NVARCHAR(50)
	)

	SELECT TOP 1 
		@_intLoopId = intRecId
		,@_intItemId = intItemId
	FROM @tmpICInventoryForStorageCharge
	ORDER BY intRecId ASC


	WHILE ISNULL(@_intLoopId,0) > 0
	BEGIN
		SELECT TOP 1 
			@_intItemId  = intItemId
			,@_dblQty = dblQty
		FROM @tmpICInventoryForStorageCharge
		WHERE intRecId = @_intLoopId


		-----INBOUND
		IF(@_dblQty > 0)
		BEGIN
			--SELECT TOP 1 @_dblRemainingDeliveredQty = dblRemainingQuantityDelivered
			--FROM @tblItemDeliveredQuantity
			--WHERE intItemId = @_intItemId


			INSERT INTO @finalInventoryForStorageCharge (
				intItemId
				,intLotId
				,intTransactionTypeId
				,intTransactionId
				,strTransactionId
				,dtmDate
				,dblQty
				,intItemUOMId
				,intTransactionDetailId
				,intStorageLocationId
				,intSubLocationId
				,intInventoryStockMovementId
				,dblDeliveredQuantity
				,dtmStartDateUTC 
				,dtmEndDateUTC 
				,dtmLastBillDateUTC 
				,dtmLastFreeWarehouseDateUTC
				,dblGross
				,dblNet 
				,intWeightUOMId
				,strWeightUOMId

			)
			SELECT 
				A.intItemId
				,A.intLotId
				,A.intTransactionTypeId
				,A.intTransactionId
				,A.strTransactionId
				,A.dtmDate
				,A.dblQty
				,A.intItemUOMId
				,A.intTransactionDetailId
				,A.intStorageLocationId
				,A.intSubLocationId
				,A.intInventoryStockMovementId
				,A.dblDeliveredQuantity
				,dtmStartDateUTC = ISNULL(DATEADD(DAY,1,dtmLastBillDateUTC),ISNULL(DATEADD(DAY,1,dtmLastFreeWhseDateUTC),DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate)))
				,dtmEndDateUTC = @dtmBillDateUTC
				,A.dtmLastBillDateUTC 
				,dtmLastFreeWarehouseDateUTC = B.dtmLastFreeWhseDateUTC
				,dblGross = B.dblGross
				,dblNet = B.dblNet
				,intWeightUOMId = B.intWeightUOMId
				,strWeightUOMId = B.strUnitMeasure
			FROM @tmpICInventoryForStorageCharge A
			---------------------
			-------Get IR Detail
			---------------------
			OUTER APPLY (  
				SELECT TOP 1 
					AA.dblGross
					,AA.dblNet
					,AA.intWeightUOMId
					,CC.strUnitMeasure
					,dtmLastFreeWhseDateUTC = (DATEADD(HOUR,@LocalToUTCDiff,DD.dtmLastFreeWhseDate))
				FROM tblICInventoryReceiptItem AA
				INNER JOIN tblICInventoryReceipt DD
					ON AA.intInventoryReceiptId = DD.intInventoryReceiptId
				INNER JOIN tblICItemUOM BB
					ON AA.intWeightUOMId = BB.intItemUOMId
				INNER JOIN tblICUnitMeasure CC
					ON BB.intUnitMeasureId = CC.intUnitMeasureId
			
				WHERE AA.intInventoryReceiptItemId = A.intTransactionDetailId
					AND A.intTransactionTypeId = 4 --- Inventory receipt
			) B   
			WHERE intRecId = @_intLoopId

		END
		
		---OUTBOUND
		ELSE
		BEGIN
			
			-------- GET/Update Details from transaction
			UPDATE @tmpICInventoryForStorageCharge
			SET dtmLastFreeOutboundDateUTC = B.dtmLastFreeDate
			FROM @tmpICInventoryForStorageCharge A
			-------------------------------
			-----------Load Shipment Detail
			-------------------------------
			OUTER APPLY (
				SELECT TOP 1
					AA.dblGross
					,AA.dblNet
					,intWeightUOMId = AA.intWeightItemUOMId
					,CC.strUnitMeasure
					,DD.dtmLastFreeDate
				FROM tblLGLoadDetail AA
				LEFT JOIN tblICItemUOM BB
					ON AA.intWeightItemUOMId = BB.intItemUOMId
				LEFT JOIN tblICUnitMeasure CC
					ON BB.intUnitMeasureId = CC.intUnitMeasureId
				OUTER APPLY(
					SELECT TOP 1 
						dtmLastFreeDate = (DATEADD(HOUR,@LocalToUTCDiff,AAA.dtmLastFreeDate))
					FROM tblLGLoadWarehouse AAA
					WHERE AAA.intLoadId = AA.intLoadId
				) DD
				WHERE intLoadDetailId = A.intTransactionDetailId
					AND intTransactionTypeId = 46 --- Outbound Shipment
			) B
			WHERE A.intRecId = @_intLoopId


			GETFIRSTAVAILABLE:

			SET @_intInventoryStockMovementId = NULL
			SET @_intInboundAvailableId = NULL
			SET	@_dblInboundAvailableQty = 0
			SET	@_dblInboundAvailableDeliveredQty = 0
			SET @_dtmInboundAvailableStartDate = NULL

			---GET The first inbound available
			SELECT TOP 1
				@_intInventoryStockMovementId = intInventoryStockMovementId
				,@_intInboundAvailableId = A.intRecId
				,@_dblInboundAvailableQty = A.dblQty
				,@_dblInboundAvailableDeliveredQty = A.dblDeliveredQuantity
				,@_dtmInboundAvailableStartDate =  ISNULL(DATEADD(DAY,1,A.dtmLastBillDateUTC),ISNULL(B.dtmLastFreeWhseDateUTC, DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate)))
			FROM @tmpICInventoryForStorageCharge A
			LEFT JOIN (
				SELECT 
					dtmLastFreeWhseDateUTC = DATEADD(DAY,1,(DATEADD(HOUR,@LocalToUTCDiff,AA.dtmLastFreeWhseDate)))
					,AA.intInventoryReceiptId
				FROM tblICInventoryReceipt AA
			)B ON A.intTransactionId = B.intInventoryReceiptId
					AND A.intTransactionTypeId = 4
			WHERE A.intRecId < @_intLoopId
				AND A.dblQty > 0
				AND (A.dblQty - ABS(A.dblDeliveredQuantity)) > 0
				AND intItemId = @_intItemId
				AND intLotId = A.intLotId
			ORDER BY A.intRecId ASC

			---Inbound qty is not enough for the outbound
			IF(ISNULL(@_dblInboundAvailableQty,0) + ISNULL(@_dblInboundAvailableDeliveredQty,0) + @_dblQty) < 0 AND ISNULL(@_intInventoryStockMovementId,0) > 0
			BEGIN
				SET @_dblUsedDeliveredQty = (@_dblInboundAvailableQty - ABS(@_dblInboundAvailableDeliveredQty)) * -1

				SET @_dblQty = (ABS(@_dblQty) - ABS(@_dblUsedDeliveredQty)) * -1

				UPDATE @tmpICInventoryForStorageCharge
				SET dblDeliveredQuantity = dblQty * -1
				WHERE intRecId = @_intInboundAvailableId

				UPDATE @finalInventoryForStorageCharge
				SET dblDeliveredQuantity = dblQty * -1
				WHERE intInventoryStockMovementId = @_intInventoryStockMovementId

				INSERT INTO @finalInventoryForStorageCharge (
					intItemId
					,intLotId
					,intTransactionTypeId
					,intTransactionId
					,strTransactionId
					,dtmDate
					,dblQty
					,intItemUOMId
					,intTransactionDetailId
					,intStorageLocationId
					,intSubLocationId
					,intInventoryStockMovementId
					,dblDeliveredQuantity
					,dtmStartDateUTC 
					,dtmEndDateUTC 
					,dtmLastBillDateUTC 
					,dtmLastFreeWarehouseDateUTC
					,dtmLastFreeOutboundDateUTC
				)
				SELECT 
					A.intItemId
					,A.intLotId
					,A.intTransactionTypeId
					,A.intTransactionId
					,A.strTransactionId
					,A.dtmDate
					,A.dblQty
					,A.intItemUOMId
					,A.intTransactionDetailId
					,A.intStorageLocationId
					,A.intSubLocationId
					,A.intInventoryStockMovementId
					,dblDeliveredQuantity  = @_dblUsedDeliveredQty
					,dtmStartDateUTC = @_dtmInboundAvailableStartDate
					,dtmEndDateUTC = ISNULL(A.dtmLastFreeOutboundDateUTC,DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate))
					,A.dtmLastBillDateUTC
					,A.dtmLastFreeWarehouseDateUTC
					,A.dtmLastFreeOutboundDateUTC
				FROM @tmpICInventoryForStorageCharge A
				WHERE intRecId = @_intLoopId


				GOTO GETFIRSTAVAILABLE
			END
			ELSE
			BEGIN

				UPDATE @tmpICInventoryForStorageCharge
				SET dblDeliveredQuantity = dblDeliveredQuantity + @_dblQty
				WHERE intRecId = @_intInboundAvailableId

				UPDATE @finalInventoryForStorageCharge
				SET dblDeliveredQuantity = dblDeliveredQuantity + @_dblQty
				WHERE intInventoryStockMovementId = @_intInventoryStockMovementId
				

				INSERT INTO @finalInventoryForStorageCharge (
					intItemId
					,intLotId
					,intTransactionTypeId
					,intTransactionId
					,strTransactionId
					,dtmDate
					,dblQty
					,intItemUOMId
					,intTransactionDetailId
					,intStorageLocationId
					,intSubLocationId
					,intInventoryStockMovementId
					,dblDeliveredQuantity
					,dtmStartDateUTC 
					,dtmEndDateUTC 
					,dtmLastBillDateUTC 
					,dtmLastFreeWarehouseDateUTC
					,dtmLastFreeOutboundDateUTC
				)
				SELECT 
					A.intItemId
					,A.intLotId
					,A.intTransactionTypeId
					,A.intTransactionId
					,A.strTransactionId
					,A.dtmDate
					,A.dblQty
					,A.intItemUOMId
					,A.intTransactionDetailId
					,A.intStorageLocationId
					,A.intSubLocationId
					,A.intInventoryStockMovementId
					,dblDeliveredQuantity = @_dblQty
					,dtmStartDateUTC = ISNULL(@_dtmInboundAvailableStartDate,DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate))
					,dtmEndDateUTC = ISNULL(A.dtmLastFreeOutboundDateUTC,DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate))
					,A.dtmLastBillDateUTC 
					,A.dtmLastFreeWarehouseDateUTC
					,dtmLastFreeOutboundDateUTC
				FROM @tmpICInventoryForStorageCharge A
				WHERE intRecId = @_intLoopId
			END
		END
		

	
		SET @_intLoopId = (SELECT TOP 1 intRecId
							FROM @tmpICInventoryForStorageCharge
							WHERE intRecId > @_intLoopId
							ORDER BY intRecId ASC)
		
	END

	---Get Initial Details for the transaction to be charged
	DECLARE @tblChargeTableDetail TABLE (
		intItemId INT
		,intItemChargeId INT
		,intLotId INT
		,intTransactionTypeId INT
		,intTransactionId INT
		,strTransactionId NVARCHAR(100)
		,dtmStartDateUTC DATETIME
		,dtmEndDateUTC DATETIME
		,dtmLastBillDateUTC DATETIME
		,dblReceivedQuantity NUMERIC(36,20)
		,dblDeliveredQuantity NUMERIC(36,20)
		,intItemUOMId INT
		,intItemChargeUOMId INT
		,dblGross NUMERIC(36,20)
		,dblNet NUMERIC(36,20)
		,intWeightUOMId INT
		,dblNumberOfDays NUMERIC(18,6)
		,dblChargeQuantity NUMERIC(36,20)
		,dblRate NUMERIC(36,10)
		,intRateUOMId INT
		,dblStorageCharge NUMERIC(18,6)
		,intTransactionDetailId INT
		,intStorageLocationId INT
		,strItemNo NVARCHAR(100)
		,strLotNumber NVARCHAR(100)
		,strStorageLocation NVARCHAR(200)
		,strItemUOM NVARCHAR(100)
		,strWeightUOMId NVARCHAR(100)
		,intInventoryStockMovementId INT
		,dtmTransactionDateUTC DATETIME
		,dtmLastFreeWarehouseDateUTC DATETIME
		,dtmLastFreeOutboundDateUTC DATETIME
		,dblCustomerCharge NUMERIC(18,6)
		,dblCustomerNoOfDays NUMERIC(18,6)
		,strChargeItemNo NVARCHAR(100)
		,intStorageRateId INT
		,strPlanNo NVARCHAR(50)
		,strRateType NVARCHAR(15)
	)
	
	
	INSERT INTO @tblChargeTableDetail(

		intItemId 
		,intItemChargeId
		,intLotId 
		,intTransactionTypeId
		,intTransactionId 
		,strTransactionId 
		,dtmStartDateUTC 
		,dtmEndDateUTC
		,dtmLastBillDateUTC 
		,dblReceivedQuantity
		,dblDeliveredQuantity
		,intItemUOMId 
		,intItemChargeUOMId
		,dblGross 
		,dblNet 
		,intWeightUOMId 
		,dblNumberOfDays
		,dblChargeQuantity 
		,dblRate
		,intRateUOMId 
		,dblStorageCharge 
		,intTransactionDetailId
		,intStorageLocationId
		,strItemNo 
		,strLotNumber 
		,strStorageLocation
		,strItemUOM 
		,strWeightUOMId 
		,intInventoryStockMovementId 
		,dtmTransactionDateUTC
		,dtmLastFreeWarehouseDateUTC
		,dtmLastFreeOutboundDateUTC
		,dblCustomerCharge
		,dblCustomerNoOfDays
		,strChargeItemNo
		,intStorageRateId
		,strPlanNo
		,strRateType
	)

	SELECT 
		intItemId = A.intItemId
		,intItemChargeId = B.intItemId
		,intLotId = A.intLotId 
		,intTransactionTypeId = A.intTransactionTypeId 
		,intTransactionId = A.intTransactionId
		,strTransactionId = A.strTransactionId
		,dtmStartDateUTC = A.dtmStartDateUTC
		,dtmEndDateUTC = A.dtmEndDateUTC
		,dtmLastBillDateUTC = A.dtmLastBillDateUTC
		,dblReceivedQuantity = CASE WHEN A.dblQty < 0 THEN 0 ELSE A.dblQty END
		,dblDeliveredQuantity =  A.dblDeliveredQuantity 
		,intItemUOMId = A.intItemUOMId
		,intItemChargeUOMId = B.intCommodityUnitMeasureId
		,dblGross = A.dblGross
		,dblNet = A.dblNet
		,intWeightUOMId = A.intWeightUOMId
		,dblNumberOfDays = 0
		,dblChargeQuantity = A.dblQty
		,dblRate = B.dblRate
		,intRateUOMId = ISNULL(B.intCommodityUnitMeasureId,A.intItemUOMId)
		,dblStorageCharge = 0
		,intTransactionDetailId = ISNULL(A.intTransactionDetailId,0)
		,intStorageLocationId = A.intStorageLocationId
		,strItemNo = C.strItemNo
		,strLotNumber = E.strLotNumber
		,strStorageLocation = F.strSubLocationName
		,strItemUOM = H.strUnitMeasure
		,strWeightUOMId = A.strWeightUOMId
		,intInventoryStockMovementId = A.intInventoryStockMovementId 
		,dtmTransactionDateUTC = DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate)
		,dtmLastFreeWarehouseDateUTC = A.dtmLastFreeWarehouseDateUTC
		,dtmLastFreeOutboundDateUTC = A.dtmLastFreeOutboundDateUTC
		,dblCustomerCharge = 0
		,dblCustomerNoOfDays = 0
		,strChargeItemNo = J.strItemNo
		,B.intStorageRateId
		,B.strPlanNo
		,B.strRateType
	FROM @finalInventoryForStorageCharge A
	OUTER APPLY (
		SELECT TOP 1
			intStorageRateId
			,strPlanNo
			,intCommodityUnitMeasureId
			,dblRate
			,intItemId
			,strRateType
		FROM @tmpICStorageRate
		WHERE dblNoOfDays <= (DATEDIFF(DAY,A.dtmStartDateUTC,A.dtmEndDateUTC) + 1)
		ORDER BY dblNoOfDays DESC
	) B
	INNER JOIN tblICItem C
		ON A.intItemId = C.intItemId
	LEFT JOIN tblICLot E
		ON A.intLotId = E.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation F
		ON A.intStorageLocationId = F.intCompanyLocationSubLocationId
	INNER JOIN tblICItemUOM G
		ON A.intItemUOMId = G.intItemUOMId
	INNER JOIN tblICUnitMeasure H
		ON G.intUnitMeasureId = H.intUnitMeasureId
	LEFT JOIN tblICItem J
		ON B.intItemId = J.intItemId
	WHERE B.intStorageRateId IS NOT NULL
		


	------UPDATE no of Days
	-------------------------------------------
	UPDATE @tblChargeTableDetail
	SET dblNumberOfDays = CASE WHEN (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC) + 1) < 0 THEN 0 ELSE (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC) + 1) END

	----UPDATE charge Quantity
	-----------------------------------------------
	UPDATE  @tblChargeTableDetail
	SET dblChargeQuantity = ABS(dblReceivedQuantity + dblDeliveredQuantity)


	-----UPDATE Storage Charge
	-------------------------------------------------
	UPDATE  @tblChargeTableDetail
	SET dblStorageCharge =  CASE WHEN strRateType = 'Per Unit' THEN
									dblNumberOfDays * ABS(dblChargeQuantity) * dblRate
								WHEN strRateType = 'Gross' THEN
									dblNumberOfDays * ABS(dblGross) * dblRate
								WHEN strRateType = 'Net' THEN
									dblNumberOfDays * ABS(dblNet) * dblRate
								WHEN strRateType = 'Flat' THEN
									dblRate
								ELSE
									dblNumberOfDays * ABS(dblChargeQuantity) * dblRate
							END

	------UPDATE Customer no of Days
	-------------------------------------------
	UPDATE @tblChargeTableDetail
	SET dblCustomerNoOfDays = CASE WHEN DATEDIFF(DAY,dtmLastFreeOutboundDateUTC,dtmTransactionDateUTC) <= 0 
								THEN 0
								ELSE ISNULL((DATEDIFF(DAY,dtmLastFreeOutboundDateUTC,dtmTransactionDateUTC) + 1),0)
							  END

	-----UPDATE Customer Charge
	-------------------------------------------------
	UPDATE  @tblChargeTableDetail
	SET dblCustomerCharge = dblCustomerNoOfDays * ABS(dblChargeQuantity) * dblRate


	SELECT
		A.*
	FROM @tblChargeTableDetail A
	ORDER BY intItemId,dtmTransactionDateUTC,intInventoryStockMovementId


	
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);

END CATCH
GO

CREATE PROCEDURE [dbo].[uspICGenerateStorageCharges]
	@intLocationId AS INT
	,@intSubLocationId AS INT
	,@intCommodity AS INT
	,@dtmBillDateUTC AS DATETIME
	,@dtmBillDate AS DATETIME
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
DECLARE @_intItemUOMId INT
DECLARE @_intLotId INT
DECLARE @strChargeType NVARCHAR(15)
DECLARE @_intInboundAvailableTotalAccumulatedDays INT
DECLARE @_intFinalRecId INT

-- SET @LocalToUTCDiff = (DATEDIFF(HOUR,GETDATE(),GETUTCDATE()))
-- SET @UTCToLocalDiff = (DATEDIFF(HOUR,GETUTCDATE(),GETDATE()))


-- SELECT @dtmBillDate = DATEADD(HOUR,@UTCToLocalDiff,@dtmBillDateUTC)
-- SET @dtmBillDate = DATEADD(dd, DATEDIFF(dd, 0,@dtmBillDate), 0) ----------Remove Time
-- SET @dtmBillDateUTC = DATEADD(HOUR,@LocalToUTCDiff,@dtmBillDate)


SET @LocalToUTCDiff = (DATEDIFF(HOUR,@dtmBillDate,@dtmBillDateUTC))
SET @UTCToLocalDiff = (DATEDIFF(HOUR,@dtmBillDateUTC,@dtmBillDate))



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
		,intItemUOMId INT
		,dblUnitQty NUMERIC(36,20)
		,strChargeType NVARCHAR(15)
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
			,intItemUOMId
			,dblUnitQty
			,strChargeType
		)
		SELECT 
			A.intStorageRateId
			,A.intItemId
			,A.strPlanNo
			,B.dblRate
			,B.dblNoOfDays
			,B.intCommodityUnitMeasureId
			,B.strRateType
			,D.intItemUOMId
			,D.dblUnitQty
			,A.strChargeType
		FROM (
			SELECT TOP 1 
				intStorageRateId
				,intItemId
				,strPlanNo
				,strChargeType
			FROM tblICStorageRate
			WHERE intCompanyLocationId = @intLocationId
			AND intCommodityId = @intCommodity
			AND ISNULL(dtmStartDateUTC,'1900-01-01') <= @dtmBillDateUTC
			AND ISNULL(dtmEndDateUTC,'9999-12-31') >= @dtmBillDateUTC
			AND ysnActive = 1
		) A
		INNER JOIN tblICStorageRateDetail B
			ON A.intStorageRateId = B.intStorageRateId
		LEFT JOIN tblICCommodityUnitMeasure C
			ON B.intCommodityUnitMeasureId = C.intCommodityUnitMeasureId
		LEFT JOIN tblICItemUOM D
			ON D.intItemId = A.intItemId
				AND D.intUnitMeasureId = C.intUnitMeasureId
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
			,intItemUOMId
			,dblUnitQty
			,strChargeType
		)
		SELECT 
			A.intStorageRateId
			,A.intItemId
			,A.strPlanNo
			,B.dblRate
			,B.dblNoOfDays
			,B.intCommodityUnitMeasureId
			,B.strRateType
			,D.intItemUOMId
			,D.dblUnitQty
			,A.strChargeType
		FROM (
			SELECT TOP 1 
				intStorageRateId
				,intItemId
				,strPlanNo
				,strChargeType
			FROM tblICStorageRate
			WHERE intStorageLocationId = @intSubLocationId
			AND intCompanyLocationId = @intLocationId
			AND intCommodityId = @intCommodity
			AND ISNULL(dtmStartDateUTC,'1900-01-01') <= @dtmBillDateUTC
			AND ISNULL(dtmEndDateUTC,'9999-12-31') >= @dtmBillDateUTC
			AND ysnActive = 1
		)A
		INNER JOIN tblICStorageRateDetail B
			ON A.intStorageRateId = B.intStorageRateId
		LEFT JOIN tblICCommodityUnitMeasure C
			ON B.intCommodityUnitMeasureId = C.intCommodityUnitMeasureId
		LEFT JOIN tblICItemUOM D
			ON D.intItemId = A.intItemId
				AND D.intUnitMeasureId = C.intUnitMeasureId
		
	END

	---Check/Get Charge Type
	SELECT TOP 1
		@strChargeType = strChargeType
	FROM @tmpICStorageRate

	--GEt All Transaction from tblICInventoryStockMovement and previously generated charges Based on Params
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
		,dtmStartDateUTC DATETIME
		,dblGross NUMERIC(36,20)
		,dblNet NUMERIC(36,20)
		,intWeightUOMId INT
		,strWeightUOMId NVARCHAR(100)
		,strItemUOM NVARCHAR(100)
		,intInventoryStockMovementIdUsed INT
		,intTotalAccumulatedDays INT NOT NULL DEFAULT 0 --- previous charge accumulation of days
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
			,intTotalAccumulatedDays
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
			,intTotalAccumulatedDays = 0
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
			,intTotalAccumulatedDays = ISNULL(D.intTotalAccumulatedDays,0)
		FROM tblICStorageChargeDetail A
		INNER JOIN tblICStorageCharge B
			ON A.intStorageChargeId = B.intStorageChargeId
		INNER JOIN (
						SELECT 
							intRow = ROW_NUMBER() OVER (PARTITION BY A.intInventoryStockMovementId ORDER BY B.dtmBillDateUTC DESC)
							,A.intStorageChargeDetailId
						FROM tblICStorageChargeDetail A
						INNER JOIN tblICStorageCharge B 
							ON A.intStorageChargeId = B.intStorageChargeId
						WHERE B.ysnPosted = 1
							AND B.dtmBillDateUTC < @dtmBillDateUTC
					)C 
			ON A.intStorageChargeDetailId = C.intStorageChargeDetailId
				AND C.intRow = 1	
		OUTER APPLY (
			SELECT TOP 1
				intTotalAccumulatedDays = SUM(ISNULL(BB.dblNumberOfDays,0))
			FROM tblICStorageCharge AA
			INNER JOIN tblICStorageChargeDetail BB
				ON AA.intStorageChargeId = BB.intStorageChargeId
			WHERE BB.intInventoryStockMovementId = A.intInventoryStockMovementId
				AND AA.ysnPosted = 1
		) D
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
			,intTotalAccumulatedDays
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
			,intTotalAccumulatedDays = 0
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
			,intTotalAccumulatedDays = ISNULL(D.intTotalAccumulatedDays,0)
		FROM tblICStorageChargeDetail A
		INNER JOIN tblICStorageCharge B
			ON A.intStorageChargeId = B.intStorageChargeId
		INNER JOIN (
						SELECT 
							intRow = ROW_NUMBER() OVER (PARTITION BY A.intInventoryStockMovementId ORDER BY B.dtmBillDateUTC DESC)
							,A.intStorageChargeDetailId
						FROM tblICStorageChargeDetail A
						INNER JOIN tblICStorageCharge B 
							ON A.intStorageChargeId = B.intStorageChargeId
						WHERE B.ysnPosted = 1
							AND B.dtmBillDateUTC < @dtmBillDateUTC
					)C 
			ON A.intStorageChargeDetailId = C.intStorageChargeDetailId
				AND C.intRow = 1	
		OUTER APPLY (
			SELECT TOP 1
				intTotalAccumulatedDays = SUM(ISNULL(BB.dblNumberOfDays,0))
			FROM tblICStorageCharge AA
			INNER JOIN tblICStorageChargeDetail BB
				ON AA.intStorageChargeId = BB.intStorageChargeId
			WHERE BB.intInventoryStockMovementId = A.intInventoryStockMovementId
				AND AA.ysnPosted = 1
		) D
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
		,intInventoryStockMovementIdUsed INT
		,intTotalAccumulatedDays INT
		,intNumberOfDays INT
	)

	SELECT TOP 1 
		@_intLoopId = intRecId
	FROM @tmpICInventoryForStorageCharge
	ORDER BY intRecId ASC


	WHILE ISNULL(@_intLoopId,0) > 0
	BEGIN
		SELECT TOP 1 
			@_intItemId  = intItemId
			,@_dblQty = dblQty
			,@_intLotId = intLotId
			,@_intItemUOMId = intItemUOMId
		FROM @tmpICInventoryForStorageCharge
		WHERE intRecId = @_intLoopId


		-----INBOUND
		IF(@_dblQty > 0)
		BEGIN
			
			UPDATE @tmpICInventoryForStorageCharge
			SET		dtmStartDateUTC = ISNULL(DATEADD(DAY,1,dtmLastBillDateUTC),ISNULL(DATEADD(DAY,1,dtmLastFreeWhseDateUTC),DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate)))
					,dtmLastFreeWarehouseDateUTC = B.dtmLastFreeWhseDateUTC
					,dblGross = B.dblGross
					,dblNet = B.dblNet
					,intWeightUOMId = B.intWeightUOMId
					,strWeightUOMId = B.strWeightUnitMeasure
					--,dblQty = B.dblOpenReceive
					--,strItemUOM = B.strItemUnitMeasure
					--,intItemUOMId = intUnitMeasureId
			FROM @tmpICInventoryForStorageCharge A
			---------------------
			-------Get IR Detail
			---------------------
			OUTER APPLY (  
				SELECT TOP 1 
					dblGross = CASE WHEN GG.intInventoryReceiptItemId IS NULL THEN AA.dblGross ELSE GG.dblGrossWeight END
					,dblNet = CASE WHEN GG.intInventoryReceiptItemId IS NULL THEN AA.dblNet ELSE ISNULL(GG.dblGrossWeight,0) - ISNULL(GG.dblTareWeight,0) END
					,AA.intWeightUOMId
					,strWeightUnitMeasure = CC.strUnitMeasure
					,dtmLastFreeWhseDateUTC = (DATEADD(HOUR,@LocalToUTCDiff,DD.dtmLastFreeWhseDate))
					,AA.dblOpenReceive
					,AA.intUnitMeasureId
					,strItemUnitMeasure = FF.strUnitMeasure
				FROM tblICInventoryReceiptItem AA
				INNER JOIN tblICInventoryReceipt DD
					ON AA.intInventoryReceiptId = DD.intInventoryReceiptId
				LEFT JOIN tblICItemUOM BB
					ON AA.intWeightUOMId = BB.intItemUOMId
				LEFT JOIN tblICUnitMeasure CC
					ON BB.intUnitMeasureId = CC.intUnitMeasureId
				LEFT JOIN tblICItemUOM EE
					ON AA.intUnitMeasureId = EE.intItemUOMId
				LEFT JOIN tblICUnitMeasure FF
					ON EE.intUnitMeasureId = FF.intUnitMeasureId
				LEFT JOIN tblICInventoryReceiptItemLot GG
					ON AA.intInventoryReceiptItemId = GG.intInventoryReceiptItemId
				WHERE AA.intInventoryReceiptItemId = A.intTransactionDetailId
					AND A.intTransactionTypeId = 4 --- Inventory receipt
					AND GG.intLotId = A.intLotId
			) B   
			WHERE intRecId = @_intLoopId


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
				,intTotalAccumulatedDays
				,intNumberOfDays
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
				,dtmStartDateUTC
				,dtmEndDateUTC = @dtmBillDateUTC
				,A.dtmLastBillDateUTC 
				,dtmLastFreeWarehouseDateUTC
				,dblGross = dblGross
				,dblNet = dblNet
				,intWeightUOMId = intWeightUOMId
				,strWeightUOMId = strWeightUOMId
				,intTotalAccumulatedDays = A.intTotalAccumulatedDays
				,intNumberOfDays = ISNULL(CASE WHEN (DATEDIFF(DAY,dtmStartDateUTC,@dtmBillDateUTC)) < 0 THEN 0 ELSE (DATEDIFF(DAY,dtmStartDateUTC,@dtmBillDateUTC)) + 1 END,0)
			FROM @tmpICInventoryForStorageCharge A
			WHERE intRecId = @_intLoopId


			
		END
		
		---OUTBOUND
		ELSE
		BEGIN
			
			-------- GET/Update Details from transaction
			UPDATE @tmpICInventoryForStorageCharge
			SET dtmLastFreeOutboundDateUTC = B.dtmLastFreeDate
				,dblGross = ISNULL(B.dblGross,0.0)
				,dblNet = ISNULL(B.dblNet,0.0)
				,intWeightUOMId = B.intWeightUOMId
				,strWeightUOMId = B.strUnitMeasure
			FROM @tmpICInventoryForStorageCharge A
			-------------------------------
			-----------Load Shipment Detail
			-------------------------------
			OUTER APPLY (
				SELECT TOP 1
					dblGross = ISNULL(EE.dblGross,AA.dblGross)
					,dblNet = ISNULL(EE.dblNet,AA.dblNet)
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
				LEFT JOIN tblLGLoadDetailLot EE
					ON AA.intLoadDetailId = EE.intLoadDetailId
						AND EE.intLotId = A.intLotId
				WHERE AA.intLoadDetailId = A.intTransactionDetailId
					AND A.intTransactionTypeId = 46 --- Outbound Shipment
			) B
			WHERE A.intRecId = @_intLoopId


			GETFIRSTAVAILABLE:

			SET @_intInventoryStockMovementId = NULL
			SET @_intInboundAvailableId = NULL
			SET	@_dblInboundAvailableQty = 0
			SET	@_dblInboundAvailableDeliveredQty = 0
			SET @_dtmInboundAvailableStartDate = NULL
			SET @_intInboundAvailableTotalAccumulatedDays = 0

			---GET The first inbound available
			SELECT TOP 1
				@_intInventoryStockMovementId = intInventoryStockMovementId
				,@_intInboundAvailableId = A.intRecId
				,@_dblInboundAvailableQty = A.dblQty
				,@_dblInboundAvailableDeliveredQty = A.dblDeliveredQuantity
				,@_dtmInboundAvailableStartDate =  ISNULL(DATEADD(DAY,1,A.dtmLastBillDateUTC),ISNULL(B.dtmLastFreeWhseDateUTC, DATEADD(HOUR,@LocalToUTCDiff,A.dtmDate)))
				,@_intInboundAvailableTotalAccumulatedDays =  intTotalAccumulatedDays
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
				AND A.intItemId = @_intItemId
				AND A.intLotId = @_intLotId
				AND intItemUOMId = @_intItemUOMId
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
					,intInventoryStockMovementIdUsed
					,dblGross
					,dblNet
					,intWeightUOMId
					,strWeightUOMId
					,intTotalAccumulatedDays
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
					,@_intInventoryStockMovementId
					,dblGross
					,dblNet
					,intWeightUOMId
					,strWeightUOMId
					,intTotalAccumulatedDays = @_intInboundAvailableTotalAccumulatedDays
				FROM @tmpICInventoryForStorageCharge A
				WHERE intRecId = @_intLoopId

				SET @_intFinalRecId = @@IDENTITY

				------UPDATE no of Days
				-------------------------------------------
				UPDATE @finalInventoryForStorageCharge
				SET intNumberOfDays = ISNULL(CASE WHEN (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC)) < 0 THEN 0 ELSE (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC)) + 1 END,0)			
				WHERE intRecId = @_intFinalRecId

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
					,intInventoryStockMovementIdUsed
					,dblGross
					,dblNet
					,intWeightUOMId
					,strWeightUOMId
					,intTotalAccumulatedDays
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
					,@_intInventoryStockMovementId
					,dblGross
					,dblNet
					,intWeightUOMId
					,strWeightUOMId
					,intTotalAccumulatedDays = @_intInboundAvailableTotalAccumulatedDays
				FROM @tmpICInventoryForStorageCharge A
				WHERE intRecId = @_intLoopId

				SET @_intFinalRecId = @@IDENTITY

				------UPDATE no of Days---------------
				-------------------------------------------
				UPDATE @finalInventoryForStorageCharge
				SET intNumberOfDays = ISNULL(CASE WHEN (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC)) < 0 THEN 0 ELSE (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC)) + 1 END,0)			
				WHERE intRecId = @_intFinalRecId

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
		,dblRateUnitQty NUMERIC(36,20)
		,dblRateItemUOMUnitQty NUMERIC(36,20) -- conversion factor for the item UOM base on the charge item
		,intInventoryStockMovementIdUsed INT
		,intTotalAccumulatedDays INT
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
		,dblRateUnitQty
		,dblRateItemUOMUnitQty
		,intInventoryStockMovementIdUsed
		,intTotalAccumulatedDays
	)

	SELECT 
		intItemId = A.intItemId
		,intItemChargeId = ISNULL(B.intItemId,L.intItemId)
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
		,intItemChargeUOMId = ISNULL(B.intItemUOMId,L.intItemUOMId)
		,dblGross = A.dblGross
		,dblNet = A.dblNet
		,intWeightUOMId = A.intWeightUOMId
		,dblNumberOfDays = CASE WHEN (@strChargeType = 'Segmented') THEN L.intDaysCovered ELSE 0 END
		,dblChargeQuantity = A.dblQty
		,dblRate = ISNULL(B.dblRate,L.dblRate)
		,intRateUOMId = ISNULL(B.intItemUOMId,A.intItemUOMId)
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
		,strChargeItemNo = ISNULL(J.strItemNo,M.strItemNo)
		,intStorageRateId = ISNULL(B.intStorageRateId,L.intStorageRateId)
		,strPlanNo = ISNULL(B.strPlanNo,L.strPlanNo)
		,strRateType = ISNULL(B.strRateType,L.strRateType)
		,dblRateUnitQty = ISNULL(B.dblUnitQty,1)
		,dblRateItemUOMUnitQty = ISNULL(K.dblUnitQty,1)
		,A.intInventoryStockMovementIdUsed
		,A.intTotalAccumulatedDays
	FROM @finalInventoryForStorageCharge A
	OUTER APPLY (
		SELECT TOP 1
			intStorageRateId
			,strPlanNo
			,intCommodityUnitMeasureId
			,dblRate
			,intItemId
			,strRateType
			,intItemUOMId
			,dblUnitQty
		FROM @tmpICStorageRate
		WHERE dblNoOfDays <= CASE WHEN (A.intNumberOfDays + A.intTotalAccumulatedDays) < 0 THEN 0 ELSE  (A.intNumberOfDays + A.intTotalAccumulatedDays) END
			AND ISNULL(strChargeType,'Discounted') = 'Discounted'
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
	OUTER APPLY(
		SELECT TOP 1 
			AA.intItemUOMId
			,AA.dblUnitQty
		FROM tblICItemUOM AA
		WHERE AA.intItemId = B.intItemId
			AND AA.intUnitMeasureId = G.intUnitMeasureId
	) K
	---------------------SEGMENTED RATE---------------------
	-------------------------------------------------
	OUTER APPLY (
		SELECT
			AA.intStorageRateId
			,AA.strPlanNo
			,AA.intCommodityUnitMeasureId
			,AA.dblRate
			,AA.intItemId
			,AA.strRateType
			,AA.intItemUOMId
			,AA.dblUnitQty
			--,intDaysCovered =  ISNULL(CC.intNoDays,(ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays)) 
			--,intDaysCovered =  ISNULL(CC.intNoDays,(ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays + 1)) 
			--,intDaysCovered =  ISNULL(AA.dblNoOfDays,0)
			--,intDaysCovered = CASE WHEN CC.intNoDays IS NULL THEN 0 ELSE 1 END
			,intDaysCovered = ISNULL(CC.intNoDays,(ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays)) --- Higher range/accumulated
								- CASE WHEN ISNULL(AA.dblNoOfDays,0) > 0 THEN AA.dblNoOfDays - 1 ELSE ISNULL(AA.dblNoOfDays,0) END --  
								- CASE WHEN CC.intNoDays IS NULL AND ISNULL(A.intTotalAccumulatedDays,0) = 0 THEN 0 ELSE 1 END
		FROM @tmpICStorageRate AA
		--OUTER APPLY(
		--	SELECT intNoDays = (SELECT TOP 1 dblNoOfDays 
		--						FROM @tmpICStorageRate 
		--						WHERE dblNoOfDays < AA.dblNoOfDays 
		--							AND dblNoOfDays <= CASE WHEN  (ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays) < 0 THEN 0 ELSE (ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays) END
		--						ORDER BY dblNoOfDays DESC)
		--)BB --- Lower No of Days
		OUTER APPLY(
			SELECT intNoDays = (SELECT TOP 1 dblNoOfDays 
								FROM @tmpICStorageRate 
								WHERE dblNoOfDays > AA.dblNoOfDays 
									AND dblNoOfDays <= CASE WHEN  (ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays) < 0 THEN 0 ELSE (ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays) END
								ORDER BY dblNoOfDays ASC)
		)CC --- Higher No of Days
		WHERE AA.dblNoOfDays <= CASE WHEN  (ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays) < 0 THEN 0 ELSE (ISNULL(A.intNumberOfDays,0) + A.intTotalAccumulatedDays) END
			AND AA.dblNoOfDays >= A.intTotalAccumulatedDays
			AND ISNULL(AA.strChargeType,'Discounted') = 'Segmented'
	) L 
	LEFT JOIN tblICItem M
		ON L.intItemId = M.intItemId
	--------------------------------------------------------------------
	--------------------------------------------------------------------
	WHERE COALESCE(B.intStorageRateId,L.intStorageRateId) IS NOT NULL OR (B.intStorageRateId IS NULL AND A.dblQty <= 0 AND A.dblDeliveredQuantity < 0)
		AND COALESCE(B.intItemId,L.intItemId) IS NOT NULL
	
	--SELECT 'debug',* FROM @finalInventoryForStorageCharge

	------UPDATE no of Days
	-------------------------------------------
	IF(ISNULL(@strChargeType,'Discounted') = 'Discounted')
	BEGIN
		UPDATE @tblChargeTableDetail
		SET dblNumberOfDays = ISNULL(CASE WHEN (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC) + 1) < 0 THEN 0 ELSE (DATEDIFF(DAY,dtmStartDateUTC,dtmEndDateUTC) + 1) END,0)
	END

	----UPDATE charge Quantity
	-----------------------------------------------
	UPDATE  @tblChargeTableDetail
	SET dblChargeQuantity = ABS(dblReceivedQuantity + dblDeliveredQuantity)


	-----UPDATE Storage Charge
	-------------------------------------------------
	UPDATE  @tblChargeTableDetail
	SET dblStorageCharge =  ROUND( CASE WHEN strRateType = 'Per Unit' THEN
									dblNumberOfDays * ABS(dblChargeQuantity) * dblRate * dblRateUnitQty * dblRateItemUOMUnitQty
								WHEN strRateType = 'Gross' THEN
									dblNumberOfDays * ABS(dblGross) * dblRate * dblRateUnitQty * dblRateItemUOMUnitQty
								WHEN strRateType = 'Net' THEN
									dblNumberOfDays * ABS(dblNet) * dblRate * dblRateUnitQty * dblRateItemUOMUnitQty
								WHEN strRateType = 'Flat' THEN
									dblRate * dblRateUnitQty * dblRateItemUOMUnitQty
								ELSE
									dblNumberOfDays * ABS(dblChargeQuantity) * dblRate * dblRateUnitQty * dblRateItemUOMUnitQty
							END,2)

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
	SET dblCustomerCharge = ROUND((dblCustomerNoOfDays * ABS(dblChargeQuantity) * dblRate * dblRateUnitQty * dblRateItemUOMUnitQty),2)


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
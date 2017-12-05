CREATE PROCEDURE [dbo].[uspSCDeliverySheetSummary]
	@intDeliverySheetId AS INT
	,@intSplitId AS INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
SET NOCOUNT ON
IF 1=0 
BEGIN
	SET FMTONLY OFF
END

DECLARE @intEntityId INT
		,@intTicketId INT
		,@intItemId INT
		,@intStorageScheduleTypeId INT
		,@strName NVARCHAR(MAX)
		,@counter INT
		,@Contract AS NUMERIC(38,6)
		,@Cash AS NUMERIC(38,6)
		,@Storage AS NUMERIC(38,6)
		,@StorageScale AS NUMERIC(38,6)
		,@DP AS NUMERIC(38,6)
		,@DPScale AS NUMERIC(38,6)
		,@Basis AS NUMERIC(38,6)
		,@WHGB AS NUMERIC(38,6)
		,@WHGBScale AS NUMERIC(38,6)
		,@Hold AS NUMERIC(38,6)
		,@SplitAverage AS NUMERIC(38,6);

IF OBJECT_ID (N'tempdb.dbo.#tblSCDeliverySheetSummary') IS NOT NULL
   DROP TABLE #temp

DECLARE @temp TABLE (fields NVARCHAR(50))
INSERT INTO @temp (fields)
VALUES ('Id') ,('Contract') ,('Cash') ,('Storage') ,('DP') ,('Basis'),('WHGB') ,('Hold')

SELECT *
INTO #temp
FROM (
    SELECT fields
	, a = CAST(NULL AS NUMERIC(38,6)) 
    FROM @temp
) 
src
PIVOT 
(
    MAX(a) 
    FOR fields IN (Id, Contract, Cash, Storage, DP, Basis, WHGB, Hold)
) unpvt

ALTER TABLE #temp
DROP COLUMN Id

ALTER TABLE #temp
ADD Id INT

ALTER TABLE #temp
ADD EntityId INT

ALTER TABLE #temp
ADD EntityName NVARCHAR(MAX)

ALTER TABLE #temp
ADD SplitPercentage NUMERIC(38,6)

DELETE FROM #temp

--FOR ticket splits
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR

SELECT SCDS.intEntityId,EM.strName,SCDS.dblSplitPercent,SCDS.intStorageScheduleTypeId FROM tblSCDeliverySheet SCD
INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
INNER JOIN tblEMEntity EM ON EM.intEntityId = SCDS.intEntityId
WHERE SCD.intSplitId = @intSplitId  AND SCD.intDeliverySheetId = @intDeliverySheetId

SELECT @intItemId = intItemId FROM tblSCDeliverySheet WHERE intDeliverySheetId = @intDeliverySheetId

SET @counter = 1

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @intEntityId, @strName, @SplitAverage, @intStorageScheduleTypeId;

--SPLIT
WHILE @@FETCH_STATUS = 0
BEGIN
	IF ISNULL(@intEntityId,0) != 0
	BEGIN
			
		--For priced contract
		SET @Contract = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IR.intSourceType IN (1,5) AND CTD.intPricingTypeId = 1),0)

		--For cash contract
		SET @Cash = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IR.intSourceType IN (1,5) AND CTD.intPricingTypeId = 6),0)

		--Storage hold split ticket
		SET @Storage = ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
		LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
		AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCT.strTicketStatus = 'H'
		AND SCDS.intEntityId = @intEntityId AND SCD.intItemId = @intItemId AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId), 0)

		--For DP contract
		--SET @DP = 
		--ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblSCDeliverySheet SCD
		--INNER JOIN tblICInventoryReceiptItem IRI ON SCD.intDeliverySheetId = IRI.intSourceId
		--INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		--INNER JOIN tblGRCustomerStorage GRC ON SCD.intDeliverySheetId = GRC.intDeliverySheetId
		--INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRC.intStorageTypeId
		--WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		--AND IR.intSourceType IN (1,5) AND GR.ysnDPOwnedType = 1 
		--AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0), 0)

		--For DP contract scale
		SET @DP = 
		ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
		LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE SCDS.intEntityId = @intEntityId AND SCT.intItemId = @intItemId
		AND GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0), 0)

		--SET @DP = @DP + @DPScale;

		--For basis contract
		SET @Basis = 
		ISNULL((SELECT SUM((IRI.dblOpenReceive * @SplitAverage) / 100) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IR.intSourceType IN (1,5) AND CTD.intPricingTypeId = 2), 0)

		--GBWH hold split ticket
		SET @WHGB = ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
		LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
		AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCT.strTicketStatus = 'H'
		AND SCDS.intEntityId = @intEntityId AND SCT.intItemId = @intItemId AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId), 0)

		--For hold
		SET @Hold = 0;
		--ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
		--WHERE SCD.intDeliverySheetId = @intDeliverySheetId AND SCT.strTicketStatus = 'H'
		--AND SCD.intEntityId = @intEntityId AND SCD.intItemId = @intItemId), 0)

	END
	
	INSERT INTO #temp (Id, Contract, Cash, Storage, DP, Basis, WHGB, Hold) 
	VALUES(@counter, @Contract, @Cash, @Storage, @DP, @Basis, @WHGB, @Hold)

	update #temp SET EntityId = @intEntityId, EntityName = @strName, SplitPercentage = @SplitAverage WHERE Id = @counter

	SET @counter = @counter+1

	FETCH NEXT FROM intListCursor INTO @intEntityId, @strName, @SplitAverage, @intStorageScheduleTypeId;
END

CLOSE intListCursor;
DEALLOCATE intListCursor;

--NON-SPLIT
IF ISNULL(@intEntityId,0) = 0
	BEGIN
		SELECT TOP 1 @intEntityId = SCD.intEntityId, @strName = EM.strName, @SplitAverage = 100 FROM tblSCDeliverySheet SCD 
		INNER JOIN tblEMEntity EM ON EM.intEntityId = SCD.intEntityId 
		WHERE intDeliverySheetId = @intDeliverySheetId
		
		--For priced contract
		SET @Contract = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IR.intSourceType IN (1,5) AND CTD.intPricingTypeId = 1),0)

		--For cash contract
		SET @Cash = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IR.intSourceType IN (1,5) AND CTD.intPricingTypeId = 6),0)

		--For storage
		SET @Storage = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblSCDeliverySheet SCD
		INNER JOIN tblICInventoryReceiptItem IRI ON SCD.intDeliverySheetId = IRI.intSourceId
		INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN tblGRCustomerStorage GRC ON SCD.intDeliverySheetId = GRC.intDeliverySheetId
		INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRC.intStorageTypeId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		AND IR.intSourceType IN (1,5) AND GR.ysnReceiptedStorage = 0 
		AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0), 0)
		
		--For storage scale
		SET @StorageScale = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN tblSCTicket SC ON IRI.intSourceId = SC.intTicketId
		INNER JOIN tblGRCustomerStorage GRC ON SC.intTicketId = GRC.intTicketId
		INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SC.intStorageScheduleTypeId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		AND IR.intSourceType IN (1,5) AND SC.intItemId = @intItemId
		AND GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0), 0)

		SET @Storage = @Storage + @StorageScale

		--For DP contract
		SET @DP = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblSCDeliverySheet SCD
		INNER JOIN tblICInventoryReceiptItem IRI ON SCD.intDeliverySheetId = IRI.intSourceId
		INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN tblGRCustomerStorage GRC ON SCD.intDeliverySheetId = GRC.intDeliverySheetId
		INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRC.intStorageTypeId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		AND IR.intSourceType IN (1,5) AND GR.ysnDPOwnedType = 1 
		AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0), 0)

		--For DP contract scale
		SET @DPScale = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN tblSCTicket SC ON IRI.intSourceId = SC.intTicketId
		INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SC.intStorageScheduleTypeId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		AND IR.intSourceType IN (1,5) AND SC.intItemId = @intItemId
		AND GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0), 0)

		SET @DP = @DP + @DPScale;

		--For basis contract
		SET @Basis = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IR.intSourceType IN (1,5) AND CTD.intPricingTypeId = 2), 0)

		--For warehouse and grainbank
		SET @WHGB = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblSCDeliverySheet SCD
		INNER JOIN tblICInventoryReceiptItem IRI ON SCD.intDeliverySheetId = IRI.intSourceId
		INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN tblGRCustomerStorage GRC ON SCD.intDeliverySheetId = GRC.intDeliverySheetId
		INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRC.intStorageTypeId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		AND IR.intSourceType IN (1,5) AND IRI.intItemId = @intItemId
		AND (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0), 0)

		--For warehouse and grainbank scale
		SET @WHGBScale = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN tblSCTicket SC ON IRI.intSourceId = SC.intTicketId
		INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SC.intStorageScheduleTypeId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intOwnershipType = 2 
		AND IR.intSourceType IN (1,5) AND SC.intItemId = @intItemId
		AND (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0), 0)

		SET @WHGB = @WHGB + @WHGBScale;
	
		--For hold
		SET @Hold = 
		ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
		WHERE SCD.intDeliverySheetId = @intDeliverySheetId AND SCT.strTicketStatus = 'H' AND SCT.ysnDeliverySheetPost = 0), 0)

		INSERT INTO #temp (Id, Contract, Cash, Storage, DP, Basis, WHGB, Hold) 
		VALUES(@counter, @Contract, @Cash, @Storage, @DP, @Basis, @WHGB, @Hold)

		update #temp SET EntityId = @intEntityId, EntityName = @strName, SplitPercentage = @SplitAverage WHERE Id = @counter

		SET @counter = @counter+1
	END

ALTER TABLE #temp
ADD intDecimalPrecision INT

UPDATE #temp SET intDecimalPrecision = (SELECT intCurrencyDecimal FROM tblSMCompanyPreference)

ALTER TABLE #temp
ADD strItemUOM NVARCHAR(MAX)

UPDATE #temp SET strItemUOM = (SELECT TOP 1 strItemUOM FROM tblSCTicket WHERE intDeliverySheetId = @intDeliverySheetId)

ALTER TABLE #temp
ADD intDeliverySheetId INT

UPDATE #temp SET intDeliverySheetId = @intDeliverySheetId

SELECT * FROM #temp
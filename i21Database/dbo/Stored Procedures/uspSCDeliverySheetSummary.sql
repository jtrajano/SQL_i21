CREATE PROCEDURE [dbo].[uspSCDeliverySheetSummary]
	@intDeliverySheetId AS INT,
	@ysnAddHistory AS BIT = 0
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
		,@NetUnits AS NUMERIC(38,6)
		,@tmpUnits AS NUMERIC(38,6)
		,@remainingUnits AS NUMERIC(38,6)
		,@ticketTotalUnitQty AS NUMERIC(38,6)
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
		,@SplitAverage AS NUMERIC(38,6)
		,@currencyDecimal INT
		,@intDeliverySheetSplitId INT
		,@ysnPost BIT
		,@curDate DATE;

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

SET @curDate = GETDATE();

SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference


SELECT @remainingUnits = SUM(SCD.dblNet)
FROM tblSCDeliverySheet SCD
WHERE SCD.intDeliverySheetId = @intDeliverySheetId

SELECT @ticketTotalUnitQty = SUM(SCT.dblNetUnits)
FROM tblSCDeliverySheet SCD
INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.strTicketStatus = 'H'
WHERE SCD.intDeliverySheetId = @intDeliverySheetId

IF @remainingUnits = 0
	SET @remainingUnits = @ticketTotalUnitQty;

--FOR ticket splits
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR

SELECT SCDS.intEntityId,EM.strName,SCDS.dblSplitPercent,SCDS.intStorageScheduleTypeId,SCD.dblNet, SCD.intItemId, SCD.ysnPost, SCDS.intDeliverySheetSplitId
FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
LEFT JOIN tblEMEntity EM ON EM.intEntityId = SCDS.intEntityId
WHERE SCD.intDeliverySheetId = @intDeliverySheetId

SET @counter = 1

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @intEntityId, @strName, @SplitAverage, @intStorageScheduleTypeId, @NetUnits, @intItemId, @ysnPost, @intDeliverySheetSplitId;

--SPLIT
WHILE @@FETCH_STATUS = 0
BEGIN
	IF ISNULL(@intEntityId,0) != 0
	BEGIN
		IF @NetUnits = 0
			SET @NetUnits = @ticketTotalUnitQty;
		SET @tmpUnits = (@NetUnits * @SplitAverage) / 100;
		IF @remainingUnits < @tmpUnits
			SET @tmpUnits = @remainingUnits;

		--For priced contract
		SET @Contract = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IRI.intSourceId = @intDeliverySheetId
		AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 1),0)

		--For cash contract
		SET @Cash = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IRI.intSourceId = @intDeliverySheetId
		AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 6),0)

		--For Storage
		SET @Storage = 0;
		IF ISNULL((SELECT SUM((@NetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
		AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCDS.intEntityId = @intEntityId AND SCD.intItemId = @intItemId
		AND SCD.intItemId = @intItemId AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId), 0) > 0
		BEGIN
			SET @Storage = @tmpUnits;
		END

		--For DP contract
		SET @DP = 0;
		IF ISNULL((SELECT SUM((@NetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE SCDS.intEntityId = @intEntityId AND SCD.intItemId = @intItemId
		AND GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0
		AND SCD.intDeliverySheetId = @intDeliverySheetId AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId), 0) > 0
		BEGIN
			SET @DP = @tmpUnits;
		END

		--For basis contract
		SET @Basis = 
		ISNULL((SELECT SUM((IRI.dblOpenReceive * @SplitAverage) / 100) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IRI.intSourceId = @intDeliverySheetId
		AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 2), 0)

		
		--For WHGB
		SET @WHGB = 0;
		IF ISNULL((SELECT SUM((@NetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		LEFT JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
		AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCDS.intEntityId = @intEntityId 
		AND SCD.intItemId = @intItemId AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId), 0) > 0
		BEGIN
			SET @WHGB = @tmpUnits;
		END
		
		--For hold
		SET @Hold = 0;
		--ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
		--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
		--WHERE SCD.intDeliverySheetId = @intDeliverySheetId AND SCT.strTicketStatus = 'H'
		--AND SCD.intEntityId = @intEntityId AND SCD.intItemId = @intItemId), 0)
		
		IF @ysnPost = 0 AND @ysnAddHistory = 1
			IF NOT EXISTS(SELECT TOP 1 * FROM tblSCDeliverySheetHistory WHERE intDeliverySheetId = @intDeliverySheetId AND dtmDeliverySheetHistoryDate = @curDate AND intEntityId = @intEntityId )
				INSERT INTO tblSCDeliverySheetHistory (intEntityId, dblQuantity, dblSplitPercent, intStorageScheduleTypeId, intDeliverySheetId, intDeliverySheetSplitId, dtmDeliverySheetHistoryDate, intConcurrencyId)
				VALUES (@intEntityId, ISNULL(@tmpUnits,0), @SplitAverage, @intStorageScheduleTypeId, @intDeliverySheetId, @intDeliverySheetSplitId, GETDATE(), 1)
			ELSE
				UPDATE tblSCDeliverySheetHistory set intStorageScheduleTypeId = @intStorageScheduleTypeId
				, dblQuantity = ISNULL(@tmpUnits,0) , dblSplitPercent = ISNULL(@SplitAverage,0) 
				WHERE intEntityId = @intEntityId AND intDeliverySheetId = @intDeliverySheetId AND dtmDeliverySheetHistoryDate = @curDate

		SET @remainingUnits -= @tmpUnits;

	END
	
	INSERT INTO #temp (Id, Contract, Cash, Storage, DP, Basis, WHGB, Hold) 
	VALUES(@counter, @Contract, @Cash, @Storage, @DP, @Basis, @WHGB, @Hold)

	update #temp SET EntityId = @intEntityId, EntityName = @strName, SplitPercentage = @SplitAverage WHERE Id = @counter

	SET @counter = @counter+1

	FETCH NEXT FROM intListCursor INTO @intEntityId, @strName, @SplitAverage, @intStorageScheduleTypeId, @NetUnits, @intItemId, @ysnPost, @intDeliverySheetSplitId;
END

CLOSE intListCursor;
DEALLOCATE intListCursor;

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
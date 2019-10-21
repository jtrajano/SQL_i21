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
		,@SplitAverage AS NUMERIC(38,6)
		,@currencyDecimal INT
		,@intDeliverySheetSplitId INT
		,@ysnPost BIT
		,@NetUnits AS NUMERIC(38,6)
		,@strEntityNo NVARCHAR(50)

IF OBJECT_ID (N'tempdb.dbo.#temp') IS NOT NULL
   DROP TABLE #temp

DECLARE @temp TABLE (fields NVARCHAR(50))
INSERT INTO @temp (fields)
VALUES ('Id') ,('EntityNo'),('Contract') ,('Cash') ,('Storage') ,('DP') ,('Basis'),('WHGB') ,('Hold'),('SplitPercentage')

SELECT *
INTO #temp
FROM (
    SELECT fields
	, a = CAST(0 AS NUMERIC(38,6)) 
    FROM @temp
) 
src
PIVOT 
(
    MAX(a) 
    FOR fields IN (Id,EntityNo, Contract, Cash, Storage, DP, Basis, WHGB, Hold)
) unpvt

--------------------------------------------------------------------------------------------------------
--- Start Additional Columns
--------------------------------------------------------------------------------------------------------

ALTER TABLE #temp
DROP COLUMN Id

ALTER TABLE #temp
ADD Id INT 

ALTER TABLE #temp
DROP COLUMN EntityNo

ALTER TABLE #temp
ADD EntityNo  NVARCHAR(50) 

ALTER TABLE #temp
ADD EntityId INT

ALTER TABLE #temp
ADD EntityName NVARCHAR(MAX)

ALTER TABLE #temp
ADD SplitPercentage NUMERIC(38,6)

ALTER TABLE #temp
ADD strItemUOM NVARCHAR(MAX)

ALTER TABLE #temp
ADD intDeliverySheetId INT

ALTER TABLE #temp
ADD intDecimalPrecision INT

--------------------------------------------------------------------------------------------------------
--- End Additional Columns
-----------------------------------------------------------------------------------------------------


DELETE FROM #temp

SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

SELECT @intItemId = intItemId
FROM tblSCDeliverySheet SCD
WHERE SCD.intDeliverySheetId = @intDeliverySheetId

--FOR ticket splits
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR

SELECT SCDS.intEntityId, EM.strEntityNo, EM.strName, SCDS.intStorageScheduleTypeId,dblSplitPercent 
FROM tblSCDeliverySheetSplit SCDS 
INNER JOIN tblEMEntity EM ON EM.intEntityId = SCDS.intEntityId
WHERE SCDS.intDeliverySheetId = @intDeliverySheetId

SET @counter = 1

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @intEntityId,@strEntityNo, @strName, @intStorageScheduleTypeId,@SplitAverage

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
		SET @Storage = ISNULL((SELECT sum(dblOriginalBalance) FROM tblGRCustomerStorage GRS
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRS.intStorageTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
		AND GRS.intEntityId = @intEntityId AND GRS.intItemId = @intItemId 
		AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId 
		AND GRS.intDeliverySheetId = @intDeliverySheetId 
		AND GRS.ysnTransferStorage = 0), 0)
		
		--For DP contract
		SET @DP = ISNULL((SELECT sum(dblOriginalBalance) FROM tblGRCustomerStorage GRS
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRS.intStorageTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE GRS.intEntityId = @intEntityId AND GRS.intItemId = @intItemId
		AND GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0
		AND GRS.intDeliverySheetId = @intDeliverySheetId 
		AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId
		AND GRS.ysnTransferStorage = 0), 0)

		--For basis contract
		SET @Basis = 
		ISNULL((SELECT SUM(IRI.dblOpenReceive) FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
		WHERE IR.intEntityVendorId = @intEntityId AND IRI.intLineNo > 0 
		AND IRI.intOwnershipType = 1 AND IRI.intItemId = @intItemId
		AND IRI.intSourceId = @intDeliverySheetId
		AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 2), 0)
		
		--For WHGB
		SET @WHGB = ISNULL((SELECT sum(dblOriginalBalance) FROM tblGRCustomerStorage GRS
		LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRS.intStorageTypeId AND GR.intStorageScheduleTypeId > 0
		WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
		AND GRS.intDeliverySheetId = @intDeliverySheetId AND GRS.intEntityId = @intEntityId 
		AND GRS.intItemId = @intItemId AND GR.intStorageScheduleTypeId = @intStorageScheduleTypeId
		AND GRS.ysnTransferStorage = 0), 0)
		
		--For hold
		SET @Hold = 0;
		
		
	END
	
	INSERT INTO #temp (Id, EntityNo, Contract, Cash, Storage, DP, Basis, WHGB, Hold,SplitPercentage) 
	VALUES(@counter, @strEntityNo,@Contract, @Cash, @Storage, @DP, @Basis, @WHGB, @Hold,@SplitAverage)

	update #temp SET EntityId = @intEntityId, EntityName = @strName WHERE Id = @counter

	SET @counter = @counter+1

	FETCH NEXT FROM intListCursor INTO  @intEntityId, @strEntityNo,@strName, @intStorageScheduleTypeId,@SplitAverage
END

CLOSE intListCursor;
DEALLOCATE intListCursor;

UPDATE #temp SET intDecimalPrecision = (SELECT intCurrencyDecimal FROM tblSMCompanyPreference)
UPDATE #temp SET strItemUOM = (SELECT TOP 1 strItemUOM FROM tblSCTicket WHERE intDeliverySheetId = @intDeliverySheetId)
UPDATE #temp SET intDeliverySheetId = @intDeliverySheetId

SELECT * FROM #temp
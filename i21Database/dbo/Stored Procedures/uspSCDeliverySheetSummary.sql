CREATE PROCEDURE [dbo].[uspSCDeliverySheetSummary]
	@intDeliverySheetId AS INT
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
		,@strName NVARCHAR(MAX)
		,@counter INT
		,@Contract AS NUMERIC(38,6)
		,@Cash AS NUMERIC(38,6)
		,@Storage AS NUMERIC(38,6)
		,@DP AS NUMERIC(38,6)
		,@Basis AS NUMERIC(38,6)
		,@WHGB AS NUMERIC(38,6)
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
ADD SplitPercentage INT

--UPDATE #temp SET Id = 1
----For priced contract
--UPDATE #temp SET Contract = 
--ISNULL((SELECT SUM(SCC.dblScheduleQty) AS dblAppliedQty FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
--LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
--INNER JOIN tblSCTicketContractUsed SCC ON SCT.intTicketId = SCC.intTicketId AND SCC.intContractDetailId = SCT.intContractId AND SCC.intEntityId = SCT.intEntityId
--WHERE CTH.intPricingTypeId = 1 AND SCD.intDeliverySheetId = @intDeliverySheetId
--AND SCT.intTicketId = @intTicketId AND SCT.strDistributionOption = 'CNT'), 0)


----For cash contract
--UPDATE #temp SET Cash = 
--ISNULL((SELECT SUM(CTD.dblQuantity - CTD.dblBalance) AS dblAppliedQty FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
--LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
--WHERE CTH.intPricingTypeId = 5 AND SCT.strDistributionOption = 'CNT'
--AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

----For storage
--UPDATE #temp SET Storage = 
--ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId
--WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
--AND GR.intStorageScheduleTypeId > 0 AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

----For DP contract
--UPDATE #temp SET DP = 
--ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId
--WHERE GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0
--AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

----For basis contract
--UPDATE #temp SET Basis = 
--ISNULL((SELECT SUM(CTD.dblQuantity - CTD.dblBalance) AS dblAppliedQty FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
--LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
--WHERE CTH.intPricingTypeId = 2 AND SCT.strDistributionOption = 'CNT' AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

----For warehouse and grainbank
--UPDATE #temp SET WHGB = 
--ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId
--WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
--AND GR.intStorageScheduleTypeId > 0 AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

----For hold
--UPDATE #temp SET Hold = 
--ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
--LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--WHERE SCT.intStorageScheduleTypeId = -5 AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

--SELECT @intEntityId = SCT.intEntityId, @strName = SCT.strName FROM tblSCDeliverySheet SCD
--LEFT JOIN vyuSCTicketView SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
--WHERE SCD.intDeliverySheetId = @intDeliverySheetId

--update #temp SET EntityId = @intEntityId, EntityName = @strName, SplitPercentage = 100

DELETE FROM #temp

--FOR ticket splits
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT DISTINCT SCS.intCustomerId,EM.strName FROM tblSCTicket SC
INNER JOIN tblSCTicketSplit SCS ON SC.intTicketId = SCS.intTicketId
INNER JOIN tblEMEntity EM ON SCS.intCustomerId = EM.intEntityId 
WHERE SC.intDeliverySheetId = @intDeliverySheetId;

SET @counter = 1

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @intEntityId, @strName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SplitAverage = 
    ISNULL((SELECT AVG(SCS.dblSplitPercent) FROM tblSCDeliverySheet SCD
    LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
    INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
    WHERE SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId), 0)

	--For priced contract
	SET @Contract = 
	ISNULL((SELECT SUM((SCC.dblScheduleQty * @SplitAverage) / 100) AS dblAppliedQty FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
	LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
	INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
	INNER JOIN tblSCTicketContractUsed SCC ON SCS.intTicketId = SCC.intTicketId AND SCC.intContractDetailId = SCT.intContractId AND SCC.intEntityId = SCS.intCustomerId
	WHERE CTH.intPricingTypeId = 1 AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId),0)

	--For cash contract
	SET @Cash = 
	ISNULL((SELECT SUM((SCC.dblScheduleQty * @SplitAverage) / 100) AS dblAppliedQty FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
	LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
	INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
	INNER JOIN tblSCTicketContractUsed SCC ON SCS.intTicketId = SCC.intTicketId AND SCC.intContractDetailId = SCT.intContractId AND SCC.intEntityId = SCS.intCustomerId
	WHERE CTH.intPricingTypeId = 5 AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId), 0)

	--For storage
	SET @Storage = 
	ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCS.intStorageScheduleTypeId
	WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
	AND SCS.intStorageScheduleTypeId > 0 AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId), 0)

	--For DP contract
	SET @DP = 
	ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCS.intStorageScheduleTypeId
	WHERE GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0
	AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId), 0)

	--For basis contract
	SET @Basis = 
	ISNULL((SELECT SUM((SCC.dblScheduleQty * @SplitAverage) / 100) AS dblAppliedQty FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
	LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
	INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
	INNER JOIN tblSCTicketContractUsed SCC ON SCS.intTicketId = SCC.intTicketId AND SCC.intContractDetailId = SCT.intContractId AND SCC.intEntityId = SCS.intCustomerId
	WHERE CTH.intPricingTypeId = 2  AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId), 0)

	--For warehouse and grainbank
	SET @WHGB = 
	ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	INNER JOIN tblSCTicketSplit SCS ON SCT.intTicketId = SCS.intTicketId
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCS.intStorageScheduleTypeId
	WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
	AND SCS.intStorageScheduleTypeId > 0 AND SCD.intDeliverySheetId = @intDeliverySheetId AND SCS.intCustomerId = @intEntityId), 0)

	--For hold
	SET @Hold = 
	ISNULL((SELECT SUM((SCT.dblNetUnits * @SplitAverage) / 100) FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	WHERE SCT.intStorageScheduleTypeId = -5 OR SCT.strDistributionOption = 'HLD' 
	AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

	INSERT INTO #temp (Id, Contract, Cash, Storage, DP, Basis, WHGB, Hold) 
	VALUES(@counter, @Contract, @Cash, @Storage, @DP, @Basis, @WHGB, @Hold)

	update #temp SET EntityId = @intEntityId, EntityName = @strName, SplitPercentage = @SplitAverage WHERE Id = @counter

	SET @counter = @counter+1

	FETCH NEXT FROM intListCursor INTO @intEntityId, @strName;
END;

CLOSE intListCursor;
DEALLOCATE intListCursor;


ALTER TABLE #temp
ADD intDeliverySheetId INT

UPDATE #temp SET intDeliverySheetId = @intDeliverySheetId

SELECT * FROM #temp
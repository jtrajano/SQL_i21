CREATE PROCEDURE [dbo].[uspSCDeliverySheetSummary]
	@intDeliverySheetId AS INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF OBJECT_ID (N'tempdb.dbo.#tblSCDeliverySheetSummary') IS NOT NULL
   DROP TABLE #temp

DECLARE @temp TABLE (fields NVARCHAR(50))
INSERT INTO @temp (fields)
VALUES ('Id') ,('Contract') ,('Cash') ,('Storage') ,('DP') ,('Basis'),('WHGB') ,('Hold')

SELECT *
INTO #temp
FROM (
    SELECT fields, a = CAST(NULL AS NUMERIC(38,6)) 
    FROM @temp
) src
PIVOT 
(
    MAX(a) 
    FOR fields IN (Id, Contract, Cash, Storage, DP, Basis, WHGB, Hold)
) unpvt

ALTER TABLE #temp
DROP COLUMN Id

ALTER TABLE #temp
ADD Id INT

UPDATE #temp SET Id = 1
--For priced contract
UPDATE #temp SET Contract = 
(SELECT SUM(CTD.dblQuantity - CTD.dblBalance) AS dblAppliedQty FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
WHERE CTH.intPricingTypeId = 1 AND SCD.intDeliverySheetId = @intDeliverySheetId)


--For cash contract
UPDATE #temp SET Cash = 
ISNULL((SELECT SUM(CTD.dblQuantity - CTD.dblBalance) AS dblAppliedQty FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
WHERE CTH.intPricingTypeId = 5 AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

--For storage
UPDATE #temp SET Storage = 
ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId
WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
AND GR.intStorageScheduleTypeId > 0 AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

--For DP contract
UPDATE #temp SET DP = 
ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId
WHERE GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0 AND GR.intStorageScheduleTypeId > 0
AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

--For basis contract
UPDATE #temp SET Basis = 
ISNULL((SELECT SUM(CTD.dblQuantity - CTD.dblBalance) AS dblAppliedQty FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
WHERE CTH.intPricingTypeId = 2  AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

--For warehouse and grainbank
UPDATE #temp SET WHGB = 
ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId
WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
AND GR.intStorageScheduleTypeId > 0 AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

--For hold
UPDATE #temp SET Hold = 
ISNULL((SELECT SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
WHERE SCT.intStorageScheduleTypeId = -5 OR SCT.strDistributionOption = 'HLD' AND SCD.intDeliverySheetId = @intDeliverySheetId), 0)

ALTER TABLE #temp
ADD intDeliverySheetId INT

UPDATE #temp SET intDeliverySheetId = @intDeliverySheetId

SELECT * FROM #temp
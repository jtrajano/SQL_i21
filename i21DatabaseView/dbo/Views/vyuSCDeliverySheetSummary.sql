CREATE VIEW vyuSCDeliverySheetSummary
AS
SELECT
	intDeliverySheetSplitId
    ,SDS.intDeliverySheetId
    ,SDS.intEntityId
    ,SDS.dblSplitPercent
    ,SDS.intStorageScheduleTypeId
    ,SDS.strDistributionOption
    ,SDS.intStorageScheduleRuleId
    ,strEntityName = EM.strName
    ,GR.strStorageTypeDescription
    ,GRSR.strScheduleId
    ,GRSR.strScheduleDescription
	,SDS.intConcurrencyId
	,Contract = ISNULL(CT.Contract,0)
	,Cash =ISNULL(CTC.Cash,0)
	,Storage =ISNULL(GRStorage.Storage,0)
	,DP =ISNULL(DPStorage.DP,0)
	,Basis =ISNULL(CTBasis.Basis,0)
	,WHGB =ISNULL(WHGBStorage.WHGB,0)
	,Hold = 0.00
FROM tblSCDeliverySheetSplit SDS
INNER JOIN tblSCDeliverySheet DS ON DS.intDeliverySheetId = SDS.intDeliverySheetId
INNER JOIN tblEMEntity EM ON EM.intEntityId = SDS.intEntityId
INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SDS.intStorageScheduleTypeId
LEFT JOIN tblGRStorageScheduleRule GRSR ON GRSR.intStorageScheduleRuleId = SDS.intStorageScheduleRuleId
OUTER APPLY(
	SELECT SUM(IRI.dblOpenReceive) AS Contract FROM tblICInventoryReceipt IR
	INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
	WHERE IR.intEntityVendorId = SDS.intEntityId AND IRI.intLineNo > 0 
	AND IRI.intOwnershipType = 1 AND IRI.intItemId = DS.intItemId
	AND IRI.intSourceId = SDS.intDeliverySheetId
	AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 1
)CT 
OUTER APPLY(
	SELECT SUM(IRI.dblOpenReceive) AS Cash FROM tblICInventoryReceipt IR
	INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
	WHERE IR.intEntityVendorId = SDS.intEntityId AND IRI.intLineNo > 0 
	AND IRI.intOwnershipType = 1 AND IRI.intItemId = DS.intItemId
	AND IRI.intSourceId = SDS.intDeliverySheetId
	AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 6
)CTC 
OUTER APPLY(
	SELECT dblOriginalBalance AS Storage FROM tblGRCustomerStorage GRS
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRS.intStorageTypeId AND GR.intStorageScheduleTypeId > 0
	WHERE GR.ysnReceiptedStorage = 0 AND GR.ysnDPOwnedType = 0 AND GR.ysnGrainBankType = 0 AND GR.ysnCustomerStorage = 0
	AND GRS.intDeliverySheetId = SDS.intDeliverySheetId AND GRS.intEntityId = SDS.intEntityId
	AND GRS.intItemId = DS.intItemId AND GR.intStorageScheduleTypeId = SDS.intStorageScheduleTypeId
	AND GRS.ysnTransferStorage = 0
)GRStorage
OUTER APPLY(
	SELECT dblOriginalBalance AS DP FROM tblGRCustomerStorage GRS
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRS.intStorageTypeId AND GR.intStorageScheduleTypeId > 0
	WHERE GRS.intEntityId = SDS.intEntityId AND GRS.intItemId = DS.intItemId
	AND GR.ysnDPOwnedType = 1 AND GR.ysnCustomerStorage = 0
	AND GRS.intDeliverySheetId = SDS.intDeliverySheetId 
	AND GR.intStorageScheduleTypeId = SDS.intStorageScheduleTypeId
	AND GRS.ysnTransferStorage = 0
)DPStorage
OUTER APPLY(
	SELECT SUM(IRI.dblOpenReceive) AS Basis FROM tblICInventoryReceipt IR
	INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	INNER JOIN vyuCTContractDetailView CTD ON IRI.intLineNo = CTD.intContractDetailId
	WHERE IR.intEntityVendorId = SDS.intEntityId AND IRI.intLineNo > 0 
	AND IRI.intOwnershipType = 1 AND IRI.intItemId = DS.intItemId
	AND IRI.intSourceId = DS.intDeliverySheetId
	AND IR.intSourceType = 5 AND CTD.intPricingTypeId = 2
)CTBasis
OUTER APPLY(
	SELECT dblOriginalBalance AS WHGB FROM tblGRCustomerStorage GRS
	INNER JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = GRS.intStorageTypeId AND GR.intStorageScheduleTypeId > 0
	WHERE (GR.ysnReceiptedStorage = 1 OR GR.ysnGrainBankType = 1) AND GR.ysnDPOwnedType = 0 AND GR.ysnCustomerStorage = 0 
	AND GRS.intDeliverySheetId = DS.intDeliverySheetId AND GRS.intEntityId = SDS.intEntityId 
	AND GRS.intItemId = DS.intItemId AND GR.intStorageScheduleTypeId = SDS.intStorageScheduleTypeId
	AND GRS.ysnTransferStorage = 0
)WHGBStorage
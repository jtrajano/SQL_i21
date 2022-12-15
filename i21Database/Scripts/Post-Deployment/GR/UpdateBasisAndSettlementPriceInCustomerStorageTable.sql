PRINT 'BEGIN update of DP storages with no basis and settlement price'
IF EXISTS(
    SELECT TOP 1 1
    FROM tblGRCustomerStorage CS
    INNER JOIN tblGRStorageType ST
        ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
        AND ST.ysnDPOwnedType = 1
    WHERE ISNULL(CS.dblBasis,0) = 0
        AND ISNULL(CS.dblSettlementPrice,0) = 0
)
BEGIN
    -- Update DP storages created from transfer storage
    UPDATE CS
        SET CS.dblSettlementPrice = ISNULL(IT.dblCost, 0)
    FROM tblGRTransferStorage TS
    INNER JOIN tblGRTransferStorageReference TSR
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS
        ON TSR.intToCustomerStorageId = CS.intCustomerStorageId
    INNER JOIN tblGRStorageType ST
        ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
        AND ST.ysnDPOwnedType = 1
    OUTER APPLY (
        SELECT TOP 1 IT.dblCost FROM tblICInventoryTransaction IT
        WHERE TS.intTransferStorageId = IT.intTransactionId
        AND IT.intTransactionTypeId = 56 -- Transfer storage
    ) IT
    WHERE ISNULL(CS.dblSettlementPrice, 0) = 0
    AND ISNULL(CS.dblBasis, 0) = 0
    AND IT.dblCost IS NOT NULL;

    -- Update DP storages created from scale ticket
    UPDATE CS
        SET CS.dblSettlementPrice = ISNULL(IRI.dblUnitCost, 0)
    FROM tblSCTicket SC
    INNER JOIN (
        tblICInventoryReceipt IR
        INNER JOIN tblICInventoryReceiptItem IRI
        ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
        AND IR.intSourceType = 1 --Scale Ticket
    ) ON IRI.intSourceId = SC.intTicketId
    INNER JOIN tblGRStorageHistory SH
        ON SH.intInventoryReceiptId = IR.intInventoryReceiptId
    INNER JOIN tblGRCustomerStorage CS
        ON SH.intCustomerStorageId = CS.intCustomerStorageId
    INNER JOIN tblGRStorageType ST
        ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
        AND ST.ysnDPOwnedType = 1
    WHERE ISNULL(CS.dblBasis, 0) = 0
    AND ISNULL(CS.dblSettlementPrice, 0) = 0

END
PRINT 'END update of DP storages with no basis and settlement price'
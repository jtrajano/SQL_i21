CREATE VIEW [dbo].[vyuGRBasisSettleStorage]
AS 

SELECT 
    CS.intCustomerStorageId
    ,CS.intEntityId
    ,CH.intContractHeaderId
    ,CH.strContractNumber
    ,CD.intContractDetailId
    ,CD.intContractSeq
    ,CD.intItemId
    ,CS.strStorageTicketNumber
    ,CS.intTicketId
    ,CH.intCommodityId
    ,CS.dtmDeliveryDate
    ,CS.intShipFromLocationId
    ,CS.intItemUOMId
    ,CS.intStorageLocationId
    ,CS.intCompanyLocationSubLocationId
    ,CS.intCurrencyId
    ,dblGross			= SC.dblUnits
    ,dblDiscountAmount	= SC.dblUnits * CS.dblDiscountsDue
    ,dblChargeAmount	= (SC.dblUnits / SS.dblSelectedUnits) * SS.dblStorageDue
FROM tblGRSettleContract SC
INNER JOIN tblCTContractDetail CD
    ON CD.intContractDetailId = SC.intContractDetailId
INNER JOIN tblCTContractHeader CH
    ON CH.intContractHeaderId = CD.intContractHeaderId
INNER JOIN tblGRSettleStorage SS
    ON SS.intSettleStorageId = SC.intSettleStorageId
        AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN tblGRSettleStorageTicket SST
    ON SST.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = SST.intCustomerStorageId
WHERE CD.intPricingTypeId = 2
    AND SC.dblUnits > 0

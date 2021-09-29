CREATE VIEW [dbo].[vyuSCDirectAPClearing]
AS 

    ----DIRECT TICKET
        ----SPOT
        SELECT
            strMark = '10'
            -- original select
            ,intEntityVendorId = SC.intEntityId
            ,dtmDate = SC.dtmTicketDateTime
            ,SC.strTicketNumber
            ,intTicketId = SC.intTicketId
            ,intBillId = NULL
            ,strBillId = NULL
            ,intBillDetailId = NULL
            ,intScalTicketId = SC.intTicketId
            ,SC.intItemId
            ,intItemUOMId = SC.intItemUOMIdTo
            ,strUOM = ICUnitOfMeasure.strUnitMeasure
            ,dblVoucherTotal = 0.0
            ,dblVoucherQty = 0.0
            ,dblReceiptTotal = ROUND((SCS.dblQty * (ISNULL(SCS.dblUnitBasis,0) + ISNULL(SCS.dblUnitFuture,0))),2)	
            ,dblReceiptQty = SCS.dblQty
            ,intLocationId = SC.intProcessingLocationId
            ,compLoc.strLocationName
            ,CAST(1 AS BIT) ysnAllowVoucher
            ,APClearing.intAccountId
            ,APClearing.strAccountId
        FROM tblSCTicket SC
        INNER JOIN tblSCTicketSpotUsed SCS
            ON SC.intTicketId = SCS.intTicketId
        INNER JOIN tblSMCompanyLocation compLoc
            ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
        OUTER APPLY( 
            SELECT TOP 1
            intAccountId
            , strAccountId
            FROM tblGLAccount
            WHERE intAccountId = dbo.fnGetItemGLAccount(SC.intItemId, SC.intProcessingLocationId, 'AP Clearing')) APClearing
        INNER JOIN tblICItemUOM ICUOM
            ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
        INNER JOIN tblICUnitMeasure ICUnitOfMeasure
            ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
        WHERE SC.intTicketType = 6
            AND SC.intTicketTypeId = 8
            AND SC.strTicketStatus = 'C'
        
        UNION
        ----CONTRACT priced
        SELECT
            strMark = '10'
            -- original select
            ,intEntityVendorId = SC.intEntityId
            ,dtmDate = SC.dtmTicketDateTime
            ,SC.strTicketNumber
            ,intTicketId = SC.intTicketId
            ,intBillId = NULL
            ,strBillId = NULL
            ,intBillDetailId = NULL
            ,intScalTicketId = SC.intTicketId
            ,SC.intItemId
            ,intItemUOMId = SC.intItemUOMIdTo
            ,strUOM = ICUnitOfMeasure.strUnitMeasure
            ,dblVoucherTotal = 0.0
            ,dblVoucherQty = 0.0
            ,dblReceiptTotal = ROUND((SCC.dblScheduleQty * (ISNULL(CTD.dblBasis,0) + ISNULL(CTD.dblFutures,0))),2)	
            ,dblReceiptQty = SCC.dblScheduleQty
            ,intLocationId = SC.intProcessingLocationId
            ,compLoc.strLocationName
            ,CAST(1 AS BIT) ysnAllowVoucher
            ,APClearing.intAccountId
            ,APClearing.strAccountId
        FROM tblSCTicket SC
        INNER JOIN tblSCTicketContractUsed SCC
            ON SC.intTicketId = SCC.intTicketId
        INNER JOIN tblSMCompanyLocation compLoc
            ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
        OUTER APPLY( 
            SELECT TOP 1
            intAccountId
            , strAccountId
            FROM tblGLAccount
            WHERE intAccountId = dbo.fnGetItemGLAccount(SC.intItemId, SC.intProcessingLocationId, 'AP Clearing')) APClearing
        INNER JOIN tblICItemUOM ICUOM
            ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
        INNER JOIN tblICUnitMeasure ICUnitOfMeasure
            ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
        INNER JOIN tblCTContractDetail CTD
            ON SCC.intContractDetailId = CTD.intContractDetailId
        INNER JOIN tblCTContractHeader CTH
            ON CTD.intContractHeaderId = CTH.intContractHeaderId
        WHERE SC.intTicketType = 6
            AND SC.intTicketTypeId = 8
            AND SC.strTicketStatus = 'C'
            AND CTH.intPricingTypeId = 1

        UNION
        ---LOAD (priced contract)
        SELECT
            strMark = '10'
            -- original select
            ,intEntityVendorId = SC.intEntityId
            ,dtmDate = SC.dtmTicketDateTime
            ,SC.strTicketNumber
            ,intTicketId = SC.intTicketId
            ,intBillId = NULL
            ,strBillId = NULL
            ,intBillDetailId = NULL
            ,intScalTicketId = SC.intTicketId
            ,SC.intItemId
            ,intItemUOMId = SC.intItemUOMIdTo
            ,strUOM = ICUnitOfMeasure.strUnitMeasure
            ,dblVoucherTotal = 0.0
            ,dblVoucherQty = 0.0
            ,dblReceiptTotal = ROUND((SCL.dblQty * LGD.dblUnitPrice),2)	
            ,dblReceiptQty = SCL.dblQty
            ,intLocationId = SC.intProcessingLocationId
            ,compLoc.strLocationName
            ,CAST(1 AS BIT) ysnAllowVoucher
            ,APClearing.intAccountId
            ,APClearing.strAccountId
        FROM tblSCTicket SC
        INNER JOIN tblSCTicketLoadUsed SCL
            ON SC.intTicketId = SCL.intTicketId
        INNER JOIN tblSMCompanyLocation compLoc
            ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
        OUTER APPLY( 
            SELECT TOP 1
            intAccountId
            , strAccountId
            FROM tblGLAccount
            WHERE intAccountId = dbo.fnGetItemGLAccount(SC.intItemId, SC.intProcessingLocationId, 'AP Clearing')) APClearing
        INNER JOIN tblICItemUOM ICUOM
            ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
        INNER JOIN tblICUnitMeasure ICUnitOfMeasure
            ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
        INNER JOIN tblLGLoadDetail LGD
            ON SCL.intLoadDetailId = LGD.intLoadDetailId
        INNER JOIN tblCTContractDetail CTD
            ON LGD.intPContractDetailId = CTD.intContractDetailId
        INNER JOIN tblCTContractHeader CTH
            ON CTD.intContractHeaderId = CTH.intContractHeaderId
        WHERE SC.intTicketType = 6
            AND SC.intTicketTypeId = 8
            AND SC.strTicketStatus = 'C'
            AND CTH.intPricingTypeId = 1

        UNION

    ---DIRECT TICKET VOUCHER
        ----SPOT
        SELECT
            strMark = '10'
            -- original select
            ,intEntityVendorId = SC.intEntityId
            ,dtmDate = SC.dtmTicketDateTime
            ,SC.strTicketNumber
            ,intTicketId = SC.intTicketId
            ,bill.intBillId
            ,bill.strBillId
            ,billDetail.intBillDetailId
            ,intScalTicketId = SC.intTicketId
            ,SC.intItemId
            ,intItemUOMId = SC.intItemUOMIdTo
            ,strUOM = ICUnitOfMeasure.strUnitMeasure
            ,dblVoucherTotal = billDetail.dblTotal
            ,dblVoucherQty = billDetail.dblQtyReceived
            ,0 AS dblReceiptTotal
            ,0 AS dblReceiptQty
            ,intLocationId = SC.intProcessingLocationId
            ,compLoc.strLocationName
            ,CAST(1 AS BIT) ysnAllowVoucher
            ,APClearing.intAccountId
            ,APClearing.strAccountId
        FROM tblSCTicket SC
        INNER JOIN tblSCTicketSpotUsed SCS
            ON SC.intTicketId = SCS.intTicketId
        INNER JOIN tblSCTicketDistributionAllocation SCDA
            ON SCS.intTicketSpotUsedId = SCDA.intSourceId
                AND intSourceType = 4
        INNER JOIN tblSMCompanyLocation compLoc
            ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItemUOM ICUOM
            ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
        INNER JOIN tblICUnitMeasure ICUnitOfMeasure
            ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
        INNER JOIN tblAPBillDetail billDetail
            ON  billDetail.intItemId = SC.intItemId
                AND billDetail.intTicketDistributionAllocationId = SCDA.intTicketDistributionAllocationId
        INNER JOIN tblAPBill bill 
            ON billDetail.intBillId = bill.intBillId
        OUTER APPLY( 
            SELECT TOP 1
            intAccountId
            , strAccountId
            FROM tblGLAccount
            WHERE intAccountId = billDetail.intAccountId) APClearing
        WHERE SC.intTicketType = 6
            AND SC.intTicketTypeId = 8
            AND SC.strTicketStatus = 'C'
        
        UNION
        ----CONTRACT priced
        SELECT
            strMark = '10'
            -- original select
            ,intEntityVendorId = SC.intEntityId
            ,dtmDate = SC.dtmTicketDateTime
            ,SC.strTicketNumber
            ,intTicketId = SC.intTicketId
            ,intBillId = NULL
            ,strBillId = NULL
            ,intBillDetailId = NULL
            ,intScalTicketId = SC.intTicketId
            ,SC.intItemId
            ,intItemUOMId = SC.intItemUOMIdTo
            ,strUOM = ICUnitOfMeasure.strUnitMeasure
            ,dblVoucherTotal = billDetail.dblTotal
            ,dblVoucherQty = billDetail.dblQtyReceived
            ,dblReceiptTotal = 0.0
            ,dblReceiptQty = 0.0
            ,intLocationId = SC.intProcessingLocationId
            ,compLoc.strLocationName
            ,CAST(1 AS BIT) ysnAllowVoucher
            ,APClearing.intAccountId
            ,APClearing.strAccountId
        FROM tblSCTicket SC
        INNER JOIN tblSCTicketContractUsed SCC
            ON SC.intTicketId = SCC.intTicketId
        INNER JOIN tblSMCompanyLocation compLoc
            ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblSCTicketDistributionAllocation SCDA
            ON SCC.intTicketContractUsed = SCDA.intSourceId
                AND intSourceType = 1
        INNER JOIN tblICItemUOM ICUOM
            ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
        INNER JOIN tblICUnitMeasure ICUnitOfMeasure
            ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
        INNER JOIN tblCTContractDetail CTD
            ON SCC.intContractDetailId = CTD.intContractDetailId
        INNER JOIN tblCTContractHeader CTH
            ON CTD.intContractHeaderId = CTH.intContractHeaderId
        INNER JOIN tblAPBillDetail billDetail
            ON  billDetail.intItemId = SC.intItemId
                AND billDetail.intTicketDistributionAllocationId = SCDA.intTicketDistributionAllocationId
        INNER JOIN tblAPBill bill 
            ON billDetail.intBillId = bill.intBillId
        OUTER APPLY( 
            SELECT TOP 1
            intAccountId
            , strAccountId
            FROM tblGLAccount
            WHERE intAccountId = billDetail.intAccountId) APClearing
        WHERE SC.intTicketType = 6
            AND SC.intTicketTypeId = 8
            AND SC.strTicketStatus = 'C'
            AND CTH.intPricingTypeId = 1

        UNION
        ---LOAD (priced contract)
        SELECT
            strMark = '10'
            -- original select
            ,intEntityVendorId = SC.intEntityId
            ,dtmDate = SC.dtmTicketDateTime
            ,SC.strTicketNumber
            ,intTicketId = SC.intTicketId
            ,intBillId = NULL
            ,strBillId = NULL
            ,intBillDetailId = NULL
            ,intScalTicketId = SC.intTicketId
            ,SC.intItemId
            ,intItemUOMId = SC.intItemUOMIdTo
            ,strUOM = ICUnitOfMeasure.strUnitMeasure
            ,dblVoucherTotal = billDetail.dblTotal
            ,dblVoucherQty = billDetail.dblQtyReceived
            ,dblReceiptTotal = 0.0
            ,dblReceiptQty = 0.0
            ,intLocationId = SC.intProcessingLocationId
            ,compLoc.strLocationName
            ,CAST(1 AS BIT) ysnAllowVoucher
            ,APClearing.intAccountId
            ,APClearing.strAccountId
        FROM tblSCTicket SC
        INNER JOIN tblSCTicketLoadUsed SCL
            ON SC.intTicketId = SCL.intTicketId
        INNER JOIN tblSMCompanyLocation compLoc
            ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblSCTicketDistributionAllocation SCDA
            ON SCL.intTicketLoadUsedId = SCDA.intSourceId
                AND intSourceType = 2
        INNER JOIN tblICItemUOM ICUOM
            ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
        INNER JOIN tblICUnitMeasure ICUnitOfMeasure
            ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
        INNER JOIN tblLGLoadDetail LGD
            ON SCL.intLoadDetailId = LGD.intLoadDetailId
        INNER JOIN tblCTContractDetail CTD
            ON LGD.intPContractDetailId = CTD.intContractDetailId
        INNER JOIN tblCTContractHeader CTH
            ON CTD.intContractHeaderId = CTH.intContractHeaderId
        INNER JOIN tblAPBillDetail billDetail
            ON  billDetail.intItemId = SC.intItemId
                AND billDetail.intTicketDistributionAllocationId = SCDA.intTicketDistributionAllocationId
        INNER JOIN tblAPBill bill 
            ON billDetail.intBillId = bill.intBillId
        OUTER APPLY( 
            SELECT TOP 1
            intAccountId
            , strAccountId
            FROM tblGLAccount
            WHERE intAccountId = billDetail.intAccountId) APClearing
        WHERE SC.intTicketType = 6
            AND SC.intTicketTypeId = 8
            AND SC.strTicketStatus = 'C'
            AND CTH.intPricingTypeId = 1

GO

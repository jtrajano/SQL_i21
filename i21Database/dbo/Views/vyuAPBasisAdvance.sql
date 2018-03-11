﻿CREATE VIEW [dbo].[vyuAPBasisAdvance]
AS 

SELECT TOP 100 PERCENT * FROM (
    SELECT 
        CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS intBasisAdvanceId --generate identity without sorting
        ,ticket.intTicketId
        ,entity.strName
        ,entity.intEntityId
        ,ISNULL(customer.dblARBalance,0) AS dblARBalance
        ,split.strSplitNumber AS strSplit
        ,ct.strContractNumber
        ,ct.intContractHeaderId
        ,ctd.intContractDetailId
        ,ctd.intContractSeq
        ,ticket.strTicketNumber 
        ,ticket.dtmTicketDateTime
        ,loc.intPurchaseAdvAccount AS intAccountId
        ,loc.intCompanyLocationId
        ,loc.strLocationName
        ,receipt.intInventoryReceiptId
        ,receiptItem.intInventoryReceiptItemId
        ,receipt.strReceiptNumber
        ,receipt.strBillOfLading
        ,receipt.intShipFromId
        ,receiptItem.intItemId
        ,commodity.intCommodityId
        ,commodity.strDescription
        ,0.00 AS dblFuture
        ,cur.strCurrency
        ,ctd.intCurrencyId
        ,ISNULL(receiptItem.dblOpenReceive,0) AS dblQuantity
        ,(ISNULL(basisFutures.dblPrice, 0) + ISNULL(ctd.dblBasis,0)) * ISNULL(receiptItem.dblOpenReceive,0) AS dblGross
        ,ISNULL(taxes.dblTax,0.00) AS dblTax
        ,0.00 AS dblAdvance
        ,CAST(((
            ((ISNULL(basisFutures.dblPrice, 0) + ISNULL(ctd.dblBasis,0)) * ISNULL(receiptItem.dblOpenReceive,0)) 
            - ISNULL(discounts.dblAmount,0)
            + ISNULL(taxes.dblTax,0.00)) 
            * (ISNULL(basisCommodity.dblPercentage,0.00) / 100))
            - ISNULL(priorAdvances.dblPriorAdvance,0.00) AS DECIMAL(18,2)) AS dblAmountToAdvance
        ,ISNULL(priorAdvances.dblPriorAdvance,0.00) AS dblPriorAdvance
        ,priorAdvances.strBillIds
        ,uom.strUnitMeasure
        ,ISNULL(ctd.dblBasis,0) AS dblUnitBasis
        ,ISNULL(basisFutures.dblPrice, 0) AS dblFuturesPrice
        ,ISNULL(discounts.dblAmount,0) AS dblDiscountAmount
        ,futureMarket.intFutureMarketId
        ,futureMarket.strFutMarketName
        ,futureMonth.intFutureMonthId
        ,futureMonth.strFutureMonth
        ,ISNULL(basisCommodity.dblPercentage,0.00) AS dblPercentage
    FROM tblSCTicket ticket
    INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
        ON ticket.intEntityId = vendor.intEntityId
    INNER JOIN tblSMCompanyLocation loc ON ticket.intProcessingLocationId = loc.intCompanyLocationId
    LEFT JOIN tblARCustomer customer ON ticket.intEntityId = customer.intEntityId
    LEFT JOIN tblEMEntitySplit split ON ticket.intSplitId = split.intSplitId
    -- LEFT JOIN tblSCTicketSplit tcktSPlit ON ticket.intTicketId = tcktSPlit.intTicketId
    --Load basis ticket that is always have receipt or delivered
    INNER JOIN (tblICInventoryReceipt receipt INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)
        ON ticket.intTicketId = receiptItem.intSourceId AND receipt.intSourceType = 1
    INNER JOIN (tblCTContractHeader ct INNER JOIN tblCTContractDetail ctd ON ct.intContractHeaderId =  ctd.intContractHeaderId)
        ON receiptItem.intLineNo = ctd.intContractDetailId
    INNER JOIN tblRKFutureMarket futureMarket ON ctd.intFutureMarketId = futureMarket.intFutureMarketId
    INNER JOIN tblRKFuturesMonth futureMonth ON ctd.intFutureMonthId = futureMonth.intFutureMonthId
    INNER JOIN tblICCommodity commodity ON ticket.intCommodityId = commodity.intCommodityId
    INNER JOIN tblSMCurrency cur ON ctd.intCurrencyId = cur.intCurrencyID
    INNER JOIN (tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId)
        ON itemUOM.intItemId = ticket.intItemId AND itemUOM.ysnStockUnit = 1
    OUTER APPLY (
        SELECT
            SUM(charge.dblAmount) AS dblAmount
        FROM tblQMTicketDiscount tktDiscount
        LEFT JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
        LEFT JOIN tblICInventoryReceiptCharge charge ON dscntCode.intItemId = charge.intChargeId
        WHERE charge.intInventoryReceiptId = receipt.intInventoryReceiptId
        AND tktDiscount.dblGradeReading != 0
        AND tktDiscount.intTicketId = ticket.intTicketId
        AND tktDiscount.strSourceType = 'Scale'
        GROUP BY charge.intInventoryReceiptId
    ) discounts
    OUTER APPLY (
        SELECT
            SUM(itemTax.dblTax) AS dblTax
        FROM tblICInventoryReceiptItem receiptDetail
        INNER JOIN tblICInventoryReceiptItemTax itemTax ON receiptDetail.intInventoryReceiptItemId = itemTax.intInventoryReceiptItemId
        WHERE receiptDetail.intInventoryReceiptId = receipt.intInventoryReceiptId
        GROUP BY receiptDetail.intInventoryReceiptId
    ) taxes
    OUTER APPLY (
		SELECT 
			SUM(voucherDetail.dblTotal + dblTax) AS dblPriorAdvance,
			SUBSTRING(
				(SELECT ',' + CAST(voucherDetail2.intBillId AS NVARCHAR)
				FROM tblAPBillDetail voucherDetail2
				WHERE voucherDetail2.intScaleTicketId = ticket.intTicketId
				FOR XML PATH ('')) , 2, 200000) AS strBillIds
		FROM tblAPBillDetail voucherDetail
		WHERE voucherDetail.intScaleTicketId = ticket.intTicketId
    ) priorAdvances
    LEFT JOIN tblAPBasisAdvanceFuture basisFutures 
        ON basisFutures.intFutureMarketId = futureMarket.intFutureMarketId AND basisFutures.intMonthId = futureMonth.intFutureMonthId
    LEFT JOIN tblAPBasisAdvanceCommodity basisCommodity ON basisCommodity.intCommodityId = ticket.intCommodityId
    WHERE ctd.intPricingTypeId = 2
) basisAdvance
ORDER BY intTicketId DESC


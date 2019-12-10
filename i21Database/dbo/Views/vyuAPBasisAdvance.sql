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
        ,ctd.strContractNumber
        ,ctd.intContractHeaderId
        ,ctd.intContractDetailId
        ,ctd.intContractSeq
        ,ticket.strTicketNumber 
        ,ticket.dtmTicketDateTime
        ,loc.intPurchaseAdvAccount AS intAccountId
        ,loc.intCompanyLocationId
        ,loc.strLocationName
        ,ticketTrans.intInventoryReceiptId
        ,ticketTrans.intInventoryReceiptItemId
        ,ticketTrans.strReceiptNumber
        ,ticketTrans.strBillOfLading
        ,ticketTrans.intShipFromId
        ,ticketTrans.intItemId
        ,ticketTrans.intStorageLocationId
        ,ticketTrans.intSubLocationId
        ,commodity.intCommodityId
        ,commodity.strDescription
        ,0.00 AS dblFuture
        ,cur.strCurrency
        ,ctd.intSeqCurrencyId AS intCurrencyId
        ,ticketTrans.intItemUOMId
        ,ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0) AS dblQuantity
        ,(ISNULL(basisFutures.dblPrice, 0) 
                + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0)) 
            * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0)) AS dblGross
        ,ISNULL(taxes.dblTax,0.00) AS dblTax
        ,0.00 AS dblAdvance
        ,CAST(((
                    ((ISNULL(basisFutures.dblPrice, 0) 
                        + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0)) 
                        * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0))) 
                    + ISNULL(ticketTrans.dblDiscountAmount,0)
                    + ISNULL(ticketTrans.dblChargeAmount, 0)
                    + ISNULL(taxes.dblTax,0.00)) 
                    ) AS DECIMAL(18,2)) AS dblNetAdvance
        ,CAST(
            --not selected
            CASE WHEN staging.intBasisAdvanceStagingId IS NULL 
                THEN --IF not selected, show prior advance only
                    ISNULL(priorAdvances.dblTotalPriorAdvance,0) 
                    / 
                    --compute the net base on last price made on the ticket to get the percentage
                    (
                        ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) * ISNULL(priorAdvances.dblContractPrice, 1)
                    )
            ELSE
            --selected
            (
                ISNULL(priorAdvances.dblTotalPriorAdvance,0) --previous advances
                + 
                (
                    --current advance
                    CASE WHEN staging.intBasisAdvanceStagingId IS NULL THEN 0
                    ELSE
                        (CASE WHEN basisFutures.dblPrice = 0 OR basisCommodity.dblPercentage = 0 THEN 0 --if no price selected yet or percentage
                        ELSE
                            CAST(
                                ((((ISNULL(basisFutures.dblPrice, 0) 
                                    + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0)) 
                                    * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0))) 
                                + ISNULL(ticketTrans.dblDiscountAmount,0)
                                + ISNULL(ticketTrans.dblChargeAmount, 0)
                                + ISNULL(taxes.dblTax,0.00)) 
                                - ISNULL(priorAdvances.dblPriorAdvance,0.00)) --subtract first the prior advance to get the percentage
                                * (ISNULL(basisCommodity.dblPercentage,0.00) / 100) 
                            AS DECIMAL(18,2))
                        END)
                    END
                )
            )
            / 
                --net advance
                CASE WHEN staging.intBasisAdvanceStagingId IS NULL 
                    THEN 1 --avoid divide by zero
                ELSE
                    CASE WHEN (ISNULL(basisFutures.dblPrice,0) = 0 OR ISNULL(basisCommodity.dblPercentage,0) = 0)
                                AND ISNULL(priorAdvances.dblContractPrice, 0) != 0
                        THEN --if selected, but did not input yet a future price, use the last price made on the prior advance if not 0
                            CAST(((
                            ((ISNULL(priorAdvances.dblContractPrice, 0)) 
                                * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0))) 
                            + ISNULL(ticketTrans.dblDiscountAmount,0)
                            + ISNULL(ticketTrans.dblChargeAmount, 0)
                            + ISNULL(taxes.dblTax,0.00)) 
                            ) AS DECIMAL(18,2)) 
                    WHEN (ISNULL(basisFutures.dblPrice,0) = 0 OR ISNULL(basisCommodity.dblPercentage,0) = 0)
                            AND ISNULL(priorAdvances.dblContractPrice, 0) = 0
                        THEN
                            CAST(((
                            ((1) 
                                * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0))) 
                            + ISNULL(ticketTrans.dblDiscountAmount,0)
                            + ISNULL(ticketTrans.dblChargeAmount, 0)
                            + ISNULL(taxes.dblTax,0.00)) 
                            ) AS DECIMAL(18,2)) 
                    ELSE
                        CAST(((
                            ((ISNULL(basisFutures.dblPrice, 0) 
                                + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0)) 
                                * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0))) 
                            + ISNULL(ticketTrans.dblDiscountAmount,0)
                            + ISNULL(ticketTrans.dblChargeAmount, 0)
                            + ISNULL(taxes.dblTax,0.00)) 
                            ) AS DECIMAL(18,2))
                    END
                END
            END  * 100
        AS DECIMAL(18,2))
        AS dblTotalAdvance
        ,CASE WHEN staging.intBasisAdvanceStagingId IS NULL OR basisFutures.dblPrice = 0 OR basisCommodity.dblPercentage = 0
                THEN 0
                ELSE CAST(((
                    ((ISNULL(basisFutures.dblPrice, 0) 
                        + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0)) 
                        * (ISNULL(ticket.dblNetUnits,ISNULL(ticketTrans.dblQuantity,0)) - ISNULL(pricedSequence.dblQtyPriced, 0))) 
                    + ISNULL(ticketTrans.dblDiscountAmount,0)
                    + ISNULL(ticketTrans.dblChargeAmount, 0)
                    + ISNULL(taxes.dblTax,0.00)) 
                    - ISNULL(priorAdvances.dblPriorAdvance,0.00))
                    * (ISNULL(basisCommodity.dblPercentage,0.00) / 100)
                    AS DECIMAL(18,2)) END AS dblAmountToAdvance
        ,ISNULL(priorAdvances.dblPriorAdvance,0.00) AS dblPriorAdvance
        ,priorAdvances.strBillIds COLLATE Latin1_General_CI_AS AS strBillIds
        ,uom.strUnitMeasure
        ,ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0) AS dblUnitBasis
        ,CASE WHEN staging.intBasisAdvanceStagingId IS NULL THEN 0 ELSE ISNULL(basisFutures.dblPrice, 0) END AS dblFuturesPrice
        ,ISNULL(ticketTrans.dblDiscountAmount,0) AS dblDiscountAmount
        ,ISNULL(ticketTrans.dblChargeAmount,0) AS dblChargeAmount
        ,futureMarket.intFutureMarketId
        ,futureMarket.strFutMarketName
        ,futureMonth.intFutureMonthId
        ,futureMonth.strFutureMonth
        ,ISNULL(basisCommodity.dblPercentage,0.00) AS dblPercentage
        ,exchangeRates.dblRate AS dblExchangeRate
    FROM tblSCTicket ticket
    INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
        ON ticket.intEntityId = vendor.intEntityId
    INNER JOIN tblSMCompanyLocation loc ON ticket.intProcessingLocationId = loc.intCompanyLocationId
    LEFT JOIN tblARCustomer customer ON ticket.intEntityId = customer.intEntityId
    LEFT JOIN tblEMEntitySplit split ON ticket.intSplitId = split.intSplitId
    -- LEFT JOIN tblSCTicketSplit tcktSPlit ON ticket.intTicketId = tcktSPlit.intTicketId
    --Load basis ticket that is always have receipt or delivered
    INNER JOIN 
    (
        SELECT
            receiptItem.intLineNo AS intContractDetailId,
            receiptItem.intSourceId AS intTicketId,
            receiptCharge.dblAmount AS dblChargeAmount,
            discounts.dblAmount AS dblDiscountAmount,
            receiptItem.dblOpenReceive AS dblQuantity,
            receiptItem.intInventoryReceiptItemId,
            receipt.intInventoryReceiptId,
            receipt.strReceiptNumber,
            receipt.strBillOfLading,
            receipt.intShipFromId,
            receiptItem.intItemId,
            receipt.dtmReceiptDate,
            receiptItem.intTaxGroupId,
            receipt.intFreightTermId,
            CASE WHEN receiptItem.intWeightUOMId > 0 THEN receiptItem.intWeightUOMId ELSE receiptItem.intUnitMeasureId END AS intItemUOMId,
            receipt.intCurrencyId,
            receiptItem.intStorageLocationId,
            receiptItem.intSubLocationId,
            receiptItem.intForexRateTypeId,
            receiptItem.dblForexRate
        FROM tblICInventoryReceipt receipt 
        INNER JOIN tblICInventoryReceiptItem receiptItem 
            ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
        OUTER APPLY
        (
            SELECT
                    (ISNULL(charge.dblAmount,0) * (CASE WHEN charge.ysnPrice = 1 THEN -1 ELSE 1 END))
                    + (
                        ISNULL((CASE WHEN ISNULL(charge.intEntityVendorId, receipt.intEntityVendorId) != receipt.intEntityVendorId
                                    THEN (CASE WHEN charge.ysnPrice = 1 AND chargeTax.ysnCheckoffTax = 0 THEN -charge.dblTax --negate, inventory receipt will bring postive tax
                                                WHEN chargeTax.ysnCheckoffTax = 0 THEN ABS(charge.dblTax) ELSE charge.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
                                    ELSE (CASE WHEN charge.ysnPrice = 1 AND chargeTax.ysnCheckoffTax = 1 THEN charge.dblTax * -1 ELSE charge.dblTax END ) END),0)
                    )
                AS dblAmount
            FROM tblICInventoryReceiptCharge charge
            OUTER APPLY
            (
                SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
                WHERE IRCT.intInventoryReceiptChargeId = charge.intInventoryReceiptChargeId
            )  chargeTax
            WHERE charge.intInventoryReceiptId = receipt.intInventoryReceiptId
            AND charge.intChargeId NOT IN (
                SELECT
                    dscntCode.intItemId
                FROM tblQMTicketDiscount tktDiscount
                INNER JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
                WHERE tktDiscount.intTicketId = receiptItem.intSourceId
            )
        ) receiptCharge
        OUTER APPLY
        (
            SELECT
                SUM(CASE WHEN charge.ysnPrice > 0 THEN -charge.dblAmount ELSE charge.dblAmount END) AS dblAmount
            FROM tblQMTicketDiscount tktDiscount
            INNER JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
            INNER JOIN tblICInventoryReceiptCharge charge ON dscntCode.intItemId = charge.intChargeId
            WHERE charge.intInventoryReceiptId = receipt.intInventoryReceiptId
            AND tktDiscount.dblGradeReading != 0
            AND tktDiscount.intTicketId = receiptItem.intSourceId
            AND tktDiscount.strSourceType = 'Scale'
            GROUP BY charge.intInventoryReceiptId
        ) discounts
        WHERE 
            receipt.intSourceType = 1 
        AND receiptItem.intLineNo > 0
        UNION ALL
        SELECT
            intContractDetailId,
            intTicketId,
            dblChargeAmount,
            dblDiscountAmount,
            dblGross,
            NULL,
            NULL,
            NULL,
            NULL,
            intShipFromLocationId,
            intItemId,
            dtmDeliveryDate,
            NULL,
            NULL,
            intItemUOMId,
            intCurrencyId,
            intStorageLocationId,
            intCompanyLocationSubLocationId,
            NULL,
            NULL
        FROM vyuGRBasisSettleStorage settleStorage
    ) ticketTrans
    ON ticketTrans.intTicketId = ticket.intTicketId
    -- INNER JOIN (tblCTContractHeader ct INNER JOIN tblCTContractDetail ctd ON ct.intContractHeaderId =  ctd.intContractHeaderId)
    --     ON receiptItem.intLineNo = ctd.intContractDetailId
    INNER JOIN vyuCTContractDetailView ctd ON ticketTrans.intContractDetailId = ctd.intContractDetailId
    INNER JOIN tblRKFutureMarket futureMarket ON ctd.intFutureMarketId = futureMarket.intFutureMarketId
    INNER JOIN tblRKFuturesMonth futureMonth ON ctd.intFutureMonthId = futureMonth.intFutureMonthId
    INNER JOIN tblICCommodity commodity ON ticket.intCommodityId = commodity.intCommodityId
    INNER JOIN tblSMCurrency cur ON ctd.intSeqCurrencyId = cur.intCurrencyID
    INNER JOIN (tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId)
        ON itemUOM.intItemId = ticket.intItemId AND itemUOM.ysnStockUnit = 1
    -- OUTER APPLY (
    --     SELECT
    --         SUM(CASE WHEN charge.ysnPrice > 0 THEN -charge.dblAmount ELSE charge.dblAmount END) AS dblAmount
    --     FROM tblQMTicketDiscount tktDiscount
    --     INNER JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
    --     INNER JOIN tblICInventoryReceiptCharge charge ON dscntCode.intItemId = charge.intChargeId
    --     WHERE charge.intInventoryReceiptId = receipt.intInventoryReceiptId
    --     AND tktDiscount.dblGradeReading != 0
    --     AND tktDiscount.intTicketId = ticket.intTicketId
    --     AND tktDiscount.strSourceType = 'Scale'
    --     GROUP BY charge.intInventoryReceiptId
    -- ) discounts
    --  OUTER APPLY (
	-- 	SELECT SUM(dblAmount) AS dblAmount
	-- 	FROM (
	-- 		SELECT
	-- 			 (ISNULL(charge.dblAmount,0) * (CASE WHEN charge.ysnPrice = 1 THEN -1 ELSE 1 END))
	-- 				+ (
	-- 					ISNULL((CASE WHEN ISNULL(charge.intEntityVendorId, receipt.intEntityVendorId) != receipt.intEntityVendorId
	-- 								THEN (CASE WHEN charge.ysnPrice = 1 AND chargeTax.ysnCheckoffTax = 0 THEN -charge.dblTax --negate, inventory receipt will bring postive tax
	-- 										   WHEN chargeTax.ysnCheckoffTax = 0 THEN ABS(charge.dblTax) ELSE charge.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
	-- 								ELSE (CASE WHEN charge.ysnPrice = 1 AND chargeTax.ysnCheckoffTax = 1 THEN charge.dblTax * -1 ELSE charge.dblTax END ) END),0)
	-- 				)
	-- 			AS dblAmount
	-- 		FROM tblICInventoryReceiptCharge charge
	-- 		OUTER APPLY
	-- 		(
	-- 			SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
	-- 			WHERE IRCT.intInventoryReceiptChargeId = charge.intInventoryReceiptChargeId
	-- 		)  chargeTax
	-- 		WHERE charge.intInventoryReceiptId = receipt.intInventoryReceiptId
	-- 		AND charge.intChargeId NOT IN (
	-- 			SELECT
	-- 				dscntCode.intItemId
	-- 			FROM tblQMTicketDiscount tktDiscount
	-- 			INNER JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
	-- 			WHERE tktDiscount.intTicketId = ticket.intTicketId
	-- 		)
	-- 	) chargesAmount
    -- ) charges
    OUTER APPLY (
		SELECT 
			SUM(voucherDetail.dblTotal + voucherDetail.dblTax) AS dblPriorAdvance,
            --get the actual percentage made base on the remaining amount to pay
            SUM(ISNULL(voucherDetail.dblTotal,0)) AS dblTotalPriorAdvance,
            -- MIN(lastPrice.dblContractPrice) AS dblContractPrice,
            AVG(CASE WHEN voucherDetail.dblContractCost > 0 AND voucherDetail.dblBasis = 0
                     THEN --older version we use the contract cost to fill futures + basis
                         voucherDetail.dblContractCost
                     ELSE
                         voucherDetail.dblBasis + voucherDetail.dblFutures
                     END) AS dblContractPrice, 
			SUBSTRING(
				(SELECT ',' + CAST(voucherDetail2.intBillId AS NVARCHAR)
				FROM tblAPBillDetail voucherDetail2
                INNER JOIN tblAPBill voucher2 ON voucher2.intBillId = voucherDetail2.intBillId
				WHERE voucherDetail2.intScaleTicketId = ticket.intTicketId
                AND voucher2.intTransactionType = 13
				FOR XML PATH ('')) , 2, 200000) AS strBillIds
		FROM tblAPBillDetail voucherDetail
        INNER JOIN tblAPBill voucher ON voucher.intBillId = voucherDetail.intBillId
        INNER JOIN (tblAPPaymentDetail payDetail INNER JOIN tblAPPayment pay ON payDetail.intPaymentId = pay.intPaymentId AND pay.ysnPosted = 1) --prior advances should have payment
            ON payDetail.intBillId = voucher.intBillId
        LEFT JOIN tblAPBasisAdvanceCommodity commodity ON commodity.intCommodityId = ticket.intCommodityId
		WHERE voucherDetail.intScaleTicketId = ticket.intTicketId
        AND voucher.intTransactionType = 13
    ) priorAdvances
    OUTER APPLY (
        SELECT
            SUM(voucherDetail.dblQtyReceived) AS dblQtyPriced
        FROM tblAPBill voucher
        INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
        WHERE voucherDetail.intContractDetailId = ctd.intContractDetailId --AND voucherDetail.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
        AND voucherDetail.intItemId = ctd.intItemId
        AND voucherDetail.intScaleTicketId = ticket.intTicketId
        AND voucher.intTransactionType = 1
    ) pricedSequence
    OUTER APPLY (
		SELECT TOP 1
			exchangeRateDetail.dblRate
		FROM tblSMCurrencyExchangeRate exchangeRate
		INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
        OUTER APPLY (
            SELECT TOP 1
			    intAccountsPayableRateTypeId
		    FROM tblSMMultiCurrency
        ) rateType
        OUTER APPLY (
            SELECT TOP 1 
                intDefaultCurrencyId 
            FROM tblSMCompanyPreference
        ) mainCurrency
		WHERE exchangeRateDetail.intRateTypeId = rateType.intAccountsPayableRateTypeId
		AND exchangeRate.intFromCurrencyId = ctd.intSeqCurrencyId AND exchangeRate.intToCurrencyId = mainCurrency.intDefaultCurrencyId
		AND exchangeRateDetail.dtmValidFromDate <= GETDATE()
		ORDER BY exchangeRateDetail.dtmValidFromDate DESC
    ) exchangeRates
    LEFT JOIN tblAPBasisAdvanceFuture basisFutures 
        ON basisFutures.intFutureMarketId = futureMarket.intFutureMarketId AND basisFutures.intMonthId = futureMonth.intFutureMonthId
    LEFT JOIN tblAPBasisAdvanceCommodity basisCommodity ON basisCommodity.intCommodityId = ticket.intCommodityId
    LEFT JOIN tblAPBasisAdvanceStaging staging ON staging.intContractDetailId = ctd.intContractDetailId
                                    AND staging.intTicketId = ticket.intTicketId
     OUTER APPLY (
        SELECT
            SUM(taxData.dblTax) AS dblTax
        FROM dbo.fnGetItemTaxComputationForVendor(
            ticketTrans.intItemId
            ,ticket.intEntityId
            ,ticketTrans.dtmReceiptDate
            ,(ISNULL(basisFutures.dblPrice, 0) 
                    + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ctd.intSeqBasisUOMId, itemUOM.intItemUOMId, ctd.dblSeqBasis),0))
            ,ticketTrans.dblQuantity
            ,ticketTrans.intTaxGroupId
            ,ticket.intProcessingLocationId
            ,ticketTrans.intShipFromId
            ,1
			,0
            ,ticketTrans.intFreightTermId
            ,0
            ,ticketTrans.intItemUOMId
            ,ticketTrans.intCurrencyId
            ,ticketTrans.intForexRateTypeId
            ,ticketTrans.dblForexRate
        ) taxData
    ) taxes
    WHERE ctd.intPricingTypeId = 2
) basisAdvance
WHERE dblQuantity != 0 --do not include unpriced qty is 0
ORDER BY intTicketId DESC

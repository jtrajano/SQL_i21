CREATE PROCEDURE [dbo].[uspAPDiagnoseGrainClearing]
	@account INT = NULL,
	@dateStart DATETIME = NULL,
	@dateEnd DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @start DATETIME = CASE WHEN @dateStart IS NOT NULL THEN @dateStart ELSE '1/1/1900' END
DECLARE @end DATETIME = CASE WHEN @dateEnd IS NOT NULL THEN @dateEnd ELSE GETDATE() END

DECLARE @grainGLTotal TABLE(strSettleStorage NVARCHAR(50), dblTotal DECIMAL(18,2));
;WITH grainGLTotal (
    strSettleStorage,
    dblTotal
) AS (
    SELECT TOP 100 PERCENT
        strTransactionId,
        SUM(dblTotal) AS dblTotal
    FROM
    (    
        SELECT
            strTransactionId,
            SUM(dblCredit - dblDebit) AS dblTotal
        FROM tblGLDetail A
        INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
        WHERE 
            A.ysnIsUnposted = 0
        AND B.intAccountCategoryId = 45
        AND A.strModuleName = 'Inventory'
        AND A.strTransactionType = 'Storage Settlement'
        AND DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN '1/1/1900' AND '7/31/2019'
        GROUP BY A.strTransactionId
    ) tmp
    GROUP BY strTransactionId
    ORDER BY strTransactionId
)

INSERT INTO @grainGLTotal
SELECT * FROM grainGLTotal

DECLARE @grainTotal TABLE(strSettleStorage NVARCHAR(50), dblTotal DECIMAL(18,2));
;WITH grainTotal (
    strSettleStorage,
    dblTotal
) AS (
    SELECT
        strTransactionNumber,
        SUM(dblSettleStorageAmount) AS dblTotal
    FROM
    (
    SELECT 
        SS.strStorageTicket AS strTransactionNumber
        --,CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2)) AS dblSettleStorageAmount
        --,CASE WHEN SS.dblUnpaidUnits != 0 
        --	THEN (
        --		CASE WHEN ST.intSettleContractId IS NOT NULL THEN ST.dblUnits * ST.dblPrice
        --		ELSE SS.dblNetSettlement
        --		END
        --	)
        --	ELSE CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2))
        --	END AS dblSettleStorageAmount
        --,SS.dblSettleUnits AS dblSettleStorageQty
        ,GD.dblCredit - GD.dblDebit AS dblSettleStorageAmount
        --,CAST(CASE WHEN SS.dblUnpaidUnits != 0 THEN SS.dblUnpaidUnits ELSE SS.dblSettleUnits END AS DECIMAL(18,2)) AS dblSettleStorageQty
        -- ,CAST(GD.dblCreditUnit - GD.dblDebitUnit AS DECIMAL(18,2)) AS dblSettleStorageQty
    FROM tblGRCustomerStorage CS
    INNER JOIN tblICItem IM
        ON IM.intItemId = CS.intItemId
    INNER JOIN tblICCommodity CO
        ON CO.intCommodityId = CS.intCommodityId
    INNER JOIN tblSMCompanyLocation CL
        ON CL.intCompanyLocationId = CS.intCompanyLocationId	
    INNER JOIN tblGRSettleStorageTicket SST
        ON SST.intCustomerStorageId = CS.intCustomerStorageId
    INNER JOIN tblGRSettleStorage SS
        ON SST.intSettleStorageId = SS.intSettleStorageId
            AND SS.intParentSettleStorageId IS NOT NULL
            --AND SS.dblSettleUnits = 0 --OPEN STORAGE ONLY , THIS IS THE ONLY SETTLE STORAGE THAT DO NOT CREATE VOUCHER IMMEDIATELEY
            AND SS.dblSpotUnits = 0
    INNER JOIN tblGLDetail GD
        ON GD.strTransactionId = SS.strStorageTicket
            AND GD.intTransactionId = SS.intSettleStorageId
            AND GD.strTransactionType = 'Storage Settlement'
            AND GD.ysnIsUnposted = 0
            AND GD.strDescription LIKE '%Item: ' + IM.strItemNo + '%'
            --AND GD.strCode = 'STR' --get only the AP Clearing for item
    INNER JOIN vyuGLAccountDetail AD
	    ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
    UNION ALL --CHARGES
    SELECT 
        SS.strStorageTicket
        ,CAST(-SS.dblStorageDue AS DECIMAL(18,2)) AS dblSettleStorageAmount
    FROM tblGRCustomerStorage CS
    INNER JOIN tblICCommodity CO
        ON CO.intCommodityId = CS.intCommodityId
    INNER JOIN tblICItem IM
        ON IM.strType = 'Other Charge' 
            AND IM.strCostType = 'Storage Charge' 
            AND (IM.intCommodityId = CO.intCommodityId OR IM.intCommodityId IS NULL)
    INNER JOIN tblSMCompanyLocation CL
        ON CL.intCompanyLocationId = CS.intCompanyLocationId
    INNER JOIN tblGRSettleStorageTicket SST
        ON SST.intCustomerStorageId = CS.intCustomerStorageId
    INNER JOIN tblGRSettleStorage SS
        ON SST.intSettleStorageId = SS.intSettleStorageId
            AND SS.intParentSettleStorageId IS NOT NULL
            AND SS.dblSpotUnits = 0
    UNION ALL
    SELECT 
        SS.strStorageTicket
        --,CAST(CASE
        --	WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 
        --	THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END) * -1)
        --	WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END)) *  -1
        --	WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount)
        --	WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * -1)
        --END * (CASE WHEN QM.strCalcMethod = 3 THEN CS.dblGrossQuantity ELSE SST.dblUnits END) AS DECIMAL(18,2))
        ,GLDetail.dblCredit - GLDetail.dblDebit
        --,CASE WHEN QM.strCalcMethod = 3 
        --	THEN (CS.dblGrossQuantity * (SST.dblUnits / CS.dblOriginalBalance))--@dblGrossUnits 
        --ELSE SST.dblUnits END * (CASE WHEN QM.dblDiscountAmount > 0 THEN -1 ELSE 1 END)
        -- ,GLDetail.dblCreditUnit - GLDetail.dblDebitUnit 
    FROM tblQMTicketDiscount QM
    INNER JOIN tblGRDiscountScheduleCode DSC
        ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
    INNER JOIN tblGRCustomerStorage CS
        ON CS.intCustomerStorageId = QM.intTicketFileId
    INNER JOIN tblICItem IM
        ON DSC.intItemId = IM.intItemId
    INNER JOIN tblGRDiscountSchedule DS
        ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
    -- INNER JOIN tblICCommodity CO
    -- 	ON CO.intCommodityId = DS.intCommodityId
    INNER JOIN tblSMCompanyLocation CL
        ON CL.intCompanyLocationId = CS.intCompanyLocationId
    INNER JOIN tblGRSettleStorageTicket SST
        ON SST.intCustomerStorageId = CS.intCustomerStorageId
    INNER JOIN tblGRSettleStorage SS
        ON SST.intSettleStorageId = SS.intSettleStorageId
            AND SS.intParentSettleStorageId IS NOT NULL
            AND SS.ysnPosted = 1
            AND SS.dblSpotUnits = 0
    OUTER APPLY
    (
        SELECT GD.intAccountId, AD.strAccountId, GD.dblDebit, GD.dblCredit, GD.dblCreditUnit, GD.dblDebitUnit
        FROM tblGLDetail GD
        INNER JOIN vyuGLAccountDetail AD
            ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
        WHERE GD.strTransactionId = SS.strStorageTicket
            AND GD.intTransactionId = SS.intSettleStorageId
            AND GD.strCode = 'STR'
            AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
            AND GD.ysnIsUnposted = 0
    ) GLDetail
    WHERE 
        QM.strSourceType = 'Storage' 
    AND QM.dblDiscountDue <> 0
    ) tmp
    GROUP BY strTransactionNumber
)

INSERT INTO @grainTotal
SELECT * FROM grainTotal

SELECT
    A.strSettleStorage,
    A.dblTotal AS dblGrainTotal,
    B.dblTotal AS dblGrainGLTotal
FROM @grainTotal A
LEFT JOIN @grainGLTotal B ON A.strSettleStorage = B.strSettleStorage
WHERE (A.dblTotal - B.dblTotal) != 0

DECLARE @grainVoucherTotal TABLE(strSettleStorage NVARCHAR(50), dblTotal DECIMAL(18,2));
;WITH grainVoucherTotal (
    strSettleStorage,
    dblTotal
)
AS (
    SELECT
        strStorageTicket,
        SUM(dblVoucherTotal) AS dblTotal
    FROM 
    (
        SELECT
            SS.strStorageTicket
            ,CAST(CASE WHEN SS.dblUnpaidUnits != 0 
                THEN (
                    CASE WHEN ST.intSettleContractId IS NOT NULL THEN ST.dblUnits * ST.dblPrice
                    ELSE SS.dblNetSettlement
                    END
                )
                ELSE 
                    CASE WHEN ST.intSettleContractId IS NOT NULL THEN ST.dblUnits * ST.dblPrice
                    ELSE CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2)) END
                END AS DECIMAL(18,2)) dblVoucherTotal
        FROM tblAPBill bill
        INNER JOIN tblAPBillDetail billDetail
            ON bill.intBillId = billDetail.intBillId
        INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST
                    ON SST.intCustomerStorageId = CS.intCustomerStorageId
                INNER JOIN tblGRSettleStorage SS
                    ON SST.intSettleStorageId = SS.intSettleStorageId 
                        AND SS.intParentSettleStorageId IS NOT NULL
                        AND SS.dblSpotUnits = 0)
            ON billDetail.intCustomerStorageId = CS.intCustomerStorageId AND billDetail.intItemId = CS.intItemId
                AND SS.intBillId = bill.intBillId
        INNER JOIN vyuGLAccountDetail glAccnt
            ON glAccnt.intAccountId = billDetail.intAccountId
        INNER JOIN tblSMCompanyLocation compLoc
            ON bill.intShipToId = compLoc.intCompanyLocationId
        LEFT JOIN tblGRSettleContract ST
            ON ST.intSettleStorageId = SS.intSettleStorageId AND ST.intContractDetailId = billDetail.intContractDetailId
        LEFT JOIN tblCTContractDetail CT
            ON CT.intContractDetailId = ST.intContractDetailId
        WHERE 
        glAccnt.intAccountCategoryId = 45
        -- UNION ALL

    ) tmp
    GROUP BY strStorageTicket
)


INSERT INTO @grainVoucherTotal
SELECT * FROM grainVoucherTotal

CREATE VIEW [dbo].[vyuAPForClearing]
AS 

SELECT TOP 100 PERCENT
    CAST(ROW_NUMBER() OVER(ORDER BY dtmDate DESC) AS INT) AS intClearingId
    ,clearingData.*
FROM 
(
    --Receipt Item
    SELECT
        A.*
        ,ISNULL(vouchersInfo.strVoucherIds, (CASE WHEN A.ysnAllowVoucher = 1 THEN 'New Voucher' ELSE NULL END)) COLLATE Latin1_General_CI_AS AS strVoucherIds
        -- ,vouchersInfo.strFilter
        ,1 AS intClearingType
    FROM 
    (
        SELECT
            receiptItems.intEntityVendorId
            ,r.dtmReceiptDate AS dtmDate
            ,receiptItems.strTransactionNumber
            ,receiptItems.intInventoryReceiptItemId
            ,NULL AS intInventoryReceiptChargeId
            ,NULL AS intInventoryShipmentChargeId
            ,NULL AS intLoadDetailId
            ,NULL AS intLoadCostId
            ,NULL AS intCustomerStorageId
            ,NULL AS intRefundId
            ,SUM(receiptItems.dblReceiptQty) AS dblReceiptQty
            ,SUM(receiptItems.dblReceiptTotal) AS dblReceiptTotal
            ,(SUM(receiptItems.dblReceiptQty) - SUM(receiptItems.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(receiptItems.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(receiptItems.dblVoucherQty) AS dblVoucherQty
            ,(SUM(receiptItems.dblReceiptTotal) - SUM(receiptItems.dblVoucherTotal)) AS dblUnclearedAmount
            ,item.strItemNo
            ,item.intItemId
            ,receiptItems.intItemUOMId
            ,receiptItems.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
            ,receiptItems.strAccountId
            ,receiptItems.intAccountId
            ,receiptItems.intLocationId
            ,compLoc.strLocationName
            ,CAST(receiptItems.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM 
        (
            SELECT
                *
            FROM vyuAPReceiptClearing
        ) receiptItems
        INNER JOIN tblICInventoryReceipt r
            ON receiptItems.intInventoryReceiptId = r.intInventoryReceiptId
        LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
                ON B.[intEntityId] = receiptItems.[intEntityVendorId]
        INNER JOIN tblSMCompanyLocation compLoc
                ON receiptItems.intLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItem item
            ON item.intItemId = receiptItems.intItemId
        GROUP BY
            r.dtmReceiptDate
            ,receiptItems.intEntityVendorId
            ,receiptItems.intInventoryReceiptItemId
            -- ,receiptItems.dblReceiptQty
            -- ,receiptItems.dblReceiptTotal
            ,item.strItemNo
            ,item.intItemId
            ,receiptItems.intItemUOMId
            ,receiptItems.strUOM
            ,receiptItems.intLocationId
            ,receiptItems.strTransactionNumber
            ,receiptItems.intAccountId
            ,receiptItems.strAccountId
            ,receiptItems.strTransactionNumber
            ,B.strVendorId
            ,C.strEntityNo
            ,C.strName
            ,compLoc.strLocationName
            ,receiptItems.ysnAllowVoucher
        -- HAVING 
        --     (SUM(receiptItems.dblReceiptQty) - SUM(receiptItems.dblVoucherQty)) != 0 
        -- OR  (SUM(receiptItems.dblReceiptTotal) - SUM(receiptItems.dblVoucherTotal)) != 0
    ) A
    LEFT JOIN
    (
        SELECT 
			intInventoryReceiptItemId, intItemId
			,STUFF
			(
				(
					SELECT  ',' + b.strBillId
					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
								ON b.intBillId = bd.intBillId
					WHERE	bd.intInventoryReceiptItemId IS NOT NULL
							AND bd.intInventoryReceiptItemId = billDetail.intInventoryReceiptItemId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
							AND b.ysnPosted =1 
					GROUP BY b.strBillId, bd.intInventoryReceiptItemId, bd.intItemId
					FOR xml path('')
				)
			, 1
			, 1
			, ''
			) AS strVoucherIds
		FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
							ON bill.intBillId = billDetail.intBillId
		WHERE 
			bill.ysnPosted = 1
		AND billDetail.intInventoryReceiptItemId IS NOT NULL
		GROUP BY billDetail.intInventoryReceiptItemId, billDetail.intItemId
    ) vouchersInfo 
		ON 
			vouchersInfo.intInventoryReceiptItemId = A.intInventoryReceiptItemId
		AND vouchersInfo.intItemId = A.intItemId
    WHERE 
        (A.dblReceiptQty - A.dblVoucherQty) != 0 
    OR  (A.dblReceiptTotal - A.dblVoucherTotal) != 0
    UNION ALL
    SELECT
        B.*
        ,ISNULL(vouchersInfo.strVoucherIds, (CASE WHEN B.ysnAllowVoucher = 1 THEN 'New Voucher' ELSE NULL END)) COLLATE Latin1_General_CI_AS AS strVoucherIds
        --,vouchersInfo.strFilter
        ,2 AS intClearingType
    FROM
    (
        SELECT
            receiptChargeItems.intEntityVendorId
            ,r.dtmReceiptDate AS dtmDate
            ,receiptChargeItems.strTransactionNumber
            ,NULL AS intInventoryReceiptItemId
            ,receiptChargeItems.intInventoryReceiptChargeId
            ,NULL AS intInventoryShipmentChargeId
            ,NULL AS intLoadDetailId
            ,NULL AS intLoadCostId
            ,NULL AS intCustomerStorageId
            ,NULL AS intRefundId
            ,SUM(receiptChargeItems.dblReceiptChargeQty) AS dblReceiptChargeQty
            ,SUM(receiptChargeItems.dblReceiptChargeTotal) AS dblReceiptChargeTotal
            ,(SUM(receiptChargeItems.dblReceiptChargeQty) - SUM(receiptChargeItems.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(receiptChargeItems.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(receiptChargeItems.dblVoucherQty) AS dblVoucherQty
            ,(SUM(receiptChargeItems.dblReceiptChargeTotal) - SUM(receiptChargeItems.dblVoucherTotal)) AS dblUnclearedAmount
            ,item.strItemNo
            ,item.intItemId
            ,receiptChargeItems.intItemUOMId
            ,receiptChargeItems.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
            ,receiptChargeItems.strAccountId
            ,receiptChargeItems.intAccountId
            ,receiptChargeItems.intLocationId
            ,compLoc.strLocationName
            ,CAST(receiptChargeItems.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM
        (
            SELECT
                *
            FROM vyuAPReceiptChargeClearing
        ) receiptChargeItems
        INNER JOIN tblICInventoryReceipt r
            ON receiptChargeItems.intInventoryReceiptId = r.intInventoryReceiptId
        LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
                ON B.[intEntityId] = receiptChargeItems.[intEntityVendorId]
        INNER JOIN tblSMCompanyLocation compLoc
                ON receiptChargeItems.intLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItem item
            ON item.intItemId = receiptChargeItems.intItemId
        GROUP BY
            r.dtmReceiptDate
            ,receiptChargeItems.intEntityVendorId
            ,receiptChargeItems.intInventoryReceiptChargeId
            -- ,receiptChargeItems.dblReceiptChargeQty
            -- ,receiptChargeItems.dblReceiptChargeTotal
            ,item.strItemNo
            ,item.intItemId
            ,receiptChargeItems.intItemUOMId
            ,receiptChargeItems.strUOM
            ,receiptChargeItems.intLocationId
            ,receiptChargeItems.strTransactionNumber
            ,receiptChargeItems.intAccountId
            ,receiptChargeItems.strAccountId
            ,receiptChargeItems.strTransactionNumber
            ,B.strVendorId
            ,C.strEntityNo
            ,C.strName
            ,compLoc.strLocationName
            ,receiptChargeItems.ysnAllowVoucher
        -- HAVING 
        --     (SUM(receiptChargeItems.dblReceiptChargeQty) - SUM(receiptChargeItems.dblVoucherQty)) != 0
        -- OR  (SUM(receiptChargeItems.dblReceiptChargeTotal) - SUM(receiptChargeItems.dblVoucherTotal)) != 0
    ) B
    LEFT JOIN
    (
        SELECT 
            intInventoryReceiptChargeId, intItemId
            ,STUFF(
                    (
                        SELECT  ',' + b.strBillId
                        FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                    ON b.intBillId = bd.intBillId
                        WHERE	bd.intInventoryReceiptChargeId IS NOT NULL
                                AND bd.intInventoryReceiptChargeId = billDetail.intInventoryReceiptChargeId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
                                AND b.ysnPosted =1 
                        GROUP BY b.strBillId
                        FOR xml path('')
                    )
                , 1
                , 1
                , ''
            ) AS strVoucherIds
        FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
                            ON bill.intBillId = billDetail.intBillId
        WHERE 
            bill.ysnPosted = 1
        AND billDetail.intInventoryReceiptChargeId IS NOT NULL
        GROUP BY billDetail.intInventoryReceiptChargeId, billDetail.intItemId
    ) vouchersInfo
        ON 
            vouchersInfo.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
        AND vouchersInfo.intItemId = B.intItemId
    WHERE 
        (dblUnclearedQty) != 0
    OR  (dblUnclearedAmount) != 0
    UNION ALL--SHIPMENT CHARGE
    SELECT
        C.*
        ,ISNULL(vouchersInfo.strVoucherIds, (CASE WHEN C.ysnAllowVoucher = 1 THEN 'New Voucher' ELSE NULL END)) COLLATE Latin1_General_CI_AS AS strVoucherIds
        --,vouchersInfo.strFilter
        ,3 AS intClearingType
    FROM
    (
        SELECT
            shipmentCharges.intEntityVendorId
            ,r.dtmShipDate AS dtmDate
            ,shipmentCharges.strTransactionNumber
            ,NULL AS intInventoryReceiptItemId
            ,NULL AS intInventoryReceiptChargeId
            ,shipmentCharges.intInventoryShipmentChargeId
            ,NULL AS intLoadDetailId
            ,NULL AS intLoadCostId
            ,NULL AS intCustomerStorageId 
            ,NULL AS intRefundId
            ,SUM(shipmentCharges.dblReceiptChargeQty) AS dblReceiptChargeQty
            ,SUM(shipmentCharges.dblReceiptChargeTotal) AS dblReceiptChargeTotal
            ,(SUM(shipmentCharges.dblReceiptChargeQty) - SUM(shipmentCharges.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(shipmentCharges.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(shipmentCharges.dblVoucherQty) AS dblVoucherQty
            ,(SUM(shipmentCharges.dblReceiptChargeTotal) - SUM(shipmentCharges.dblVoucherTotal)) AS dblUnclearedAmount
            ,item.strItemNo
            ,item.intItemId
            ,shipmentCharges.intItemUOMId
            ,shipmentCharges.strUOM
            ,dbo.fnTrim(ISNULL(B.strCustomerNumber, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS AS strVendorIdName 
            ,shipmentCharges.strAccountId
            ,shipmentCharges.intAccountId
            ,shipmentCharges.intLocationId
            ,compLoc.strLocationName
            ,CAST(shipmentCharges.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM
        (
        	SELECT
        		*
        	FROM vyuAPShipmentChargeClearing
        ) shipmentCharges
        INNER JOIN tblICInventoryShipment r
            ON shipmentCharges.intInventoryShipmentId = r.intInventoryShipmentId
        LEFT JOIN (dbo.tblARCustomer B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
        		ON B.[intEntityId] = shipmentCharges.[intEntityVendorId]
        INNER JOIN tblSMCompanyLocation compLoc
        		ON shipmentCharges.intLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItem item
        	ON item.intItemId = shipmentCharges.intItemId
        GROUP BY
        	shipmentCharges.intEntityVendorId
        	,item.strItemNo
            ,item.intItemId
            ,shipmentCharges.intItemUOMId
            ,shipmentCharges.strUOM
        	,shipmentCharges.intLocationId
        	,shipmentCharges.strTransactionNumber
        	-- ,shipmentCharges.dblReceiptChargeQty
            -- ,shipmentCharges.dblReceiptChargeTotal
        	,r.dtmShipDate
            ,shipmentCharges.intAccountId
        	,shipmentCharges.strAccountId
        	,shipmentCharges.intInventoryShipmentChargeId
        	,B.strCustomerNumber
        	,C.strEntityNo
        	,C.strName
        	,compLoc.strLocationName
            ,shipmentCharges.ysnAllowVoucher
        -- HAVING 
        --     (SUM(shipmentCharges.dblReceiptChargeQty) - SUM(shipmentCharges.dblVoucherQty)) != 0
        -- OR  (SUM(shipmentCharges.dblReceiptChargeTotal) - SUM(shipmentCharges.dblVoucherTotal)) != 0
    ) C
    LEFT JOIN
    (
        SELECT 
            intInventoryShipmentChargeId, intItemId
            ,STUFF(
                    (
                        SELECT  ',' + b.strBillId
                        FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                    ON b.intBillId = bd.intBillId
                        WHERE	bd.intInventoryShipmentChargeId IS NOT NULL
                                AND bd.intInventoryShipmentChargeId = billDetail.intInventoryShipmentChargeId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
                                AND b.ysnPosted =1 
                        GROUP BY b.strBillId
                        FOR xml path('')
                    )
                , 1
                , 1
                , ''
            ) AS strVoucherIds
        FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
                            ON bill.intBillId = billDetail.intBillId
        WHERE 
            bill.ysnPosted = 1
        AND billDetail.intInventoryShipmentChargeId IS NOT NULL
        GROUP BY billDetail.intInventoryShipmentChargeId, billDetail.intItemId
    ) vouchersInfo 
        ON
            vouchersInfo.intInventoryShipmentChargeId = C.intInventoryShipmentChargeId
        AND vouchersInfo.intItemId = C.intItemId
    WHERE 
        (dblUnclearedQty) != 0
    OR  (dblUnclearedAmount) != 0
    UNION ALL--LOAD TRANSACTION
    SELECT
        D.*
        ,ISNULL(vouchersInfo.strVoucherIds, (CASE WHEN D.ysnAllowVoucher = 1 THEN 'New Voucher' ELSE NULL END)) COLLATE Latin1_General_CI_AS AS strVoucherIds
        --,vouchersInfo.strFilter
        ,4 AS intClearingType
    FROM
    (
        SELECT
            loadTran.intEntityVendorId
            ,r.dtmPostedDate
            ,loadTran.strTransactionNumber
            ,NULL AS intInventoryReceiptItemId
            ,NULL AS intInventoryReceiptChargeId
            ,NULL AS intInventoryShipmentChargeId
            ,loadTran.intLoadDetailId
            ,NULL AS intLoadCostId
            ,NULL AS intCustomerStorageId
            ,NULL AS intRefundId
            ,SUM(loadTran.dblLoadDetailQty) AS dblLoadDetailQty
            ,SUM(loadTran.dblLoadDetailTotal) AS dblLoadDetailTotal
            ,(SUM(loadTran.dblLoadDetailQty) - SUM(loadTran.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(loadTran.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(loadTran.dblVoucherQty) AS dblVoucherQty
            ,(SUM(loadTran.dblLoadDetailTotal) - SUM(loadTran.dblVoucherTotal)) AS dblUnclearedAmount
            ,item.strItemNo
            ,item.intItemId
            ,loadTran.intItemUOMId
            ,loadTran.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
            ,loadTran.strAccountId
            ,loadTran.intAccountId
            ,loadTran.intLocationId
            ,compLoc.strLocationName
            ,CAST(loadTran.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM
        (
            SELECT
                *
            FROM vyuAPLoadClearing
        ) loadTran
        INNER JOIN tblLGLoad r
            ON r.intLoadId = loadTran.intLoadId
        LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
                ON B.[intEntityId] = loadTran.[intEntityVendorId]
        INNER JOIN tblSMCompanyLocation compLoc
                ON loadTran.intLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItem item
            ON item.intItemId = loadTran.intItemId
        GROUP BY
            r.dtmPostedDate
            ,loadTran.intEntityVendorId
            ,item.intItemId
            ,item.strItemNo
            ,loadTran.intItemUOMId
            ,loadTran.strUOM
            ,loadTran.intLocationId
            ,loadTran.intLoadDetailId
            ,loadTran.strTransactionNumber
            -- ,loadTran.dblLoadDetailQty
            -- ,loadTran.dblLoadDetailTotal
            ,loadTran.intAccountId
            ,loadTran.strAccountId
            ,loadTran.strTransactionNumber
            ,B.strVendorId
            ,C.strEntityNo
            ,C.strName
            ,compLoc.strLocationName
            ,loadTran.ysnAllowVoucher
        -- HAVING 
        --     (SUM(loadTran.dblLoadDetailQty) - SUM(loadTran.dblVoucherQty)) != 0
        -- OR  (SUM(loadTran.dblLoadDetailTotal) - SUM(loadTran.dblVoucherTotal)) != 0
    ) D
    LEFT JOIN
    (
        SELECT 
            intLoadDetailId, intItemId
            ,STUFF(
                    (
                        SELECT  ',' + b.strBillId
                        FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                    ON b.intBillId = bd.intBillId
                        WHERE	bd.intLoadDetailId = billDetail.intLoadDetailId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
                                AND b.ysnPosted =1 
                        GROUP BY b.strBillId
                        FOR xml path('')
                    )
                , 1
                , 1
                , ''
            ) AS strVoucherIds
        FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
                            ON bill.intBillId = billDetail.intBillId
        WHERE 
            bill.ysnPosted = 1
        AND billDetail.intLoadDetailId IS NOT NULL
        GROUP BY billDetail.intLoadDetailId, billDetail.intItemId
    ) vouchersInfo
        ON
            vouchersInfo.intLoadDetailId = D.intLoadDetailId
        AND vouchersInfo.intItemId = D.intItemId
    WHERE 
        (dblUnclearedQty) != 0
    OR  (dblUnclearedAmount) != 0
    UNION ALL --LOAD COST
    SELECT
        E.*
        ,ISNULL(vouchersInfo.strVoucherIds, (CASE WHEN E.ysnAllowVoucher = 1 THEN 'New Voucher' ELSE NULL END)) COLLATE Latin1_General_CI_AS AS strVoucherIds
        --,vouchersInfo.strFilter
        ,5 AS intClearingType
    FROM
    (
        SELECT
            loadCost.intEntityVendorId
            ,r.dtmPostedDate
            ,loadCost.strTransactionNumber
            ,NULL AS intInventoryReceiptItemId
            ,NULL AS intInventoryReceiptChargeId
            ,NULL AS intInventoryShipmentChargeId
            ,loadCost.intLoadDetailId
            ,loadCost.intLoadCostId
            ,NULL AS intCustomerStorageId
            ,NULL AS intRefundId
            ,SUM(loadCost.dblLoadCostDetailQty) AS dblLoadCostDetailQty
            ,SUM(loadCost.dblLoadCostDetailTotal) AS dblLoadCostDetailTotal
            ,(SUM(loadCost.dblLoadCostDetailQty) - SUM(loadCost.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(loadCost.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(loadCost.dblVoucherQty) AS dblVoucherQty
            ,(SUM(loadCost.dblLoadCostDetailTotal) - SUM(loadCost.dblVoucherTotal)) AS dblUnclearedAmount
            ,item.strItemNo
            ,item.intItemId
            ,loadCost.intItemUOMId
            ,loadCost.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
            ,loadCost.strAccountId
            ,loadCost.intAccountId
            ,loadCost.intLocationId
            ,compLoc.strLocationName
            ,CAST(loadCost.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM
        (
            SELECT
                *
            FROM vyuAPLoadCostClearing
        ) loadCost
        INNER JOIN tblLGLoad r
            ON r.intLoadId = loadCost.intLoadId
        LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
                ON B.[intEntityId] = loadCost.[intEntityVendorId]
        INNER JOIN tblSMCompanyLocation compLoc
                ON loadCost.intLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItem item
            ON item.intItemId = loadCost.intItemId
        GROUP BY
            r.dtmPostedDate
            ,loadCost.intEntityVendorId
            ,item.intItemId
            ,item.strItemNo
            ,loadCost.intItemUOMId
            ,loadCost.strUOM
            ,loadCost.intLocationId
            ,loadCost.intLoadDetailId
            ,loadCost.intLoadCostId
            ,loadCost.strTransactionNumber
            -- ,loadCost.dblLoadCostDetailQty
            -- ,loadCost.dblLoadCostDetailTotal
            ,loadCost.intAccountId
            ,loadCost.strAccountId
            ,loadCost.strTransactionNumber
            ,B.strVendorId
            ,C.strEntityNo
            ,C.strName
            ,compLoc.strLocationName
            ,loadCost.ysnAllowVoucher
        -- HAVING 
        --     (SUM(loadCost.dblLoadCostDetailQty) - SUM(loadCost.dblVoucherQty)) != 0
        -- OR  (SUM(loadCost.dblLoadCostDetailTotal) - SUM(loadCost.dblVoucherTotal)) != 0
    ) E
    LEFT JOIN
    (
        SELECT 
            intLoadDetailId, intItemId
            ,STUFF(
                    (
                        SELECT  ',' + b.strBillId
                        FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                    ON b.intBillId = bd.intBillId
                        WHERE	bd.intLoadDetailId = billDetail.intLoadDetailId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
                                AND b.ysnPosted =1 
                        GROUP BY b.strBillId
                        FOR xml path('')
                    )
                , 1
                , 1
                , ''
            ) AS strVoucherIds
        FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
                            ON bill.intBillId = billDetail.intBillId
        WHERE 
            bill.ysnPosted = 1
        AND billDetail.intLoadDetailId IS NOT NULL
        GROUP BY billDetail.intLoadDetailId, billDetail.intItemId
    ) vouchersInfo
        ON
            vouchersInfo.intLoadDetailId = E.intLoadDetailId
        AND vouchersInfo.intItemId = E.intItemId
    WHERE 
        (dblUnclearedQty) != 0
    OR  (dblUnclearedAmount) != 0
    UNION ALL --SETTLE STORAGE
    SELECT
        F.*
        ,ISNULL(vouchersInfo.strVoucherIds, NULL) COLLATE Latin1_General_CI_AS AS strVoucherIds
        --,vouchersInfo.strFilter
        ,6 AS intClearingType
    FROM
    (
        SELECT
            settleStorage.intEntityVendorId
            ,r.dtmDeliveryDate
            ,settleStorage.strTransactionNumber
            ,NULL AS intInventoryReceiptItemId
            ,NULL AS intInventoryReceiptChargeId
            ,NULL AS intInventoryShipmentChargeId
            ,NULL AS intLoadDetailId
            ,NULL AS intLoadCostId
            ,settleStorage.intCustomerStorageId
            ,NULL AS intRefundId
            ,SUM(settleStorage.dblSettleStorageQty) AS dblSettleStorageQty
            ,SUM(settleStorage.dblSettleStorageAmount) AS dblSettleStorageAmount
            ,(SUM(settleStorage.dblSettleStorageQty) - SUM(settleStorage.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(settleStorage.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(settleStorage.dblVoucherQty) AS dblVoucherQty
            ,(SUM(settleStorage.dblSettleStorageAmount) - SUM(settleStorage.dblVoucherTotal)) AS dblUnclearedAmount
            ,item.strItemNo
            ,item.intItemId
            ,settleStorage.intItemUOMId
            ,settleStorage.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
            ,settleStorage.strAccountId
            ,settleStorage.intAccountId
            ,settleStorage.intLocationId
            ,compLoc.strLocationName
            ,CAST(settleStorage.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM
        (
            SELECT
                *
            FROM vyuAPGrainClearing
        ) settleStorage
        INNER JOIN tblGRCustomerStorage r
            ON r.intCustomerStorageId = settleStorage.intCustomerStorageId
        LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
                ON B.[intEntityId] = settleStorage.[intEntityVendorId]
        INNER JOIN tblSMCompanyLocation compLoc
                ON settleStorage.intLocationId = compLoc.intCompanyLocationId
        INNER JOIN tblICItem item
            ON item.intItemId = settleStorage.intItemId
        GROUP BY
            r.dtmDeliveryDate
            ,settleStorage.intEntityVendorId
            ,item.intItemId
            ,item.strItemNo
            ,settleStorage.intItemUOMId
            ,settleStorage.strUOM
            ,settleStorage.intLocationId
            ,settleStorage.intCustomerStorageId
            ,settleStorage.strTransactionNumber
            -- ,settleStorage.dblSettleStorageQty
            -- ,settleStorage.dblSettleStorageAmount
            ,settleStorage.intAccountId
            ,settleStorage.strAccountId
            ,settleStorage.strTransactionNumber
            ,B.strVendorId
            ,C.strEntityNo
            ,C.strName
            ,compLoc.strLocationName
            ,settleStorage.ysnAllowVoucher
        -- HAVING 
        --     (SUM(settleStorage.dblSettleStorageQty) - SUM(settleStorage.dblVoucherQty)) != 0
        -- OR  (SUM(settleStorage.dblSettleStorageAmount) - SUM(settleStorage.dblVoucherTotal)) != 0
    ) F
    LEFT JOIN
    (
        SELECT 
            intCustomerStorageId, intItemId
            ,STUFF(
                    (
                        SELECT  ',' + b.strBillId
                        FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                    ON b.intBillId = bd.intBillId
                        WHERE	bd.intCustomerStorageId = billDetail.intCustomerStorageId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
                                AND b.ysnPosted =1 
                        GROUP BY b.strBillId
                        FOR xml path('')
                    )
                , 1
                , 1
                , ''
            ) AS strVoucherIds
        FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
                            ON bill.intBillId = billDetail.intBillId
        WHERE 
            bill.ysnPosted = 1
        AND billDetail.intCustomerStorageId IS NOT NULL
        GROUP BY billDetail.intCustomerStorageId, billDetail.intItemId
    ) vouchersInfo 
        ON
            vouchersInfo.intCustomerStorageId = F.intCustomerStorageId
        AND vouchersInfo.intItemId = F.intItemId
    WHERE 
        (dblUnclearedQty) != 0
    OR  (dblUnclearedAmount) != 0
    UNION ALL --PATRONAGE
    SELECT
        G.*
        ,ISNULL(vouchersInfo.strVoucherIds, NULL) COLLATE Latin1_General_CI_AS AS strVoucherIds
        --,vouchersInfo.strFilter
        ,7 AS intClearingType
    FROM
    (
        SELECT
            pat.intEntityVendorId
            ,refund.dtmRefundDate
            ,pat.strTransactionNumber
            ,NULL AS intInventoryReceiptItemId
            ,NULL AS intInventoryReceiptChargeId
            ,NULL AS intInventoryShipmentChargeId
            ,NULL AS intLoadDetailId
            ,NULL AS intLoadCostId
            ,NULL AS intCustomerStorageId
            ,pat.intRefundCustomerId
            ,SUM(pat.dblRefundQty) AS dblRefundQty
            ,SUM(pat.dblRefundTotal) AS dblRefundTotal
            ,(SUM(pat.dblRefundQty) - SUM(pat.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(pat.dblVoucherTotal) AS dblVoucherTotal
            ,SUM(pat.dblVoucherQty) AS dblVoucherQty
            ,(SUM(pat.dblRefundTotal) - SUM(pat.dblVoucherTotal)) AS dblUnclearedAmount
            ,NULL AS strItemNo
            ,NULL AS intItemId
            ,NULL AS intItemUOMId
            ,NULL AS strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
            ,pat.strAccountId
            ,pat.intAccountId
            ,NULL AS intLocationId
            ,NULL AS strLocationName
            ,CAST(pat.ysnAllowVoucher AS BIT) AS ysnAllowVoucher
        FROM
        (
            SELECT
                *
            FROM vyuAPPatClearing
        ) pat
        INNER JOIN (tblPATRefund refund INNER JOIN tblPATRefundCustomer refundEntity 
                        ON refund.intRefundId = refundEntity.intRefundId)
                ON refundEntity.intRefundCustomerId = pat.intRefundCustomerId
        LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
                ON B.[intEntityId] = pat.[intEntityVendorId]
        -- LEFT JOIN tblSMCompanyLocation compLoc
        --         ON pat.intLocationId = compLoc.intCompanyLocationId
        -- LEFT JOIN tblICItem item
        --     ON item.intItemId = pat.intItemId
        GROUP BY
            refund.dtmRefundDate
            ,pat.intEntityVendorId
            -- ,item.intItemId
            -- ,item.strItemNo
            -- ,pat.intItemUOMId
            -- ,pat.strUOM
            -- ,pat.intLocationId
            ,pat.intRefundCustomerId
            ,pat.strTransactionNumber
            ,pat.intAccountId
            ,pat.strAccountId
            ,pat.strTransactionNumber
            ,B.strVendorId
            ,C.strEntityNo
            ,C.strName
            -- ,compLoc.strLocationName
            ,pat.ysnAllowVoucher
    ) G
    LEFT JOIN
    (
        SELECT 
            refundEntity.intRefundCustomerId
            ,NULL AS intItemId
            ,STUFF(
                    (
                        SELECT  ', ' + b.strBillId
                        FROM	tblAPBill b INNER JOIN tblPATRefundCustomer refundBill
                                    ON b.intBillId = refundBill.intBillId
                        WHERE	refundBill.intRefundCustomerId = refundEntity.intRefundCustomerId
                                AND b.ysnPosted =1 AND refundBill.ysnEligibleRefund = 1
                        GROUP BY b.strBillId
                        FOR xml path('')
                    )
                , 1
                , 1
                , ''
            ) AS strVoucherIds
        FROM	tblAPBill bill 
        INNER JOIN (tblPATRefund refund INNER JOIN tblPATRefundCustomer refundEntity ON refund.intRefundId = refundEntity.intRefundId)
            ON bill.intBillId = refundEntity.intBillId
        WHERE 
            bill.ysnPosted = 1
        AND refund.ysnPosted = 1
        AND refundEntity.ysnEligibleRefund = 1
        GROUP BY refundEntity.intRefundCustomerId
    ) vouchersInfo
        ON
            vouchersInfo.intRefundCustomerId = G.intRefundCustomerId
    WHERE 
        (dblUnclearedQty) != 0
    OR  (dblUnclearedAmount) != 0
) clearingData
ORDER BY dtmDate DESC
GO


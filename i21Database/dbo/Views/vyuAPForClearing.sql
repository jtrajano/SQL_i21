CREATE VIEW [dbo].[vyuAPForClearing]
AS 

SELECT
    CAST(ROW_NUMBER() OVER(ORDER BY dtmDate DESC) AS INT) AS intClearingId
    ,clearingData.*
FROM 
(
    --Receipt Item
    SELECT
        A.*
        ,ISNULL(vouchersInfo.strVoucherIds, (CASE WHEN A.ysnAllowVoucher = 1 THEN 'New Voucher' ELSE NULL END)) AS strVoucherIds
        ,vouchersInfo.strFilter
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
            ,SUM(receiptItems.dblReceiptQty) AS dblReceiptQty
            ,SUM(receiptItems.dblReceiptTotal) AS dblReceiptTotal
            ,(SUM(receiptItems.dblReceiptQty) - SUM(receiptItems.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(receiptItems.dblVoucherQty) AS dblVoucherQty
            ,item.strItemNo
            ,item.intItemId
            ,receiptItems.intItemUOMId
            ,receiptItems.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
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
        HAVING (SUM(receiptItems.dblReceiptQty) - SUM(receiptItems.dblVoucherQty)) != 0
    ) A
    OUTER APPLY 
    (
        SELECT strVoucherIds = 
            LTRIM(
                STUFF(
                        (
                            SELECT  ', ' + b.strBillId
                            FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                        ON b.intBillId = bd.intBillId
                            WHERE	bd.intInventoryReceiptItemId = A.intInventoryReceiptItemId AND bd.intItemId = A.intItemId
                                    AND b.ysnPosted =1 
                            GROUP BY b.strBillId
                            FOR xml path('')
                        )
                    , 1
                    , 1
                    , ''
                ) 
            )
            , strFilter = ''
            -- LTRIM(
			-- 		STUFF(
			-- 				' ' + (
			-- 					SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
			-- 					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
			-- 								ON b.intBillId = bd.intBillId
			-- 					WHERE	bd.intInventoryReceiptItemId = A.intInventoryReceiptItemId
			-- 							AND bd.intInventoryReceiptChargeId IS NULL 
			-- 							AND b.ysnPosted = 1
			-- 					GROUP BY b.intBillId
			-- 					FOR xml path('')
			-- 				)
			-- 			, 1
			-- 			, 1
			-- 			, ''
			-- 		)
            -- )
    ) vouchersInfo 
    UNION ALL
    SELECT
        B.*
        ,ISNULL(vouchersInfo.strVoucherIds, 'New Voucher') AS strVoucherIds
        ,vouchersInfo.strFilter
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
            ,SUM(receiptChargeItems.dblReceiptChargeQty) AS dblReceiptChargeQty
            ,SUM(receiptChargeItems.dblReceiptChargeTotal) AS dblReceiptChargeTotal
            ,(SUM(receiptChargeItems.dblReceiptChargeQty) - SUM(receiptChargeItems.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(receiptChargeItems.dblVoucherQty) AS dblVoucherQty
            ,item.strItemNo
            ,item.intItemId
            ,receiptChargeItems.intItemUOMId
            ,receiptChargeItems.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
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
        HAVING (SUM(receiptChargeItems.dblReceiptChargeQty) - SUM(receiptChargeItems.dblVoucherQty)) != 0
    ) B
    OUTER APPLY 
    (
        SELECT strVoucherIds = 
            LTRIM(
                STUFF(
                        (
                            SELECT  ', ' + b.strBillId
                            FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                        ON b.intBillId = bd.intBillId
                            WHERE	bd.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId AND bd.intItemId = B.intItemId
                                    AND b.ysnPosted =1 
                            GROUP BY b.strBillId
                            FOR xml path('')
                        )
                    , 1
                    , 1
                    , ''
                )
            )
            , strFilter = ''
            -- LTRIM(
			-- 		STUFF(
			-- 				' ' + (
			-- 					SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
			-- 					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
			-- 								ON b.intBillId = bd.intBillId
			-- 					WHERE	bd.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId AND bd.intItemId = B.intItemId 
			-- 							AND b.ysnPosted = 1
			-- 					GROUP BY b.intBillId
			-- 					FOR xml path('')
			-- 				)
			-- 			, 1
			-- 			, 1
			-- 			, ''
			-- 		)
            -- )
    ) vouchersInfo 
    UNION ALL--SHIPMENT CHARGE
    SELECT
        C.*
        ,ISNULL(vouchersInfo.strVoucherIds, 'New Voucher') AS strVoucherIds
        ,vouchersInfo.strFilter
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
            ,SUM(shipmentCharges.dblReceiptChargeQty) AS dblReceiptChargeQty
            ,SUM(shipmentCharges.dblReceiptChargeTotal) AS dblReceiptChargeTotal
            ,(SUM(shipmentCharges.dblReceiptChargeQty) - SUM(shipmentCharges.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(shipmentCharges.dblVoucherQty) AS dblVoucherQty
            ,item.strItemNo
            ,item.intItemId
            ,shipmentCharges.intItemUOMId
            ,shipmentCharges.strUOM
            ,dbo.fnTrim(ISNULL(B.strCustomerNumber, C.strEntityNo) + ' - ' + isnull(C.strName,'')) AS strVendorIdName 
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
        HAVING (SUM(shipmentCharges.dblReceiptChargeQty) - SUM(shipmentCharges.dblVoucherQty)) != 0
    ) C
    OUTER APPLY 
    (
        SELECT strVoucherIds = 
            LTRIM(
                STUFF(
                        (
                            SELECT  ', ' + b.strBillId
                            FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                        ON b.intBillId = bd.intBillId
                            WHERE	bd.intInventoryShipmentChargeId = C.intInventoryShipmentChargeId AND bd.intItemId = C.intItemId
                                    AND b.ysnPosted =1 
                            GROUP BY b.strBillId
                            FOR xml path('')
                        )
                    , 1
                    , 1
                    , ''
                )
            )
            , strFilter = ''
            -- LTRIM(
			-- 		STUFF(
			-- 				' ' + (
			-- 					SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
			-- 					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
			-- 								ON b.intBillId = bd.intBillId
			-- 					WHERE	bd.intInventoryShipmentChargeId = C.intInventoryShipmentChargeId AND bd.intItemId = C.intItemId
			-- 							AND b.ysnPosted = 1
			-- 					GROUP BY b.intBillId
			-- 					FOR xml path('')
			-- 				)
			-- 			, 1
			-- 			, 1
			-- 			, ''
			-- 		)
            -- )
    ) vouchersInfo 
    UNION ALL--LOAD TRANSACTION
    SELECT
        D.*
        ,ISNULL(vouchersInfo.strVoucherIds, 'New Voucher') AS strVoucherIds
        ,vouchersInfo.strFilter
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
            ,SUM(loadTran.dblLoadDetailQty) AS dblLoadDetailQty
            ,SUM(loadTran.dblLoadDetailTotal) AS dblLoadDetailTotal
            ,(SUM(loadTran.dblLoadDetailQty) - SUM(loadTran.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(loadTran.dblVoucherQty) AS dblVoucherQty
            ,item.strItemNo
            ,item.intItemId
            ,loadTran.intItemUOMId
            ,loadTran.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
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
        HAVING (SUM(loadTran.dblLoadDetailQty) - SUM(loadTran.dblVoucherQty)) != 0
    ) D
    OUTER APPLY 
    (
        SELECT strVoucherIds = 
            LTRIM(
                STUFF(
                        (
                            SELECT  ', ' + b.strBillId
                            FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                        ON b.intBillId = bd.intBillId
                            WHERE	bd.intLoadDetailId = D.intLoadDetailId AND bd.intItemId = D.intItemId
                                    AND b.ysnPosted =1 
                            GROUP BY b.strBillId
                            FOR xml path('')
                        )
                    , 1
                    , 1
                    , ''
                )
            )
            , strFilter = ''
            -- LTRIM(
			-- 		STUFF(
			-- 				' ' + (
			-- 					SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
			-- 					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
			-- 								ON b.intBillId = bd.intBillId
			-- 					WHERE	bd.intLoadDetailId = D.intLoadDetailId AND bd.intItemId = D.intItemId
			-- 							AND b.ysnPosted = 1
			-- 					GROUP BY b.intBillId
			-- 					FOR xml path('')
			-- 				)
			-- 			, 1
			-- 			, 1
			-- 			, ''
			-- 		)
            -- )
    ) vouchersInfo 
    UNION ALL --LOAD COST
    SELECT
        E.*
        ,ISNULL(vouchersInfo.strVoucherIds, 'New Voucher') AS strVoucherIds
        ,vouchersInfo.strFilter
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
            ,SUM(loadCost.dblLoadCostDetailQty) AS dblLoadCostDetailQty
            ,SUM(loadCost.dblLoadCostDetailTotal) AS dblLoadCostDetailTotal
            ,(SUM(loadCost.dblLoadCostDetailQty) - SUM(loadCost.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(loadCost.dblVoucherQty) AS dblVoucherQty
            ,item.strItemNo
            ,item.intItemId
            ,loadCost.intItemUOMId
            ,loadCost.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
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
        HAVING (SUM(loadCost.dblLoadCostDetailQty) - SUM(loadCost.dblVoucherQty)) != 0
    ) E
    OUTER APPLY 
    (
        SELECT strVoucherIds = 
            LTRIM(
                STUFF(
                        (
                            SELECT  ', ' + b.strBillId
                            FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                        ON b.intBillId = bd.intBillId
                            WHERE	bd.intLoadDetailId = E.intLoadDetailId AND bd.intItemId = E.intItemId
                                    AND b.ysnPosted =1 
                            GROUP BY b.strBillId
                            FOR xml path('')
                        )
                    , 1
                    , 1
                    , ''
                )
            )
             , strFilter = ''
            -- LTRIM(
			-- 		STUFF(
			-- 				' ' + (
			-- 					SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
			-- 					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
			-- 								ON b.intBillId = bd.intBillId
			-- 					WHERE	bd.intLoadDetailId = E.intLoadDetailId AND bd.intItemId = E.intItemId
			-- 							AND b.ysnPosted = 1
			-- 					GROUP BY b.intBillId
			-- 					FOR xml path('')
			-- 				)
			-- 			, 1
			-- 			, 1
			-- 			, ''
			-- 		)
            -- )
    ) vouchersInfo 
    UNION ALL --SETTLE STORAGE
    SELECT
        F.*
        ,ISNULL(vouchersInfo.strVoucherIds, NULL) AS strVoucherIds
        ,vouchersInfo.strFilter
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
            ,SUM(settleStorage.dblSettleStorageQty) AS dblSettleStorageQty
            ,SUM(settleStorage.dblSettleStorageAmount) AS dblSettleStorageAmount
            ,(SUM(settleStorage.dblSettleStorageQty) - SUM(settleStorage.dblVoucherQty)) AS dblUnclearedQty
            ,SUM(settleStorage.dblVoucherQty) AS dblVoucherQty
            ,item.strItemNo
            ,item.intItemId
            ,settleStorage.intItemUOMId
            ,settleStorage.strUOM
            ,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
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
        HAVING (SUM(settleStorage.dblSettleStorageQty) - SUM(settleStorage.dblVoucherQty)) != 0
    ) F
    OUTER APPLY 
    (
        SELECT strVoucherIds = 
            LTRIM(
                STUFF(
                        (
                            SELECT  ', ' + b.strBillId
                            FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                                        ON b.intBillId = bd.intBillId
                            WHERE	bd.intCustomerStorageId = F.intCustomerStorageId AND bd.intItemId = F.intItemId
                                    AND b.ysnPosted =1 
                            GROUP BY b.strBillId
                            FOR xml path('')
                        )
                    , 1
                    , 1
                    , ''
                )
            )
             , strFilter = ''
            -- LTRIM(
			-- 		STUFF(
			-- 				' ' + (
			-- 					SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
			-- 					FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
			-- 								ON b.intBillId = bd.intBillId
			-- 					WHERE	bd.intCustomerStorageId = F.intCustomerStorageId AND bd.intItemId = F.intItemId
			-- 							AND b.ysnPosted = 1
			-- 					GROUP BY b.intBillId
			-- 					FOR xml path('')
			-- 				)
			-- 			, 1
			-- 			, 1
			-- 			, ''
			-- 		)
            -- )
    ) vouchersInfo 
) clearingData
GO


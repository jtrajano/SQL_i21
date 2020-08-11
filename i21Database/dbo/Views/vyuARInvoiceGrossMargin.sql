  
CREATE VIEW vyuARInvoiceGrossMargin  
AS  
  
WITH Query AS(  
    SELECT  
         dblTotalCost   = ISNULL(SAR.dblStandardCost, 0) *  
                                        CASE WHEN SAR.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund')   
                                            THEN CASE WHEN SAR.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment', 'Cash Refund')  
                                            THEN -ISNULL(SAR.dblQtyShipped, 0) ELSE ISNULL(SAR.dblQtyShipped, 0) END  
                                            ELSE ISNULL(SAR.dblQtyOrdered, 0)  
                                        END  
        , dblTotal  
  , dtmDate  
    FROM  
    (  
        --INVOICE/NORMAL ITEMS  
        SELECT   
  
  
  
            strTransactionType  = ARI.strTransactionType  
            , intTransactionId   = ARI.intInvoiceId    
            , intEntityCustomerId  = ARI.intEntityCustomerId  
            , intItemAccountId   = CASE WHEN ICI.strType IN ('Non-Inventory','Service','Other Charge') THEN ISNULL(ARID.intAccountId, ARID.intSalesAccountId) ELSE ISNULL(ARID.intSalesAccountId, ARID.intAccountId) END  
            , dblQtyOrdered    = ARID.dblQtyOrdered  
            , dblQtyShipped    = ARID.dblQtyShipped  
            , dblStandardCost   = (CASE WHEN ARI.strType = 'CF Tran' AND CFTRAN.strTransactionType IN ('Remote', 'Extended Remote')  
                                                    THEN ISNULL(CFTRAN.dblNetTransferCost, 0)  
                                                WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))  
                                                ELSE dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                            END)  
            ,dblTotal  
   ,ARI.dtmDate  
  
        FROM tblARInvoiceDetail ARID   
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId  
          
        LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId  
        LEFT OUTER JOIN (  
            SELECT intTransactionId  
                , strTransactionId  
                , intItemId  
                , intItemUOMId  
                , dblCost    = CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END  
            FROM tblICInventoryTransaction   
            WHERE ysnIsUnposted = 0  
            AND intItemUOMId IS NOT NULL  
            AND intTransactionTypeId <> 1  
            GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId  
        ) AS NONSO ON ARI.intInvoiceId  = NONSO.intTransactionId  
                AND ARI.strInvoiceNumber = NONSO.strTransactionId  
                AND ARID.intItemId  = NONSO.intItemId  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , ICIT.dblCost     
            FROM tblICInventoryShipmentItem ICISI   
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') = 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   = 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId  
                                                    AND ICIT.intInTransitSourceLocationId  IS NULL  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1               
        ) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = NONLOTTED.intItemId  
                    AND ((ARID.intSalesOrderDetailId IS NOT NULL AND ARID.intSalesOrderDetailId = NONLOTTED.intLineNo) OR ARID.intSalesOrderDetailId IS NULL)  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                    , ICISI.intLineNo  
                    , ICISI.intItemId  
                    , ICISI.intItemUOMId  
                    , dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))  
            FROM tblICInventoryShipmentItem ICISI  
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   <> 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId    
                                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
            INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId  
                                AND ICISI.intItemUOMId = (CASE WHEN (ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1) THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)  
            GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId  
        ) AS LOTTED ON ARID.intInventoryShipmentItemId = LOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = LOTTED.intItemId      
                    AND ARID.intSalesOrderDetailId  = LOTTED.intLineNo  
        LEFT OUTER JOIN (  
            SELECT intInvoiceId  
                , dblNetTransferCost  
                , strTransactionType  
            FROM tblCFTransaction CF  
            WHERE ISNULL(CF.intInvoiceId, 0) <> 0  
        ) AS CFTRAN ON ARI.intInvoiceId = CFTRAN.intInvoiceId   
                AND ARI.strType = 'CF Tran'  
          
        WHERE ARI.ysnPosted = 1   
            AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')  
            AND ISNULL(ICI.strType, '') NOT IN ('Software', 'Bundle')  
            AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0  
  
        --start-- workaround for AR-6909 might changed once AR-6843 has been coded  
        UNION ALL  
        SELECT   
              
            strTransactionType  = ARI.strTransactionType  
            , intTransactionId   = ARI.intInvoiceId  
            , intEntityCustomerId  = ARI.intEntityCustomerId  
            , intItemAccountId   = CASE WHEN ICI.strType IN ('Non-Inventory','Service','Other Charge') THEN ISNULL(ARID.intAccountId, ARID.intSalesAccountId) ELSE ISNULL(ARID.intSalesAccountId, ARID.intAccountId) END  
            , dblQtyOrdered    = ARID.dblQtyOrdered  
            , dblQtyShipped    = ARID.dblQtyShipped  
            , dblStandardCost   = (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0  
                                                    THEN CASE WHEN ISNULL(NONSO.dblCost, 0) > 0 THEN ISNULL(NONSO.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(NONSO.dblCost, 0) END  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN CASE WHEN ISNULL(NONLOTTED.dblCost, 0) > 0 THEN ISNULL(NONLOTTED.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(NONLOTTED.dblCost, 0) END  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN CASE WHEN ISNULL(LOTTED.dblCost, 0) > 0 THEN ISNULL(LOTTED.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(LOTTED.dblCost, 0) END   
                                                ELSE CASE WHEN ISNULL(NONSO.dblCost, 0) > 0 THEN ISNULL(NONSO.dblCost, 0) / ARID.dblQtyShipped ELSE ISNULL(NONSO.dblCost, 0) END  
                                            END)  
            ,dblTotal  
   ,ARI.dtmDate  
        FROM tblARInvoiceDetail ARID   
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId  
        LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId  
        LEFT OUTER JOIN (  
            SELECT intTransactionId  
                , strTransactionId  
                , intTransactionDetailId  
                , dblCost = SUM(ICIT.dblCost * (ABS(ICIT.dblQty) * ICIT.dblUOMQty))  
            FROM tblICInventoryTransaction ICIT  
            INNER JOIN tblARInvoiceDetailComponent ARIDC ON ICIT.intTransactionDetailId = ARIDC.intInvoiceDetailId  
                                                        AND ICIT.intItemId = ARIDC.intComponentItemId  
            WHERE ICIT.ysnIsUnposted = 0  
            AND ICIT.intItemUOMId IS NOT NULL  
            AND ICIT.intTransactionTypeId <> 1  
            GROUP BY ICIT.intTransactionDetailId, ICIT.intTransactionId, ICIT.strTransactionId  
        ) AS NONSO ON ARI.intInvoiceId   = NONSO.intTransactionId  
                AND ARI.strInvoiceNumber  = NONSO.strTransactionId  
                AND ARID.intInvoiceDetailId  = NONSO.intTransactionDetailId  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , ICIT.dblCost     
            FROM tblICInventoryShipmentItem ICISI   
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') = 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   = 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                               AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId               
                                                    AND ICIT.intInTransitSourceLocationId  IS NULL  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
        ) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = NONLOTTED.intItemId        
                    AND ARID.intSalesOrderDetailId  = NONLOTTED.intLineNo  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                    , ICISI.intLineNo  
                    , ICISI.intItemId  
                    , ICISI.intItemUOMId  
                    , dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))  
            FROM tblICInventoryShipmentItem ICISI  
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   <> 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId    
                                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
            INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId  
                                AND ICISI.intItemUOMId = (CASE WHEN (ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1) THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)  
            GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId  
        ) AS LOTTED ON ARID.intInventoryShipmentItemId = LOTTED.intInventoryShipmentItemId  
                AND ARID.intItemId     = LOTTED.intItemId  
                AND ARID.intSalesOrderDetailId  = LOTTED.intLineNo  
        WHERE ARI.ysnPosted = 1   
        AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')  
        AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0  
        AND ISNULL(ICI.strType, '') = 'Bundle'   
        --end-- workaround for AR-6909 might changed once AR-6843 has been coded  
  
  
        UNION ALL  
  
        --INVOICE/SOFTWARE ITEMS/LICENSE MAINTENANCE TYPE  
        SELECT  
              
            strTransactionType  = ARI.strTransactionType  
            , intTransactionId   = ARI.intInvoiceId  
            ,intEntityCustomerId  = ARI.intEntityCustomerId  
            , intItemAccountId   = ARID.intLicenseAccountId   
            , dblQtyOrdered    = ARID.dblQtyOrdered  
            , dblQtyShipped    = ARID.dblQtyShipped  
            , dblStandardCost   = (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))  
                                                ELSE 0.000000  
                                            END)  
            ,dblTotal  
   ,ARI.dtmDate  
        FROM tblARInvoiceDetail ARID   
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId  
        LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId  
        LEFT OUTER JOIN (  
            SELECT intTransactionId  
                , strTransactionId  
                , intItemId  
                , intItemUOMId  
                , dblCost   = CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END  
            FROM tblICInventoryTransaction   
            WHERE ysnIsUnposted = 0  
            AND intItemUOMId IS NOT NULL  
            AND intTransactionTypeId <> 1  
            GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId  
        ) AS NONSO ON ARI.intInvoiceId  = NONSO.intTransactionId  
                AND ARI.strInvoiceNumber = NONSO.strTransactionId  
                AND ARID.intItemId  = NONSO.intItemId  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , ICIT.dblCost     
            FROM tblICInventoryShipmentItem ICISI   
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') = 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   = 0  
                                                    AND ICIS.intInventoryShipmentId   = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId      = ICIT.intItemId              
                                                    AND ICIT.intInTransitSourceLocationId  IS NULL  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
        ) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = NONLOTTED.intItemId  
                    AND ARID.intSalesOrderDetailId  = NONLOTTED.intLineNo  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))  
            FROM tblICInventoryShipmentItem ICISI  
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
            INNER JOIN tblICInventoryTransaction ICIT  
                ON ICIT.ysnIsUnposted     = 0  
                AND ISNULL(ICIT.intLotId, 0)   <> 0  
                AND ICIS.intInventoryShipmentId   = ICIT.intTransactionId  
                AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                AND ICISI.intItemId      = ICIT.intItemId    
                AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
                AND ICIT.intItemUOMId      IS NOT NULL  
                AND ICIT.intTransactionTypeId    <> 1  
            INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId  
                                AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)  
            GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId  
        ) AS LOTTED ON ARID.intInventoryShipmentItemId = LOTTED.intInventoryShipmentItemId  
                AND ARID.intItemId     = LOTTED.intItemId  
                AND ARID.intSalesOrderDetailId  = LOTTED.intLineNo  
        WHERE ARI.ysnPosted = 1   
        AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund')  
        AND ICI.strType = 'Software'  
        AND ARID.strMaintenanceType IN ('License/Maintenance', 'License Only')  
        AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0  
  
        UNION ALL  
        --INVOICE/SOFTWARE ITEMS/MAINTENANCE TYPE  
        SELECT  
            strTransactionType  = ARI.strTransactionType  
            , intTransactionId   = ARI.intInvoiceId  
            , intEntityCustomerId  = ARI.intEntityCustomerId  
            , intItemAccountId   = ARID.intMaintenanceAccountId  
            , dblQtyOrdered    = ARID.dblQtyOrdered  
            , dblQtyShipped    = ARID.dblQtyShipped  
            , dblStandardCost   = (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))  
                                                ELSE 0.000000  
                                            END)  
            ,dblTotal  
   ,ARI.dtmDate  
        FROM tblARInvoiceDetail ARID   
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId  
        LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId  
        LEFT OUTER JOIN (  
            SELECT intTransactionId  
                , strTransactionId  
                , intItemId  
                , intItemUOMId  
                , dblCost    = CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END  
            FROM tblICInventoryTransaction   
            WHERE ysnIsUnposted = 0  
            AND intItemUOMId IS NOT NULL  
            AND intTransactionTypeId <> 1   
            GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId  
        ) AS NONSO ON ARI.intInvoiceId  = NONSO.intTransactionId  
                AND ARI.strInvoiceNumber = NONSO.strTransactionId  
                AND ARID.intItemId  = NONSO.intItemId  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , ICIT.dblCost     
            FROM tblICInventoryShipmentItem ICISI   
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') = 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   = 0  
                                                    AND ICIS.intInventoryShipmentId   = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId      = ICIT.intItemId  
                                                    AND ICIT.intInTransitSourceLocationId  IS NULL  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
        ) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = NONLOTTED.intItemId  
                    AND ARID.intSalesOrderDetailId  = NONLOTTED.intLineNo  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))  
            FROM tblICInventoryShipmentItem ICISI  
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   <> 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId    
                                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
            INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId  
                                AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)  
            GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId  
        ) AS LOTTED ON ARID.intInventoryShipmentItemId = LOTTED.intInventoryShipmentItemId  
                AND ARID.intItemId     = LOTTED.intItemId  
                AND ARID.intSalesOrderDetailId  = LOTTED.intLineNo  
        WHERE ARI.ysnPosted = 1   
        AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund')  
        AND ICI.strType = 'Software'  
        AND ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')  
        AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0  
  
        UNION ALL  
  
          
  
          
        SELECT   
              
         strTransactionType  = ARI.strTransactionType  
            , intTransactionId   = ARI.intInvoiceId  
            , intEntityCustomerId  = ARI.intEntityCustomerId  
            , intItemAccountId   = ARID.intMaintenanceAccountId  
            , dblQtyOrdered    = ARID.dblQtyOrdered  
            , dblQtyShipped    = ARID.dblQtyShipped  
            , dblStandardCost   = (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))  
                                                ELSE 0.000000  
                                            END)  
            ,dblTotal  
   ,ARI.dtmDate  
        FROM tblARInvoiceDetail ARID   
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId  
        LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId  
        LEFT OUTER JOIN (  
            SELECT intTransactionId  
                , strTransactionId  
                , intItemId  
                , intItemUOMId  
                , dblCost    = CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END  
            FROM tblICInventoryTransaction   
            WHERE ysnIsUnposted = 0  
            AND intItemUOMId IS NOT NULL  
            AND intTransactionTypeId <> 1   
            GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId  
        ) AS NONSO ON ARI.intInvoiceId  = NONSO.intTransactionId  
                AND ARI.strInvoiceNumber = NONSO.strTransactionId  
                AND ARID.intItemId  = NONSO.intItemId  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , ICIT.dblCost     
            FROM tblICInventoryShipmentItem ICISI   
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') = 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   = 0  
                                                    AND ICIS.intInventoryShipmentId   = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId      = ICIT.intItemId  
                                                    AND ICIT.intInTransitSourceLocationId  IS NULL  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
        ) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = NONLOTTED.intItemId  
                    AND ARID.intSalesOrderDetailId  = NONLOTTED.intLineNo  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))  
            FROM tblICInventoryShipmentItem ICISI  
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   <> 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId    
                                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
            INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId  
                                AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)  
            GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId  
        ) AS LOTTED ON ARID.intInventoryShipmentItemId = LOTTED.intInventoryShipmentItemId  
                AND ARID.intItemId     = LOTTED.intItemId  
                AND ARID.intSalesOrderDetailId  = LOTTED.intLineNo  
        WHERE ARI.ysnPosted = 1   
        AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund')  
        AND ICI.strType = 'Software'  
        AND ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')  
        AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0  
  
        UNION ALL  
  
  
        --INVOICE/SOFTWARE ITEMS/NO MAINTENANCE TYPE  
        SELECT   
            strTransactionType  = ARI.strTransactionType  
            , intTransactionId   = ARI.intInvoiceId  
            , intEntityCustomerId  = ARI.intEntityCustomerId  
            , intItemAccountId   =  ISNULL(ARID.intSalesAccountId , ARID.intAccountId)     
            , dblQtyOrdered    = ARID.dblQtyOrdered  
            , dblQtyShipped    = ARID.dblQtyShipped  
            , dblStandardCost   = (CASE WHEN ISNULL(ARID.intInventoryShipmentItemId, 0) = 0              
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') = 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(NONLOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(NONLOTTED.dblCost, 0))  
                                                WHEN ISNULL(ICI.strLotTracking, 'No') <> 'No' AND ISNULL(ARID.intInventoryShipmentItemId, 0) <> 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) <> 0  
                                                    THEN dbo.fnCalculateCostBetweenUOM(LOTTED.intItemUOMId, ARID.intItemUOMId, ISNULL(LOTTED.dblCost, 0))  
                                                ELSE dbo.fnCalculateCostBetweenUOM(NONSO.intItemUOMId, ARID.intItemUOMId, ISNULL(NONSO.dblCost, 0))  
                                            END)  
            , dblTotal  
   ,ARI.dtmDate  
        FROM tblARInvoiceDetail ARID   
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId  
        LEFT JOIN tblICItem ICI ON ARID.intItemId = ICI.intItemId  
        LEFT OUTER JOIN (  
            SELECT intTransactionId  
                , strTransactionId  
                , intItemId  
                , intItemUOMId  
                , dblCost    = CASE WHEN SUM(dblQty) <> 0 THEN SUM(dblQty * dblCost + dblValue) / SUM(dblQty) ELSE 0 END  
            FROM tblICInventoryTransaction   
            WHERE ysnIsUnposted = 0  
            AND intItemUOMId IS NOT NULL  
            AND intTransactionTypeId <> 1  
            GROUP BY intTransactionId, strTransactionId, intItemId, intItemUOMId  
        ) AS NONSO ON ARI.intInvoiceId  = NONSO.intTransactionId  
                AND ARI.strInvoiceNumber = NONSO.strTransactionId  
                AND ARID.intItemId  = NONSO.intItemId       
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                    , ICISI.intLineNo  
                    , ICISI.intItemId  
                    , ICISI.intItemUOMId  
                    , ICIT.dblCost     
            FROM tblICInventoryShipmentItem ICISI   
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') = 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   = 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId               
                                                    AND ICIT.intInTransitSourceLocationId  IS NULL  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
        ) AS NONLOTTED ON ARID.intInventoryShipmentItemId = NONLOTTED.intInventoryShipmentItemId  
                    AND ARID.intItemId     = NONLOTTED.intItemId  
                    AND ARID.intSalesOrderDetailId  = NONLOTTED.intLineNo  
        LEFT OUTER JOIN (  
            SELECT ICISI.intInventoryShipmentItemId  
                , ICISI.intLineNo  
                , ICISI.intItemId  
                , ICISI.intItemUOMId  
                , dblCost = ABS(AVG(ICIT.dblQty * ICIT.dblCost))  
            FROM tblICInventoryShipmentItem ICISI  
            INNER JOIN tblICInventoryShipment ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId  
            INNER JOIN tblICItem ICI ON ICISI.intItemId = ICI.intItemId  
                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
            INNER JOIN tblICInventoryTransaction ICIT ON ICIT.ysnIsUnposted     = 0  
                                                    AND ISNULL(ICIT.intLotId, 0)   <> 0  
                                                    AND ICIS.intInventoryShipmentId  = ICIT.intTransactionId  
                                                    AND ICIS.strShipmentNumber    = ICIT.strTransactionId  
                                                    AND ICISI.intInventoryShipmentItemId = ICIT.intTransactionDetailId  
                                                    AND ICISI.intItemId     = ICIT.intItemId    
                                                    AND ISNULL(ICI.strLotTracking, 'No') <> 'No'  
                                                    AND ICIT.intItemUOMId      IS NOT NULL  
                                                    AND ICIT.intTransactionTypeId    <> 1  
            INNER JOIN tblICLot ICL ON ICIT.intLotId = ICL.intLotId  
                                AND ICISI.intItemUOMId = (CASE WHEN ICI.strType = 'Finished Good' OR ICI.ysnAutoBlend = 1 THEN ICISI.intItemUOMId ELSE ICL.intItemUOMId END)  
            GROUP BY ICISI.intInventoryShipmentItemId, ICISI.intLineNo, ICISI.intItemId, ICISI.intItemUOMId  
        ) AS LOTTED ON ARID.intInventoryShipmentItemId = LOTTED.intInventoryShipmentItemId  
                AND ARID.intItemId     = LOTTED.intItemId        
                AND ARID.intSalesOrderDetailId  = LOTTED.intLineNo  
        WHERE ARI.ysnPosted = 1   
        AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Service Charge')  
        AND ISNULL(ICI.strType, '') = 'Software'  
        AND ISNULL(ARID.strMaintenanceType  ,'') =''  
        AND ISNULL(ARID.intStorageScheduleTypeId, 0) = 0  
    ) AS SAR  
    LEFT JOIN tblGLAccount GA ON SAR.intItemAccountId = GA.intAccountId  
    INNER JOIN (  
        tblARCustomer C   
        INNER JOIN tblEMEntity E ON C.[intEntityId] = E.intEntityId  
    ) ON SAR.intEntityCustomerId = C.[intEntityId]  
),  
totalQuery as (  
    SELECT   
	dtmDate,  
    SUM(dblTotalCost) Expense,  
    SUM(A.dblTotal) - SUM( dblTotalCost) Net,   
    SUM(A.dblTotal) Revenue  
    FROM Query A   
    GROUP BY dtmDate  
)  
SELECT 'Expense' strType , Expense dblAmount, dtmDate  FROM totalQuery   
UNION  
SELECT 'Revenue'  strType , Revenue dblAmount, dtmDate  FROM totalQuery   
UNION  
SELECT 'Net' strType , Net dblAmount, dtmDate  FROM totalQuery 
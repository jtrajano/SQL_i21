CREATE VIEW [dbo].[vyuSTDealerCommission]  
AS  
SELECT      a.intStoreId,
            GETDATE() AS dtmReportProducedOn,
            a.strDescription AS strDealerName,
            '' AS strDateRange,
            b.dtmCheckoutDate, 
            b.dblTotalSales AS dblSalesAmount,
            b.dblDealerCommission,
            CASE
                WHEN b.strCheckoutStatus = 'Posted'
                THEN b.dblTotalSales
                ELSE 0
                END AS dblPaid,
            CASE
                WHEN b.strCheckoutStatus = 'Posted'
                THEN 0
                ELSE b.dblTotalSales
                END AS dblBalance
FROM        tblSTStore a
LEFT JOIN   tblSTCheckoutHeader b
ON          a.intStoreId = b.intStoreId
CREATE VIEW dbo.vyuCFCalculatedInvoice
AS
SELECT        cfInv.intCustomerId, cfInv.strTempInvoiceReportNumber, cfInv.dblAccountTotalAmount, cfInv.dblAccountTotalDiscount, cfInv.intTermID, cfInv.dtmInvoiceDate, cfInvFee.dblFeeTotalAmount, 
                         cfInv.dblAccountTotalAmount + ISNULL(cfInvFee.dblFeeTotalAmount,0) AS dblInvoiceTotal, SUM(cfInv.dblQuantity) AS dblTotalQuantity, cfInv.dblEligableGallon, cfInv.strCustomerName, cfInv.strEmail, 
                         cfInv.strEmailDistributionOption, 'Ready' AS strStatus
FROM            dbo.tblCFInvoiceStagingTable AS cfInv LEFT JOIN
                             (SELECT        dblFeeTotalAmount, intAccountId
                               FROM            dbo.tblCFInvoiceFeeStagingTable
                               GROUP BY intAccountId, dblFeeTotalAmount) AS cfInvFee ON cfInv.intAccountId = cfInvFee.intAccountId
GROUP BY cfInv.intCustomerId, cfInv.strTempInvoiceReportNumber, cfInv.dblAccountTotalAmount, cfInv.dblAccountTotalDiscount, cfInv.intTermID, cfInv.dtmInvoiceDate, cfInv.intSalesPersonId, cfInvFee.dblFeeTotalAmount, 
                         cfInv.dblEligableGallon, cfInv.strCustomerName, cfInv.strEmail, cfInv.strEmailDistributionOption
GO
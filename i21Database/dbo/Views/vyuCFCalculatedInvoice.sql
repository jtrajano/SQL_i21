CREATE VIEW [dbo].[vyuCFCalculatedInvoice]
AS

SELECT  
	 strCustomerNumber,
	 strUserId,intCustomerId, 
	 strTempInvoiceReportNumber, 
	 dblAccountTotalAmount, 
	 dblAccountTotalDiscount, 
	 intTermID,
	 dtmInvoiceDate, 
	 dblFeeTotalAmount, 
	 dblInvoiceTotal, 
	 SUM(dblQuantity) AS dblTotalQuantity, 
	 dblEligableGallon, 
	 strCustomerName, 
	 strEmail, 
	 strEmailDistributionOption, 
	 strStatus,
	 CASE 
			WHEN (ISNULL(strEmail,'') != '') AND (strEmailDistributionOption like '%CF Invoice%') THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
			END
			AS ysnEmail
FROM (
	SELECT        
		cfInv.strCustomerNumber,
		cfInv.strUserId,
		cfInv.intCustomerId, 
		cfInv.strTempInvoiceReportNumber, 
		cfInv.dblAccountTotalAmount, 
		cfInv.dblAccountTotalDiscount, 
		CASE strTransactionType
			WHEN 'Foreign Sale' THEN NULL
			ELSE cfInv.intTermID
			END
			AS intTermID,
		cfInv.dtmInvoiceDate, 
		cfInvFee.dblFeeTotalAmount, 
		ISNULL(cfInv.dblAccountTotalAmount,0) + ISNULL(cfInvFee.dblFeeTotalAmount,0) AS dblInvoiceTotal, 
		cfInv.dblQuantity, 
		cfInv.dblEligableGallon, 
		cfInv.strCustomerName, 
		cfInv.strEmail, 
		cfInv.strEmailDistributionOption, 
		'Ready' AS strStatus
	FROM            dbo.tblCFInvoiceStagingTable AS cfInv 
	LEFT JOIN
	(SELECT        dblFeeTotalAmount, intAccountId
	FROM            dbo.tblCFInvoiceFeeStagingTable
	GROUP BY intAccountId, dblFeeTotalAmount) AS cfInvFee 
	ON cfInv.intAccountId = cfInvFee.intAccountId) AS outertable
	GROUP BY intCustomerId, strTempInvoiceReportNumber, dblAccountTotalAmount, dblAccountTotalDiscount, intTermID, dtmInvoiceDate, dblFeeTotalAmount, 
	dblEligableGallon, strCustomerName, strEmail, strEmailDistributionOption,strCustomerNumber,strUserId,dblInvoiceTotal,strStatus
GO



CREATE VIEW [dbo].[vyuCFCalculatedInvoice]
AS

SELECT  
	 strCustomerNumber,
	 strUserId,
	 intCustomerId, 
	 strTempInvoiceReportNumber, 
	 dblAccountTotalAmount , 
	 dblAccountTotalDiscount, 
	 intTermID,
	 dtmInvoiceDate, 
	 dblFeeTotalAmount, 
	 dblInvoiceTotal = dblInvoiceTotal + ISNULL(dblTotalFuelExpensed,0), 
	 SUM(dblQuantity) AS dblTotalQuantity, 
	 dblEligableGallon, 
	 strCustomerName, 
	 strEmail, 
	 strEmailDistributionOption, 
	 strStatus,
	 strStatementType,
	 CASE 
			WHEN (ISNULL(strEmail,'') != '') AND (strEmailDistributionOption like '%CF Invoice%') THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
			END
			AS ysnEmail,
	 dblTotalFuelExpensed

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
		dblFeeTotalAmount = CASE 
								WHEN LOWER(strStatementType) = 'invoice'
								THEN cfInvFee.dblFeeTotalAmount
							ELSE 0
							END, 
		dblInvoiceTotal =	CASE 
								WHEN LOWER(strStatementType) = 'invoice'
								THEN ISNULL(cfInv.dblAccountTotalAmount,0) + ISNULL(cfInvFee.dblFeeTotalAmount,0)
							ELSE ISNULL(cfInv.dblAccountTotalAmount,0)
							END,
		cfInv.dblQuantity, 
		cfInv.dblEligableGallon, 
		cfInv.strCustomerName, 
		cfInv.strEmail, 
		cfInv.strEmailDistributionOption, 
		dblTotalFuelExpensed,
		cfInv.strStatementType,
		'Ready' AS strStatus
	FROM            dbo.tblCFInvoiceStagingTable AS cfInv 
	LEFT JOIN
	(SELECT        dblFeeTotalAmount 
	, intAccountId, strUserId
	FROM            dbo.tblCFInvoiceFeeStagingTable
	GROUP BY intAccountId, dblFeeTotalAmount, strUserId) AS cfInvFee 
	ON cfInv.intAccountId = cfInvFee.intAccountId
	AND cfInv.strUserId  COLLATE Latin1_General_CI_AS = cfInvFee.strUserId) AS outertable
	GROUP BY intCustomerId, strTempInvoiceReportNumber, dblAccountTotalAmount, dblAccountTotalDiscount, intTermID, dtmInvoiceDate, dblFeeTotalAmount, 
	dblEligableGallon, strCustomerName, strEmail, strEmailDistributionOption,strCustomerNumber,strUserId,dblInvoiceTotal,strStatus,dblTotalFuelExpensed,strStatementType
GO




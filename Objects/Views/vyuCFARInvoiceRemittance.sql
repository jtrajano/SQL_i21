


CREATE VIEW [dbo].[vyuCFARInvoiceRemittance]
AS


SELECT 
 *
FROM 
(SELECT
 intEntityCustomerId					AS intCustomerId
,strCFTempInvoiceReportNumber			AS strTempInvoiceReportNumber
,dblCFAccountTotalAmount				AS dblAccountTotalAmount 		
,dblCFAccountTotalDiscount				AS dblAccountTotalDiscount				
,intCFTermID							AS intTermID							
,dtmCFInvoiceDate						AS dtmInvoiceDate						
,ISNULL(dblCFFeeTotalAmount,0) 			AS dblFeeTotalAmount 					
,dblCFEligableGallon					AS dblEligableGallon					
,strCustomerName						AS strCustomerName
,strCFEmail								AS strEmail								
,strCFEmailDistributionOption			AS strEmailDistributionOption	
,arStaging.strCustomerNumber			AS strCustomerNumber	
,intEntityUserId	
, CASE 
			WHEN (ISNULL(strCFEmail,'') != '') AND (strCFEmailDistributionOption like '%CF Invoice%') THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
			END
			AS ysnEmail,
dblCFTotalFuelExpensed					AS dblTotalFuelExpensed
,arCust.ysnActive						AS ysnActive
FROM            dbo.tblARCustomerStatementStagingTable arStaging
INNER JOIN tblARCustomer as arCust
ON arCust.intEntityId = arStaging.intEntityCustomerId 
GROUP BY 
intEntityCustomerId, 
strCFTempInvoiceReportNumber, 
dblCFAccountTotalAmount, 
dblCFAccountTotalDiscount, 
intCFTermID, 
dtmCFInvoiceDate, 
dblCFFeeTotalAmount, 
dblCFEligableGallon, 
strCustomerName,
strCFEmail, 
strCFEmailDistributionOption,
arStaging.strCustomerNumber,
intEntityUserId,
dblCFTotalFuelExpensed,
arCust.ysnActive) as tbl1
INNER JOIN 

(SELECT intEntityCustomerId,
SUM(CASE WHEN strTransactionType IN ('Payment',
'Discount Taken') THEN dblPayment * - 1 WHEN
strTransactionType = 'Balance Forward' THEN dblBalance ELSE
dblInvoiceTotal END) as dblBalance
from
tblARCustomerStatementStagingTable
group by intEntityCustomerId) as tbl2
ON tbl2.intEntityCustomerId = tbl1.intCustomerId
GO



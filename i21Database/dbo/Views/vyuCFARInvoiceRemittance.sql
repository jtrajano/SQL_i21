﻿
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
,dblCFFeeTotalAmount 					AS dblFeeTotalAmount 					
,dblCFEligableGallon					AS dblEligableGallon					
,strCustomerName						AS strCustomerName
,strCFEmail								AS strEmail								
,strCFEmailDistributionOption			AS strEmailDistributionOption	
,strCustomerNumber						AS strCustomerNumber		
FROM            dbo.tblARCustomerStatementStagingTable 
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
strCustomerNumber) as tbl1

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
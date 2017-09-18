
CREATE VIEW [dbo].[vyuCFARInvoiceRemittance]
AS

SELECT
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
strCustomerNumber
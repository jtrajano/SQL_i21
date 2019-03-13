CREATE PROCEDURE [dbo].[uspCFInvoiceReportSummary](
	@UserId NVARCHAR(MAX)
)
AS
BEGIN 

	INSERT INTO tblCFInvoiceSummaryTempTable(
		 intDiscountScheduleId
		,intTermsCode
		,intTermsId
		,intARItemId
		,strDepartmentDescription
		,strShortName
		,strProductDescription
		,strItemNumber
		,strItemDescription
		,dblTotalQuantity
		,dblTotalGrossAmount
		,dblTotalNetAmount
		,dblTotalAmount
		,dblTotalTaxAmount
		,TotalFET
		,TotalSET
		,TotalSST
		,TotalLC
		,ysnIncludeInQuantityDiscount
		,intAccountId
		,intTransactionId
		,strUserId					
	)
	SELECT 
		 intDiscountScheduleId
		,intTermsCode
		,intTermsId
		,intARItemId
		,strDepartmentDescription
		,strShortName
		,strProductDescription
		,strItemNumber
		,strItemDescription
		,dblTotalQuantity
		,dblTotalGrossAmount
		,dblTotalNetAmount
		,dblTotalAmount
		,dblTotalTaxAmount
		,TotalFET
		,TotalSET
		,TotalSST
		,TotalLC
		,ysnIncludeInQuantityDiscount
		,intAccountId
		,intTransactionId
		,@UserId			
	FROM
	vyuCFInvoiceReportSummary
	WHERE intTransactionId IN (SELECT intTransactionId FROM tblCFInvoiceReportTempTable WHERE strUserId = @UserId)

END
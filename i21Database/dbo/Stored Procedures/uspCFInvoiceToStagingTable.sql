
CREATE PROCEDURE [dbo].[uspCFInvoiceToStagingTable](
	 @xmlParam					NVARCHAR(MAX)  
	,@ErrorMessage				NVARCHAR(250)  = NULL	OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@SuccessfulPostCount		INT			   = 0		OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN

	DECLARE @CatchErrorMessage NVARCHAR(MAX);  
	DECLARE @CatchErrorSeverity INT;  
	DECLARE @CatchErrorState INT;  
	DECLARE @index INT = 0

	-------------CLEAN TEMP TABLES------------
	DELETE FROM tblCFInvoiceReportTempTable
	DELETE FROM tblCFInvoiceSummaryTempTable
	DELETE FROM tblCFInvoiceDiscountTempTable
	DELETE FROM tblCFInvoiceStagingTable
	DELETE FROM tblCFInvoiceFeeStagingTable
	------------------------------------------

BEGIN TRY


	IF (@@TRANCOUNT = 0) BEGIN TRANSACTION

	-- EXECUTE INVOICE REPORT SP's--
	-----------------------------------------------------------
	-- EXECUTING THIS SP's WILL INSERT RECORDS ON TEMP TABLES--
	-----------------------------------------------------------
	EXEC "dbo"."uspCFInvoiceReport"			@xmlParam	=	@xmlParam

	SELECT * FROM tblCFInvoiceReportTempTable

	EXEC "dbo"."uspCFInvoiceReportSummary"	@xmlParam	=	@xmlParam

	SELECT * FROM tblCFInvoiceSummaryTempTable

	EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam	=	@xmlParam

	SELECT * FROM tblCFInvoiceDiscountTempTable
	

	-- INSERT CALCULATED INVOICES TO STAGING TABLE --
	-----------------------------------------------------------
	INSERT INTO tblCFInvoiceStagingTable
	(
	 intCustomerGroupId
	,intTransactionId
	,intOdometer
	,intOdometerAging
	,intInvoiceId
	,intProductId
	,intCardId
	,intAccountId
	,intInvoiceCycle
	,intSubAccountId
	,intCustomerId
	,intDiscountScheduleId
	,intTermsCode
	,intTermsId
	,intARItemId
	,intSalesPersonId
	,intTermID
	,intBalanceDue
	,intDiscountDay
	,intDayofMonthDue
	,intDueNextMonth
	,intSort
	,strGroupName
	,strCustomerNumber
	,strShipTo
	,strBillTo
	,strCompanyName
	,strCompanyAddress
	,strType
	,strCustomerName
	,strLocationName
	,strInvoiceNumber
	,strTransactionId
	,strTransactionType
	,strInvoiceReportNumber
	,strTempInvoiceReportNumber
	,strMiscellaneous
	,strName
	,strCardNumber
	,strCardDescription
	,strNetwork
	,strInvoiceCycle
	,strPrimarySortOptions
	,strSecondarySortOptions
	,strPrintRemittancePage
	,strPrintPricePerGallon
	,strPrintSiteAddress
	,strSiteNumber
	,strSiteName
	,strProductNumber
	,strItemNo
	,strDescription
	,strVehicleNumber
	,strVehicleDescription
	,strTaxState
	,strDepartment
	,strSiteType
	,strState
	,strSiteAddress
	,strSiteCity
	,strPrintTimeStamp
	,strEmailDistributionOption 
	,strEmail
	,strDepartmentDescription
	,strShortName
	,strProductDescription
	,strItemNumber
	,strItemDescription
	,strTerm
	,strTermCode
	,strTermType
	,dtmTransactionDate
	,dtmDate
	,dtmPostedDate
	,dtmDiscountDate
	,dtmDueDate
	,dtmInvoiceDate
	,dblTotalMiles
	,dblQuantity
	,dblCalculatedTotalAmount
	,dblOriginalTotalAmount
	,dblCalculatedGrossAmount
	,dblOriginalGrossAmount
	,dblCalculatedNetAmount
	,dblOriginalNetAmount
	,dblMargin
	,dblTotalTax
	,dblTotalSST
	,dblTaxExceptSST
	,dblInvoiceTotal
	,dblTotalQuantity
	,dblTotalGrossAmount
	,dblTotalNetAmount
	,dblTotalAmount
	,dblTotalTaxAmount
	,dblEligableGallon
	,TotalFET
	,TotalSET
	,TotalSST
	,TotalLC
	,dblDiscountRate
	,dblDiscount
	,dblAccountTotalAmount
	,dblAccountTotalDiscount
	,dblAccountTotalLessDiscount
	,dblDiscountEP
	,dblAPR
	,ysnPrintMiscellaneous
	,ysnSummaryByCard
	,ysnSummaryByDepartment
	,ysnSummaryByMiscellaneous
	,ysnSummaryByProduct
	,ysnSummaryByVehicle
	,ysnSummaryByCardProd	 
	,ysnSummaryByDeptCardProd
	,ysnPrintTimeOnInvoices
	,ysnPrintTimeOnReports
	,ysnInvalid
	,ysnPosted
	,ysnIncludeInQuantityDiscount
	,ysnShowOnCFInvoice
	,strDiscountSchedule
	,ysnPostForeignSales
	)
	SELECT 
	 intCustomerGroupId
	,cfInvRpt.intTransactionId
	,intOdometer
	,intOdometerAging
	,intInvoiceId
	,intProductId
	,intCardId
	,cfInvRpt.intAccountId
	,intInvoiceCycle
	,intSubAccountId
	,intCustomerId
	,intDiscountScheduleId
	,intTermsCode
	,intTermsId
	,intARItemId
	,intSalesPersonId
	,intTermID
	,intBalanceDue
	,intDiscountDay
	,intDayofMonthDue
	,intDueNextMonth
	,intSort
	,strGroupName
	,strCustomerNumber
	,strShipTo
	,strBillTo
	,strCompanyName
	,strCompanyAddress
	,strType
	,strCustomerName
	,strLocationName
	,strInvoiceNumber
	,strTransactionId
	,strTransactionType
	,strInvoiceReportNumber
	,strTempInvoiceReportNumber
	,strMiscellaneous
	,strName
	,strCardNumber
	,strCardDescription
	,strNetwork
	,strInvoiceCycle
	,ISNULL(strPrimarySortOptions,'Vehicle') AS strPrimarySortOptions
	,ISNULL(strSecondarySortOptions,'Vehicle') AS strSecondarySortOptions
	,strPrintRemittancePage
	,strPrintPricePerGallon
	,strPrintSiteAddress
	,strSiteNumber
	,strSiteName
	,strProductNumber
	,strItemNo
	,strDescription
	,strVehicleNumber
	,strVehicleDescription
	,strTaxState
	,strDepartment
	,strSiteType
	,strState
	,strSiteAddress
	,strSiteCity
	,strPrintTimeStamp
	,ISNULL(strEmailDistributionOption,'') 
	,strEmail
	,strDepartmentDescription
	,strShortName
	,strProductDescription
	,strItemNumber
	,strItemDescription
	,strTerm
	,strTermCode
	,strTermType
	,dtmTransactionDate
	,dtmDate
	,dtmPostedDate
	,dtmDiscountDate
	,dtmDueDate
	,dtmInvoiceDate
	,dblTotalMiles
	,dblQuantity
	,dblCalculatedTotalAmount
	,dblOriginalTotalAmount
	,dblCalculatedGrossAmount
	,dblOriginalGrossAmount
	,dblCalculatedNetAmount
	,dblOriginalNetAmount
	,dblMargin
	,dblTotalTax
	,dblTotalSST
	,dblTaxExceptSST
	,dblAccountTotalAmount --AS dblInvoiceTotal
	,dblTotalQuantity
	,dblTotalGrossAmount
	,dblTotalNetAmount
	,dblTotalAmount
	,dblTotalTaxAmount
	,dblEligableGallon
	,TotalFET
	,TotalSET
	,TotalSST
	,TotalLC
	,dblDiscountRate
	,dblDiscount
	,dblAccountTotalAmount
	,dblAccountTotalDiscount
	,dblAccountTotalLessDiscount
	,dblDiscountEP
	,dblAPR
	,ISNULL(ysnPrintMiscellaneous,1) AS ysnPrintMiscellaneous
	,ISNULL(ysnSummaryByCard,1)	AS ysnSummaryByCard			
	,ISNULL(ysnSummaryByDepartment,1) AS ysnSummaryByDepartment		
	,ISNULL(ysnSummaryByMiscellaneous,1) AS ysnSummaryByMiscellaneous	
	,ISNULL(ysnSummaryByProduct,1) AS ysnSummaryByProduct			
	,ISNULL(ysnSummaryByVehicle,1) AS ysnSummaryByVehicle			
	,ISNULL(ysnSummaryByCardProd,1) AS ysnSummaryByCardProd	 	
	,ISNULL(ysnSummaryByDeptCardProd,1) AS ysnSummaryByDeptCardProd	
	,ISNULL(ysnPrintTimeOnInvoices,1) AS ysnPrintTimeOnInvoices		
	,ISNULL(ysnPrintTimeOnReports,1) AS ysnPrintTimeOnReports		
	,ysnInvalid
	,ysnPosted
	,ysnIncludeInQuantityDiscount
	,cfInvRptDcnt.ysnShowOnCFInvoice
	,cfInvRptDcnt.strDiscountSchedule
	,cfInvRpt.ysnPostForeignSales
	FROM tblCFInvoiceReportTempTable AS cfInvRpt
	INNER JOIN tblCFInvoiceSummaryTempTable AS cfInvRptSum
	ON cfInvRpt.intTransactionId = cfInvRptSum.intTransactionId
	INNER JOIN tblCFInvoiceDiscountTempTable AS cfInvRptDcnt
	ON cfInvRpt.intTransactionId = cfInvRptDcnt.intTransactionId

	SELECT DISTINCT 
	 intAccountId
	,intCustomerId
	,strCustomerName
	FROM tblCFInvoiceStagingTable

	--INSERT FEE RECORDS--
	EXEC "dbo"."uspCFInvoiceReportFee"		@xmlParam	=	@xmlParam

	IF (@@TRANCOUNT > 0) COMMIT TRANSACTION 

END TRY 
BEGIN CATCH
	
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
  
	SELECT   
		@CatchErrorMessage = ERROR_MESSAGE(),  
		@CatchErrorSeverity = ERROR_SEVERITY(),  
		@CatchErrorState = ERROR_STATE();  

	-------------CLEAN TEMP TABLES------------
	DELETE FROM tblCFInvoiceReportTempTable
	DELETE FROM tblCFInvoiceSummaryTempTable
	DELETE FROM tblCFInvoiceDiscountTempTable
	DELETE FROM tblCFInvoiceStagingTable
	DELETE FROM tblCFInvoiceFeeStagingTable
	------------------------------------------

END CATCH
END
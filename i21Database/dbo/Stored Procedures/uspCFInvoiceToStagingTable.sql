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
	EXEC "dbo"."uspCFInvoiceReportSummary"	@xmlParam	=	@xmlParam
	EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam	=	@xmlParam
	

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
	,ysnPrintTimeOnInvoices
	,ysnPrintTimeOnReports
	,ysnInvalid
	,ysnPosted
	,ysnIncludeInQuantityDiscount
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
	,ysnPrintTimeOnInvoices
	,ysnPrintTimeOnReports
	,ysnInvalid
	,ysnPosted
	,ysnIncludeInQuantityDiscount
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
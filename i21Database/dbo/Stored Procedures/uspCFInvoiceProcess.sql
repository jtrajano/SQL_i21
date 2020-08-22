CREATE PROCEDURE [dbo].[uspCFInvoiceProcess](
	 @entityId					INT			   = NULL
	,@username					NVARCHAR(MAX)  
	,@ErrorMessage				NVARCHAR(250)  = NULL	OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@SuccessfulPostCount		INT			   = 0		OUTPUT
	,@InvalidPostCount			INT			   = 0		OUTPUT
	,@ysnDevMode				BIT = 0
	,@reportName				NVARCHAR(MAX)
	,@balanceForwardDate		DATETIME	   = NULL
)
AS
BEGIN

	----------RESET INVOICE RESULTS-----------
	DELETE FROM tblCFInvoiceProcessResult
	DELETE FROM tblCFLog
	------------------------------------------

	INSERT INTO tblCFLog(
		 strProcess,strProcessid,strCallStack,strMessage,intSortId)
	SELECT 'Main process started','','Process Invoice','Begin transaction',0

BEGIN TRY

	DECLARE	@return_value int
	DECLARE @loopAccountId				INT
	DECLARE @loopCustomerId				INT
	DECLARE @CFID NVARCHAR(MAX)

	IF (@@TRANCOUNT = 0) BEGIN TRANSACTION

	----------CREATE TEMPORARY TABLE----------
	CREATE TABLE #tblCFDisctinctCustomerInvoice	
	(
		intAccountId					INT
		,intCustomerId					INT
	)
	CREATE TABLE #tblCFInvoice	
		(
			 intAccountId					INT
			,intSalesPersonId				INT
			,dtmInvoiceDate					DATETIME
			,intCustomerId					INT
			,intInvoiceId					INT
			,intTransactionId				INT
			,intCustomerGroupId				INT
			,intTermID						INT
			,intBalanceDue					INT
			,intDiscountDay					INT	
			,intDayofMonthDue				INT
			,intDueNextMonth				INT
			,intSort						INT
			,intConcurrencyId				INT
			,ysnAllowEFT					BIT
			,ysnActive						BIT
			,ysnEnergyTrac					BIT
			,dblQuantity					NUMERIC(18,6)
			,dblTotalQuantity				NUMERIC(18,6)
			,dblDiscountRate				NUMERIC(18,6)
			,dblDiscount					NUMERIC(18,6)
			,dblTotalAmount					NUMERIC(18,6)
			,dblAccountTotalAmount			NUMERIC(18,6)
			,dblAccountTotalDiscount		NUMERIC(18,6)
			,dblAccountTotalLessDiscount	NUMERIC(18,6)
			,dblDiscountEP					NUMERIC(18,6)
			,dblAPR							NUMERIC(18,6)	
			,strTerm						NVARCHAR(MAX)
			,strType						NVARCHAR(MAX)
			,strTermCode					NVARCHAR(MAX)	
			,strNetwork						NVARCHAR(MAX)	
			,strCustomerName				NVARCHAR(MAX)
			,strInvoiceCycle				NVARCHAR(MAX)
			,strGroupName					NVARCHAR(MAX)
			,strInvoiceNumber				NVARCHAR(MAX)
			,strInvoiceReportNumber			NVARCHAR(MAX)
			,dtmDiscountDate				DATETIME
			,dtmDueDate						DATETIME
			,dtmTransactionDate				DATETIME
			,dtmPostedDate					DATETIME
		)
	----------------------------------------
	DECLARE @ysnHasError BIT = 0
	DECLARE @dtmInvoiceDate DATETIME
	DECLARE @statementType NVARCHAR(10)= 'invoice'

	-------------INVOICE LIST-------------
	--INSERT INTO #tblCFInvoice
	--EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam=@xmlParam
	--------------------------------------

	--UPDATE tblCFTransaction SET strInvoiceReportNumber = strTempInvoiceReportNumber WHERE intTransactionId IN (SELECT intTransactionId FROM tblCFInvoiceStagingTable WHERE strUserId = @username AND LOWER(strStatementType) = @statementType) -- AND (strTransactionType != 'Foreign Sale' OR ISNULL(ysnPostForeignSales,0) != 0)
	--SELECT TOP 1 @dtmInvoiceDate = dtmInvoiceDate FROM #tblCFInvoice


	UPDATE tblCFTransaction SET strInvoiceReportNumber = cfS.strTempInvoiceReportNumber , dtmInvoiceDate = cfS.dtmInvoiceDate
	FROM (
		SELECT intTransactionId,strTempInvoiceReportNumber,dtmInvoiceDate FROM tblCFInvoiceStagingTable WHERE strUserId = @username AND LOWER(strStatementType) = @statementType
	) as cfS
	WHERE cfS.intTransactionId = tblCFTransaction.intTransactionId

	SELECT TOP 1 @dtmInvoiceDate = dtmInvoiceDate FROM tblCFInvoiceStagingTable WHERE strUserId = @username AND LOWER(strStatementType) = @statementType

	------------GROUP BY CUSTOMER-----------
	--INSERT INTO #tblCFDisctinctCustomerInvoice(
	--	intAccountId	
	--	,intCustomerId	
	--)
	--SELECT 
	--	intAccountId	
	--	,intCustomerId	
	--FROM #tblCFInvoice
	--GROUP BY intAccountId,intCustomerId	
	----------------------------------------

	------------UPDATE INVOICE REPORT NUMBER-----------
	--WHILE (EXISTS(SELECT 1 FROM #tblCFDisctinctCustomerInvoice))
	---------------------------------------------------
	--BEGIN
			
	--	EXEC uspSMGetStartingNumber 53, @CFID OUT

	--	SELECT	@loopCustomerId = intCustomerId, 
	--			@loopAccountId = intAccountId 
	--	FROM #tblCFDisctinctCustomerInvoice

	--	UPDATE tblCFTransaction SET strInvoiceReportNumber =  @CFID WHERE intTransactionId IN (SELECT intTransactionId FROM #tblCFInvoice WHERE intAccountId = @loopAccountId AND intCustomerId = @loopCustomerId)
	
	--	DELETE FROM #tblCFDisctinctCustomerInvoice WHERE intAccountId = @loopAccountId AND intCustomerId = @loopCustomerId

	--END
	

	EXEC	@return_value = [dbo].[uspCFCreateInvoicePayment]
			 @entityId				= @entityId
			,@username				= @username
			,@ErrorMessage			= @ErrorMessage			OUTPUT
			,@CreatedIvoices		= @CreatedIvoices		OUTPUT
			,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT
			,@SuccessfulPostCount	= @SuccessfulPostCount	OUTPUT
			,@InvalidPostCount		= @InvalidPostCount		OUTPUT
			,@ysnDevMode			= @ysnDevMode

	SELECT	'Payment'				AS 'Process'
			,@ErrorMessage			AS 'ErrorMessage'
			,@CreatedIvoices		AS 'CreatedIvoices'
			,@UpdatedIvoices		AS 'UpdatedIvoices'
			,@SuccessfulPostCount	AS 'SuccessfulPostCount'
			,@InvalidPostCount		AS 'InvalidPostCount'

	IF (@ErrorMessage IS NOT NULL)
	BEGIN
		SET @ysnHasError = 1
	END

	EXEC	@return_value = [dbo].[uspCFCreateDebitMemo]
			@entityId		= @entityId,
			@username		= @username,
			@ErrorMessage	= @ErrorMessage OUTPUT,
			@CreatedIvoices = @CreatedIvoices OUTPUT,
			@UpdatedIvoices = @UpdatedIvoices OUTPUT,
			@ysnDevMode		= @ysnDevMode

	SELECT	'Debit Memo'			AS 'Process'
			,@ErrorMessage			AS 'ErrorMessage'
			,@CreatedIvoices		AS 'CreatedIvoices'
			,@UpdatedIvoices		AS 'UpdatedIvoices'

	IF (@ErrorMessage IS NOT NULL)
	BEGIN
		SET @ysnHasError = 1
	END

	--EXEC	@return_value = [dbo].[uspCFCreateFeeDebitMemo]
	--		@xmlParam = @xmlParam,
	--		@entityId = @entityId,
	--		@ErrorMessage = @ErrorMessage OUTPUT,
	--		@CreatedIvoices = @CreatedIvoices OUTPUT,
	--		@UpdatedIvoices = @UpdatedIvoices OUTPUT,
	--		@ysnDevMode = @ysnDevMode

	--IF (@ErrorMessage IS NOT NULL)
	--BEGIN
	--	SET @ysnHasError = 1
	--END

	--SELECT	'Debit Memo'			AS 'Process'
	--		,@ErrorMessage			AS 'ErrorMessage'
	--		,@CreatedIvoices		AS 'CreatedIvoices'
	--		,@UpdatedIvoices		AS 'UpdatedIvoices'

	DECLARE @CatchErrorMessage NVARCHAR(MAX);  
	DECLARE @CatchErrorSeverity INT;  
	DECLARE @CatchErrorState INT;  
	DECLARE @index INT = 0

	IF(@ysnHasError = 1)
	BEGIN
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 

		SELECT   
			@CatchErrorMessage = ERROR_MESSAGE(),  
			@CatchErrorSeverity = ERROR_SEVERITY(),  
			@CatchErrorState = ERROR_STATE();  

		INSERT INTO tblCFLog(
			 strProcess,strProcessid,strCallStack,strMessage,intSortId)
		SELECT 'Main','','Catch',@CatchErrorMessage,0

		INSERT INTO tblCFLog(
			 strProcess,strProcessid,strCallStack,strMessage,intSortId)
		SELECT 'Main process exited with error','','Process Invoice','Rollback transaction',0

		
		SELECT @index = CHARINDEX('>',@CatchErrorMessage)
		SELECT @ErrorMessage = SUBSTRING(@CatchErrorMessage,@index + 1, 1000);  
	END
	ELSE
	BEGIN
		UPDATE tblCFAccount SET dtmLastBillingCycleDate = @dtmInvoiceDate WHERE intAccountId IN (SELECT intAccountId FROM tblCFInvoiceStagingTable where strUserId = @username)
		IF (@@TRANCOUNT > 0) COMMIT TRANSACTION
	END

	--------HISTORY--------
	INSERT INTO tblCFInvoiceProcessHistory
	(
		 intCustomerId
		,intInvoiceId
		,intPaymentId
		,strCustomerNumber
		,strCustomerName
		,strInvoiceNumber
		,strPaymentNumber
		,dblInvoiceAmount
		,dblTotalQuantity
		,dblDiscountEligibleQuantity
		,dblDiscountAmount
		,dtmInvoiceDate
		,strInvoiceNumberHistory
		,strReportName
		,dtmBalanceForwardDate
	)
	SELECT
		 intCustomerId
		,intInvoiceId
		,intPaymentId
		,ent.strEntityNo
		,ent.strName
		,strInvoiceReportNumber
		,strPaymentId
		,dblInvoiceAmount
		,dblInvoiceQuantity
		,dblInvoiceQuantity
		,dblInvoiceDiscount
		,dtmInvoiceDate
		,strInvoiceReportNumber
		,@reportName
		,@balanceForwardDate
	FROM tblCFInvoiceProcessResult as ipr
	INNER JOIN tblEMEntity as ent
	ON ipr.intCustomerId = ent.intEntityId


	INSERT INTO tblCFInvoiceHistoryStagingTable
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
		,intFeeLoopId
		,intItemId
		,intARLocationId
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
		,strCalculationType
		,strFeeDescription
		,strFee
		,strInvoiceFormat
		,strProductDescriptionForTotals
		,dtmTransactionDate
		,dtmDate
		,dtmPostedDate
		,dtmDiscountDate
		,dtmDueDate
		,dtmInvoiceDate
		,dtmStartDate
		,dtmEndDate
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
		,dblFeeAmount
		,dblFeeRate
		,dblEligableGallon
		,ysnPrintMiscellaneous
		,ysnSummaryByCard
		,ysnSummaryByDepartment
		,ysnSummaryByMiscellaneous
		,ysnSummaryByProduct
		,ysnSummaryByVehicle
		,ysnSummaryByDeptCardProd
		,ysnSummaryByCardProd
		,ysnPrintTimeOnInvoices
		,ysnPrintTimeOnReports
		,ysnInvalid
		,ysnPostedCSV
		,ysnPosted
		,ysnIncludeInQuantityDiscount
		,ysnAllowEFT
		,ysnActive
		,ysnEnergyTrac
		,strDiscountSchedule
		,ysnShowOnCFInvoice
		,ysnPostForeignSales
		,ysnSummaryByDeptVehicleProd
		,ysnDepartmentGrouping
		,strGuid
		,strUserId
		,strInvoiceNumberHistory
		,dtmDueDateBaseOnTermsHistory
		,dtmDiscountDateBaseOnTermsHistory
		,ysnMPGCalculation
		,dblAccountTotalDiscountQuantity
		,strDetailDisplayValue
		,strDetailDisplay
		,strDetailDisplayLabel
		,ysnShowVehicleDescriptionOnly	
		,ysnShowDriverPinDescriptionOnly
		,strDriverPinNumber
		,strDriverDescription
		,ysnSummaryByDriverPin
		,ysnSummaryByDeptDriverPinProd
		,ysnPageBreakByPrimarySortOrder
	)
	SELECT 
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
		,intFeeLoopId
		,intItemId
		,intARLocationId
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
		,strTempInvoiceReportNumber --strInvoiceReportNumber
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
		,strCalculationType
		,strFeeDescription
		,strFee
		,strInvoiceFormat
		,strProductDescriptionForTotals
		,dtmTransactionDate
		,dtmDate
		,dtmPostedDate
		,dtmDiscountDate
		,dtmDueDate
		,dtmInvoiceDate
		,dtmStartDate
		,dtmEndDate
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
		,dblFeeAmount
		,dblFeeRate
		,dblEligableGallon
		,ysnPrintMiscellaneous
		,ysnSummaryByCard
		,ysnSummaryByDepartment
		,ysnSummaryByMiscellaneous
		,ysnSummaryByProduct
		,ysnSummaryByVehicle
		,ysnSummaryByDeptCardProd
		,ysnSummaryByCardProd
		,ysnPrintTimeOnInvoices
		,ysnPrintTimeOnReports
		,ysnInvalid
		,ysnPostedCSV
		,ysnPosted
		,ysnIncludeInQuantityDiscount
		,ysnAllowEFT
		,ysnActive
		,ysnEnergyTrac
		,strDiscountSchedule
		,ysnShowOnCFInvoice
		,ysnPostForeignSales
		,ysnSummaryByDeptVehicleProd
		,ysnDepartmentGrouping
		,strGuid
		,strUserId
		,strTempInvoiceReportNumber
		,dbo.fnGetDueDateBasedOnTerm(dtmInvoiceDate, intTermID)
		,dbo.fnGetDiscountDateBasedOnTerm(dtmInvoiceDate, intTermID,NULL) 
		,ysnMPGCalculation
		,dblAccountTotalDiscountQuantity
		,strDetailDisplayValue
		,strDetailDisplay
		,strDetailDisplayLabel
		,ysnShowVehicleDescriptionOnly	
		,ysnShowDriverPinDescriptionOnly	
		,strDriverPinNumber
		,strDriverDescription
		,ysnSummaryByDriverPin
		,ysnSummaryByDeptDriverPinProd
		,ysnPageBreakByPrimarySortOrder
	FROM
	tblCFInvoiceStagingTable
	WHERE strUserId = @username
	AND LOWER(strStatementType) = @statementType
	
	INSERT INTO tblCFCustomerStatementHistoryStagingTable
	(
	intEntityCustomerId
	,intInvoiceId
	,intPaymentId
	,intDaysDue
	,intEntityUserId
	,dtmDate
	,dtmDueDate
	,dtmShipDate
	,dtmDatePaid
	,dtmAsOfDate
	,strCustomerNumber
	,strCustomerName
	,strDisplayName
	,strInvoiceNumber
	,strReferenceNumber
	,strBOLNumber
	,strRecordNumber
	,strTransactionType
	,strPaymentInfo
	,strSalespersonName
	,strAccountStatusCode
	,strLocationName
	,strFullAddress
	,strStatementFooterComment
	,strContact
	,strPaid
	,strPaymentMethod
	,strTicketNumbers
	,strCompanyName
	,strCompanyAddress
	,strUserId
	,strStatementFormat
	,dblTotalAmount
	,dblAmountPaid
	,dblAmountDue
	,dblAmountApplied
	,dblPastDue
	,dblMonthlyBudget
	,dblRunningBalance
	,dblCreditLimit
	,dblInvoiceTotal
	,dblPayment
	,dblBalance
	,dblTotalAR
	,dblCreditAvailable
	,dblFuture
	,dbl0Days
	,dbl10Days
	,dbl30Days
	,dbl60Days
	,dbl90Days
	,dbl91Days
	,dblCredits
	,dblPrepayments
	,dblUnappliedAmount
	,ysnPrintFromCardFueling
	,intCFAccountId
	,dblCFDiscount
	,dblCFEligableGallon
	,strCFGroupDiscoount
	,intCFDiscountDay
	,strCFTermType
	,dtmCFInvoiceDate
	,dblCFTotalBalance
	,intCFTermID
	,dblCFAccountTotalAmount
	,dblCFAccountTotalDiscount
	,dblCFFeeTotalAmount
	,dblCFInvoiceTotal
	,dblCFTotalQuantity
	,strCFTempInvoiceReportNumber
	,strCFEmailDistributionOption
	,strCFEmail
	,ysnCFShowDiscountOnInvoice
	,ysnStatementCreditLimit
	,blbLogo
	,strCFTerm
	,strCFTermCode
	,strComment
	,strCFInvoiceNumber
	,strInvoiceNumberHistory
	,dtmDueDateBaseOnTermsHistory
	,dtmDiscountDateBaseOnTermsHistory
	)
	SELECT 
	intEntityCustomerId
	,intInvoiceId
	,intPaymentId
	,intDaysDue
	,intEntityUserId
	,dtmDate
	,dtmDueDate
	,dtmShipDate
	,dtmDatePaid
	,dtmAsOfDate
	,strCustomerNumber
	,strCustomerName
	,strDisplayName
	,strInvoiceNumber
	,strReferenceNumber
	,strBOLNumber
	,strRecordNumber
	,strTransactionType
	,strPaymentInfo
	,strSalespersonName
	,strAccountStatusCode
	,strLocationName
	,strFullAddress
	,strStatementFooterComment
	,strContact
	,strPaid
	,strPaymentMethod
	,strTicketNumbers
	,strCompanyName
	,strCompanyAddress
	,strUserId
	,strStatementFormat
	,dblTotalAmount
	,dblAmountPaid
	,dblAmountDue
	,dblAmountApplied
	,dblPastDue
	,dblMonthlyBudget
	,dblRunningBalance
	,dblCreditLimit
	,dblInvoiceTotal
	,dblPayment
	,dblBalance
	,dblTotalAR
	,dblCreditAvailable
	,dblFuture
	,dbl0Days
	,dbl10Days
	,dbl30Days
	,dbl60Days
	,dbl90Days
	,dbl91Days
	,dblCredits
	,dblPrepayments
	,dblUnappliedAmount
	,ysnPrintFromCardFueling
	,intCFAccountId
	,dblCFDiscount
	,dblCFEligableGallon
	,strCFGroupDiscoount
	,intCFDiscountDay
	,strCFTermType
	,dtmCFInvoiceDate
	,dblCFTotalBalance
	,intCFTermID
	,dblCFAccountTotalAmount
	,dblCFAccountTotalDiscount
	,dblCFFeeTotalAmount
	,dblCFInvoiceTotal
	,dblCFTotalQuantity
	,strCFTempInvoiceReportNumber
	,strCFEmailDistributionOption
	,strCFEmail
	,ysnCFShowDiscountOnInvoice
	,ysnStatementCreditLimit
	,blbLogo
	,strCFTerm
	,strCFTermCode
	,strComment
	,strCFTempInvoiceReportNumber
	,strCFTempInvoiceReportNumber
	,dbo.fnGetDueDateBasedOnTerm(dtmCFInvoiceDate, intCFTermID)
	,dbo.fnGetDiscountDateBasedOnTerm(dtmCFInvoiceDate, intCFTermID,NULL) 
	FROM
	tblARCustomerStatementStagingTable
	WHERE intEntityUserId = @entityId

	INSERT INTO tblCFDiscountScheduleHistory
	(
		intCustomerId
		,intAccountId
		,intFromQty
		,intThruQty
		,dblRate
		,intDiscountScheduleId
		,intDiscountSchedDetailId
		,strInvoiceNumberHistory
	)
	SELECT 
		 dis.intCustomerId
		,dis.intAccountId
		,dis.intFromQty
		,dis.intThruQty
		,dis.dblRate
		,dis.intDiscountScheduleId
		,dis.intDiscountSchedDetailId
		,inv.strTempInvoiceReportNumber
	FROM vyuCFDiscountSchedule as dis 
	INNER JOIN (SELECT DISTINCT strTempInvoiceReportNumber, intDiscountScheduleId , intAccountId, strUserId FROM tblCFInvoiceStagingTable WHERE strUserId = @username AND LOWER(strStatementType) = @statementType) as inv
	ON dis.intDiscountScheduleId = inv.intDiscountScheduleId
	AND dis.intAccountId = inv.intAccountId
	WHERE strUserId = @username



	INSERT INTO tblCFInvoiceFeeHistoryStagingTable
	(
		 intFeeLoopId
		,intAccountId
		,intTransactionId
		,intCardId
		,intCustomerId
		,intTermID
		,intSalesPersonId
		,intItemId
		,intARLocationId
		,dblFeeRate
		,dblQuantity
		,dblFeeAmount
		,dblFeeTotalAmount
		,strFeeDescription
		,strFee
		,strInvoiceFormat
		,strInvoiceReportNumber
		,strCalculationType
		,strGuid
		,strUserId
		,dtmTransactionDate
		,dtmInvoiceDate
		,dtmStartDate
		,dtmEndDate
		,strInvoiceNumberHistory
	)
	SELECT 
		intFeeLoopId
		,intAccountId
		,intTransactionId
		,intCardId
		,intCustomerId
		,intTermID
		,intSalesPersonId
		,intItemId
		,intARLocationId
		,dblFeeRate
		,dblQuantity
		,dblFeeAmount
		,dblFeeTotalAmount
		,strFeeDescription
		,strFee
		,strInvoiceFormat
		,strInvoiceReportNumber
		,strCalculationType
		,strGuid
		,strUserId
		,dtmTransactionDate
		,dtmInvoiceDate
		,dtmStartDate
		,dtmEndDate
		,strInvoiceReportNumber
	FROM
	tblCFInvoiceFeeStagingTable
	WHERE strUserId = @username
	
	--vyuCFInvoiceGroupByCardOdometer
	INSERT INTO tblCFInvoiceGroupByCardOdometerHistory(
		 intCardId
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,strInvoiceNumberHistory
	)
	SELECT 
		 intCardId
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,(SELECT TOP 1 strTempInvoiceReportNumber FROM tblCFInvoiceStagingTable WHERE intAccountId = vyu.intAccountId AND strUserId = @username AND LOWER(strStatementType) = @statementType)
	FROM
	vyuCFInvoiceGroupByCardOdometer as vyu
	WHERE strUserId = @username AND LOWER(strStatementType) = @statementType 
	
	--vyuCFInvoiceGroupByDeptOdometer
	INSERT INTO tblCFInvoiceGroupByDeptOdometerHistory(
		 strDepartment
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,strInvoiceNumberHistory
	)
	SELECT 
		 strDepartment
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,(SELECT TOP 1 strTempInvoiceReportNumber FROM tblCFInvoiceStagingTable WHERE intAccountId = vyu.intAccountId AND strUserId = @username AND LOWER(strStatementType) = @statementType)
	FROM
	vyuCFInvoiceGroupByDeptOdometer as vyu
	WHERE strUserId = @username AND LOWER(strStatementType) = @statementType

	--vyuCFInvoiceGroupByMiscOdometer
	INSERT INTO tblCFInvoiceGroupByMiscOdometerHistory(
		 strMiscellaneous
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,strInvoiceNumberHistory
	)
	SELECT 
		 strMiscellaneous
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,(SELECT TOP 1 strTempInvoiceReportNumber FROM tblCFInvoiceStagingTable WHERE intAccountId = vyu.intAccountId AND strUserId = @username AND LOWER(strStatementType) = @statementType)
	FROM
	vyuCFInvoiceGroupByMiscOdometer as vyu
	WHERE strUserId = @username AND LOWER(strStatementType) = @statementType

	--vyuCFInvoiceGroupByVehicleOdometer
	INSERT INTO tblCFInvoiceGroupByVehicleOdometerHistory(
		 strVehicleNumber
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,strInvoiceNumberHistory
	)
	SELECT 
		 strVehicleNumber
		,intAccountId
		,intLastOdometer
		,dtmMinDate
		,(SELECT TOP 1 strTempInvoiceReportNumber FROM tblCFInvoiceStagingTable WHERE intAccountId = vyu.intAccountId AND strUserId = @username AND LOWER(strStatementType) = @statementType)
	FROM
	vyuCFInvoiceGroupByVehicleOdometer as vyu
	WHERE strUserId = @username AND LOWER(strStatementType) = @statementType


	-------HISTORY----------

	
	UPDATE tblCFTransaction 
	SET ysnInvoiced = 1
	-- WHERE intTransactionId IN (SELECT intTransactionId FROM tblCFInvoiceStagingTable WHERE strUserId = @username  AND ISNULL(ysnExpensed,0) = 0 AND LOWER(strStatementType) = @statementType) 
	WHERE intTransactionId IN (SELECT intTransactionId FROM tblCFInvoiceStagingTable WHERE strUserId = @username AND LOWER(strStatementType) = @statementType) -- CF-2459


	----------DROP TEMPORARY TABLE----------
	IF OBJECT_ID(N'tempdb..#tblCFInvoice', N'U') IS NOT NULL 
	DROP TABLE #tblCFInvoice

	IF OBJECT_ID(N'tempdb..#tblCFDisctinctCustomerInvoice', N'U') IS NOT NULL 
	DROP TABLE #tblCFDisctinctCustomerInvoice
	----------------------------------------

	 

END TRY
BEGIN CATCH
	
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
  
	SELECT   
		@CatchErrorMessage = ERROR_MESSAGE(),  
		@CatchErrorSeverity = ERROR_SEVERITY(),  
		@CatchErrorState = ERROR_STATE();  

	INSERT INTO tblCFLog(
		 strProcess,strProcessid,strCallStack,strMessage,intSortId)
	SELECT 'Main','','Catch',@CatchErrorMessage,0

	INSERT INTO tblCFLog(
		 strProcess,strProcessid,strCallStack,strMessage,intSortId)
	SELECT 'Main process exited with error','','Process Invoice','Rollback transaction',0

	SELECT @index = CHARINDEX('>',@CatchErrorMessage)
	SELECT @ErrorMessage = SUBSTRING(@CatchErrorMessage,@index + 1, 1000);  


	----------DROP TEMPORARY TABLE----------
	IF OBJECT_ID(N'tempdb..#tblCFInvoice', N'U') IS NOT NULL 
	DROP TABLE #tblCFInvoice

	IF OBJECT_ID(N'tempdb..#tblCFDisctinctCustomerInvoice', N'U') IS NOT NULL 
	DROP TABLE #tblCFDisctinctCustomerInvoice
	----------------------------------------

END CATCH



END
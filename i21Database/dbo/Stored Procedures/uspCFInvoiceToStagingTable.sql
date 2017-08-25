﻿CREATE PROCEDURE [dbo].[uspCFInvoiceToStagingTable](
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

	--SELECT * FROM tblCFInvoiceReportTempTable

	EXEC "dbo"."uspCFInvoiceReportSummary"	@xmlParam	=	@xmlParam

	--SELECT * FROM tblCFInvoiceSummaryTempTable

	EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam	=	@xmlParam

	--SELECT * FROM tblCFInvoiceDiscountTempTable
	

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


	DECLARE @idoc INT
	
	--READ XML
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam

	--TEMP TABLE FOR PARAMETERS
	DECLARE @temp_params TABLE (
		 [fieldname] NVARCHAR(MAX)
		,[condition] NVARCHAR(MAX)      
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(MAX)
		,[begingroup] NVARCHAR(MAX)
		,[endgroup] NVARCHAR(MAX) 
		,[datatype] NVARCHAR(MAX)
	) 

	--XML DATA TO TABLE
	INSERT INTO @temp_params
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
	WITH ([fieldname] NVARCHAR(MAX)
		, [condition] NVARCHAR(MAX)
		, [from] NVARCHAR(MAX)
		, [to] NVARCHAR(MAX)
		, [join] NVARCHAR(MAX)
		, [begingroup] NVARCHAR(MAX)
		, [endgroup] NVARCHAR(MAX)
		, [datatype] NVARCHAR(MAX))

	
	DECLARE @ysnIncludeRemittancePage BIT
	SELECT TOP 1
			@ysnIncludeRemittancePage = ISNULL([from],0)
	FROM @temp_params WHERE [fieldname] = 'ysnIncludeRemittancePage'

	IF(@ysnIncludeRemittancePage = 1)
	BEGIN

		DECLARE @dtmBalanceForwardDate DATETIME
		SELECT TOP 1
				@dtmBalanceForwardDate = [from]
		FROM @temp_params WHERE [fieldname] = 'dtmBalanceForwardDate'

		DECLARE @dtmTransactionDateFrom DATETIME
		DECLARE @dtmTransactionDateTo DATETIME
		SELECT TOP 1
				@dtmTransactionDateFrom = [from]
				,@dtmTransactionDateFrom = [to]
		FROM @temp_params WHERE [fieldname] = 'dtmTransactionDate'

		DECLARE @strCustomerNumber NVARCHAR(MAX)
		SELECT TOP 1
				@strCustomerNumber = ISNULL([from],'')
		FROM @temp_params WHERE [fieldname] = 'strCustomerNumber'
		
		IF(ISNULL(@strCustomerNumber,'') = '')
		BEGIN
			EXEC uspARCustomerStatementBalanceForwardReport 
			@dtmDateFrom = @dtmBalanceForwardDate
			,@dtmDateTo = @dtmTransactionDateTo
			,@ysnPrintFromCF = 1

		END
		ELSE
		BEGIN
			DECLARE @strCustomerName NVARCHAR(MAX)

			SET @strCustomerName = (SELECT TOP 1 strName FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)

			EXEC uspARCustomerStatementBalanceForwardReport 
			 @dtmDateFrom = @dtmBalanceForwardDate
			,@dtmDateTo = @dtmTransactionDateTo
			,@ysnPrintFromCF = 1
			,@strCustomerName = @strCustomerName

		END

		INSERT INTO tblARCustomerStatementStagingTable
		(
		 intEntityCustomerId
		,intInvoiceId
		,intPaymentId
		,dtmDate
		,dtmDueDate
		,dtmShipDate
		,dtmDatePaid
		,dtmAsOfDate
		,strCustomerNumber
		,strCustomerName
		,strInvoiceNumber
		,strBOLNumber
		,strRecordNumber
		,strTransactionType
		,strPaymentInfo
		,strSalespersonName
		,strAccountStatusCode
		,strLocationName
		,strFullAddress
		,strStatementFooterComment
		,strCompanyName
		,strCompanyAddress
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
		,intCFAccountId	
		,dblCFDiscount	
		,dblCFEligableGallon	
		,strCFGroupDiscoount	
		,intCFDiscountDay	
		,strCFTermType	
		,dtmCFInvoiceDate
		,ysnCFShowDiscountOnInvoice
		)
		SELECT
		 intCustomerId
		,0
		,NULL --intPaymentId
		,dtmInvoiceDate
		,dtmInvoiceDate
		,NULL --dtmShipDate
		,NULL --dtmDatePaid
		,NULL --dtmAsOfDate
		,strCustomerNumber
		,strCustomerName
		,strTempInvoiceReportNumber
		,NULL --strBOLNumber
		,NULL --strRecordNumber
		,'Debit Memo'
		,NULL --strPaymentInfo
		,NULL --strSalespersonName
		,NULL --strAccountStatusCode
		,NULL
		,NULL --strFullAddress
		,NULL --strStatementFooterComment
		,strCompanyName
		,strCompanyAddress
		,NULL --dblCreditLimit
		,dblAccountTotalAmount --dblInvoiceTotal
		,0 --dblPayment
		,dblAccountTotalAmount --dblBalance
		,NULL --dblTotalAR
		,NULL --dblCreditAvailable
		,NULL --dblFuture
		,NULL --dbl0Days
		,NULL --dbl10Days
		,NULL --dbl30Days
		,NULL --dbl60Days
		,NULL --dbl90Days
		,NULL --dbl91Days
		,NULL --dblCredits
		,NULL --dblPrepayments
		,intAccountId
		,dblAccountTotalDiscount	
		,dblEligableGallon	
		,strGroupName	
		,intDiscountDay	
		,strTermType	
		,dtmInvoiceDate
		,ysnShowOnCFInvoice
		FROM
		tblCFInvoiceStagingTable 
		AS cfInv
		GROUP BY 
		intCustomerId
		,dtmInvoiceDate
		,strCustomerNumber
		,strCustomerName
		,strTempInvoiceReportNumber
		,strCompanyName
		,strCompanyAddress
		,intAccountId
		,dblEligableGallon	
		,strGroupName	
		,intDiscountDay	
		,strTermType	
		,dtmInvoiceDate
		,dblAccountTotalAmount
		,dblAccountTotalDiscount
		,ysnShowOnCFInvoice
		

		UPDATE tblARCustomerStatementStagingTable SET ysnPrintFromCardFueling = 1


		UPDATE tblARCustomerStatementStagingTable
		SET 
				 tblARCustomerStatementStagingTable.intCFAccountId					   = 		cfInv.intAccountId				
				,tblARCustomerStatementStagingTable.dblCFDiscount					   = 		cfInv.dblDiscount				
				,tblARCustomerStatementStagingTable.dblCFEligableGallon				   = 		cfInv.dblEligableGallon			
				,tblARCustomerStatementStagingTable.strCFGroupDiscoount				   = 		cfInv.strGroupName			
				,tblARCustomerStatementStagingTable.intCFDiscountDay				   = 		cfInv.intDiscountDay			
				,tblARCustomerStatementStagingTable.strCFTermType					   = 		cfInv.strTermType				
				,tblARCustomerStatementStagingTable.dtmCFInvoiceDate				   = 		cfInv.dtmInvoiceDate			
				,tblARCustomerStatementStagingTable.intCFTermID						   = 		cfInv.intTermID					
				,tblARCustomerStatementStagingTable.dblCFAccountTotalAmount			   = 		cfInv.dblAccountTotalAmount		
				,tblARCustomerStatementStagingTable.dblCFAccountTotalDiscount		   = 		cfInv.dblAccountTotalDiscount	
				,tblARCustomerStatementStagingTable.dblCFFeeTotalAmount				   = 		cfInv.dblFeeAmount			
				,tblARCustomerStatementStagingTable.dblCFInvoiceTotal				   = 		cfInv.dblInvoiceTotal			
				,tblARCustomerStatementStagingTable.dblCFTotalQuantity				   = 		cfInv.dblTotalQuantity			
				,tblARCustomerStatementStagingTable.strCFTempInvoiceReportNumber	   = 		cfInv.strTempInvoiceReportNumber
				,tblARCustomerStatementStagingTable.strCFEmailDistributionOption	   = 		cfInv.strEmailDistributionOption
				,tblARCustomerStatementStagingTable.strCFEmail						   = 		cfInv.strEmail			
				,tblARCustomerStatementStagingTable.ysnCFShowDiscountOnInvoice		   =		cfInv.ysnShowOnCFInvoice
		FROM tblCFInvoiceStagingTable cfInv
		WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfInv.intCustomerId

		UPDATE tblARCustomerStatementStagingTable
		SET
				 tblARCustomerStatementStagingTable.intCFAccountId						=	  cfAccntTerm.intAccountId
				,tblARCustomerStatementStagingTable.intCFDiscountDay					=	  cfAccntTerm.intDiscountDay
				,tblARCustomerStatementStagingTable.strCFTermType						=	  cfAccntTerm.strType
				,tblARCustomerStatementStagingTable.intCFTermID							=	  cfAccntTerm.intTermsCode
				,tblARCustomerStatementStagingTable.strCFEmail							=	  (SELECT TOP (1) strEmail
																								FROM    dbo.vyuARCustomerContacts
																								WHERE (intEntityCustomerId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																								AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																								AND (ISNULL(strEmail, N'') <> ''))
				,tblARCustomerStatementStagingTable.strCFEmailDistributionOption		=	  (SELECT TOP (1) strEmailDistributionOption
																								FROM    dbo.vyuARCustomerContacts
																								WHERE (intEntityCustomerId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																								AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																								AND (ISNULL(strEmail, N'') <> ''))	
		FROM vyuCFAccountTerm cfAccntTerm
		WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfAccntTerm.intCustomerId

		
		DECLARE @strWebsite NVARCHAR(MAX)
		SET @strWebsite = (select TOP 1 ISNULL(strWebSite,'') from [tblSMCompanySetup])

		UPDATE tblARCustomerStatementStagingTable
		SET
				 dblTotalAR						 = 		tbl1.dblTotalAR					
				,dblCreditAvailable				 = 		tbl1.dblCreditAvailable			
				,dblFuture						 = 		tbl1.dblFuture					
				,dbl0Days						 = 		tbl1.dbl0Days					
				,dbl10Days						 = 		tbl1.dbl10Days					
				,dbl30Days						 = 		tbl1.dbl30Days					
				,dbl60Days						 = 		tbl1.dbl60Days					
				,dbl90Days						 = 		tbl1.dbl90Days					
				,dbl91Days						 = 		tbl1.dbl91Days					
				,dblCredits						 = 		tbl1.dblCredits					
				,dblPrepayments					 = 		tbl1.dblPrepayments				
				,strAccountStatusCode			 = 		tbl1.strAccountStatusCode		
				,strFullAddress					 = 		tbl1.strFullAddress				
				,strCompanyName					 = 		tbl1.strCompanyName				
				,strCompanyAddress				 = 		tbl1.strCompanyAddress + CHAR(13) + @strWebsite
				,dblCreditLimit					 = 		tbl1.dblCreditLimit				
				,strCustomerName				 = 		tbl1.strCustomerName			
				,strCustomerNumber				 = 		tbl1.strCustomerNumber			
				,dtmAsOfDate					 = 		tbl1.dtmAsOfDate				
		FROM (
				select 
				 top 1 
				 dblTotalAR	
				,intEntityCustomerId
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
				,strAccountStatusCode	
				,strFullAddress	
				,strCompanyName	
				,strCompanyAddress	
				,dblCreditLimit
				,strCustomerName
				,strCustomerNumber
				,dtmAsOfDate
				from tblARCustomerStatementStagingTable
				where dblTotalAR IS NOT NULL
				group by 
				dblTotalAR	
				,intEntityCustomerId
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
				,strAccountStatusCode	
				,strFullAddress	
				,strCompanyName	
				,strCompanyAddress	
				,dblCreditLimit
				,strCustomerName
				,strCustomerNumber
				,dtmAsOfDate) as tbl1
				WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = tbl1.intEntityCustomerId

	END

	--SELECT * FROM vyuCFAccountTerm
	--select * from vyuCFCardAccount


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
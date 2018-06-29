CREATE PROCEDURE [dbo].[uspCFInvoiceToStagingTable](
	 @xmlParam					NVARCHAR(MAX)  
	,@Guid						NVARCHAR(MAX)  
	,@UserId					NVARCHAR(MAX)  
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

	print @Guid	
	print @UserId
	DECLARE @intEntityUserId INT;

	select TOP 1 @intEntityUserId = intEntityId from tblSMUserSecurity where strUserName = @UserId


	-------------CLEAN TEMP TABLES------------
	DELETE FROM tblCFInvoiceReportTempTable			WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceSummaryTempTable		WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceDiscountTempTable		WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceStagingTable			WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceFeeStagingTable			WHERE strUserId = @UserId
	
	DELETE tblCFInvoiceStagingTable					WHERE strUserId is null
	DELETE tblARCustomerStatementStagingTable		WHERE intEntityUserId is null

	------------------------------------------

BEGIN TRY


	IF (@@TRANCOUNT = 0) BEGIN TRANSACTION

	-- EXECUTE INVOICE REPORT SP's--
	-----------------------------------------------------------
	-- EXECUTING THIS SP's WILL INSERT RECORDS ON TEMP TABLES--
	-----------------------------------------------------------
	
	DELETE FROM tblCFInvoiceReportTempTable WHERE strUserId = @UserId
	EXEC "dbo"."uspCFInvoiceReport"			@xmlParam	=	@xmlParam , @UserId = @UserId

	--SELECT 'tblCFInvoiceReportTempTable',* FROM tblCFInvoiceReportTempTable
	
	DELETE FROM tblCFInvoiceSummaryTempTable WHERE strUserId = @UserId
	EXEC "dbo"."uspCFInvoiceReportSummary"	@xmlParam	=	@xmlParam , @UserId = @UserId


	--SELECT 'tblCFInvoiceSummaryTempTable',* FROM tblCFInvoiceSummaryTempTable
	
	DELETE FROM tblCFInvoiceDiscountTempTable WHERE strUserId = @UserId
	EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam	=	@xmlParam , @UserId = @UserId


	--SELECT 'tblCFInvoiceDiscountTempTable',* FROM tblCFInvoiceDiscountTempTable
	

	-- INSERT CALCULATED INVOICES TO STAGING TABLE --
	-----------------------------------------------------------
	DELETE FROM tblCFInvoiceStagingTable WHERE strUserId = @UserId
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
	,dblAccountTotalDiscountQuantity
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
	,ysnSummaryByDeptVehicleProd
	,ysnDepartmentGrouping
	,ysnPostedCSV
	,strGuid
	,strUserId
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
	,strCardNumber = CASE WHEN ((select top 1 strNetworkType from tblCFNetwork where strNetwork = cfInvRpt.strNetwork) = 'Voyager')
					 THEN  
						RTRIM(LTRIM(strCardNumber + dbo.fnCFGetLuhn(((select top 1 strIso from tblCFNetwork where strNetwork = cfInvRpt.strNetwork) + strCardNumber ) ,0)))
					 ELSE 
						strCardNumber
					 END
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
	,ISNULL(dblTotalMiles				  ,0) AS dblTotalMiles
	,ISNULL(dblQuantity					  ,0) AS dblQuantity
	,ISNULL(dblCalculatedTotalAmount	  ,0) AS dblCalculatedTotalAmount
	,ISNULL(dblOriginalTotalAmount		  ,0) AS dblOriginalTotalAmount
	,ISNULL(dblCalculatedGrossAmount	  ,0) AS dblCalculatedGrossAmount
	,ISNULL(dblOriginalGrossAmount		  ,0) AS dblOriginalGrossAmount
	,ISNULL(dblCalculatedNetAmount		  ,0) AS dblCalculatedNetAmount
	,ISNULL(dblOriginalNetAmount		  ,0) AS dblOriginalNetAmount
	,ISNULL(dblMargin					  ,0) AS dblMargin
	,ISNULL(dblTotalTax					  ,0) AS dblTotalTax
	,ISNULL(dblTotalSST					  ,0) AS dblTotalSST
	,ISNULL(dblTaxExceptSST				  ,0) AS dblTaxExceptSST
	,ISNULL(dblAccountTotalAmount 		  ,0) AS dblAccountTotalAmount 
	,ISNULL(dblTotalQuantity			  ,0) AS dblTotalQuantity
	,ISNULL(dblTotalGrossAmount			  ,0) AS dblTotalGrossAmount
	,ISNULL(dblTotalNetAmount			  ,0) AS dblTotalNetAmount
	,ISNULL(dblTotalAmount				  ,0) AS dblTotalAmount
	,ISNULL(dblTotalTaxAmount			  ,0) AS dblTotalTaxAmount
	,ISNULL(dblEligableGallon			  ,0) AS dblEligableGallon
	,TotalFET
	,TotalSET
	,TotalSST
	,TotalLC
	,ISNULL(dblDiscountRate						,0) AS dblDiscountRate
	,ISNULL(dblDiscount							,0) AS dblDiscount
	,ISNULL(dblAccountTotalAmount				,0) AS dblAccountTotalAmount
	,ISNULL(dblAccountTotalDiscount				,0) AS dblAccountTotalDiscount
	,ISNULL(dblAccountTotalLessDiscount			,0) AS dblAccountTotalLessDiscount
	,ISNULL(dblAccountTotalDiscountQuantity		,0) AS dblAccountTotalDiscountQuantity
	,ISNULL(dblDiscountEP						,0) AS dblDiscountEP
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
	,ysnSummaryByDeptVehicleProd
	,ysnDepartmentGrouping
	,ysnPostedCSV
	,@Guid
	,@UserId
	FROM tblCFInvoiceReportTempTable AS cfInvRpt
	INNER JOIN tblCFInvoiceSummaryTempTable AS cfInvRptSum
	ON cfInvRpt.intTransactionId = cfInvRptSum.intTransactionId
	INNER JOIN tblCFInvoiceDiscountTempTable AS cfInvRptDcnt
	ON cfInvRpt.intTransactionId = cfInvRptDcnt.intTransactionId
	WHERE cfInvRpt.strUserId = @UserId 
	AND cfInvRptSum.strUserId = @UserId
	AND cfInvRptDcnt.strUserId = @UserId

	SELECT DISTINCT 
	 intAccountId
	,intCustomerId
	,strCustomerName
	FROM tblCFInvoiceStagingTable

	--INSERT FEE RECORDS--
	EXEC "dbo"."uspCFInvoiceReportFee"		@xmlParam	=	@xmlParam , @UserId = @UserId


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

	DECLARE @ysnReprintInvoice BIT
	SELECT TOP 1
			@ysnReprintInvoice = ISNULL([from],0)
	FROM @temp_params WHERE [fieldname] = 'ysnReprintInvoice'


	IF(@ysnIncludeRemittancePage = 1)
	BEGIN

		DECLARE @dtmBalanceForwardDate DATETIME
		SELECT TOP 1
				@dtmBalanceForwardDate = [from]
		FROM @temp_params WHERE [fieldname] = 'dtmBalanceForwardDate'

		DECLARE @dtmInvoiceDate DATETIME
		SELECT TOP 1
				@dtmInvoiceDate = [from]
		FROM @temp_params WHERE [fieldname] = 'dtmInvoiceDate'

		--DECLARE @dtmTransactionDateFrom DATETIME
		--DECLARE @dtmTransactionDateTo DATETIME
		--SELECT TOP 1
		--		@dtmTransactionDateFrom = [from]
		--		,@dtmTransactionDateFrom = [to]
		--FROM @temp_params WHERE [fieldname] = 'dtmTransactionDate'

		DECLARE @strInvoiceCycle NVARCHAR(MAX)
		SELECT TOP 1
				@strInvoiceCycle = ISNULL([from],'')
		FROM @temp_params WHERE [fieldname] = 'strInvoiceCycle'
		

		DECLARE @strCustomerNumber NVARCHAR(MAX)
		SELECT TOP 1
				@strCustomerNumber = ISNULL([from],'')
		FROM @temp_params WHERE [fieldname] = 'strCustomerNumber'

		
		SET @strCustomerNumber = NULLIF(@strCustomerNumber, '')

		EXEC uspARCustomerStatementBalanceForwardReport 
				@dtmDateFrom = NULL			
			, @dtmDateTo = @dtmInvoiceDate
			, @ysnPrintZeroBalance = 1
			, @dtmBalanceForwardDate = @dtmBalanceForwardDate
			, @ysnPrintFromCF = 1
			, @strCustomerNumber = @strCustomerNumber		
			,@intEntityUserId = @intEntityUserId
			,@ysnReprintInvoice = @ysnReprintInvoice


		--SELECT '1',* FROM tblARCustomerStatementStagingTable

		IF(@ysnReprintInvoice = 0)
		BEGIN
		
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
		,strCFTerm
		,strCFTermCode
		,intEntityUserId
		)
		SELECT
		 intCustomerId
		,0
		,NULL --intPaymentId
		,dtmInvoiceDate
		,dbo.fnGetDueDateBasedOnTerm(dtmInvoiceDate,intTermID)
		,NULL --dtmShipDate
		,NULL --dtmDatePaid
		,NULL --dtmAsOfDate
		,strCustomerNumber
		,strCustomerName
		,strTempInvoiceReportNumber
		,NULL --strBOLNumber
		,NULL --strRecordNumber
		,'Invoice'
		,NULL --strPaymentInfo
		,NULL --strSalespersonName
		,NULL --strAccountStatusCode
		,NULL
		,NULL --strFullAddress
		,NULL --strStatementFooterComment
		,strCompanyName
		,strCompanyAddress
		,NULL --dblCreditLimit
		,(dblAccountTotalAmount + ( 
			ISNULL((SELECT SUM(ISNULL(dblFeeAmount,0)) AS dblTotalFeeAMount FROM tblCFInvoiceFeeStagingTable AS innerTable
			WHERE innerTable.intAccountId = cfInv.intAccountId AND strUserId = @UserId
			GROUP BY intAccountId),0)
		)) --dblInvoiceTotal
		,0 --dblPayment
		,(dblAccountTotalAmount + ( 
			ISNULL((SELECT SUM(ISNULL(dblFeeAmount,0)) AS dblTotalFeeAMount FROM tblCFInvoiceFeeStagingTable AS innerTable
			WHERE innerTable.intAccountId = cfInv.intAccountId  AND strUserId = @UserId
			GROUP BY intAccountId),0)
		))  --dblBalance
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
		,strTerm
		,strTermCode
		,@intEntityUserId
		FROM
		tblCFInvoiceStagingTable 
		AS cfInv
		WHERE strUserId = @UserId
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
		,intTermID		
		,strTerm
		,strTermCode

		--SELECT '2',* FROM tblARCustomerStatementStagingTable

		IF(ISNULL(@strInvoiceCycle,'') != '')
		BEGIN

			DELETE FROM tblARCustomerStatementStagingTable 
			WHERE intEntityUserId = @intEntityUserId
				AND intEntityCustomerId NOT IN (
				SELECT cfAC.intCustomerId 
				FROM tblCFAccount as cfAC
				INNER JOIN tblCFInvoiceCycle cfIC
				ON cfAC.intInvoiceCycle = cfIC.intInvoiceCycleId
				WHERE cfIC.strInvoiceCycle COLLATE Latin1_General_CI_AS IN (
					SELECT Record FROM fnCFSplitString(@strInvoiceCycle,'|^|')
				)
			)
		END
		

		UPDATE tblARCustomerStatementStagingTable SET ysnPrintFromCardFueling = 1 , dtmCFInvoiceDate = @dtmInvoiceDate WHERE intEntityUserId = @intEntityUserId

		UPDATE tblARCustomerStatementStagingTable
		SET 
		strCFEmail							=	  (SELECT TOP (1) strEmail
																						FROM    dbo.vyuARCustomerContacts
																						WHERE (intEntityCustomerId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																						AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																						AND (ISNULL(strEmail, N'') <> ''))
		,strCFEmailDistributionOption		=	  (SELECT TOP (1) strEmailDistributionOption
																						FROM    dbo.vyuARCustomerContacts
																						WHERE (intEntityCustomerId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																						AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																						AND (ISNULL(strEmail, N'') <> ''))	
		WHERE intEntityUserId = @intEntityUserId


		UPDATE tblARCustomerStatementStagingTable
		SET 
				 tblARCustomerStatementStagingTable.intCFAccountId					   = 		cfInv.intAccountId				
				,tblARCustomerStatementStagingTable.dblCFDiscount					   = 		cfInv.dblDiscount				
				,tblARCustomerStatementStagingTable.dblCFEligableGallon				   = 		cfInv.dblEligableGallon			
				,tblARCustomerStatementStagingTable.strCFGroupDiscoount				   = 		cfInv.strGroupName			
				,tblARCustomerStatementStagingTable.intCFDiscountDay				   = 		cfInv.intDiscountDay			
				,tblARCustomerStatementStagingTable.strCFTermType					   = 		cfInv.strTermType				
				--,tblARCustomerStatementStagingTable.dtmCFInvoiceDate				   = 		cfInv.dtmInvoiceDate			
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
				,tblARCustomerStatementStagingTable.strCFTerm						   = 		cfInv.strTerm			
				,tblARCustomerStatementStagingTable.strCFTermCode					   = 		cfInv.strTermCode		
		FROM tblCFInvoiceStagingTable cfInv
		WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfInv.intCustomerId
		AND cfInv.strUserId = @UserId
		AND intEntityUserId = @intEntityUserId

		UPDATE tblARCustomerStatementStagingTable
		SET
				 tblARCustomerStatementStagingTable.intCFAccountId						=	  cfAccntTerm.intAccountId
				,tblARCustomerStatementStagingTable.intCFDiscountDay					=	  cfAccntTerm.intDiscountDay
				,tblARCustomerStatementStagingTable.strCFTermType						=	  cfAccntTerm.strType
				,tblARCustomerStatementStagingTable.intCFTermID							=	  cfAccntTerm.intTermsCode

				,tblARCustomerStatementStagingTable.strCFEmail							=	  (SELECT TOP (1) ISNULL(strEmail,'')
																								FROM    dbo.vyuARCustomerContacts as arCustCont
																								WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																								AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																								AND (ISNULL(strEmail, N'') <> ''))

				,tblARCustomerStatementStagingTable.strCFEmailDistributionOption		=	  (SELECT TOP (1) ISNULL(strEmailDistributionOption,'')
																							FROM    dbo.vyuARCustomerContacts as arCustCont
																							WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																							AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																							AND (ISNULL(strEmail, N'') <> ''))
		FROM vyuCFAccountTerm cfAccntTerm
		WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfAccntTerm.intCustomerId
		AND intEntityUserId = @intEntityUserId
		----AR SHOULD HANDLE MULTI USER TOO---
		
		DECLARE @strWebsite NVARCHAR(MAX)
		SET @strWebsite = (select TOP 1 ISNULL(strWebSite,'') from [tblSMCompanySetup])


		
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityCustomerId IN (
			SELECT intEntityCustomerId FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserId AND intEntityCustomerId not in (
				SELECT intEntityCustomerId AS intCount FROM tblARCustomerStatementStagingTable
				WHERE 
				strTransactionType != 'Balance Forward' 
				AND intEntityUserId = @intEntityUserId
				GROUP BY intEntityCustomerId,strCustomerName
				HAVING ISNULL(COUNT(*),0) > 0)
		AND ISNULL(dblTotalAR,0) = 0)
		AND intEntityUserId = @intEntityUserId

		UPDATE STAGING
		SET STAGING.dblTotalAR				= STAGING2.dblTotalAR
		  , STAGING.dblCreditAvailable		= STAGING2.dblCreditAvailable   
		  , STAGING.dblFuture				= STAGING2.dblFuture     
		  , STAGING.dbl0Days				= STAGING2.dbl0Days
		  , STAGING.dbl10Days				= STAGING2.dbl10Days     
		  , STAGING.dbl30Days				= STAGING2.dbl30Days     
		  , STAGING.dbl60Days				= STAGING2.dbl60Days     
		  , STAGING.dbl90Days				= STAGING2.dbl90Days     
		  , STAGING.dbl91Days				= STAGING2.dbl91Days     
		  , STAGING.dblCredits				= STAGING2.dblCredits     
		  , STAGING.dblPrepayments			= STAGING2.dblPrepayments    
		  , STAGING.strAccountStatusCode    = STAGING2.strAccountStatusCode  
		  , STAGING.strFullAddress			= STAGING2.strFullAddress
		  , STAGING.strStatementFooterComment = STAGING2.strStatementFooterComment    
		  , STAGING.strCompanyName			= STAGING2.strCompanyName    
		  , STAGING.strCompanyAddress		= STAGING2.strCompanyAddress + CHAR(13) + @strWebsite
		  , STAGING.dblCreditLimit			= STAGING2.dblCreditLimit    
		  , STAGING.strCustomerName			= STAGING2.strCustomerName   
		  , STAGING.strCustomerNumber		= STAGING2.strCustomerNumber   
		  , STAGING.dtmAsOfDate				= STAGING2.dtmAsOfDate
		FROM tblARCustomerStatementStagingTable STAGING
		CROSS APPLY (
		 select top 1 dblTotalAR 
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
		  ,strStatementFooterComment
		  ,strCompanyName 
		  ,strCompanyAddress 
		  ,dblCreditLimit
		  ,strCustomerName
		  ,strCustomerNumber
		  ,dtmAsOfDate
		  from tblARCustomerStatementStagingTable
		  where dblTotalAR IS NOT NULL
		   AND intEntityCustomerId = STAGING.intEntityCustomerId
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
		  ,strStatementFooterComment 
		  ,strCompanyName 
		  ,strCompanyAddress 
		  ,dblCreditLimit
		  ,strCustomerName
		  ,strCustomerNumber
		  ,dtmAsOfDate
		) STAGING2
		WHERE STAGING.dblTotalAR IS NULL
		AND intEntityUserId = @intEntityUserId

		END
		ELSE
		BEGIN

			IF(ISNULL(@strInvoiceCycle,'') != '')
			BEGIN

				DELETE FROM tblARCustomerStatementStagingTable 
				WHERE 
					intEntityUserId = @intEntityUserId 
					AND intEntityCustomerId NOT IN (
					SELECT cfAC.intCustomerId 
					FROM tblCFAccount as cfAC
					INNER JOIN tblCFInvoiceCycle cfIC
					ON cfAC.intInvoiceCycle = cfIC.intInvoiceCycleId
					WHERE cfIC.strInvoiceCycle COLLATE Latin1_General_CI_AS IN (
						SELECT Record FROM fnCFSplitString(@strInvoiceCycle,'|^|')
					)
				)
			END

			UPDATE tblARCustomerStatementStagingTable SET ysnPrintFromCardFueling = 1 , dtmCFInvoiceDate = @dtmInvoiceDate
			WHERE intEntityUserId = @intEntityUserId

			UPDATE tblARCustomerStatementStagingTable
			SET 
			strCFEmail							=	  (SELECT TOP (1) ISNULL(strEmail,'')
																							FROM    dbo.vyuARCustomerContacts as arCustCont
																							WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																							AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																							AND (ISNULL(strEmail, N'') <> ''))
			,strCFEmailDistributionOption		=	  (SELECT TOP (1) ISNULL(strEmailDistributionOption,'')
																							FROM    dbo.vyuARCustomerContacts as arCustCont
																							WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
																							AND (strEmailDistributionOption LIKE '%CF Invoice%') 
																							AND (ISNULL(strEmail, N'') <> ''))	
			WHERE intEntityUserId = @intEntityUserId


			UPDATE tblARCustomerStatementStagingTable
			SET 
					 tblARCustomerStatementStagingTable.intCFAccountId					   = 		cfInv.intAccountId				
					,tblARCustomerStatementStagingTable.dblCFDiscount					   = 		cfInv.dblDiscount				
					,tblARCustomerStatementStagingTable.dblCFEligableGallon				   = 		cfInv.dblEligableGallon			
					,tblARCustomerStatementStagingTable.strCFGroupDiscoount				   = 		cfInv.strGroupName			
					,tblARCustomerStatementStagingTable.intCFDiscountDay				   = 		cfInv.intDiscountDay			
					,tblARCustomerStatementStagingTable.strCFTermType					   = 		cfInv.strTermType				
					--,tblARCustomerStatementStagingTable.dtmCFInvoiceDate				   = 		cfInv.dtmInvoiceDate			
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
					,tblARCustomerStatementStagingTable.strCFTerm						   = 		cfInv.strTerm			
					,tblARCustomerStatementStagingTable.strCFTermCode					   = 		cfInv.strTermCode	
						
			FROM tblCFInvoiceStagingTable cfInv
			WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfInv.intCustomerId
			AND cfInv.strUserId = @UserId
			AND tblARCustomerStatementStagingTable.intEntityUserId = @intEntityUserId


			DELETE FROM tblARCustomerStatementStagingTable 
				WHERE intEntityUserId = @intEntityUserId
				AND intEntityCustomerId IN (
				SELECT intEntityCustomerId FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserId AND intEntityCustomerId not in (
					SELECT intEntityCustomerId AS intCount FROM tblARCustomerStatementStagingTable
					WHERE 
					strTransactionType != 'Balance Forward' 
					AND intEntityUserId = @intEntityUserId
					GROUP BY intEntityCustomerId,strCustomerName
					HAVING ISNULL(COUNT(*),0) > 0)
			AND ISNULL(dblTotalAR,0) = 0)

		END


	END


	UPDATE tblARCustomerStatementStagingTable SET strCFEmailDistributionOption = '' WHERE strCFEmailDistributionOption IS NULL AND intEntityUserId = @intEntityUserId
	UPDATE tblARCustomerStatementStagingTable SET strCFEmail = '' WHERE strCFEmail IS NULL AND intEntityUserId = @intEntityUserId
	

	--SELECT * FROM vyuCFAccountTerm
	--select * from vyuCFCardAccount


	IF (@@TRANCOUNT > 0) COMMIT TRANSACTION 

END TRY 
BEGIN CATCH
	
	SELECT   
		@CatchErrorMessage = ERROR_MESSAGE(),  
		@CatchErrorSeverity = ERROR_SEVERITY(),  
		@CatchErrorState = ERROR_STATE();  

		

		print @CatchErrorMessage
		print @CatchErrorSeverity
		print @CatchErrorState

	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
  
	--SELECT   
	--	@CatchErrorMessage = ERROR_MESSAGE(),  
	--	@CatchErrorSeverity = ERROR_SEVERITY(),  
	--	@CatchErrorState = ERROR_STATE();  

	-------------CLEAN TEMP TABLES------------
	DELETE FROM tblCFInvoiceReportTempTable			 WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceSummaryTempTable		 WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceDiscountTempTable		 WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceStagingTable			 WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceFeeStagingTable			 WHERE strUserId = @UserId
	------------------------------------------

	RAISERROR (@CatchErrorMessage,@CatchErrorSeverity,@CatchErrorState)

	
	

END CATCH
END
CREATE PROCEDURE [dbo].[uspCFInvoiceToStagingTable](
	 @xmlParam					NVARCHAR(MAX)  
	,@Guid						NVARCHAR(MAX)  
	,@UserId					NVARCHAR(MAX)  
	,@StatementType				NVARCHAR(MAX)
)
AS
BEGIN

	DECLARE @ErrorMessage NVARCHAR(MAX);  
	DECLARE @CatchErrorMessage NVARCHAR(MAX);  
	DECLARE @CatchErrorSeverity INT;  
	DECLARE @CatchErrorState INT;  
	DECLARE @index INT = 0

	print @Guid	
	print @UserId
	DECLARE @intEntityUserId INT;
	DECLARE @strStatementFormat NVARCHAR(20) = 'Balance Forward'

	select TOP 1 @intEntityUserId = intEntityId from tblSMUserSecurity where strUserName = @UserId
	
	IF LOWER(@StatementType)  = 'invoice'
	BEGIN
		DELETE FROM tblCFInvoiceFeeStagingTable			WHERE strUserId = @UserId
	END
	
	DELETE FROM tblCFInvoiceReportTempTable			WHERE strUserId = @UserId 
	DELETE FROM tblCFInvoiceSummaryTempTable		WHERE strUserId = @UserId 
	DELETE FROM tblCFInvoiceDiscountTempTable		WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceStagingTable			WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)

	DELETE tblCFInvoiceStagingTable					WHERE strUserId is null
	DELETE tblARCustomerStatementStagingTable		WHERE intEntityUserId is null AND strStatementFormat = @strStatementFormat

BEGIN TRY

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

	DECLARE @ysnIncludePrintedTransaction BIT
	SELECT TOP 1
			@ysnIncludePrintedTransaction = ISNULL([from],0)
	FROM @temp_params WHERE [fieldname] = 'ysnIncludePrintedTransaction'

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



	--IF (@@TRANCOUNT = 0) BEGIN TRANSACTION

	-- EXECUTE INVOICE REPORT SP's--
	-----------------------------------------------------------
	-- EXECUTING THIS SP's WILL INSERT RECORDS ON TEMP TABLES--
	-----------------------------------------------------------
	DELETE FROM tblCFInvoiceReportTempTable	WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)
	EXEC "dbo"."uspCFInvoiceReport"			@xmlParam	=	@xmlParam , @UserId = @UserId, @StatementType = @StatementType


	DELETE FROM tblCFInvoiceReportTotalValidation WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)
	IF (ISNULL(@ysnReprintInvoice,0) = 0 AND ISNULL(@ysnIncludePrintedTransaction,0) = 0 ) 
	BEGIN
		EXEC "dbo"."uspCFInvoiceReportValidation" @UserId = @UserId , @StatementType = @StatementType

		DECLARE @intInvalidTransaction INT 
		SELECT @intInvalidTransaction = COUNT(1) FROM tblCFInvoiceReportTotalValidation	WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)

		IF (@intInvalidTransaction >= 1) 
		BEGIN
			SET @ErrorMessage = 'Total Validation Error'
			GOTO EXITWITHERROR
		END
	END
	
	
	DELETE FROM tblCFInvoiceSummaryTempTable WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)
	EXEC "dbo"."uspCFInvoiceReportSummary" @UserId = @UserId , @StatementType = @StatementType

	DELETE FROM tblCFInvoiceDiscountTempTable WHERE strUserId = @UserId 
	EXEC "dbo"."uspCFInvoiceReportDiscount" @UserId = @UserId , @StatementType = @StatementType

	-- INSERT CALCULATED INVOICES TO STAGING TABLE --
	-----------------------------------------------------------
	DELETE FROM tblCFInvoiceStagingTable WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)
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
	,dtmBillingDate
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
	,ysnSummaryByDepartmentProduct
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
	,ysnMPGCalculation
	,ysnShowOnCFInvoice
	,strDiscountSchedule
	,ysnPostForeignSales
	,ysnSummaryByDeptVehicleProd
	,ysnDepartmentGrouping
	,ysnPostedCSV
	,strGuid
	,strUserId
	,ysnExpensed
	,strStatementType
	,strDriverPinNumber		
	,strDriverDescription	
	,intDriverPinId			
	,ysnSummaryByDriverPin	
	,strDetailDisplay
	,strDetailDisplayValue
	,strDetailDisplayLabel	
	,ysnShowVehicleDescriptionOnly	
	,ysnShowDriverPinDescriptionOnly
	,ysnPageBreakByPrimarySortOrder
	,ysnSummaryByDeptDriverPinProd
	,strDepartmentGrouping
	)
	SELECT 
	 intCustomerGroupId
	,cfInvRpt.intTransactionId
	,cfInvRpt.intOdometer
	----------------------------------------------------------------------------------
	,intOdometerAging = (CASE 
						WHEN cfInvRpt.strPrimarySortOptions = 'Card' 
						THEN cfCardOdom.intOdometer
                        WHEN cfInvRpt.strPrimarySortOptions = 'Vehicle' 
							THEN 
								CASE 
								WHEN ISNULL(cfInvRpt.intVehicleId, 0) =  0
									THEN cfCardOdom.intOdometer
								ELSE cfVehicleOdom.intOdometer
								END
						 WHEN cfInvRpt.strPrimarySortOptions = 'Miscellaneous' 
							THEN 
								CASE 
								WHEN strMiscellaneous =  '' OR strMiscellaneous IS NULL
									THEN cfCardOdom.intOdometer
								ELSE ISNULL((SELECT TOP 1 intOdometer FROM (
											SELECT iocftran.*  
												FROM   dbo.tblCFTransaction as iocftran
												LEFT JOIN tblCFItem as iocfitem
												ON iocftran.intProductId = iocfitem.intItemId
												WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
												AND strMiscellaneous IS NOT NULL
												AND strMiscellaneous != ''
												AND ISNULL(ysnPosted,0) = 1
											) as miscBase
										WHERE  (dtmTransactionDate < cfInvRpt.dtmTransactionDate ) 
										AND ( strMiscellaneous = cfInvRpt.strMiscellaneous ) 
										ORDER  BY dtmTransactionDate DESC),0)
								END
						ELSE 0
					END)
	----------------------------------------------------------------------------------
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
	,ISNULL(strMiscellaneous,'')
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
	,cfInvRpt.strDepartmentDescription
	,strShortName
	,strProductDescription
	,strItemNumber
	,strItemDescription
	,strTerm
	,strTermCode
	,strTermType
	,dtmTransactionDate
	,dtmBillingDate
	,dtmDate
	,dtmPostedDate
	,dtmDiscountDate
	,dtmDueDate
	,@dtmInvoiceDate
	,dblTotalMiles = (CASE 
						WHEN cfInvRpt.strPrimarySortOptions = 'Card' 
						THEN
							CASE
								WHEN  ISNULL (cfCardOdom.intOdometer, 0)   > 0 
								THEN cfInvRpt.intOdometer -	ISNULL (cfCardOdom.intOdometer, 0) 
								ELSE 0 
							END
                        WHEN cfInvRpt.strPrimarySortOptions = 'Vehicle' 
						THEN 
							CASE 
								WHEN ISNULL(cfInvRpt.intVehicleId, 0) =  0
								THEN 
									CASE
										WHEN  ISNULL (cfCardOdom.intOdometer, 0)   > 0 
										THEN cfInvRpt.intOdometer -	ISNULL (cfCardOdom.intOdometer, 0) 
										ELSE 0 
									END
								ELSE 
									CASE
										WHEN  ISNULL (cfVehicleOdom.intOdometer, 0)   > 0 
										THEN cfInvRpt.intOdometer -	ISNULL (cfVehicleOdom.intOdometer, 0) 
										ELSE 0 
									END
							END
							WHEN cfInvRpt.strPrimarySortOptions = 'Miscellaneous' 
							THEN 
								CASE 
								WHEN cfInvRpt.strMiscellaneous =  '' OR cfInvRpt.strMiscellaneous IS NULL
								THEN 
									CASE
										WHEN  ISNULL (cfCardOdom.intOdometer, 0)   > 0 
										THEN cfInvRpt.intOdometer -	ISNULL (cfCardOdom.intOdometer, 0) 
										ELSE 0 
									END
								ELSE 
									CASE
										WHEN  
										ISNULL((SELECT TOP 1 intOdometer FROM (
											SELECT iocftran.*  
												FROM   dbo.tblCFTransaction as iocftran
												LEFT JOIN tblCFItem as iocfitem
												ON iocftran.intProductId = iocfitem.intItemId
												WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
												AND strMiscellaneous IS NOT NULL
												AND strMiscellaneous != ''
												AND ISNULL(ysnPosted,0) = 1
											) as miscBase
										WHERE  (dtmTransactionDate < cfInvRpt.dtmTransactionDate ) 
										AND ( strMiscellaneous = cfInvRpt.strMiscellaneous ) 
										ORDER  BY dtmTransactionDate DESC),0)  > 0 
										THEN cfInvRpt.intOdometer -	ISNULL((SELECT TOP 1 intOdometer FROM (
											SELECT iocftran.*  
												FROM   dbo.tblCFTransaction as iocftran
												LEFT JOIN tblCFItem as iocfitem
												ON iocftran.intProductId = iocfitem.intItemId
												WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
												AND strMiscellaneous IS NOT NULL
												AND strMiscellaneous != ''
												AND ISNULL(ysnPosted,0) = 1
											) as miscBase
										WHERE  (dtmTransactionDate < cfInvRpt.dtmTransactionDate ) 
										AND ( strMiscellaneous = cfInvRpt.strMiscellaneous ) 
										ORDER  BY dtmTransactionDate DESC),0) 
										ELSE 0 
									END
							END
						ELSE 0
					END)

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
	,ysnSummaryByDepartmentProduct
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
	,cfInvRpt.ysnMPGCalculation
	,cfInvRptDcnt.ysnShowOnCFInvoice
	,cfInvRptDcnt.strDiscountSchedule
	,cfInvRpt.ysnPostForeignSales
	,ysnSummaryByDeptVehicleProd
	,ysnDepartmentGrouping
	,ysnPostedCSV
	,@Guid
	,@UserId
	,ysnExpensed
	,@StatementType 
	,strDriverPinNumber		
	,strDriverDescription	
	,intDriverPinId			
	,ysnSummaryByDriverPin	
	,strDetailDisplay	
	,strDetailDisplayValue = CASE WHEN LOWER(strDetailDisplay) = 'card'
									THEN strCardNumber + ' - ' + strCardDescription

								  WHEN LOWER(strDetailDisplay) = 'vehicle'
									THEN (CASE	
											WHEN ISNULL(strVehicleNumber,'') != '' THEN 
												CASE WHEN ISNULL(ysnShowVehicleDescriptionOnly,0) = 0 THEN strVehicleNumber + ' - ' + strVehicleDescription ELSE strVehicleDescription END
											ELSE (CASE	
													WHEN LOWER(strPrimarySortOptions) = 'card' THEN 
														CASE WHEN ISNULL(ysnShowDriverPinDescriptionOnly,0) = 0 THEN strDriverPinNumber + ' - ' + strDriverDescription ELSE strDriverDescription END
													WHEN LOWER(strPrimarySortOptions) = 'driverpin' THEN strCardNumber + ' - ' + strCardDescription
													WHEN LOWER(strPrimarySortOptions) = 'driver pin' THEN strCardNumber + ' - ' + strCardDescription
													WHEN LOWER(strPrimarySortOptions) = 'miscellaneous' THEN 
														CASE WHEN ISNULL(ysnShowDriverPinDescriptionOnly,0) = 0 THEN strDriverPinNumber + ' - ' + strDriverDescription ELSE strDriverDescription END
												  END)
										  END)

								  WHEN LOWER(strDetailDisplay) = 'driverpin' OR LOWER(strDetailDisplay) = 'driver pin' 
									THEN (CASE
											WHEN ISNULL(strDriverPinNumber,'') != '' THEN
												CASE WHEN ISNULL(ysnShowDriverPinDescriptionOnly,0) = 0 THEN strDriverPinNumber + ' - ' + strDriverDescription ELSE strDriverDescription END
											ELSE (CASE 
													WHEN LOWER(strPrimarySortOptions) = 'card' THEN CASE WHEN ISNULL(ysnShowVehicleDescriptionOnly,0) = 0 THEN strVehicleNumber + ' - ' + strVehicleDescription ELSE strVehicleDescription END
													WHEN LOWER(strPrimarySortOptions) = 'vehicle' THEN strCardNumber + ' - ' + strCardDescription
													WHEN LOWER(strPrimarySortOptions) = 'miscellaneous' THEN CASE WHEN ISNULL(ysnShowVehicleDescriptionOnly,0) = 0 THEN strVehicleNumber + ' - ' + strVehicleDescription ELSE strVehicleDescription END
												  END)
											END)
							 END

	,strDetailDisplayLabel = CASE WHEN LOWER(strDetailDisplay) = 'card'
									THEN 'Card'

								  WHEN LOWER(strDetailDisplay) = 'vehicle'
									THEN 'Vehicle'

								  WHEN LOWER(strDetailDisplay) = 'driverpin' OR LOWER(strDetailDisplay) = 'driver pin' 
									THEN  'Driver Pin'
							 END
	,ysnShowVehicleDescriptionOnly	
	,ysnShowDriverPinDescriptionOnly
	,ysnPageBreakByPrimarySortOrder
	,ysnSummaryByDeptDriverPinProd
	,strDepartmentGrouping
	FROM tblCFInvoiceReportTempTable AS cfInvRpt
	INNER JOIN ( SELECT * FROM tblCFInvoiceSummaryTempTable WHERE strUserId = @UserId) AS cfInvRptSum
	ON cfInvRpt.intTransactionId = cfInvRptSum.intTransactionId 
	INNER JOIN ( SELECT * FROM tblCFInvoiceDiscountTempTable WHERE strUserId = @UserId) AS cfInvRptDcnt
	ON cfInvRpt.intTransactionId = cfInvRptDcnt.intTransactionId 
	-------------------------------------------------------------
	OUTER APPLY (
		SELECT TOP (1) intOdometer 
			  FROM   dbo.tblCFTransaction as iocftran
			  LEFT JOIN tblCFItem as iocfitem
			  ON iocftran.intProductId = iocfitem.intItemId
			  WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
			  AND ( dtmTransactionDate < cfInvRpt.dtmTransactionDate ) 
			  AND ( intCardId = cfInvRpt.intCardId ) 
			  AND (ISNULL(iocftran.ysnPosted,0) = 1) 
			  ORDER  BY dtmTransactionDate DESC
	) AS cfCardOdom
	-----------------------------------------------------------
	OUTER APPLY (
		SELECT TOP (1) intOdometer 
			  FROM   dbo.tblCFTransaction as iocftran
			  LEFT JOIN tblCFItem as iocfitem
			  ON iocftran.intProductId = iocfitem.intItemId
			  WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
			  AND ( dtmTransactionDate < cfInvRpt.dtmTransactionDate ) 
			  AND ( intVehicleId = cfInvRpt.intVehicleId ) 
			  AND intVehicleId IS NOT NULL
			  AND intVehicleId != 0
			  AND (ISNULL(iocftran.ysnPosted,0) = 1) 
			  ORDER  BY dtmTransactionDate DESC
	) AS cfVehicleOdom
	-----------------------------------------------------------
	--OUTER APPLY (
	--	SELECT TOP 1 intOdometer FROM (
	--		SELECT iocftran.*  
	--			FROM   dbo.tblCFTransaction as iocftran
	--			LEFT JOIN tblCFItem as iocfitem
	--			ON iocftran.intProductId = iocfitem.intItemId
	--			WHERE ISNULL(iocfitem.ysnMPGCalculation,0) = 1 
	--			AND strMiscellaneous IS NOT NULL
	--			AND strMiscellaneous != ''
	--			AND ISNULL(ysnPosted,0) = 1
	--		) as miscBase
	--	WHERE  (dtmTransactionDate < cfInvRpt.dtmTransactionDate ) 
	--	AND ( strMiscellaneous = cfInvRpt.strMiscellaneous ) 
	--	ORDER  BY dtmTransactionDate DESC
	--) AS cfMiscOdom
	-----------------------------------------------------------
	WHERE cfInvRpt.strUserId = @UserId 



	--AZ TAX--
	DECLARE @intAZTaxCodeId INT 
	SELECT TOP 1 @intAZTaxCodeId = intAZTaxCodeId FROM tblCFCompanyPreference

	IF(ISNULL(@intAZTaxCodeId,0) != 0)
	BEGIN

		DECLARE @intTaxCodeId INT
		DECLARE @ysnExempt BIT


		DECLARE @tblTransWithAZtax TABLE
		(
			intTransactionId INT		
		)	

		INSERT INTO @tblTransWithAZtax ( intTransactionId )
		SELECT intTransactionId FROM tblCFTransactionTax WHERE (ISNULL(tblCFTransactionTax.ysnTaxExempt,0) = 1 AND tblCFTransactionTax.intTaxCodeId = @intAZTaxCodeId)


		UPDATE tblCFInvoiceStagingTable
		SET strProductDescriptionForTotals = strItemDescription + '- Light Class'
		WHERE intTransactionId IN (SELECT intTransactionId FROM @tblTransWithAZtax)
		AND LOWER(strStatementType) =  LOWER(@StatementType)
		AND LOWER(strUserId) = Lower(@UserId)

	
		UPDATE tblCFInvoiceStagingTable
		SET strProductDescriptionForTotals = strItemDescription
		WHERE intTransactionId NOT IN (SELECT intTransactionId FROM @tblTransWithAZtax)
		AND LOWER(strStatementType) =  LOWER(@StatementType)
		AND LOWER(strUserId) = Lower(@UserId)

	END
	ELSE
	BEGIN
		UPDATE tblCFInvoiceStagingTable
		SET strProductDescriptionForTotals = strItemDescription
		WHERE intTransactionId NOT IN (SELECT intTransactionId FROM @tblTransWithAZtax)
		AND LOWER(strStatementType) =  LOWER(@StatementType)
	END 
	--AZ TAX--


	--AND cfInvRptSum.strUserId = @UserId
	--AND cfInvRptDcnt.strUserId = @UserId

	--UPDATE tblCFInvoiceStagingTable SET dblTotalFuelExpensed = ISNULL((SELECT SUM(t.dblCalculatedTotalPrice * -1) FROM tblCFInvoiceStagingTable as s
	--													INNER JOIN tblCFTransaction as t
	--													ON s.intTransactionId = t.intTransactionId
	--													WHERE ISNULL(t.ysnExpensed,0) = 1 
	--													AND s.strUserId = @UserId)
	--													,0)
	--WHERE strUserId = @UserId


	
	
	--SELECT DISTINCT 
	-- intAccountId
	--,intCustomerId
	--,strCustomerName
	--FROM tblCFInvoiceStagingTable
	--WHERE strUserId = @UserId 
	--AND LOWER(strStatementType) =  LOWER(@StatementType)

	--INSERT FEE RECORDS--
	IF LOWER(@StatementType)  = 'invoice'
	BEGIN
		EXEC "dbo"."uspCFInvoiceReportFee"		@xmlParam	=	@xmlParam , @UserId = @UserId
	END


	
	UPDATE tblCFInvoiceStagingTable
	SET 
			tblCFInvoiceStagingTable.dblTotalFuelExpensed			   =		ISNULL(cfInv.dblTotalFuelExpensed,0),
			tblCFInvoiceStagingTable.dblFeeAmount					   =		iSNULL((SELECT SUM(ISNULL(innerTable.dblFeeAmount,0)) AS dblTotalFeeAMount 
																						FROM tblCFInvoiceFeeStagingTable AS innerTable
																						WHERE innerTable.intAccountId = tblCFInvoiceStagingTable.intAccountId  
																						AND LOWER(tblCFInvoiceStagingTable.strStatementType) =  LOWER(@StatementType)
																						AND strUserId = @UserId 
																				GROUP BY intAccountId),0)
	FROM (
		SELECT SUM(t.dblCalculatedTotalPrice * -1) as dblTotalFuelExpensed , s.intCustomerId
		FROM tblCFInvoiceStagingTable as s
		INNER JOIN tblCFTransaction as t
		ON s.intTransactionId = t.intTransactionId
		WHERE ISNULL(t.ysnExpensed,0) = 1 
		AND LOWER(s.strStatementType) =  LOWER(@StatementType)
		AND s.strUserId = @UserId
		GROUP BY s.intCustomerId
	) AS cfInv
	WHERE tblCFInvoiceStagingTable.intCustomerId = cfInv.intCustomerId
	AND tblCFInvoiceStagingTable.strUserId = @UserId
	AND LOWER(tblCFInvoiceStagingTable.strStatementType) =  LOWER(@StatementType)

	


	IF(@ysnIncludeRemittancePage = 1 AND LOWER(@StatementType)  = 'invoice')
	BEGIN

		EXEC uspARCustomerStatementBalanceForwardReport 
			  @dtmDateFrom = NULL			
			, @dtmDateTo = @dtmInvoiceDate
			, @ysnPrintZeroBalance = 1
			, @dtmBalanceForwardDate = @dtmBalanceForwardDate
			, @ysnPrintFromCF = 1
			, @strCustomerNumber = @strCustomerNumber		
			,@intEntityUserId = @intEntityUserId
			,@ysnReprintInvoice = @ysnReprintInvoice
			,@strUserId = @UserId

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
		,dblCFTotalFuelExpensed
		,dblCFFeeTotalAmount
		,strStatementFormat
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
		,LTRIM(REPLACE(strBillTo,strCustomerName,'')) --strFullAddress
		,NULL --strStatementFooterComment
		,strCompanyName
		,strCompanyAddress
		,NULL --dblCreditLimit
		,(dblAccountTotalAmount + ISNULL(dblTotalFuelExpensed,0) +( 
			ISNULL((SELECT SUM(ISNULL(dblFeeAmount,0)) AS dblTotalFeeAMount FROM tblCFInvoiceFeeStagingTable AS innerTable
			WHERE innerTable.intAccountId = cfInv.intAccountId AND strUserId = @UserId
			GROUP BY intAccountId),0)
		)) --dblInvoiceTotal
		,0 --dblPayment
		,(dblAccountTotalAmount + ISNULL(dblTotalFuelExpensed,0) + ( 
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
		,ISNULL(dblTotalFuelExpensed,0)
		,ISNULL(dblFeeAmount,0)
		,@strStatementFormat
		FROM
		tblCFInvoiceStagingTable 
		AS cfInv
		WHERE strUserId = @UserId
		AND LOWER(strStatementType) =  LOWER(@StatementType)
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
		,dblTotalFuelExpensed
		,dblFeeAmount
		,strBillTo
		

		--SELECT '2',* FROM tblARCustomerStatementStagingTable

		IF(ISNULL(@strInvoiceCycle,'') != '')
		BEGIN

			DELETE FROM tblARCustomerStatementStagingTable 
			WHERE intEntityUserId = @intEntityUserId
				AND strStatementFormat = @strStatementFormat
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
		

		UPDATE tblARCustomerStatementStagingTable SET ysnPrintFromCardFueling = 1 , dtmCFInvoiceDate = @dtmInvoiceDate WHERE intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat

		--UPDATE tblARCustomerStatementStagingTable
		--SET 
		--strCFEmail							=	  (SELECT TOP (1) strEmail
		--																				FROM    dbo.vyuARCustomerContacts
		--																				WHERE (intEntityCustomerId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
		--																				AND (strEmailDistributionOption LIKE '%CF Invoice%') 
		--																				AND (ISNULL(strEmail, N'') <> ''))
		--,strCFEmailDistributionOption		=	  (SELECT TOP (1) strEmailDistributionOption
		--																				FROM    dbo.vyuARCustomerContacts
		--																				WHERE (intEntityCustomerId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
		--																				AND (strEmailDistributionOption LIKE '%CF Invoice%') 
		--																				AND (ISNULL(strEmail, N'') <> ''))	
		--WHERE intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat


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
				,tblARCustomerStatementStagingTable.dblCFFeeTotalAmount				   = 		ISNULL(cfInv.dblFeeAmount,0)
				,tblARCustomerStatementStagingTable.dblCFInvoiceTotal				   = 		cfInv.dblInvoiceTotal			
				,tblARCustomerStatementStagingTable.dblCFTotalQuantity				   = 		cfInv.dblTotalQuantity			
				,tblARCustomerStatementStagingTable.strCFTempInvoiceReportNumber	   = 		cfInv.strTempInvoiceReportNumber
				,tblARCustomerStatementStagingTable.strCFEmailDistributionOption	   = 		cfInv.strEmailDistributionOption
				,tblARCustomerStatementStagingTable.strCFEmail						   = 		cfInv.strEmail			
				,tblARCustomerStatementStagingTable.ysnCFShowDiscountOnInvoice		   =		cfInv.ysnShowOnCFInvoice	
				,tblARCustomerStatementStagingTable.strCFTerm						   = 		cfInv.strTerm			
				,tblARCustomerStatementStagingTable.strCFTermCode					   = 		cfInv.strTermCode
				,tblARCustomerStatementStagingTable.dblCFTotalFuelExpensed			   =		ISNULL(cfInv.dblTotalFuelExpensed,0)
		FROM tblCFInvoiceStagingTable cfInv
		WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfInv.intCustomerId
		AND strStatementFormat = @strStatementFormat
		AND cfInv.strUserId = @UserId
		AND intEntityUserId = @intEntityUserId
		AND LOWER(cfInv.strStatementType) =  LOWER(@StatementType)



	


		UPDATE tblARCustomerStatementStagingTable
		SET
				 tblARCustomerStatementStagingTable.intCFAccountId						=	  cfAccntTerm.intAccountId
				,tblARCustomerStatementStagingTable.intCFDiscountDay					=	  cfAccntTerm.intDiscountDay
				,tblARCustomerStatementStagingTable.strCFTermType						=	  cfAccntTerm.strType
				,tblARCustomerStatementStagingTable.intCFTermID							=	  cfAccntTerm.intTermsCode

				--,tblARCustomerStatementStagingTable.strCFEmail							=	  (SELECT TOP (1) ISNULL(strEmail,'')
				--																				FROM    dbo.vyuARCustomerContacts as arCustCont
				--																				WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
				--																				AND (strEmailDistributionOption LIKE '%CF Invoice%') 
				--																				AND (ISNULL(strEmail, N'') <> ''))

				--,tblARCustomerStatementStagingTable.strCFEmailDistributionOption		=	  (SELECT TOP (1) ISNULL(strEmailDistributionOption,'')
				--																			FROM    dbo.vyuARCustomerContacts as arCustCont
				--																			WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
				--																			AND (strEmailDistributionOption LIKE '%CF Invoice%') 
				--																			AND (ISNULL(strEmail, N'') <> ''))
		FROM vyuCFAccountTerm cfAccntTerm
		WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfAccntTerm.intCustomerId
		AND intEntityUserId = @intEntityUserId
		AND strStatementFormat = @strStatementFormat
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
		AND strStatementFormat = @strStatementFormat

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
		   AND intEntityUserId = STAGING.intEntityUserId
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
		AND strStatementFormat = @strStatementFormat

		END
		ELSE
		BEGIN

			IF(ISNULL(@strInvoiceCycle,'') != '')
			BEGIN

				DELETE FROM tblARCustomerStatementStagingTable 
				WHERE 
					intEntityUserId = @intEntityUserId 
					AND strStatementFormat = @strStatementFormat
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
			WHERE intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat

			--UPDATE tblARCustomerStatementStagingTable
			--SET 
			--strCFEmail							=	  (SELECT TOP (1) ISNULL(strEmail,'')
			--																				FROM    dbo.vyuARCustomerContacts as arCustCont
			--																				WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
			--																				AND (strEmailDistributionOption LIKE '%CF Invoice%') 
			--																				AND (ISNULL(strEmail, N'') <> ''))
			--,strCFEmailDistributionOption		=	  (SELECT TOP (1) ISNULL(strEmailDistributionOption,'')
			--																				FROM    dbo.vyuARCustomerContacts as arCustCont
			--																				WHERE (arCustCont.intCustomerEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId) 
			--																				AND (strEmailDistributionOption LIKE '%CF Invoice%') 
			--																				AND (ISNULL(strEmail, N'') <> ''))	
			--WHERE intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat


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
					,tblARCustomerStatementStagingTable.dblCFFeeTotalAmount				   = 		ISNULL(cfInv.dblFeeAmount,0)			
					,tblARCustomerStatementStagingTable.dblCFInvoiceTotal				   = 		cfInv.dblInvoiceTotal			
					,tblARCustomerStatementStagingTable.dblCFTotalQuantity				   = 		cfInv.dblTotalQuantity			
					,tblARCustomerStatementStagingTable.strCFTempInvoiceReportNumber	   = 		cfInv.strTempInvoiceReportNumber
					,tblARCustomerStatementStagingTable.strCFEmailDistributionOption	   = 		cfInv.strEmailDistributionOption
					,tblARCustomerStatementStagingTable.strCFEmail						   = 		cfInv.strEmail			
					,tblARCustomerStatementStagingTable.ysnCFShowDiscountOnInvoice		   =		cfInv.ysnShowOnCFInvoice	
					,tblARCustomerStatementStagingTable.strCFTerm						   = 		cfInv.strTerm			
					,tblARCustomerStatementStagingTable.strCFTermCode					   = 		cfInv.strTermCode	
					,tblARCustomerStatementStagingTable.dblCFTotalFuelExpensed			   =		ISNULL(cfInv.dblTotalFuelExpensed,0)
						
			FROM tblCFInvoiceStagingTable cfInv
			WHERE tblARCustomerStatementStagingTable.intEntityCustomerId = cfInv.intCustomerId
			AND cfInv.strUserId = @UserId
			AND strStatementFormat = @strStatementFormat
			AND tblARCustomerStatementStagingTable.intEntityUserId = @intEntityUserId
			AND LOWER(cfInv.strStatementType) =  LOWER(@StatementType)


			DELETE FROM tblARCustomerStatementStagingTable 
				WHERE intEntityUserId = @intEntityUserId
				AND strStatementFormat = @strStatementFormat
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

	UPDATE tblARCustomerStatementStagingTable
	SET 
			
	 strCFEmail							= arCustomerContact.strEmail
	,strCFEmailDistributionOption = 
	(SELECT (CASE 
		WHEN (LOWER(emEntity.strDocumentDelivery) like '%direct mail%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
			THEN 'print , email , CF Invoice'

		WHEN (LOWER(emEntity.strDocumentDelivery) like '%email%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
			THEN 'email , CF Invoice'

		WHEN ( (LOWER(emEntity.strDocumentDelivery) not like '%email%' OR  LOWER(emEntity.strDocumentDelivery) not like '%direct mail%') AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
			THEN 'email , CF Invoice'

		WHEN ( LOWER(emEntity.strDocumentDelivery) like '%direct mail%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
			THEN 'print'

		WHEN ( LOWER(emEntity.strDocumentDelivery) like '%email%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
			THEN 'print'

		WHEN (  (LOWER(emEntity.strDocumentDelivery) not like '%email%' OR  LOWER(emEntity.strDocumentDelivery) not like '%direct mail%') AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
			THEN 'print'
		ELSE 'print'
	END))													
	FROM tblARCustomerStatementStagingTable
	INNER JOIN vyuCFCustomerEntity AS emEntity 
	ON emEntity.intEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId
	OUTER APPLY (
	SELECT TOP 1 
		 strEmailDistributionOption
		,strEmail 
	FROM vyuARCustomerContacts
	WHERE intEntityId = tblARCustomerStatementStagingTable.intEntityCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '' AND ISNULL(ysnActive,0) = 1
	) AS arCustomerContact
	WHERE intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat
	

	IF LOWER(@StatementType)  = 'invoice'
	BEGIN
		UPDATE tblARCustomerStatementStagingTable SET strCFEmailDistributionOption = '' WHERE strCFEmailDistributionOption IS NULL AND intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat
		UPDATE tblARCustomerStatementStagingTable SET strCFEmail = '' WHERE strCFEmail IS NULL AND intEntityUserId = @intEntityUserId AND strStatementFormat = @strStatementFormat
	END

	
	IF (ISNULL(@ysnReprintInvoice,0) = 0 AND ISNULL(@ysnIncludePrintedTransaction,0) = 0 AND ISNULL(@ysnIncludeRemittancePage,0) = 1 ) 
	BEGIN
		EXEC "dbo"."uspCFInvoiceReportBalanceValidation" @UserId = @UserId ,  @StatementType = @StatementType 
		DECLARE @intInvalidBalance INT 
		SELECT @intInvalidBalance = COUNT(1) FROM tblCFInvoiceReportTotalValidation	WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)

		IF (@intInvalidBalance >= 1) 
		BEGIN
			SET @ErrorMessage = 'Balance Validation Error'
			GOTO EXITWITHERROR
		END

	END
	

	--SELECT * FROM vyuCFAccountTerm
	--select * from vyuCFCardAccount


	--IF (@@TRANCOUNT > 0) COMMIT TRANSACTION 
	RETURN
END TRY 
BEGIN CATCH
	
	SELECT   
		@CatchErrorMessage = ERROR_MESSAGE(),  
		@CatchErrorSeverity = ERROR_SEVERITY(),  
		@CatchErrorState = ERROR_STATE();  

		

		print @CatchErrorMessage
		print @CatchErrorSeverity
		print @CatchErrorState

	--IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
  --IF (@@TRANCOUNT > 0) COMMIT TRANSACTION 
	--SELECT   
	--	@CatchErrorMessage = ERROR_MESSAGE(),  
	--	@CatchErrorSeverity = ERROR_SEVERITY(),  
	--	@CatchErrorState = ERROR_STATE();  

	-----------CLEAN TEMP TABLES------------
	DELETE FROM tblCFInvoiceReportTempTable			 WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceSummaryTempTable		 WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceDiscountTempTable		WHERE strUserId = @UserId
	DELETE FROM tblCFInvoiceStagingTable			 WHERE strUserId = @UserId AND LOWER(strStatementType) =  LOWER(@StatementType)

	IF LOWER(@StatementType)  = 'invoice'
	BEGIN
		DELETE FROM tblCFInvoiceFeeStagingTable			WHERE strUserId = @UserId
	END
	------------------------------------------

	RAISERROR (@CatchErrorMessage,@CatchErrorSeverity,@CatchErrorState)


END CATCH


	EXITWITHERROR:
	RAISERROR (@ErrorMessage,16,1)

END
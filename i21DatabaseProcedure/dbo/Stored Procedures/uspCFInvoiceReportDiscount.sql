CREATE PROCEDURE [dbo].[uspCFInvoiceReportDiscount](
	@UserId NVARCHAR(MAX)
)
AS
BEGIN
	

		DECLARE @SQL NVARCHAR(MAX)

		-----------------------------------
		--**BEGIN DISCOUNT CALCULATION**---
		-----------------------------------

		DELETE FROM tblCFInvoiceDiscountCalculationTempTable 
		WHERE strUserId = @UserId OR ISNULL(strUserId ,'') = ''
		
		-------------VARIABLES------------
		DECLARE @dblTotalQuantity NUMERIC(18,6)
		DECLARE @intDistinctDiscountLoop INT

		DECLARE @tblCFGroupVolumeDisctinct TABLE
		(
			 intCustomerGroupId INT
		)
		DECLARE @tblCFAccountVolumeDisctinct TABLE
		(
			 intAccountId INT
		)
		DECLARE @tblCFMergeVolumeDisctinct TABLE
		(
			 intAccountId INT
		)

		DECLARE @tblCFGroupVolumeTemp	TABLE
		(
			  intAccountId				INT
			 ,intSalesPersonId			INT
			 ,dtmInvoiceDate			DATETIME
			 ,intCustomerId				INT
			 ,intInvoiceId				INT
			 ,intTransactionId			INT
			 ,intCustomerGroupId		INT
			 ,intTermID					INT
			 ,intBalanceDue				INT
			 ,intDiscountDay			INT	
			 ,intDayofMonthDue			INT
			 ,intDueNextMonth			INT
			 ,intSort					INT
			 ,intConcurrencyId			INT
			 ,ysnAllowEFT				BIT
			 ,ysnActive					BIT
			 ,ysnEnergyTrac				BIT		
			 ,strDiscountSchedule		NVARCHAR(100)	
			 ,ysnShowOnCFInvoice		BIT
			 ,dblQuantity				NUMERIC(18,6)
			 ,dblTotalQuantity			NUMERIC(18,6)
			 ,dblDiscountRate			NUMERIC(18,6)
			 ,dblDiscount				NUMERIC(18,6)
			 ,dblTotalAmount			NUMERIC(18,6)
			 ,dblAccountTotalAmount		NUMERIC(18,6)
			 ,dblDiscountEP				NUMERIC(18,6)
			 ,dblAPR					NUMERIC(18,6)	
			 ,strTerm					NVARCHAR(MAX)
			 ,strType					NVARCHAR(MAX)
			 ,strTermCode				NVARCHAR(MAX)	
			 ,strNetwork				NVARCHAR(MAX)	
			 ,strCustomerName			NVARCHAR(MAX)
			 ,strInvoiceCycle			NVARCHAR(MAX)
			 ,strGroupName				NVARCHAR(MAX)
			 ,strInvoiceNumber			NVARCHAR(MAX)
			 ,strInvoiceReportNumber	NVARCHAR(MAX)
			 ,dtmDiscountDate			DATETIME
			 ,dtmDueDate				DATETIME
			 ,dtmTransactionDate		DATETIME
			 ,dtmPostedDate				DATETIME

		)
		DECLARE @tblCFAccountVolumeTemp TABLE
		(
			  intAccountId				INT
			 ,intSalesPersonId			INT
			 ,dtmInvoiceDate			DATETIME
			 ,intCustomerId				INT
			 ,intInvoiceId				INT
			 ,intTransactionId			INT
			 ,intCustomerGroupId		INT
			 ,intTermID					INT
			 ,intBalanceDue				INT
			 ,intDiscountDay			INT	
			 ,intDayofMonthDue			INT
			 ,intDueNextMonth			INT
			 ,intSort					INT
			 ,intConcurrencyId			INT
			 ,ysnAllowEFT				BIT
			 ,ysnActive					BIT
			 ,ysnEnergyTrac				BIT	
			 ,strDiscountSchedule		NVARCHAR(100)	
			 ,ysnShowOnCFInvoice		BIT
			 ,dblQuantity				NUMERIC(18,6)
			 ,dblTotalQuantity			NUMERIC(18,6)
			 ,dblDiscountRate			NUMERIC(18,6)
			 ,dblDiscount				NUMERIC(18,6)
			 ,dblTotalAmount			NUMERIC(18,6)
			 ,dblAccountTotalAmount		NUMERIC(18,6)
			 ,dblDiscountEP				NUMERIC(18,6)
			 ,dblAPR					NUMERIC(18,6)	
			 ,strTerm					NVARCHAR(MAX)
			 ,strType					NVARCHAR(MAX)
			 ,strTermCode				NVARCHAR(MAX)	
			 ,strNetwork				NVARCHAR(MAX)	
			 ,strCustomerName			NVARCHAR(MAX)
			 ,strInvoiceCycle			NVARCHAR(MAX)
			 ,strGroupName				NVARCHAR(MAX)
			 ,strInvoiceNumber			NVARCHAR(MAX)
			 ,strInvoiceReportNumber	NVARCHAR(MAX)
			 ,dtmDiscountDate			DATETIME
			 ,dtmDueDate				DATETIME
			 ,dtmTransactionDate		DATETIME
			 ,dtmPostedDate				DATETIME

		)
		DECLARE @tblCFInvoiceDiscount TABLE 	
		(
			 intCustomerId				INT
			,intTransactionId			INT
			,intSalesPersonId			INT
			,intInvoiceId				INT
			,intAccountId				INT
			,intTermID					INT
			,intBalanceDue				INT
			,intDiscountDay				INT
			,intDayofMonthDue			INT
			,intDueNextMonth			INT
			,intSort					INT
			,intConcurrencyId			INT
			,intDiscountScheduleId		INT
			,intCustomerGroupId			INT
			,ysnInvoiced				BIT
			,ysnAllowEFT				BIT
			,ysnActive					BIT
			,ysnEnergyTrac				BIT
			,ysnShowOnCFInvoice			BIT
			,dblAPR						NUMERIC(18,6)
			,dblDiscountEP				NUMERIC(18,6)
			,dblTotalAmount				NUMERIC(18,6)
			,dblQuantity				NUMERIC(18,6)
			,dtmDiscountDate			DATETIME
			,dtmDueDate					DATETIME
			,dtmPostedDate				DATETIME
			,dtmTransactionDate			DATETIME
			,dtmBillingDate				DATETIME
			,dtmCreatedDate				DATETIME
			,dtmInvoiceDate				DATETIME
			,strGroupName				NVARCHAR(MAX)
			,strEmailDistributionOption	NVARCHAR(MAX)
			,strEmail					NVARCHAR(MAX)
			,strDiscountSchedule		NVARCHAR(MAX)
			,strNetwork					NVARCHAR(MAX)
			,strInvoiceCycle			NVARCHAR(MAX)
			,strTerm					NVARCHAR(MAX)
			,strType					NVARCHAR(MAX)
			,strCustomerName			NVARCHAR(MAX)
			,strCustomerNumber			NVARCHAR(MAX)
			,strInvoiceNumber			NVARCHAR(MAX)
			,strTransactionType			NVARCHAR(MAX)
			,strInvoiceReportNumber		NVARCHAR(MAX)
			,strPrintTimeStamp			NVARCHAR(MAX)
			,strTermCode				NVARCHAR(MAX)
		)
		DECLARE @tblCFDiscountschedule TABLE
		(
			 intDiscountSchedDetailId	  INT
			,intDiscountScheduleId		  INT
			,intFromQty					  INT
			,intThruQty					  INT
			,dblRate					  NUMERIC(18,6)
		)
		-------------VARIABLES------------

		
		----------GET DISCOUNT SCHEDULE------------
		INSERT INTO @tblCFDiscountschedule
		(
			intDiscountSchedDetailId
			,intDiscountScheduleId
			,intFromQty
			,intThruQty
			,dblRate
		)
		SELECT 
			 intDiscountSchedDetailId
			,intDiscountScheduleId
			,intFromQty
			,intThruQty
			,dblRate
		FROM tblCFDiscountScheduleDetail
		----------GET DISCOUNT SCHEDULE------------


		-----------------MAIN QUERY------------------
		INSERT INTO @tblCFInvoiceDiscount
		(
			 intCustomerId				
			,intTransactionId			
			,intSalesPersonId			
			,intInvoiceId				
			,intAccountId				
			,intTermID					
			,intBalanceDue				
			,intDiscountDay				
			,intDayofMonthDue			
			,intDueNextMonth			
			,intSort					
			,intConcurrencyId			
			,intDiscountScheduleId		
			,intCustomerGroupId			
			,ysnInvoiced				
			,ysnAllowEFT				
			,ysnActive					
			,ysnEnergyTrac				
			,ysnShowOnCFInvoice			
			,dblAPR						
			,dblDiscountEP				
			,dblTotalAmount				
			,dblQuantity				
			,dtmDiscountDate			
			,dtmDueDate					
			,dtmPostedDate				
			,dtmTransactionDate			
			,dtmBillingDate				
			,dtmCreatedDate				
			,dtmInvoiceDate				
			,strGroupName				
			,strEmailDistributionOption	
			,strEmail					
			,strDiscountSchedule		
			,strNetwork					
			,strInvoiceCycle			
			,strTerm					
			,strType					
			,strCustomerName			
			,strCustomerNumber			
			,strInvoiceNumber			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strPrintTimeStamp			
			,strTermCode				
		)
		
		SELECT 
			 intCustomerId				
			,intTransactionId			
			,intSalesPersonId			
			,intInvoiceId				
			,intAccountId				
			,intTermID					
			,intBalanceDue				
			,intDiscountDay				
			,intDayofMonthDue			
			,intDueNextMonth			
			,intSort					
			,intConcurrencyId			
			,intDiscountScheduleId		
			,intCustomerGroupId			
			,ysnInvoiced				
			,ysnAllowEFT				
			,ysnActive					
			,ysnEnergyTrac				
			,ysnShowOnCFInvoice			
			,dblAPR						
			,dblDiscountEP				
			,dblTotalAmount				
			,dblQuantity				
			,dtmDiscountDate			
			,dtmDueDate					
			,dtmPostedDate				
			,dtmTransactionDate			
			,dtmBillingDate				
			,dtmCreatedDate				
			,dtmInvoiceDate				
			,strGroupName				
			,strEmailDistributionOption	
			,strEmail					
			,strDiscountSchedule		
			,strNetwork					
			,strInvoiceCycle			
			,strTerm					
			,strType					
			,strCustomerName			
			,strCustomerNumber			
			,strInvoiceNumber			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strPrintTimeStamp			
			,strTermCode				
		FROM vyuCFInvoiceDiscount 
		WHERE intTransactionId IN (SELECT intTransactionId FROM tblCFInvoiceReportTempTable WHERE strUserId = @UserId)
		-----------------MAIN QUERY------------------

		
		-------------GROUP VOLUME DISCOUNT---------------
		INSERT @tblCFGroupVolumeDisctinct
		SELECT DISTINCT ISNULL(intCustomerGroupId,0)
		FROM @tblCFInvoiceDiscount
		WHILE (EXISTS(SELECT 1 FROM @tblCFGroupVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intCustomerGroupId FROM @tblCFGroupVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 
			@dblTotalQuantity = SUM(dblQuantity)	
			FROM @tblCFInvoiceDiscount as cfInvoice
			WHERE intCustomerGroupId = @intDistinctDiscountLoop
			GROUP BY intCustomerGroupId

			INSERT @tblCFGroupVolumeTemp(
				 intAccountId		
			    ,intSalesPersonId			
			    ,dtmInvoiceDate			
				,intCustomerId			
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,strDiscountSchedule
				,ysnShowOnCFInvoice
			)
			SELECT 
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate			
				,intCustomerId
				,intInvoiceId				
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,@dblTotalQuantity		
				,ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM @tblCFDiscountschedule
					 WHERE @dblTotalQuantity >= intFromQty AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId
					 ORDER BY intFromQty DESC), 0)
				,ROUND((ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM @tblCFDiscountschedule
					 WHERE @dblTotalQuantity >= intFromQty AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId
					 ORDER BY intFromQty DESC), 0) * dblQuantity),2)
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,strDiscountSchedule
				,ysnShowOnCFInvoice
			FROM @tblCFInvoiceDiscount as cfInvoice
			WHERE intCustomerGroupId = @intDistinctDiscountLoop

			END
			
			DELETE FROM @tblCFGroupVolumeDisctinct WHERE intCustomerGroupId = @intDistinctDiscountLoop
		END
		-------------GROUP VOLUME DISCOUNT---------------


		-------------ACCOUNT VOLUME DISCOUNT---------------
		INSERT @tblCFAccountVolumeDisctinct
		SELECT DISTINCT ISNULL(intAccountId,0)
		FROM @tblCFInvoiceDiscount
		WHILE (EXISTS(SELECT 1 FROM @tblCFAccountVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intAccountId FROM @tblCFAccountVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 
			@dblTotalQuantity = SUM(dblQuantity)	
			FROM @tblCFInvoiceDiscount as cfInvoice
			WHERE intAccountId = @intDistinctDiscountLoop
			GROUP BY intAccountId

			INSERT @tblCFAccountVolumeTemp(
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate			
				,intCustomerId
				,intInvoiceId		
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,strDiscountSchedule
				,ysnShowOnCFInvoice
			)
			SELECT 
				 intAccountId				
			    ,intSalesPersonId			
			    ,dtmInvoiceDate	
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,@dblTotalQuantity		
				,ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM @tblCFDiscountschedule
					 WHERE @dblTotalQuantity >= intFromQty AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId
					 ORDER BY intFromQty DESC), 0)
				,ROUND((ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM @tblCFDiscountschedule
					 WHERE @dblTotalQuantity >= intFromQty AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId
					 ORDER BY intFromQty DESC), 0) * dblQuantity),2)
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,strDiscountSchedule
				,ysnShowOnCFInvoice
			FROM @tblCFInvoiceDiscount as cfInvoice
			WHERE intAccountId = @intDistinctDiscountLoop AND intCustomerGroupId = 0
			END
			
			DELETE FROM @tblCFAccountVolumeDisctinct WHERE intAccountId = @intDistinctDiscountLoop
		END
		-------------ACCOUNT VOLUME DISCOUNT---------------

		
		-------------MERGE ACCOUNT & GROUP VOLUME DISCOUNT---------------

		DECLARE @totalAccountDiscount					NUMERIC(18,6)
		DECLARE @totalAccountAmount						NUMERIC(18,6)
		DECLARE @totalAccountAmountLessDiscount			NUMERIC(18,6)
		DECLARE @totalAccountTotalDiscountQuantity		NUMERIC(18,6)
		

		-------------SET GROUP VOLUME TO OUTPUT---------------
		INSERT @tblCFMergeVolumeDisctinct
		SELECT DISTINCT ISNULL(intAccountId,0)
		FROM @tblCFGroupVolumeTemp
		WHILE (EXISTS(SELECT 1 FROM @tblCFMergeVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intAccountId FROM @tblCFMergeVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 						
			 @totalAccountDiscount				= ROUND(ISNULL(SUM(dblDiscount),0),2)
			,@totalAccountAmount				= ISNULL(SUM(dblTotalAmount),0)
			,@totalAccountAmountLessDiscount	= ISNULL(ISNULL(SUM(dblTotalAmount),0) - ISNULL(SUM(dblDiscount),0),0)
			,@totalAccountTotalDiscountQuantity	= ISNULL(SUM(dblQuantity),0)
			FROM @tblCFGroupVolumeTemp
			WHERE intAccountId = @intDistinctDiscountLoop

			INSERT INTO tblCFInvoiceDiscountCalculationTempTable(
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate		
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,dblAccountTotalAmount		
				,dblAccountTotalDiscount
				,dblAccountTotalLessDiscount
				,dblAccountTotalDiscountQuantity	
				,strDiscountSchedule
				,ysnShowOnCFInvoice
				,strUserId
			)
			SELECT 
				 intAccountId				
			    ,intSalesPersonId			
			    ,dtmInvoiceDate	
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity		
				,dblDiscountRate
				,dblDiscount
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate	
				,@totalAccountAmount		
				,@totalAccountDiscount				
				,@totalAccountAmountLessDiscount
				,@totalAccountTotalDiscountQuantity
				,strDiscountSchedule
				,ysnShowOnCFInvoice
				,@UserId
			FROM @tblCFGroupVolumeTemp as cfGroupVolumeDiscount
			WHERE intAccountId = @intDistinctDiscountLoop

			END
			
			DELETE FROM @tblCFMergeVolumeDisctinct WHERE intAccountId = @intDistinctDiscountLoop
		END
		-------------SET GROUP VOLUME TO OUTPUT---------------


		-------------SET ACCOUNT VOLUME TO OUTPUT---------------
		INSERT @tblCFMergeVolumeDisctinct
		SELECT DISTINCT ISNULL(intAccountId,0)
		FROM @tblCFAccountVolumeTemp
		WHILE (EXISTS(SELECT 1 FROM @tblCFMergeVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intAccountId FROM @tblCFMergeVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 						
			 @totalAccountDiscount				= ROUND(ISNULL(SUM(dblDiscount),0),2)
			,@totalAccountAmount				= ISNULL(SUM(dblTotalAmount),0)
			,@totalAccountAmountLessDiscount	= ISNULL(ISNULL(SUM(dblTotalAmount),0) - ISNULL(SUM(dblDiscount),0),0)
			,@totalAccountTotalDiscountQuantity	= ISNULL(SUM(dblQuantity),0)
			FROM @tblCFAccountVolumeTemp
			WHERE intAccountId = @intDistinctDiscountLoop

			INSERT INTO tblCFInvoiceDiscountCalculationTempTable(
				 intAccountId				
			    ,intSalesPersonId			
			    ,dtmInvoiceDate	
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,dblAccountTotalAmount		
				,dblAccountTotalDiscount
				,dblAccountTotalLessDiscount	
				,dblAccountTotalDiscountQuantity
				,strDiscountSchedule
				,ysnShowOnCFInvoice
				,strUserId
			)
			SELECT 
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate		
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity		
				,dblDiscountRate
				,dblDiscount
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate	
				,@totalAccountAmount		
				,@totalAccountDiscount				
				,@totalAccountAmountLessDiscount
				,@totalAccountTotalDiscountQuantity
				,strDiscountSchedule
				,ysnShowOnCFInvoice
				,@UserId
			FROM @tblCFAccountVolumeTemp as cfAccountVolumeDiscount
			WHERE intAccountId = @intDistinctDiscountLoop

			END
			
			DELETE FROM @tblCFMergeVolumeDisctinct WHERE intAccountId = @intDistinctDiscountLoop
		END
		-------------SET ACCOUNT VOLUME TO OUTPUT---------------

		-------------MERGE ACCOUNT & GROUP VOLUME DISCOUNT---------------


		----------------------------------
		---**END DISCOUNT CALCULATION**---
		----------------------------------

		-------------SELECT MAIN TABLE FOR OUTPUT---------------
		
		INSERT INTO tblCFInvoiceDiscountTempTable(
			 intSalesPersonId
			,intTermID
			,intBalanceDue
			,intDiscountDay
			,intDayofMonthDue
			,intDueNextMonth
			,intSort
			,strTerm
			,strTermCode
			,strTermType
			,dtmDiscountDate
			,dtmDueDate
			,dtmInvoiceDate
			,dblDiscountRate
			,dblDiscount
			,dblAccountTotalAmount
			,dblAccountTotalDiscount
			,dblAccountTotalLessDiscount
			,dblAccountTotalDiscountQuantity
			,dblEligableGallon
			,dblDiscountEP
			,dblAPR
			,intAccountId
			,intTransactionId
			,strDiscountSchedule
			,ysnShowOnCFInvoice
			,strUserId)
		SELECT 
			 intSalesPersonId
			,intTermID
			,intBalanceDue
			,intDiscountDay
			,intDayofMonthDue
			,intDueNextMonth
			,intSort
			,strTerm
			,strTermCode
			,strType
			,dtmDiscountDate
			,dtmDueDate
			,dtmInvoiceDate
			,dblDiscountRate
			,dblDiscount
			,dblAccountTotalAmount
			,dblAccountTotalDiscount
			,dblAccountTotalLessDiscount
			,dblAccountTotalDiscountQuantity
			,dblTotalQuantity
			,dblDiscountEP
			,dblAPR
			,intAccountId
			,intTransactionId
			,strDiscountSchedule
			,ysnShowOnCFInvoice
			,strUserId
	    FROM tblCFInvoiceDiscountCalculationTempTable
		WHERE strUserId = @UserId

	
		-------------SELECT MAIN TABLE FOR OUTPUT---------------
END
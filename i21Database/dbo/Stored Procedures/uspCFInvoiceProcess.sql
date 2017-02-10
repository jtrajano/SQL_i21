﻿CREATE PROCEDURE [dbo].[uspCFInvoiceProcess](
	 @xmlParam					NVARCHAR(MAX)  
	,@entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL	OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@SuccessfulPostCount		INT			   = 0		OUTPUT
	,@InvalidPostCount			INT			   = 0		OUTPUT
	,@ysnDevMode				BIT = 0
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
	CREATE TABLE #tblCFInvoiceDiscount	
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

	-------------INVOICE LIST-------------
	INSERT INTO #tblCFInvoiceDiscount
	EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam=@xmlParam
	--------------------------------------

	UPDATE tblCFTransaction SET strInvoiceReportNumber = strTempInvoiceReportNumber WHERE intTransactionId IN (SELECT intTransactionId FROM #tblCFInvoiceDiscount)

	------------GROUP BY CUSTOMER-----------
	--INSERT INTO #tblCFDisctinctCustomerInvoice(
	--	intAccountId	
	--	,intCustomerId	
	--)
	--SELECT 
	--	intAccountId	
	--	,intCustomerId	
	--FROM #tblCFInvoiceDiscount
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

	--	UPDATE tblCFTransaction SET strInvoiceReportNumber =  @CFID WHERE intTransactionId IN (SELECT intTransactionId FROM #tblCFInvoiceDiscount WHERE intAccountId = @loopAccountId AND intCustomerId = @loopCustomerId)
	
	--	DELETE FROM #tblCFDisctinctCustomerInvoice WHERE intAccountId = @loopAccountId AND intCustomerId = @loopCustomerId

	--END
	

	EXEC	@return_value = [dbo].[uspCFCreateInvoicePayment]
			@xmlParam				= @xmlParam
			,@entityId				= @entityId
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

	EXEC	@return_value = [dbo].[uspCFCreateDebitMemo]
			@xmlParam = @xmlParam,
			@entityId = @entityId,
			@ErrorMessage = @ErrorMessage OUTPUT,
			@CreatedIvoices = @CreatedIvoices OUTPUT,
			@UpdatedIvoices = @UpdatedIvoices OUTPUT,
			@ysnDevMode = @ysnDevMode

	SELECT	'Debit Memo'			AS 'Process'
			,@ErrorMessage			AS 'ErrorMessage'
			,@CreatedIvoices		AS 'CreatedIvoices'
			,@UpdatedIvoices		AS 'UpdatedIvoices'


	----------DROP TEMPORARY TABLE----------
	DROP TABLE #tblCFInvoiceDiscount
	DROP TABLE #tblCFDisctinctCustomerInvoice
	----------------------------------------

	IF (@@TRANCOUNT > 0) COMMIT TRANSACTION 

END TRY
BEGIN CATCH
	
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 

	DECLARE @CatchErrorMessage NVARCHAR(MAX);  
	DECLARE @CatchErrorSeverity INT;  
	DECLARE @CatchErrorState INT;  
  
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



	DECLARE @index INT = 0

	SELECT @index = CHARINDEX('>',@CatchErrorMessage)
	SELECT @ErrorMessage = SUBSTRING(@CatchErrorMessage,@index + 1, 1000);  

END CATCH



END


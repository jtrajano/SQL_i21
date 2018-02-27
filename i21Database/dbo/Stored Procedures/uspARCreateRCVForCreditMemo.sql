CREATE PROCEDURE [dbo].[uspARCreateRCVForCreditMemo]

	@intInvoiceId			INT,
	@intUserId 				INT,
	@strCPIds				NVARCHAR(MAX) = ''
AS
	
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT OFF  
	SET ANSI_WARNINGS OFF  

	DECLARE @intEntityCustomerId	INT
	DECLARE @intLocationId			INT

	SELECT 
		@intEntityCustomerId = intEntityCustomerId, 
		@intLocationId = intCompanyLocationId
	FROM tblARInvoice 
		WHERE intInvoiceId = @intInvoiceId

	--set @strCPIds = '524,523'
	-- set @intInvoiceId = 522
	-- set @intLocationId = 2
	-- set @intEntityCustomerId = 8 

	declare @intPaymentId INT

	declare @intCurrencyId	INT
	declare @intPaymentMethodId INT
	declare @strPaymentMethod nvarchar(100)

	declare @sum NUMERIC(18,6)
	declare @basesum NUMERIC(18,6)

	declare @cde table(
		id int
	)

	insert into @cde(id)
	SELECT intPrepaymentId 
		FROM tblARPrepaidAndCredit 
			where intInvoiceId = @intInvoiceId 
				and ysnApplied = 1

	if NOT EXISTS( SELECT TOP 1 1 FROM @cde)
	BEGIN
		RETURN 0;
	END
	-- select cast(Item as int) from dbo.fnSplitString(@strCPIds, ',')

	
	set @strPaymentMethod = 'Cash'
	select @intPaymentMethodId = intPaymentMethodID 
		from tblSMPaymentMethod where LOWER(strPaymentMethod) = LOWER(@strPaymentMethod)

	select @intCurrencyId = intCurrencyId from tblARInvoice where intInvoiceId = @intInvoiceId


	insert into tblARPayment ( 
		intEntityCustomerId, intCurrencyId, intPaymentMethodId, intLocationId, dtmDatePaid, strReceivePaymentType, strPaymentMethod,
		dblAmountPaid, dblBaseAmountPaid, dblUnappliedAmount, dblBaseUnappliedAmount,
		dblOverpayment, dblBaseOverpayment,
		dblBalance, dblExchangeRate,
		strPaymentInfo, strNotes, ysnApplytoBudget
	)
	select 
		@intEntityCustomerId, @intCurrencyId, @intPaymentMethodId, @intLocationId, GETDATE(), 'Cash Receipts', @strPaymentMethod,
		0, 0, 0, 0,
		0, 0,
		0, 1,
		'', '', 0

	SET @intPaymentId = @@IDENTITY
	

	select 
		@sum = sum(dblInvoiceTotal) ,
		@basesum = sum(dblBaseInvoiceTotal) 
		from tblARInvoice 
			where intInvoiceId in (select id from @cde)

	DECLARE @InvoicesDetail TABLE(
		intInvoiceId		INT,
		dblPayment			NUMERIC(18, 6)
	)
	INSERT INTO @InvoicesDetail( intInvoiceId, dblPayment )
	select 
		intInvoiceId,
		dblInvoiceTotal * -1
		from tblARInvoice where intInvoiceId in (select id from @cde)
	
	INSERT INTO @InvoicesDetail( intInvoiceId, dblPayment )
	select 
		intInvoiceId,
		@sum
		from tblARInvoice where intInvoiceId = @intInvoiceId

	
	DECLARE @CurrentInvoice INT
	DEClARE @CurrentPayment NUMERIC(18, 6)

	WHILE EXISTS (SELECT TOP 1 1 FROM @InvoicesDetail)
	BEGIN
		SET @CurrentPayment = 0

		SELECT TOP 1 @CurrentInvoice = intInvoiceId,
				@CurrentPayment = dblPayment
			FROM @InvoicesDetail

		exec uspARAddInvoiceToPayment
			@PaymentId	= @intPaymentId,
			@InvoiceId = @CurrentInvoice,
			@Payment = @CurrentPayment,
			@ApplyTermDiscount = 0,
			@Discount = 0,
			@RaiseError = 1
		

		DELETE FROM @InvoicesDetail 
			WHERE intInvoiceId = @CurrentInvoice
	END
	


	exec uspARPostPayment @post=1, @param=@intPaymentId, @userId=@intUserId, @raiseError = 1



RETURN 0

	/*
	delete from tblARPaymentDetail where intPaymentId = @intPaymentId
	
	select 
		@sum = sum(dblInvoiceTotal) ,
		@basesum = sum(dblBaseInvoiceTotal) 
		from tblARInvoice 
			where intInvoiceId in (select id from @cde)
				--group by intInvoiceId


	insert into tblARPaymentDetail( 
		intPaymentId, intInvoiceId, intConcurrencyId, intAccountId, intTermId, strTransactionNumber,
		dblInvoiceTotal, 
		dblBaseInvoiceTotal, 
		dblDiscount, dblBaseDiscount,
		dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest,
		dblPayment,
		dblBasePayment,		
		dblAmountDue, dblBaseAmountDue
	)
	select 
		@intPaymentId, intInvoiceId, 1, 473, 3, strInvoiceNumber,
		dblInvoiceTotal * (case when strTransactionType = 'Credit Memo' then -1 else 1 end), 
		dblBaseInvoiceTotal * (case when strTransactionType = 'Credit Memo' then -1 else 1 end), 
		0, 0,
		0, 0, 0, 0,
		dblInvoiceTotal * 1, --(case when strTransactionType = 'Credit Memo' then -1 else 1 end), 
		dblBaseInvoiceTotal * 1, -- (case when strTransactionType = 'Credit Memo' then -1 else 1 end), 
		0, 0
		from tblARInvoice where intInvoiceId in (select id from @cde)


	insert into tblARPaymentDetail( 
		intPaymentId, intInvoiceId, intConcurrencyId, intAccountId, intTermId, strTransactionNumber,
		dblInvoiceTotal, 
		dblBaseInvoiceTotal, 
		dblDiscount, dblBaseDiscount,
		dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest,
		dblAmountDue, dblBaseAmountDue,
		dblPayment, dblBasePayment
	)
	select 
		@intPaymentId, intInvoiceId, 1, 473, 3, strInvoiceNumber,
		dblInvoiceTotal * (case when strTransactionType = 'Credit Memo' then -1 else 1 end), 
		dblBaseInvoiceTotal * (case when strTransactionType = 'Credit Memo' then -1 else 1 end), 
		0, 0,
		0, 0, 0, 0,
		1 * (dblInvoiceTotal - @sum), 1 * (dblBaseInvoiceTotal - @basesum),
		-1 * @sum, -1 * @basesum
		from tblARInvoice where intInvoiceId = (@intInvoiceId)

	-- select * 
	-- 	from tblARPaymentDetail 
	-- where intPaymentId = @intPaymentId

	-- select * from tblARPayment where intPaymentId = @intPaymentId
	*/
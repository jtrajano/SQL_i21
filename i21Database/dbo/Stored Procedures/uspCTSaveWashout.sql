CREATE PROCEDURE [dbo].[uspCTSaveWashout]
	
	@intWashoutId	INT
AS

BEGIN TRY
	
	DECLARE  @ErrMsg				NVARCHAR(MAX)
			,@intSourceHeaderId		INT
			,@intSourceDetailId		INT
			,@intWashoutHeaderId	INT
			,@intWashoutDetailId	INT
			,@dblWashoutFee			NUMERIC(18,6)
			,@ysnNewContract		BIT
			,@dblWTFutures			NUMERIC(18,6)
			,@dblWTBasis			NUMERIC(18,6)
			,@dblWTCashPrice		NUMERIC(18,6)
			,@strNumber				NVARCHAR(80)
			,@strXML				NVARCHAR(MAX) 
			,@intContractTypeId		INT 
			,@strCondition			NVARCHAR(MAX)
			,@strContractNumber		NVARCHAR(50) 
			,@strDocType			NVARCHAR(50)
			,@strSequenceNumber		NVARCHAR(50)
			,@strBillInvoice		NVARCHAR(50) 
			,@CreatedIvoices		NVARCHAR(50)  
			,@dblCashPrice			NUMERIC(18,6)
			,@dblAmount				NUMERIC(18,6)
			,@intEntityId			INT
			,@intBillInvoiceId		INT 
			,@intItemId				INT
			,@intCreatedById		INT
			,@type					INT
			,@intCompanyLocationId	INT 
			,@intLoadId				INT
			,@intLocationId			INT
			,@voucherNonInvDetails	VoucherDetailNonInventory
			,@InvoiceEntries		InvoiceIntegrationStagingTable	
			,@LineItemTaxEntries	LineItemTaxDetailStagingTable

	SELECT   @intSourceHeaderId		=	intSourceHeaderId
			,@intSourceDetailId		=   intSourceDetailId
			,@intWashoutHeaderId	=   intWashoutHeaderId
			,@intWashoutDetailId	=   intWashoutDetailId
			,@dblWashoutFee			=   dblWashoutFee
			,@ysnNewContract		=   ysnNewContract
			,@dblWTFutures			=   dblWTFutures
			,@dblWTBasis			=   dblWTBasis
			,@dblWTCashPrice		=   dblWTCashPrice
			,@strDocType			=   strDocType	
			,@dblAmount				=   dblAmount
			,@intCreatedById		=   intCreatedById

	FROM	tblCTWashout
	
	SELECT  @strSequenceNumber		=	strSequenceNumber,
			@dblCashPrice			=	dblCashPrice,
			@intEntityId			=	intEntityId,
			@intCompanyLocationId	=	intCompanyLocationId,
			@intLocationId			=	intCompanyLocationId
	FROM	vyuCTContractSequence 
	WHERE   intContractDetailId = @intSourceDetailId

	SELECT	@intLoadId = MIN(intLoadId) FROM tblLGLoadDetail WHERE intPContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0)) OR intSContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0))
	
	WHILE	ISNULL(@intLoadId,0) > 0
	BEGIN
		EXEC	uspLGCancelLoadSchedule	@intLoadId, 1, @intCreatedById
		SELECT	@intLoadId = MIN(intLoadId) FROM tblLGLoadDetail WHERE (intPContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0)) OR intSContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0))) AND intLoadId > @intLoadId
	END
	
	EXEC uspAPUnrestrictContractPrepay  @intSourceDetailId
	IF ISNULL(@intWashoutDetailId,0) > 0
	BEGIN
		EXEC uspAPUnrestrictContractPrepay  @intWashoutDetailId
	END

	IF @ysnNewContract = 1
	BEGIN
		SELECT	@intContractTypeId	=   CASE WHEN intContractTypeId = 1 THEN 2 ELSE 1 END ,
				@strContractNumber	=   strContractNumber
		FROM	tblCTContractHeader WHERE intContractHeaderId = @intSourceHeaderId
		
		SELECT	@strNumber = CASE WHEN @intContractTypeId = 2 THEN 'SaleContract' ELSE 'PurchaseContract' END 

		EXEC	uspCTGetStartingNumber @strNumber, @strNumber OUTPUT

		SET @strXML = '<root>'
		SET @strXML +=		'<toUpdate>' 
		SET @strXML +=			'<strContractNumber>'+@strNumber+'</strContractNumber>' 
		SET @strXML +=			'<intContractTypeId>'+LTRIM(@intContractTypeId)+'</intContractTypeId>'
		SET @strXML +=		'</toUpdate>' 
		SET @strXML += '</root>'

		EXEC	uspCTCreateADuplicateRecord 'tblCTContractHeader',@intSourceHeaderId,@intWashoutHeaderId OUTPUT,@strXML
		SELECT	@strCondition = 'intContractHeaderId = ' + LTRIM(@intWashoutHeaderId)
		EXEC	uspCTGetTableDataInXML 'tblCTContractHeader',@strCondition,@strXML OUTPUT
		--EXEC	uspCTValidateContractHeader @strXML,'Added'

		SET @strXML = '<root>'
		SET @strXML +=		'<toUpdate>' 
		SET @strXML +=			'<dblBasis>'+LTRIM(@dblWTBasis)+'</dblBasis>' 
		SET @strXML +=			'<dblFutures>'+LTRIM(@dblWTFutures)+'</dblFutures>'
		SET @strXML +=			'<dblCashPrice>'+LTRIM(@dblWTCashPrice)+'</dblCashPrice>'
		SET @strXML +=		'</toUpdate>' 
		SET @strXML += '</root>'

		DECLARE @strTagRelaceXML NVARCHAR(MAX) =  
		'<root>
			<tags>
				<toFind>&lt;intContractHeaderId&gt;'+LTRIM(@intSourceHeaderId)+'&lt;/intContractHeaderId&gt;</toFind>
				<toReplace>&lt;intContractHeaderId&gt;'+LTRIM(@intWashoutHeaderId)+'&lt;/intContractHeaderId&gt;</toReplace>
			</tags>
		</root>'

		EXEC	uspCTCreateADuplicateRecord 'tblCTContractDetail',@intSourceDetailId,@intWashoutDetailId OUTPUT,@strXML, @strTagRelaceXML
		SELECT	@strCondition = 'intContractDetailId = ' + LTRIM(@intWashoutDetailId)
		EXEC	uspCTGetTableDataInXML 'tblCTContractDetail',@strCondition,@strXML OUTPUT
		--EXEC	uspCTValidateContractDetail @strXML,'Added'

		EXEC	uspCTSaveContract @intWashoutHeaderId, NULL

		UPDATE	tblCTWashout SET intWashoutHeaderId = @intWashoutHeaderId, intWashoutDetailId = @intWashoutDetailId WHERE intWashoutId = @intWashoutId
	END

	SELECT	@ErrMsg = LTRIM(@intSourceDetailId)+','+LTRIM(@intWashoutDetailId)
	EXEC	[uspCTChangeContractStatus] @ErrMsg, 3, @intCreatedById

    IF @strDocType = 'AP Debit Memo' OR @strDocType = 'AP Voucher'
    BEGIN
	   INSERT	INTO @voucherNonInvDetails(intItemId, dblQtyReceived, dblDiscount, dblCost)
	   SELECT	@intItemId, 1, 0, @dblAmount
	   
	   SELECT	@type = CASE WHEN @strDocType = 'AP Voucher' THEN 1 ELSE 3 END

	   EXEC		uspAPCreateBillData
				@userId					=   @intCreatedById,
				@vendorId				=   @intEntityId,
				@type					=   @type,
				@voucherNonInvDetails	=   @voucherNonInvDetails,
				@shipTo					=	@intLocationId,
				@billId					=   @intBillInvoiceId OUTPUT

	   SELECT	@strBillInvoice =	 strBillId FROM tblAPBill WHERE intBillId = @intBillInvoiceId
	   
	   IF @strDocType = 'AP Voucher'
	   BEGIN
			UPDATE tblAPBill	  SET strComment = 'Washout' WHERE intBillId = @intBillInvoiceId
	   END
    END

    IF @strDocType = 'AR Credit Memo' OR @strDocType = 'AR Invoice'
    BEGIN
	   INSERT  INTO @InvoiceEntries(strTransactionType,strSourceTransaction,strSourceId,intEntityCustomerId,intCompanyLocationId,dtmDate,intEntityId,intItemId,dblQtyOrdered,dblQtyShipped,dblPrice,dblUnitPrice)
	   SELECT	 REPLACE(@strDocType,'AR ',''), 'Direct', '', @intEntityId, @intCompanyLocationId, GETDATE(), @intEntityId, @intItemId,1, 1, @dblAmount, @dblAmount

	   EXEC		uspARProcessInvoices
				@InvoiceEntries		=   @InvoiceEntries,
				@LineItemTaxEntries	=   @LineItemTaxEntries,
				@UserId				=   @intCreatedById,
				@RaiseError			=   1,
				@CreatedIvoices		=   @CreatedIvoices OUTPUT

	   SELECT	TOP 1 @intBillInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))	
	   SELECT	@strBillInvoice =	 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intBillInvoiceId
    END

    UPDATE  tblCTWashout
    SET		strSourceNumber	  =	 @strSequenceNumber,
			strWashoutNumber  =	 (SELECT strSequenceNumber FROM vyuCTContractSequence WHERE intContractDetailId = @intWashoutDetailId),
			dblCashPrice	  =	 @dblCashPrice,
			strBillInvoice	  =	 @strBillInvoice,
			intBillInvoiceId  =	 @intBillInvoiceId
    WHERE	intWashoutId	  =	 @intWashoutId

END TRY

BEGIN CATCH
    SELECT @ErrMsg = ERROR_MESSAGE()
    RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
GO

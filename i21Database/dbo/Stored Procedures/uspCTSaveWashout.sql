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
			,@strMiscComment		NVARCHAR(150)
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
			,@intItemLocationId		INT
			,@intCreatedById		INT
			,@type					INT
			,@intCompanyLocationId	INT 
			,@intLoadId				INT
			,@intLocationId			INT
			,@intSalesPersonId		INT
			,@intProfitCenter		INT
			,@voucherNonInvDetails	VoucherPayable
			,@InvoiceEntries		InvoiceIntegrationStagingTable	
			,@LineItemTaxEntries	LineItemTaxDetailStagingTable
			,@strSourceContractNo	NVARCHAR(50)
			,@strWashoutContractNo	NVARCHAR(50)
			,@dblFXPrice			NUMERIC(18,6)
			,@strEntityName			NVARCHAR(150)

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
			@strEntityName			=	strEntityName,
			@intCompanyLocationId	=	intCompanyLocationId,
			@intLocationId			=	intCompanyLocationId
	FROM	vyuCTContractSequence 
	WHERE   intContractDetailId = @intSourceDetailId

	--SELECT	@intLoadId = MIN(intLoadId) FROM tblLGLoadDetail WHERE intPContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0)) OR intSContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0))
	
	--WHILE	ISNULL(@intLoadId,0) > 0
	--BEGIN
	--	EXEC	uspLGCancelLoadSchedule	@intLoadId, 1, @intCreatedById
	--	SELECT	@intLoadId = MIN(intLoadId) FROM tblLGLoadDetail WHERE (intPContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0)) OR intSContractDetailId IN (@intSourceDetailId,ISNULL(@intWashoutDetailId,0))) AND intLoadId > @intLoadId
	--END
	
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
		
		IF NOT EXISTS(SELECT * from vyuCTEntity WHERE intEntityId = @intEntityId AND strEntityType = CASE WHEN @intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
		BEGIN
			IF @intContractTypeId = 2 
			BEGIN
				SELECT @ErrMsg = 'Cannot continue the washout process as ' + @strEntityName + ' is not a customer.'
			END
			ELSE
			BEGIN
				SELECT @ErrMsg = 'Cannot continue the washout process as ' + @strEntityName + ' is not a vendor.'
			END
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
		END

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

		UPDATE  CD 
		SET		dblTotalCost = ROUND(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity)*CD.dblCashPrice
							  / CASE WHEN CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END,6)
		FROM    tblCTContractDetail CD
		JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID = CD.intCurrencyId
		WHERE  intContractDetailId = @intWashoutDetailId

		SELECT  @dblFXPrice = dblSeqPrice FROM dbo.[fnCTGetAdditionalColumnForDetailView](@intWashoutDetailId)
		UPDATE	tblCTContractDetail	
		SET		dblFXPrice = @dblFXPrice 
		WHERE	intContractDetailId = @intWashoutDetailId

		EXEC	uspCTSaveContract @intContractHeaderId=@intWashoutHeaderId, @userId=NULL, @strXML='',@strTFXML='';

		UPDATE	tblCTWashout SET intWashoutHeaderId = @intWashoutHeaderId, intWashoutDetailId = @intWashoutDetailId WHERE intWashoutId = @intWashoutId
	END

	SELECT	@ErrMsg = LTRIM(@intSourceDetailId)+','+LTRIM(@intWashoutDetailId)
	EXEC	[uspCTChangeContractStatus] @ErrMsg, 3, @intCreatedById

	SELECT	@intSalesPersonId	=	intSalespersonId
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId IN (@intSourceHeaderId, @intWashoutHeaderId)
	AND		intContractTypeId	=	2

	SELECT	@intItemId				=	CD.intItemId,
			@intCompanyLocationId	=	CD.intCompanyLocationId,
			@intProfitCenter		=	CL.intProfitCenter,
			@intItemLocationId		=	IL.intItemLocationId
	FROM	tblCTContractDetail		CD
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId	=	CD.intCompanyLocationId
	JOIN	tblICItemLocation		IL	ON	IL.intItemId			=	CD.intItemId
										AND	IL.intLocationId		=	CD.intCompanyLocationId
	WHERE	intContractDetailId = @intWashoutDetailId

	SELECT	@strSourceContractNo	=	strContractNumber
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId IN (@intSourceHeaderId)

	SELECT	@strWashoutContractNo	=	strContractNumber
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId IN (@intWashoutHeaderId)

    IF @strDocType = 'AP Debit Memo' OR @strDocType = 'AP Voucher'
    BEGIN

		SELECT	@type = CASE WHEN @strDocType = 'AP Voucher' THEN 1 ELSE 3 END
		
		INSERT	INTO @voucherNonInvDetails
		(
			intItemId
			,dblQuantityToBill
			,dblDiscount
			,dblCost
			,intAccountId
			,intEntityVendorId
			,intTransactionType
			,intShipToId
		)
		SELECT	NULL
				,1
				,0
				,ABS(@dblAmount)
				,dbo.fnGetItemGLAccount(@intItemId, @intItemLocationId, 'Cost of Goods')
				,@intEntityId
				,@type
				,@intLocationId

		EXEC	uspAPCreateVoucher
				@voucherPayables		=   @voucherNonInvDetails,
				@userId					=   @intCreatedById,
				@throwError				=	1,
				@createdVouchersId		=   @intBillInvoiceId OUT

		SELECT	@strBillInvoice =	 strBillId FROM tblAPBill WHERE intBillId = @intBillInvoiceId	   
		SET		@strMiscComment = ''

		SELECT	@strNumber = 'Washout, contracts ' + strContractNumber, 
				@strMiscComment =  'Washout net difference - Original Contract ' + strContractNumber
		FROM	tblCTContractHeader 
		WHERE	intContractHeaderId = @intSourceHeaderId

		SELECT	@strNumber = @strNumber + ' and ' + strContractNumber ,
				@strMiscComment =  @strMiscComment + ' and Washout Contract ' + strContractNumber
		FROM	tblCTContractHeader 
		WHERE	intContractHeaderId = @intWashoutHeaderId

		UPDATE	tblAPBill		SET strComment = @strNumber WHERE intBillId = @intBillInvoiceId
		UPDATE	tblAPBillDetail	SET dblQtyOrdered = 0, intLocationId = @intCompanyLocationId,
				strMiscDescription = @strMiscComment
		WHERE	intBillId = @intBillInvoiceId
	   
    END

    IF @strDocType = 'AR Credit Memo' OR @strDocType = 'AR Invoice'
    BEGIN
	   INSERT  INTO @InvoiceEntries
	   (
			    strTransactionType
			   ,strSourceTransaction
			   ,strSourceId
			   ,intEntityCustomerId
			   ,intCompanyLocationId
			   ,dtmDate,intEntityId
			   ,intItemId
			   ,dblQtyOrdered
			   ,dblQtyShipped
			   ,dblPrice
			   ,dblUnitPrice
			   ,intEntitySalespersonId
			   ,intSalesAccountId
			   ,strItemDescription
	   )
	   SELECT	 REPLACE(@strDocType,'AR ','')
				,'Direct'
				,''
				,@intEntityId
				,@intCompanyLocationId
				,GETDATE()
				,@intEntityId
				,NULL
				,0
				,1
				,ABS(@dblAmount)
				,ABS(@dblAmount)
				,@intSalesPersonId
				,ISNULL(
					[dbo].[fnGetGLAccountIdFromProfitCenter]
					(ISNULL(
							dbo.fnGetItemGLAccount(@intItemId, @intCompanyLocationId, N'Sales Account'), 
							NULLIF(dbo.fnGetItemBaseGLAccount(@intItemId, @intCompanyLocationId, N'Sales Account'), 0)
						), @intProfitCenter
					), 
					ISNULL(
						dbo.fnGetItemGLAccount(@intItemId, @intCompanyLocationId, N'Sales Account'), 
						NULLIF(dbo.fnGetItemBaseGLAccount(@intItemId, @intCompanyLocationId, N'Sales Account'), 0)
						)
				)
			    ,'Washout net diff: Original Contract  ' + @strSourceContractNo + ' and Washout Contract ' + @strWashoutContractNo
				-- we using the text "Washout net diff: Original Contract" to determine if an invoice to be created is for wash out
				-- we need to know it because we have to set the ysnImpactInventory to False if it is coming from a washout contract
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

	--EXEC uspCTCreateDetailHistory @intSourceHeaderId, @intSourceDetailId
	--EXEC uspCTCreateDetailHistory @intWashoutHeaderId, @intWashoutDetailId

END TRY

BEGIN CATCH
    SELECT @ErrMsg = ERROR_MESSAGE()
	IF @ErrMsg = 'The customer Id provided does not exists!'
	BEGIN
		SELECT @ErrMsg = 'Cannot continue the washout process as ' + @strEntityName + ' is not a customer.'
	END
	IF @ErrMsg = 'Vendor does not exists.'
	BEGIN
		SELECT @ErrMsg = 'Cannot continue the washout process as ' + @strEntityName + ' is not a vendor.'
	END

    RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
GO

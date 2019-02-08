CREATE PROCEDURE [dbo].[uspCTProcessBrkgCommn]
	@intBrkgCommnId	INT,
    @intUserId		INT = 1
AS

BEGIN TRY

    BEGIN TRAN
    DECLARE @ErrMsg							NVARCHAR(MAX),
			@ysnReceivable					BIT,
			@dblRcvdPaidAmount				NUMERIC(18,6),
			@VoucherDetailNonInvContract	VoucherDetailNonInvContract,
			@voucherPODetails				VoucherPODetail,
			@intEntityId					INT,
			@strBatchNumber					NVARCHAR(50),
			@intVoucherItemId				INT,
			@intInvoiceItemId				INT,
			@intNewId						INT,
			@InvoiceEntries					InvoiceIntegrationStagingTable,
			@LineItemTaxEntries				LineItemTaxDetailStagingTable,
			@ErrorMessage					NVARCHAR(MAX),
			@CreatedIvoices					NVARCHAR(MAX),
			@intCompanyLocationId			INT,
			@intCurrencyId					INT,
			@intVoucherId					INT,
			@intInvoiceId					INT,
			@intContractHeaderId			INT,
			@intContractDetailId			INT,
			@intCostItemId					INT,
			@intCostItemLocationId			INT,
			@intContractSeq					INT,
			@intContractCostId				INT

    SELECT  @ysnReceivable			=	    CC.ysnReceivable,
			@intEntityId			=	    CC.intVendorId,
			@strBatchNumber			=	    BC.strBatchNumber,
			@intCompanyLocationId	=	    CD.intCompanyLocationId,
			@intCurrencyId			=	    CC.intCurrencyId,
			@intVoucherId			=	    BC.intVoucherId,
			@intInvoiceId			=	    BC.intInvoiceId,
			@intContractHeaderId	=		CD.intContractHeaderId,
			@intContractDetailId	=		CD.intContractDetailId,
			@intCostItemId			=		CC.intItemId,
			@intCostItemLocationId	=		IL.intItemLocationId,
			@intContractSeq			=		CD.intContractSeq,
			@intContractCostId		=		CC.intContractCostId
    FROM	tblCTContractCost		CC
    JOIN	tblCTBrkgCommnDetail	BD	ON  BD.intContractCostId	=   CC.intContractCostId
    JOIN	tblCTBrkgCommn			BC	ON  BC.intBrkgCommnId		=   BD.intBrkgCommnId
    JOIN	tblCTContractDetail		CD	ON  CD.intContractDetailId  =	CC.intContractDetailId
	JOIN	tblICItemLocation		IL	ON	IL.intItemId			=	CC.intItemId
										AND	IL.intLocationId		=	CD.intCompanyLocationId
    WHERE   BD.intBrkgCommnId   =	  @intBrkgCommnId

    SELECT  @dblRcvdPaidAmount  =   SUM(CD.dblRcvdPaidAmount)
    FROM	tblCTBrkgCommnDetail	  CD
    WHERE   CD.intBrkgCommnId = @intBrkgCommnId

    SELECT @intVoucherItemId = intVoucherItemId, @intInvoiceItemId = intInvoiceItemId FROM tblCTCompanyPreference
    
    IF EXISTS (SELECT * FROM tblAPBill WHERE intBillId = ISNULL(@intVoucherId,0))
    BEGIN
	   RAISERROR('Voucher is already available for this batch.',16,1)
    END

    IF EXISTS (SELECT * FROM tblARInvoice WHERE intInvoiceId = ISNULL(@intInvoiceId,0))
    BEGIN
	   RAISERROR('Invoice is already available for this batch.',16,1)
    END

    IF  ISNULL(@ysnReceivable,0)	=   0
    BEGIN
	   INSERT INTO @VoucherDetailNonInvContract(intItemId,dblQtyReceived,dblCost,intContractHeaderId,intContractDetailId,intAccountId,intContractSeq,intContractCostId)
	   SELECT @intVoucherItemId,1,@dblRcvdPaidAmount,@intContractHeaderId,@intContractDetailId,dbo.fnGetItemGLAccount(@intCostItemId, @intCostItemLocationId, 'AP Clearing'),@intContractSeq,@intContractCostId

	   EXEC [dbo].[uspAPCreateBillData] 
			 @userId						=	 @intUserId
			,@vendorId						=	 @intEntityId
			,@voucherDetailNonInvContract	=	 @VoucherDetailNonInvContract
			,@vendorOrderNumber				=	 @strBatchNumber
			,@shipTo						=	 @intCompanyLocationId   
			,@billId						=	 @intNewId OUTPUT

		  UPDATE tblCTBrkgCommn SET intVoucherId  = @intNewId	WHERE   intBrkgCommnId = @intBrkgCommnId
    END
    ELSE 
    BEGIN
	   INSERT INTO @InvoiceEntries
	   (
				 strTransactionType,	strType,			  strSourceTransaction,	 strSourceId,				
				 strPONumber,			intEntityCustomerId,  intCompanyLocationId,	 intCurrencyId,
				 intItemId,				dblQtyOrdered,		  dblPrice,				 dtmDate,		    
				 intEntityId,			intInvoiceId,		  intSourceId,			dblQtyShipped
			 
	   )

	   SELECT	 'Invoice',				'Standard',		   'Direct',				@strBatchNumber,
				 @strBatchNumber,		@intEntityId,		@intCompanyLocationId,  @intCurrencyId,
				 @intInvoiceItemId,		1,				    @dblRcvdPaidAmount,		GETDATE(),	   
				 @intEntityId,			0,				    0,						1

	   EXEC		[dbo].[uspARProcessInvoices]
				@InvoiceEntries				=	@InvoiceEntries
				,@LineItemTaxEntries		=	@LineItemTaxEntries
				,@UserId				    =	@intUserId
				,@GroupingOption			=	1
				,@RaiseError				=	1
				,@ErrorMessage				=	@ErrorMessage	OUTPUT
				,@CreatedIvoices			=	@CreatedIvoices OUTPUT

			 UPDATE tblCTBrkgCommn SET intInvoiceId  = @CreatedIvoices	WHERE   intBrkgCommnId = @intBrkgCommnId
			 SELECT @intNewId = CAST(@CreatedIvoices AS INT)
    END

    SELECT @intNewId
    
    COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH

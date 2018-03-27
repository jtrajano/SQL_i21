CREATE PROCEDURE [dbo].[uspCTSequencePriceChanged]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ScreenName				NVARCHAR(50)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg							NVARCHAR(MAX),
			@dblCashPrice					NUMERIC(18,6),
			@ysnPosted						BIT,
			@strReceiptNumber				NVARCHAR(50),
			@intLastModifiedById			INT,
			@intInventoryReceiptId			INT,
			@intPricingTypeId				INT,
			@intContractHeaderId			INT,
			@ysnOnceApproved				BIT,
			@ysnApprovalExist				BIT,
			@ysnAllowChangePricing			BIT,
			@ysnEnablePriceContractApproval BIT,
			@intEntityId					INT,
			@intContractTypeId				INT,
			@intInvoiceId					INT,
			@intInventoryShipmentId			INT,
			@intNewInvoiceId				INT,
			@intBillId						INT,
			@intNewBillId					INT,
			@ysnSuccess						BIT,
			@voucherDetailReceipt			VoucherDetailReceipt,
			@voucherDetailReceiptCharge		VoucherDetailReceiptCharge,
			@InvoiceEntries					InvoiceIntegrationStagingTable,
			@LineItemTaxEntries				LineItemTaxDetailStagingTable,
			@ErrorMessage					NVARCHAR(250),
			@CreatedIvoices					NVARCHAR(MAX),
			@UpdatedIvoices					NVARCHAR(MAX),
			@strShipmentNumber				NVARCHAR(50),
			@intBillDetailId				INT,
			@strVendorOrderNumber			NVARCHAR(50),
			@ysnBillPosted					BIT,
			@intCompanyLocationId			INT,
			@dblTotal						NUMERIC(18,6),
			@ysnRequireApproval				BIT,
			@prePayId						Id,
			@intTicketId					INT

	SELECT	@dblCashPrice			=	dblCashPrice, 
			@intPricingTypeId		=	intPricingTypeId, 
			@intLastModifiedById	=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId	=	intContractHeaderId,
			@intCompanyLocationId	=	intCompanyLocationId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	SELECT @dblCashPrice = dblSeqPrice FROM dbo.fnCTGetAdditionalColumnForDetailView(@intContractDetailId) 
		
	SELECT	@intEntityId		=	intEntityId,
			@intContractTypeId	=	intContractTypeId
	FROM	tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById)

	SELECT @ysnAllowChangePricing = ysnAllowChangePricing, @ysnEnablePriceContractApproval = ISNULL(ysnEnablePriceContractApproval,0) FROM tblCTCompanyPreference

	IF @ScreenName = 'Price Contract'
	BEGIN
		SELECT	@ysnOnceApproved = TR.ysnOnceApproved
		FROM	tblSMTransaction	TR
		JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
		WHERE	SC.strNamespace IN( 'ContractManagement.view.Contract',
									'ContractManagement.view.Amendments')
				AND TR.intRecordId = @intContractHeaderId
		
		SELECT	@ysnApprovalExist = dbo.fnCTContractApprovalExist(@intUserId,'ContractManagement.view.Amendments')

		IF ISNULL(@ysnOnceApproved,0) = 1 AND	((@ysnEnablePriceContractApproval = 1 AND ISNULL(@ysnApprovalExist,0) = 0) 
													OR @ysnEnablePriceContractApproval = 0
												)
		BEGIN
			EXEC [uspCTContractApproved] @intContractHeaderId,@intUserId,@intContractDetailId
		END
	END

	IF 	@intPricingTypeId NOT IN (1,6) OR @ysnAllowChangePricing = 1
		RETURN

	IF @intContractTypeId = 1 
	BEGIN
		IF OBJECT_ID('tempdb..#tblReceipt') IS NOT NULL  								
		DROP TABLE #tblReceipt								

		SELECT	DISTINCT ISNULL(IR.ysnPosted,0) ysnPosted, strReceiptNumber, RI.intInventoryReceiptItemId, RI.intInventoryReceiptId,BD.intBillId,BD.intBillDetailId,ISNULL(BL.ysnPosted,0) AS ysnBillPosted
		INTO	#tblReceipt
		FROM	tblICInventoryReceipt		IR
		JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptId		=	IR.intInventoryReceiptId
   LEFT	JOIN	tblAPBillDetail				BD	ON	BD.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
   LEFT	JOIN	tblAPBill					BL	ON	BL.intBillId					=	BD.intBillId
		WHERE	RI.intLineNo = @intContractDetailId AND IR.strReceiptType = 'Purchase Contract'  AND BD.intInventoryReceiptChargeId IS NULL

		SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt

		WHILE ISNULL(@intInventoryReceiptId,0) > 0
		BEGIN
			SELECT	@intBillId = NULL, @intBillDetailId = NULL

			SELECT	@intBillId = intBillId, @intBillDetailId = intBillDetailId,@strVendorOrderNumber = strReceiptNumber,@ysnBillPosted = ysnBillPosted FROM #tblReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF ISNULL(@intBillId,0) = 0
			BEGIN
				INSERT	INTO @voucherDetailReceipt (intInventoryReceiptType,intInventoryReceiptItemId,dblCost)
				SELECT	intInventoryReceiptType		=	2,
						intInventoryReceiptItemId	=	intInventoryReceiptItemId,
						dblCost						=	@dblCashPrice
				FROM	#tblReceipt
				WHERE	intInventoryReceiptId		=	@intInventoryReceiptId

				INSERT INTO @voucherDetailReceiptCharge(intInventoryReceiptChargeId)
				SELECT intInventoryReceiptChargeId FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId

				SELECT @strVendorOrderNumber = strTicketNumber, @intTicketId = intTicketId FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId
				SELECT @strVendorOrderNumber = ISNULL(strPrefix,'') + @strVendorOrderNumber FROM tblSMStartingNumber WHERE strTransactionType = 'Ticket Management' AND strModule = 'Ticket Management'
				 
				EXEC [uspICProcessToBill] @intInventoryReceiptId,@intUserId, @intNewBillId OUTPUT

				UPDATE tblAPBill SET strVendorOrderNumber = @strVendorOrderNumber WHERE intBillId = @intNewBillId

				--EXEC [dbo].[uspAPCreateBillData] 
				--	 @userId						=	@intUserId
				--	,@vendorId						=	@intEntityId
				--	,@voucherDetailReceipt			=	@voucherDetailReceipt
				--	,@voucherDetailReceiptCharge	=	@voucherDetailReceiptCharge
				--	,@vendorOrderNumber				=	@strVendorOrderNumber
				--	,@billId						=	@intNewBillId OUTPUT

				SELECT @intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intNewBillId AND intInventoryReceiptChargeId IS NULL

				EXEC uspAPUpdateCost @intBillDetailId,@dblCashPrice,1

				DELETE FROM @prePayId

				INSERT	INTO @prePayId([intId])
				SELECT	DISTINCT BD.intBillId
				FROM	tblAPBillDetail BD
				JOIN	tblAPBill		BL	ON BL.intBillId	=	BD.intBillId
				JOIN	tblSCTicket		TK  ON TK.intTicketId =  BD.intScaleTicketId
				WHERE	BD.intContractDetailId = @intContractDetailId AND BD.intScaleTicketId = @intTicketId AND BL.intTransactionType IN (2, 13)

				IF EXISTS(SELECT * FROM	@prePayId)
				BEGIN
					EXEC uspAPApplyPrepaid @intNewBillId, @prePayId
				END
				

				EXEC [dbo].[uspAPPostBill] 
					 @post = 1
					,@recap = 0
					,@isBatch = 0
					,@param = @intNewBillId
					,@userId = @intUserId
					,@success = @ysnSuccess OUTPUT
			END
			ELSE
			BEGIN
				SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intBillId
				EXEC	[dbo].[uspSMTransactionCheckIfRequiredApproval]
						@type					=	N'AccountsPayable.view.Voucher',
						@transactionEntityId	=	@intEntityId,
						@currentUserEntityId	=	@intUserId,
						@locationId				=	@intCompanyLocationId,
						@amount					=	@dblTotal,
						@requireApproval		=	@ysnRequireApproval OUTPUT

				IF  ISNULL(@ysnRequireApproval , 0) = 0
				BEGIN
					IF ISNULL(@ysnBillPosted,0) = 1
					BEGIN
						EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
					END

					EXEC uspAPUpdateCost @intBillDetailId,@dblCashPrice,1

					IF ISNULL(@ysnBillPosted,0) = 1
					BEGIN
						EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
					END
				END
			END

			SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE intInventoryReceiptId > @intInventoryReceiptId
		END
		

	END
	IF @intContractTypeId = 2
	BEGIN

		IF OBJECT_ID('tempdb..#tblShipment') IS NOT NULL  								
			DROP TABLE #tblShipment

		SELECT	DISTINCT SH.intInventoryShipmentId,ISNULL(ID.intInvoiceId ,0) intInvoiceId,SH.strShipmentNumber
		INTO	#tblShipment
		FROM	tblICInventoryShipment		SH 
		JOIN	tblICInventoryShipmentItem	SI	ON	SI.intInventoryShipmentId		=	SH.intInventoryShipmentId 
   LEFT	JOIN	tblARInvoiceDetail			ID	ON	ID.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId
		WHERE	SI.intLineNo	= @intContractDetailId 
		AND		SH.intOrderType = 1
		AND		SH.ysnPosted	= 1

		SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId) FROM #tblShipment

		WHILE ISNULL(@intInventoryShipmentId,0) > 0
		BEGIN

			SELECT	@intInvoiceId = intInvoiceId,@strShipmentNumber = strShipmentNumber FROM #tblShipment WHERE intInventoryShipmentId = @intInventoryShipmentId

			IF	ISNULL(@intInvoiceId,0)	=	0
			BEGIN
				EXEC	uspARCreateInvoiceFromShipment 
						 @ShipmentId		= @intInventoryShipmentId
						,@UserId			= @intUserId
						,@NewInvoiceId		= @intNewInvoiceId	OUTPUT
			END
			ELSE
			BEGIN
				INSERT INTO @InvoiceEntries
				(
						strTransactionType,		strType,				intSourceId,					intInvoiceId,
						intEntityCustomerId,	intCompanyLocationId,	intAccountId,					intCurrencyId,
						intTermId,				intPeriodsToAccrue,		dtmDate,						dtmDueDate,
						dtmShipDate,			dtmPostDate,			intEntitySalespersonId,			intFreightTermId,
						intShipViaId,			intPaymentMethodId,		strInvoiceOriginId,				strPONumber,
						strBOLNumber,			/*strDeliverPickup,*/	strComments,					intShipToLocationId,
						intBillToLocationId,	ysnForgiven,			ysnCalculated,					ysnSplitted,
						intPaymentId,			intSplitId,				intLoadDistributionHeaderId,	strActualCostId,
						intShipmentId,			intTransactionId,		intMeterReadingId,				intContractHeaderId,
						intLoadId,				intOriginalInvoiceId,	intEntityId,					intTruckDriverId,	
						strSourceTransaction,	strSourceId,			intTruckDriverReferenceId,      ysnUpdateAvailableDiscount,

						intInvoiceDetailId,				intItemId,						intPrepayTypeId,			dblPrepayRate
						,strDocumentNumber,				strItemDescription,				intOrderUOMId,				dblQtyOrdered
						,intItemUOMId,					dblQtyShipped,					dblDiscount,				dblItemTermDiscount
						,strItemTermDiscountBy,			dblItemWeight,					intItemWeightUOMId,			dblPrice
						,dblUnitPrice,					strPricing,						strVFDDocumentNumber,		strMaintenanceType
						,strFrequency,					dtmMaintenanceDate,				dblMaintenanceAmount,		dblLicenseAmount
						,intTaxGroupId,					intStorageLocationId,			intCompanyLocationSubLocationId,intSCInvoiceId
						,strSCInvoiceNumber,			intSCBudgetId,					strSCBudgetDescription,		intInventoryShipmentItemId
						,intInventoryShipmentChargeId,	strShipmentNumber,				intRecipeItemId,			intRecipeId
						,intSubLocationId,				intCostTypeId,					intMarginById,				intCommentTypeId
						,dblMargin,						dblRecipeQuantity,				intSalesOrderDetailId,		strSalesOrderNumber
						,intContractDetailId,			intShipmentPurchaseSalesContractId,dblShipmentGrossWt,		dblShipmentTareWt
						,dblShipmentNetWt,				intTicketId,					intTicketHoursWorkedId,		intCustomerStorageId
						,intSiteDetailId,				intLoadDetailId,				intLotId,					intOriginalInvoiceDetailId
						,intSiteId,						strBillingBy,					dblPercentFull,				dblNewMeterReading
						,dblPreviousMeterReading,		dblConversionFactor,			intPerformerId,				ysnLeaseBilling
						,ysnVirtualMeterReading,		intCurrencyExchangeRateTypeId,	intCurrencyExchangeRateId,	dblCurrencyExchangeRate
						,intSubCurrencyId,				dblSubCurrencyRate,ysnBlended,	intConversionAccountId,		intSalesAccountId
						,intStorageScheduleTypeId,		intDestinationGradeId,			intDestinationWeightId
				)

				SELECT	IV.strTransactionType,
						IV.strType,
						@intInventoryShipmentId,
						IV.intInvoiceId,
						IV.intEntityCustomerId,
						IV.intCompanyLocationId,
						IV.intAccountId,
						IV.intCurrencyId,
						IV.intTermId,
						IV.intPeriodsToAccrue,
						IV.dtmDate,
						IV.dtmDueDate,
						IV.dtmShipDate,
						IV.dtmPostDate,
						IV.intEntitySalespersonId,
						IV.intFreightTermId,
						IV.intShipViaId,
						IV.intPaymentMethodId,
						IV.strInvoiceOriginId,
						--ysnUseOriginIdAsInvoiceNumber,
						IV.strPONumber,
						IV.strBOLNumber,
						--IV.strDeliverPickup,
						IV.strComments,
						IV.intShipToLocationId,
						IV.intBillToLocationId,
						--ysnTemplate,
						IV.ysnForgiven,
						IV.ysnCalculated,
						IV.ysnSplitted,
						IV.intPaymentId,
						IV.intSplitId,
						IV.intLoadDistributionHeaderId,
						IV.strActualCostId,
						IV.intShipmentId,
						IV.intTransactionId,
						IV.intMeterReadingId,
						IV.intContractHeaderId,
						IV.intLoadId,
						IV.intOriginalInvoiceId,
						IV.intEntityId,
						IV.intTruckDriverId,
						'Inventory Shipment',
						@strShipmentNumber,
						IV.intTruckDriverReferenceId,
						0
						--ysnResetDetails,
						--ysnRecap,
						--ysnPost,

						,ID.intInvoiceDetailId
						,ID.intItemId
						,ID.intPrepayTypeId
						,ID.dblPrepayRate
						--,ID.ysnInventory
						,ID.strDocumentNumber
						,ID.strItemDescription
						,ID.intOrderUOMId
						,ID.dblQtyOrdered
						,ID.intItemUOMId
						,ID.dblQtyShipped
						,ID.dblDiscount
						,ID.dblItemTermDiscount
						,ID.strItemTermDiscountBy
						,ID.dblItemWeight
						,ID.intItemWeightUOMId
						,@dblCashPrice
						,ID.dblUnitPrice
						,ID.strPricing
						,ID.strVFDDocumentNumber
						--,ID.ysnRefreshPrice
						,ID.strMaintenanceType
						,ID.strFrequency
						,ID.dtmMaintenanceDate
						,ID.dblMaintenanceAmount
						,ID.dblLicenseAmount
						,ID.intTaxGroupId
						,ID.intStorageLocationId
						,ID.intCompanyLocationSubLocationId
						--,ID.ysnRecomputeTax
						,ID.intSCInvoiceId
						,ID.strSCInvoiceNumber
						,ID.intSCBudgetId
						,ID.strSCBudgetDescription
						,ID.intInventoryShipmentItemId
						,ID.intInventoryShipmentChargeId
						,ID.strShipmentNumber
						,ID.intRecipeItemId
						,ID.intRecipeId
						,ID.intSubLocationId
						,ID.intCostTypeId
						,ID.intMarginById
						,ID.intCommentTypeId
						,ID.dblMargin
						,ID.dblRecipeQuantity
						,ID.intSalesOrderDetailId
						,ID.strSalesOrderNumber
						,ID.intContractDetailId
						,ID.intShipmentPurchaseSalesContractId
						,ID.dblShipmentGrossWt
						,ID.dblShipmentTareWt
						,ID.dblShipmentNetWt
						,ID.intTicketId
						,ID.intTicketHoursWorkedId
						,ID.intCustomerStorageId
						,ID.intSiteDetailId
						,ID.intLoadDetailId
						,ID.intLotId
						,ID.intOriginalInvoiceDetailId
						,ID.intSiteId
						,ID.strBillingBy
						,ID.dblPercentFull
						,ID.dblNewMeterReading
						,ID.dblPreviousMeterReading
						,ID.dblConversionFactor
						,ID.intPerformerId
						,ID.ysnLeaseBilling
						,ID.ysnVirtualMeterReading
						--,ID.ysnClearDetailTaxes
						--,ID.intTempDetailIdForTaxes
						,ID.intCurrencyExchangeRateTypeId
						,ID.intCurrencyExchangeRateId
						,ID.dblCurrencyExchangeRate
						,ID.intSubCurrencyId
						,ID.dblSubCurrencyRate
						,ID.ysnBlended
						--,ID.strImportFormat
						--,ID.dblCOGSAmount
						,ID.intConversionAccountId
						,ID.intSalesAccountId
						,ID.intStorageScheduleTypeId
						,ID.intDestinationGradeId
						,ID.intDestinationWeightId

				FROM	tblARInvoice		IV
				JOIN	tblARInvoiceDetail	ID	ON	ID.intInvoiceId	=	IV.intInvoiceId
				WHERE	IV.intInvoiceId	=	@intInvoiceId

			

				 EXEC [dbo].[uspARProcessInvoices]
						@InvoiceEntries			=	@InvoiceEntries
					   ,@LineItemTaxEntries		=	@LineItemTaxEntries
					   ,@UserId					=	@intUserId
					   ,@GroupingOption			=	8
					   ,@RaiseError				=	1
					   ,@ErrorMessage			=	@ErrorMessage	OUTPUT
					   ,@CreatedIvoices			=	@CreatedIvoices OUTPUT
					   ,@UpdatedIvoices			=	@UpdatedIvoices OUTPUT
			END
			SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId) FROM #tblShipment WHERE intInventoryShipmentId > @intInventoryShipmentId
		END
	END
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
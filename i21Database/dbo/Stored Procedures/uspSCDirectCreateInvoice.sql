﻿CREATE PROCEDURE [dbo].[uspSCDirectCreateInvoice]
	@intTicketId INT,
	@intEntityId INT,
	@intLocationId INT,
	@intUserId INT,
	@intInvoiceId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg NVARCHAR(MAX);
DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
		,@invoiceIntegrationStagingTable AS InvoiceIntegrationStagingTable
		,@success INT
		,@intFreightTermId INT
		,@intShipToId INT
		,@CreatedInvoices NVARCHAR(MAX)
		,@UpdatedInvoices NVARCHAR(MAX)
		,@successfulCount INT
		,@invalidCount INT
		,@batchIdUsed NVARCHAR(100)
		,@recapId INT
		,@recCount INT
		,@invoiceId INT,
		/* Price Contract variables*/
		@_intContractDetailId INT,
		@_intTicketId INT,
		@_dblNetUnits DECIMAL(18,6),
		@_dblRemainingNetUnits DECIMAL(18,6),
		@_intPriceFixationDetailId INT,
		@_dblPriceQty DECIMAL(18,6),
		@_dblQtyShipped DECIMAL(18,6),
		@_dblPricedAvailableQty DECIMAL(18,6),
		@_dblCashPrice DECIMAL(18,6),
		@_dtmFixationDate DATETIME,
		@_intPricingTypeId INT
		/* Price Contract variables*/

DECLARE @tblPriceContractAvailableFixation AS TABLE(
	intContractDetailId INT,
	intTicketId INT,
	dblNetUnits DECIMAL(18,6),
	intPriceFixationDetailId INT,
	dblPriceQty DECIMAL(18,6),
	dblQtyShipped DECIMAL(18,6),
	dblPricedAvailableQty DECIMAL(18,6),
	dblCashPrice DECIMAL(18,6),
	dtmFixationDate DATETIME
)

SELECT @_dblRemainingNetUnits = dblNetUnits, @_intPricingTypeId = CD.intPricingTypeId 
FROM tblSCTicket SC
INNER JOIN tblCTContractDetail CD
	ON CD.intContractDetailId = SC.intContractId
WHERE SC.intTicketId = @intTicketId

IF(@_intPricingTypeId = 2)
BEGIN
	INSERT INTO @tblPriceContractAvailableFixation
	SELECT CT.intContractDetailId, SC.intTicketId, SC.dblNetUnits,CTP.intPriceFixationDetailId,SUM(ISNULL(CTP.dblQuantity,0)) dblPricedQty, SUM(ISNULL(ARID.dblQtyShipped,0)) as dblQtyShipped, SUM(ISNULL(CTP.dblQuantity,0)) - SUM(ISNULL(ARID.dblQtyShipped,0)) dblPricedAvailableQty,CTP.dblCashPrice,CTP.dtmFixationDate FROM vyuCTPriceContractFixationDetail CTP
	INNER JOIN tblCTPriceFixation CPX
		ON CPX.intPriceFixationId = CTP.intPriceFixationId
	INNER JOIN tblCTContractDetail CT
		ON CPX.intContractDetailId = CT.intContractDetailId
	INNER JOIN tblSCTicket SC
		ON SC.intContractId = CT.intContractDetailId
	LEFT JOIN tblCTPriceFixationDetailAPAR APAR
		ON APAR.intPriceFixationDetailId = CTP.intPriceFixationDetailId
	LEFT JOIN tblARInvoiceDetail ARID
		ON ARID.intInvoiceDetailId = APAR.intInvoiceDetailId
	WHERE SC.intTicketId = @intTicketId
	GROUP BY CT.intContractDetailId, CTP.intPriceFixationDetailId, CTP.dblCashPrice,CTP.dtmFixationDate, SC.dblNetUnits, SC.intTicketId
	ORDER BY CTP.dtmFixationDate;
END

BEGIN TRY

	--Priced Contract
	IF EXISTS(SELECT NULL FROM @tblPriceContractAvailableFixation)
	BEGIN		
			DECLARE cur CURSOR FOR
			SELECT * FROM @tblPriceContractAvailableFixation
			OPEN cur
			FETCH NEXT FROM cur INTO @_intContractDetailId,	@_intTicketId, @_dblNetUnits, @_intPriceFixationDetailId, @_dblPriceQty, @_dblQtyShipped, @_dblPricedAvailableQty, @_dblCashPrice, @_dtmFixationDate
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF(@_dblPricedAvailableQty > 0)
				BEGIN	
					--FOR LINE ITEM
					INSERT INTO @invoiceIntegrationStagingTable ([strTransactionType],[strType],[strSourceTransaction],[intSourceId],[strSourceId],[intInvoiceId],[intEntityCustomerId],[intCompanyLocationId],[intCurrencyId],[intTermId],[dtmDate],[ysnTemplate],[ysnForgiven],[ysnCalculated],[ysnSplitted],[intEntityId],[ysnResetDetails],[intItemId],[strItemDescription],[intOrderUOMId],[intItemUOMId],[dblQtyOrdered],[dblQtyShipped],[dblDiscount],[dblPrice],[ysnRefreshPrice],[intTaxGroupId],[ysnRecomputeTax],[intContractDetailId],[intTicketId],[intDestinationGradeId],[intDestinationWeightId])
					SELECT 
						[strTransactionType] = 'Invoice'
						,[strType] = 'Standard'
						,[strSourceTransaction] = 'Ticket Management'
						,[intSourceId] = SC.intTicketId
						,[strSourceId] = ''
						,[intInvoiceId] = NULL --NULL Value will create new invoice
						,[intEntityCustomerId] = @intEntityId
						,[intCompanyLocationId] = SC.intProcessingLocationId
						,[intCurrencyId] = SC.intCurrencyId
						,[intTermId] = EM.intTermsId
						,[dtmDate] = SC.dtmTicketDateTime
						,[ysnTemplate] = 0
						,[ysnForgiven] = 0
						,[ysnCalculated] = 0
						,[ysnSplitted] = 0
						,[intEntityId] = @intUserId
						,[ysnResetDetails] = 0
						,[intItemId] = SC.intItemId
						,[strItemDescription] = ICI.strItemNo
						,[intOrderUOMId] = ISNULL(LGD.intItemUOMId, SC.intItemUOMIdTo)
						,[intItemUOMId]  = ISNULL(CTD.intItemUOMId,SC.intItemUOMIdTo)
						,[dblQtyOrdered] = ISNULL(LGD.dblQuantity, SC.dblNetUnits)
						,[dblQtyShipped] = dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,CTD.intItemUOMId,CASE WHEN @_dblRemainingNetUnits > @_dblPricedAvailableQty THEN @_dblPricedAvailableQty ELSE @_dblRemainingNetUnits END)
						,[dblDiscount] = 0
						,[dblPrice] = @_dblCashPrice
						,[ysnRefreshPrice] = 0
						,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
						,[ysnRecomputeTax] = 1
						,[intContractDetailId] = SC.intContractId
						,[intTicketId] = SC.intTicketId
						,[intDestinationGradeId] = SC.intGradeId
						,[intDestinationWeightId] = SC.intWeightId
						FROM tblSCTicket SC
						LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
						LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
						LEFT JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId		
						LEFT JOIN tblLGLoadDetail LGD ON LGD.intLoadId = SC.intLoadId and LGD.intSContractDetailId = SC.intContractId
						LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = SC.intContractId
						WHERE SC.intTicketId = @_intTicketId

						--FOR FREIGHT CHARGES
						INSERT INTO @invoiceIntegrationStagingTable (
							[strTransactionType]
							,[strType]
							,[strSourceTransaction]
							,[intSourceId]
							,[strSourceId]
							,[intInvoiceId]
							,[intEntityCustomerId]
							,[intCompanyLocationId]
							,[intCurrencyId]
							,[intTermId]
							,[dtmDate]
							,[ysnTemplate]
							,[ysnForgiven]
							,[ysnCalculated]
							,[ysnSplitted]
							,[intEntityId]
							,[ysnResetDetails]
							,[intItemId]
							,[strItemDescription]
							,[intOrderUOMId]
							,[intItemUOMId]
							,[dblQtyOrdered]
							,[dblQtyShipped]
							,[dblDiscount]
							,[dblPrice]
							,[ysnRefreshPrice]
							,[intTaxGroupId]
							,[ysnRecomputeTax]
							,[intContractDetailId]
							,[intTicketId]
							,[intDestinationGradeId]
							,[intDestinationWeightId]		
						)
						SELECT 
							[strTransactionType] = 'Invoice'
							,[strType] = 'Standard'
							,[strSourceTransaction] = 'Ticket Management'
							,[intSourceId] = SC.intTicketId
							,[strSourceId] = ''
							,[intInvoiceId] = NULL --NULL Value will create new invoice
							,[intEntityCustomerId] = @intEntityId
							,[intCompanyLocationId] = SC.intProcessingLocationId
							,[intCurrencyId] = SC.intCurrencyId
							,[intTermId] = EM.intTermsId
							,[dtmDate] = SC.dtmTicketDateTime
							,[ysnTemplate] = 0
							,[ysnForgiven] = 0
							,[ysnCalculated] = 0
							,[ysnSplitted] = 0
							,[intEntityId] = @intUserId
							,[ysnResetDetails] = 0
							,[intItemId] = ICI.intItemId
							,[strItemDescription] = ICI.strItemNo
							,[intOrderUOMId]= NULL
							,[intItemUOMId] = NULL
							,[dblQtyOrdered] = @_dblRemainingNetUnits
							,[dblQtyShipped] = @_dblRemainingNetUnits
							,[dblDiscount] = 0
							,[dblPrice] = SC.dblFreightRate
							,[ysnRefreshPrice] = 0
							,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
							,[ysnRecomputeTax] = 1
							,[intContractDetailId] = SC.intContractId
							,[intTicketId] = SC.intTicketId
							,[intDestinationGradeId] = SC.intGradeId
							,[intDestinationWeightId] = SC.intWeightId
							FROM tblSCTicket SC
							INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
							LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
							LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
							LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intFreightItemId		
							WHERE SC.intTicketId = @_intTicketId AND SC.dblFreightRate != 0

						--FOR FEE CHARGES
						INSERT INTO @invoiceIntegrationStagingTable (
							[strTransactionType]
							,[strType]
							,[strSourceTransaction]
							,[intSourceId]
							,[strSourceId]
							,[intInvoiceId]
							,[intEntityCustomerId]
							,[intCompanyLocationId]
							,[intCurrencyId]
							,[intTermId]
							,[dtmDate]
							,[ysnTemplate]
							,[ysnForgiven]
							,[ysnCalculated]
							,[ysnSplitted]
							,[intEntityId]
							,[ysnResetDetails]
							,[intItemId]
							,[strItemDescription]
							,[intOrderUOMId]
							,[intItemUOMId]
							,[dblQtyOrdered]
							,[dblQtyShipped]
							,[dblDiscount]
							,[dblPrice]
							,[ysnRefreshPrice]
							,[intTaxGroupId]
							,[ysnRecomputeTax]
							,[intContractDetailId]
							,[intTicketId]
							,[intDestinationGradeId]
							,[intDestinationWeightId]		
						)
						SELECT 
							[strTransactionType] = 'Invoice'
							,[strType] = 'Standard'
							,[strSourceTransaction] = 'Ticket Management'
							,[intSourceId] = SC.intTicketId
							,[strSourceId] = ''
							,[intInvoiceId] = NULL --NULL Value will create new invoice
							,[intEntityCustomerId] = @intEntityId
							,[intCompanyLocationId] = SC.intProcessingLocationId
							,[intCurrencyId] = SC.intCurrencyId
							,[intTermId] = EM.intTermsId
							,[dtmDate] = SC.dtmTicketDateTime
							,[ysnTemplate] = 0
							,[ysnForgiven] = 0
							,[ysnCalculated] = 0
							,[ysnSplitted] = 0
							,[intEntityId] = @intUserId
							,[ysnResetDetails] = 0
							,[intItemId] = ICI.intItemId
							,[strItemDescription] = ICI.strItemNo
							,[intOrderUOMId]= NULL
							,[intItemUOMId] = NULL
							,[dblQtyOrdered] = @_dblRemainingNetUnits--SC.dblNetUnits
							,[dblQtyShipped] = @_dblRemainingNetUnits
							,[dblDiscount] = 0
							,[dblPrice] = SC.dblFreightRate
							,[ysnRefreshPrice] = 0
							,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
							,[ysnRecomputeTax] = 1
							,[intContractDetailId] = SC.intContractId
							,[intTicketId] = SC.intTicketId
							,[intDestinationGradeId] = SC.intGradeId
							,[intDestinationWeightId] = SC.intWeightId
							FROM tblSCTicket SC
							INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
							LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
							LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
							LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intDefaultFeeItemId		
							WHERE SC.intTicketId = @_intTicketId AND SC.dblTicketFees != 0

						--FOR DISCOUNT
						INSERT INTO @invoiceIntegrationStagingTable (
							[strTransactionType]
							,[strType]
							,[strSourceTransaction]
							,[intSourceId]
							,[strSourceId]
							,[intInvoiceId]
							,[intEntityCustomerId]
							,[intCompanyLocationId]
							,[intCurrencyId]
							,[intTermId]
							,[dtmDate]
							,[ysnTemplate]
							,[ysnForgiven]
							,[ysnCalculated]
							,[ysnSplitted]
							,[intEntityId]
							,[ysnResetDetails]
							,[intItemId]
							,[strItemDescription]
							,[intOrderUOMId]
							,[intItemUOMId]
							,[dblQtyOrdered]
							,[dblQtyShipped]
							,[dblDiscount]
							,[dblPrice]
							,[ysnRefreshPrice]
							,[intTaxGroupId]
							,[ysnRecomputeTax]
							,[intContractDetailId]
							,[intTicketId]
							,[intDestinationGradeId]
							,[intDestinationWeightId]		
						)
						SELECT 
							[strTransactionType] = 'Invoice'
							,[strType] = 'Standard'
							,[strSourceTransaction] = 'Ticket Management'
							,[intSourceId] = SC.intTicketId
							,[strSourceId] = ''
							,[intInvoiceId] = NULL --NULL Value will create new invoice
							,[intEntityCustomerId] = @intEntityId
							,[intCompanyLocationId] = SC.intProcessingLocationId
							,[intCurrencyId] = SC.intCurrencyId
							,[intTermId] = EM.intTermsId
							,[dtmDate] = SC.dtmTicketDateTime
							,[ysnTemplate] = 0
							,[ysnForgiven] = 0
							,[ysnCalculated] = 0
							,[ysnSplitted] = 0
							,[intEntityId] = @intUserId
							,[ysnResetDetails] = 0
							,[intItemId] = ICI.intItemId
							,[strItemDescription] = ICI.strItemNo
							,[intOrderUOMId]= NULL
							,[intItemUOMId] =  CASE
													WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, SC.intItemUOMIdTo)
													WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
												END
							,[dblQtyOrdered] = CASE
												WHEN ICI.strCostMethod = 'Per Unit' THEN @_dblRemainingNetUnits
												WHEN ICI.strCostMethod = 'Amount' THEN 1
											END
							,[dblQtyShipped] = CASE
												WHEN ICI.strCostMethod = 'Per Unit' THEN @_dblRemainingNetUnits
												WHEN ICI.strCostMethod = 'Amount' THEN 1
											END
							,[dblDiscount] = 0
							,[dblPrice] = CASE
											WHEN ICI.strCostMethod = 'Per Unit' THEN QM.dblDiscountAmount
											WHEN ICI.strCostMethod = 'Amount' THEN 
											CASE 
												WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, @_dblRemainingNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis))) * -1)
												WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, @_dblRemainingNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis)))
											END
										END
							,[ysnRefreshPrice] = 0
							,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
							,[ysnRecomputeTax] = 1
							,[intContractDetailId] = SC.intContractId
							,[intTicketId] = SC.intTicketId
							,[intDestinationGradeId] = SC.intGradeId
							,[intDestinationWeightId] = SC.intWeightId
							FROM tblSCTicket SC
							INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intTicketId
							LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
							LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
							LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
							LEFT JOIN tblICItem ICI ON ICI.intItemId = GR.intItemId		
							LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
							LEFT JOIN (
								SELECT 
								CTD.intContractHeaderId
								,CTD.intContractDetailId
								,CTD.intPricingTypeId
								,AD.dblSeqPrice
								FROM tblCTContractDetail CTD
								CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
							) CNT ON CNT.intContractDetailId = SC.intContractId
							WHERE SC.intTicketId = @intTicketId
					
						IF(@_dblRemainingNetUnits > @_dblPricedAvailableQty)
						BEGIN
							SET @_dblRemainingNetUnits = @_dblRemainingNetUnits - @_dblPricedAvailableQty;
						END

				END
				FETCH NEXT FROM cur INTO @_intContractDetailId,	@_intTicketId, @_dblNetUnits, @_intPriceFixationDetailId, @_dblPriceQty, @_dblQtyShipped, @_dblPricedAvailableQty, @_dblCashPrice, @_dtmFixationDate
			END
			CLOSE cur
			DEALLOCATE cur
	END
	ELSE
	BEGIN
		--FOR LINE ITEM
		INSERT INTO @invoiceIntegrationStagingTable (
			[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[dtmDate]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intEntityId]
			,[ysnResetDetails]
			,[intItemId]
			,[strItemDescription]
			,[intOrderUOMId]
			,[intItemUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblPrice]
			,[ysnRefreshPrice]
			,[intTaxGroupId]
			,[ysnRecomputeTax]
			,[intContractDetailId]
			,[intTicketId]
			,[intDestinationGradeId]
			,[intDestinationWeightId]		
		)
		SELECT 
			[strTransactionType] = 'Invoice'
			,[strType] = 'Standard'
			,[strSourceTransaction] = 'Ticket Management'
			,[intSourceId] = SC.intTicketId
			,[strSourceId] = ''
			,[intInvoiceId] = NULL --NULL Value will create new invoice
			,[intEntityCustomerId] = @intEntityId
			,[intCompanyLocationId] = SC.intProcessingLocationId
			,[intCurrencyId] = SC.intCurrencyId
			,[intTermId] = EM.intTermsId
			,[dtmDate] = SC.dtmTicketDateTime
			,[ysnTemplate] = 0
			,[ysnForgiven] = 0
			,[ysnCalculated] = 0
			,[ysnSplitted] = 0
			,[intEntityId] = @intUserId
			,[ysnResetDetails] = 0
			,[intItemId] = SC.intItemId
			,[strItemDescription] = ICI.strItemNo
			,[intOrderUOMId] = ISNULL(LGD.intItemUOMId, SC.intItemUOMIdTo)
			,[intItemUOMId]  = ISNULL(CTD.intItemUOMId,SC.intItemUOMIdTo)
			,[dblQtyOrdered] = ISNULL(LGD.dblQuantity, SC.dblNetUnits)
			,[dblQtyShipped] = (CASE WHEN CTD.intItemUOMId IS NULL
									THEN SC.dblNetUnits 
									ELSE (SELECT dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,CTD.intItemUOMId,SC.dblNetUnits))
								END)
			,[dblDiscount] = 0
			,[dblPrice] = SC.dblUnitPrice + dblUnitBasis
			,[ysnRefreshPrice] = 0
			,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
			,[ysnRecomputeTax] = 1
			,[intContractDetailId] = SC.intContractId
			,[intTicketId] = SC.intTicketId
			,[intDestinationGradeId] = SC.intGradeId
			,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId		
			LEFT JOIN tblLGLoadDetail LGD ON LGD.intLoadId = SC.intLoadId and LGD.intSContractDetailId = SC.intContractId
			LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = SC.intContractId
			WHERE SC.intTicketId = @intTicketId

		--FOR FREIGHT CHARGES
		INSERT INTO @invoiceIntegrationStagingTable (
			[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[dtmDate]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intEntityId]
			,[ysnResetDetails]
			,[intItemId]
			,[strItemDescription]
			,[intOrderUOMId]
			,[intItemUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblPrice]
			,[ysnRefreshPrice]
			,[intTaxGroupId]
			,[ysnRecomputeTax]
			,[intContractDetailId]
			,[intTicketId]
			,[intDestinationGradeId]
			,[intDestinationWeightId]		
		)
		SELECT 
			[strTransactionType] = 'Invoice'
			,[strType] = 'Standard'
			,[strSourceTransaction] = 'Ticket Management'
			,[intSourceId] = SC.intTicketId
			,[strSourceId] = ''
			,[intInvoiceId] = NULL --NULL Value will create new invoice
			,[intEntityCustomerId] = @intEntityId
			,[intCompanyLocationId] = SC.intProcessingLocationId
			,[intCurrencyId] = SC.intCurrencyId
			,[intTermId] = EM.intTermsId
			,[dtmDate] = SC.dtmTicketDateTime
			,[ysnTemplate] = 0
			,[ysnForgiven] = 0
			,[ysnCalculated] = 0
			,[ysnSplitted] = 0
			,[intEntityId] = @intUserId
			,[ysnResetDetails] = 0
			,[intItemId] = ICI.intItemId
			,[strItemDescription] = ICI.strItemNo
			,[intOrderUOMId]= NULL
			,[intItemUOMId] = NULL
			,[dblQtyOrdered] = SC.dblNetUnits
			,[dblQtyShipped] = SC.dblNetUnits
			,[dblDiscount] = 0
			,[dblPrice] = SC.dblFreightRate
			,[ysnRefreshPrice] = 0
			,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
			,[ysnRecomputeTax] = 1
			,[intContractDetailId] = SC.intContractId
			,[intTicketId] = SC.intTicketId
			,[intDestinationGradeId] = SC.intGradeId
			,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
			LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intFreightItemId		
			WHERE SC.intTicketId = @intTicketId AND SC.dblFreightRate != 0

			--FOR FEE CHARGES
		INSERT INTO @invoiceIntegrationStagingTable (
			[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[dtmDate]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intEntityId]
			,[ysnResetDetails]
			,[intItemId]
			,[strItemDescription]
			,[intOrderUOMId]
			,[intItemUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblPrice]
			,[ysnRefreshPrice]
			,[intTaxGroupId]
			,[ysnRecomputeTax]
			,[intContractDetailId]
			,[intTicketId]
			,[intDestinationGradeId]
			,[intDestinationWeightId]		
		)
		SELECT 
			[strTransactionType] = 'Invoice'
			,[strType] = 'Standard'
			,[strSourceTransaction] = 'Ticket Management'
			,[intSourceId] = SC.intTicketId
			,[strSourceId] = ''
			,[intInvoiceId] = NULL --NULL Value will create new invoice
			,[intEntityCustomerId] = @intEntityId
			,[intCompanyLocationId] = SC.intProcessingLocationId
			,[intCurrencyId] = SC.intCurrencyId
			,[intTermId] = EM.intTermsId
			,[dtmDate] = SC.dtmTicketDateTime
			,[ysnTemplate] = 0
			,[ysnForgiven] = 0
			,[ysnCalculated] = 0
			,[ysnSplitted] = 0
			,[intEntityId] = @intUserId
			,[ysnResetDetails] = 0
			,[intItemId] = ICI.intItemId
			,[strItemDescription] = ICI.strItemNo
			,[intOrderUOMId]= NULL
			,[intItemUOMId] = NULL
			,[dblQtyOrdered] = SC.dblNetUnits
			,[dblQtyShipped] = SC.dblNetUnits
			,[dblDiscount] = 0
			,[dblPrice] = SC.dblFreightRate
			,[ysnRefreshPrice] = 0
			,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
			,[ysnRecomputeTax] = 1
			,[intContractDetailId] = SC.intContractId
			,[intTicketId] = SC.intTicketId
			,[intDestinationGradeId] = SC.intGradeId
			,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
			LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intDefaultFeeItemId		
			WHERE SC.intTicketId = @intTicketId AND SC.dblTicketFees != 0

		--FOR DISCOUNT
		INSERT INTO @invoiceIntegrationStagingTable (
			[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[dtmDate]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intEntityId]
			,[ysnResetDetails]
			,[intItemId]
			,[strItemDescription]
			,[intOrderUOMId]
			,[intItemUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblPrice]
			,[ysnRefreshPrice]
			,[intTaxGroupId]
			,[ysnRecomputeTax]
			,[intContractDetailId]
			,[intTicketId]
			,[intDestinationGradeId]
			,[intDestinationWeightId]		
		)
		SELECT 
			[strTransactionType] = 'Invoice'
			,[strType] = 'Standard'
			,[strSourceTransaction] = 'Ticket Management'
			,[intSourceId] = SC.intTicketId
			,[strSourceId] = ''
			,[intInvoiceId] = NULL --NULL Value will create new invoice
			,[intEntityCustomerId] = @intEntityId
			,[intCompanyLocationId] = SC.intProcessingLocationId
			,[intCurrencyId] = SC.intCurrencyId
			,[intTermId] = EM.intTermsId
			,[dtmDate] = SC.dtmTicketDateTime
			,[ysnTemplate] = 0
			,[ysnForgiven] = 0
			,[ysnCalculated] = 0
			,[ysnSplitted] = 0
			,[intEntityId] = @intUserId
			,[ysnResetDetails] = 0
			,[intItemId] = ICI.intItemId
			,[strItemDescription] = ICI.strItemNo
			,[intOrderUOMId]= NULL
			,[intItemUOMId] =  CASE
									WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, SC.intItemUOMIdTo)
									WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
								END
			,[dblQtyOrdered] = CASE
								WHEN ICI.strCostMethod = 'Per Unit' THEN SC.dblNetUnits
								WHEN ICI.strCostMethod = 'Amount' THEN 1
							END
			,[dblQtyShipped] = CASE
								WHEN ICI.strCostMethod = 'Per Unit' THEN SC.dblNetUnits
								WHEN ICI.strCostMethod = 'Amount' THEN 1
							END
			,[dblDiscount] = 0
			,[dblPrice] = CASE
							WHEN ICI.strCostMethod = 'Per Unit' THEN QM.dblDiscountAmount
							WHEN ICI.strCostMethod = 'Amount' THEN 
							CASE 
								WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis))) * -1)
								WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis)))
							END
						END
			,[ysnRefreshPrice] = 0
			,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
			,[ysnRecomputeTax] = 1
			,[intContractDetailId] = SC.intContractId
			,[intTicketId] = SC.intTicketId
			,[intDestinationGradeId] = SC.intGradeId
			,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intTicketId
			LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
			LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = GR.intItemId		
			LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
			LEFT JOIN (
				SELECT 
				CTD.intContractHeaderId
				,CTD.intContractDetailId
				,CTD.intPricingTypeId
				,AD.dblSeqPrice
				FROM tblCTContractDetail CTD
				CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
			) CNT ON CNT.intContractDetailId = SC.intContractId
			WHERE SC.intTicketId = @intTicketId
	END

	SELECT @recCount = COUNT(*) FROM @invoiceIntegrationStagingTable;
	
	IF ISNULL(@recCount,0) > 0
	BEGIN
		EXEC [dbo].[uspARProcessInvoices] 
			@InvoiceEntries = @invoiceIntegrationStagingTable
			,@UserId = @intUserId
			,@GroupingOption = 11
			,@RaiseError = 1
			,@ErrorMessage = @ErrorMessage OUTPUT
			,@CreatedIvoices = @CreatedInvoices OUTPUT
			,@UpdatedIvoices = @UpdatedInvoices OUTPUT

		SET @intInvoiceId = CAST(@CreatedInvoices AS INT)

		IF (EXISTS(SELECT NULL FROM @tblPriceContractAvailableFixation) AND EXISTS(SELECT NULL FROM @invoiceIntegrationStagingTable))
		BEGIN
			/* INSERT tblCTPriceFixationDetailAPAR */
			INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
			SELECT FX.intPriceFixationDetailId, ARID.intInvoiceId, ARID.intInvoiceDetailId,1 FROM fnGetRowsFromDelimitedValues(@CreatedInvoices) I
			INNER JOIN tblARInvoiceDetail ARID
				ON I.intID = ARID.intInvoiceId
			INNER JOIN tblSCTicket SC
				ON SC.intItemId = ARID.intItemId
			LEFT JOIN @tblPriceContractAvailableFixation FX
				ON FX.dblCashPrice = ARID.dblPrice and ARID.dblQtyShipped = CASE WHEN FX.dblNetUnits > FX.dblPricedAvailableQty THEN FX.dblPricedAvailableQty ELSE ARID.dblQtyShipped END--FX.dblPricedAvailableQty = CASE WHEN FX.dblNetUnits > FX.dblPricedAvailableQty THEN ARID.dblQtyShipped ELSE FX.dblPricedAvailableQty END
			WHERE SC.intTicketId = @intTicketId


			SELECT * FROM fnGetRowsFromDelimitedValues(@CreatedInvoices) I
			INNER JOIN tblCTPriceFixationDetailAPAR B ON B.intInvoiceId = I.intID
		END
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= NULL,
			@post				= 1,
			@recap				= 0,
			@param				= @CreatedInvoices,
			@userId				= @intUserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@accrueLicense		= 0,
			@raiseError			= 1
	END
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
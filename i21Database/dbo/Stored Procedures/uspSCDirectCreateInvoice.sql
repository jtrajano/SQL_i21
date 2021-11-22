CREATE PROCEDURE [dbo].[uspSCDirectCreateInvoice]
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

DECLARE @intContractHeaderPricingTypeId INT
DECLARE @intTicketContractDetailId INT
DECLARE @intTicketContractHeaderId INT
DECLARE @ysnDestinationationWGPosted BIT
DECLARE @strWhereFinalizedWeight NVARCHAR(20)
DECLARE @strWhereFinalizedGrade NVARCHAR(20)
DECLARE @intTicketCommodityId INT
dECLARE @intFutureMarketId INT
DECLARE @intFutureMonthId INT
DECLARE @intTicketStorageScheduleTypeId INT


DECLARE @_dblQty NUMERIC(36,20)
DECLARE @_intTicketContractUsed INT
DECLARE @_intBillId INT
DECLARE @_intBillDetailId INT
DECLARE @_intLoadDetailId INT
DECLARE @_intTicketLoadUsedId INT



DECLARE @invoiceItemIntegrationStagingTable InvoiceIntegrationStagingTable

DECLARE @contractBasisPriceTable TABLE(
		intContractDetailId int
		,intPriceFixationDetailId int
		,dblQuantity NUMERIC(36,20)
		,dblPrice numeric(18,6)
)


-- DECLARE @tblPriceContractAvailableFixation AS TABLE(
-- 	intContractDetailId INT,
-- 	intTicketId INT,
-- 	dblNetUnits DECIMAL(18,6),
-- 	intPriceFixationDetailId INT,
-- 	dblPriceQty DECIMAL(18,6),
-- 	dblQtyShipped DECIMAL(18,6),
-- 	dblPricedAvailableQty DECIMAL(18,6),
-- 	dblCashPrice DECIMAL(18,6),
-- 	dtmFixationDate DATETIME
-- )

IF OBJECT_ID (N'tempdb.dbo.#tmpSCContractPrice') IS NOT NULL DROP TABLE #tmpSCContractPrice
CREATE TABLE #tmpSCContractPrice (
	intIdentityId INT
	,intContractHeaderId int
	,intContractDetailId int
	,ysnLoad bit
	,intPriceContractId int
	,intPriceFixationId int
	,intPriceFixationDetailId int
	,dblQuantity numeric(38,20)
	,dblPrice numeric(38,20)
)


BEGIN TRY
	SELECT 
		@_dblRemainingNetUnits = SC.dblNetUnits
		, @_intPricingTypeId = CD.intPricingTypeId 
		,@intContractHeaderPricingTypeId = CH.intPricingTypeId
		,@intTicketContractDetailId = SC.intContractId
		,@intTicketContractHeaderId = CH.intContractHeaderId
		,@_intTicketId = SC.intTicketId
		,@intTicketStorageScheduleTypeId =  intStorageScheduleTypeId
	FROM tblSCTicket SC
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractId
	INNER JOIN tblCTContractHeader CH	
		ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE SC.intTicketId = @intTicketId

	--Priced Basis
	/*
	IF @intContractHeaderPricingTypeId = 2
	BEGIN	
		IF(ISNULL((SELECT SUM(dblQuantity) FROM #tmpSCContractPrice),0) <  @_dblRemainingNetUnits)	
		BEGIN
			GOTO _Exit
		END
		
		--FOR LINE ITEM
		BEGIN
			INSERT INTO @invoiceIntegrationStagingTable (
				[strTransactionType]
				,[strType]
				,[strSourceTransaction]
				,[intSourceId],[strSourceId]
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
				,[intDestinationWeightId])
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
				,[dblQtyShipped] = dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo,CTD.intItemUOMId,CP.dblQuantity)
				,[dblDiscount] = 0
				,[dblPrice] = CP.dblPrice
				,[ysnRefreshPrice] = 0
				,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,[ysnRecomputeTax] = 1
				,[intContractDetailId] = SC.intContractId
				,[intTicketId] = SC.intTicketId
				,[intDestinationGradeId] = SC.intGradeId
				,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN #tmpSCContractPrice CP
				ON ISNULL(SC.intContractId,0) = CP.intContractDetailId
			LEFT JOIN tblARCustomer AR 
				ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = AR.intEntityId 
					AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI 
				ON ICI.intItemId = SC.intItemId		
			LEFT JOIN tblLGLoadDetail LGD 
				ON LGD.intLoadId = SC.intLoadId 
					AND LGD.intSContractDetailId = SC.intContractId
			LEFT JOIN tblCTContractDetail CTD 
				ON CTD.intContractDetailId = SC.intContractId
			WHERE SC.intTicketId = @_intTicketId

			DELETE FROM @invoiceItemIntegrationStagingTable 
			INSERT INTO @invoiceItemIntegrationStagingTable (
				[strTransactionType]
				,[strType]
				,[strSourceTransaction]
				,[intSourceId],[strSourceId]
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
				[strTransactionType]
				,[strType]
				,[strSourceTransaction]
				,[intSourceId],[strSourceId]
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
			FROM @invoiceIntegrationStagingTable
		END

		--FOR FREIGHT CHARGES
		BEGIN
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
				,[intContractDetailId] = null --SC.intContractId
				,[intTicketId] = SC.intTicketId
				,[intDestinationGradeId] = SC.intGradeId
				,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
			LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intFreightItemId		
			WHERE SC.intTicketId = @_intTicketId AND SC.dblFreightRate != 0
		END

		--FOR FEE CHARGES
		BEGIN
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
				,[dblQtyShipped] = CP.dblQuantity
				,[dblDiscount] = 0
				,[dblPrice] = SC.dblFreightRate
				,[ysnRefreshPrice] = 0
				,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,[ysnRecomputeTax] = 1
				,[intContractDetailId] = null --SC.intContractId
				,[intTicketId] = SC.intTicketId
				,[intDestinationGradeId] = SC.intGradeId
				,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN tblSCScaleSetup SCS 
				ON SCS.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN #tmpSCContractPrice CP
				ON ISNULL(SC.intContractId,0) = CP.intContractDetailId
			LEFT JOIN tblARCustomer AR 
				ON AR.intEntityId = SC.intEntityId
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = AR.intEntityId 
					AND EM.intEntityLocationId = AR.intShipToId
			LEFT JOIN tblICItem ICI 
				ON ICI.intItemId = SCS.intDefaultFeeItemId		
			WHERE SC.intTicketId = @_intTicketId 
				AND SC.dblTicketFees != 0
		END

		--FOR DISCOUNT
		BEGIN
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
				,[dblQtyOrdered] = (CASE
									WHEN ICI.strCostMethod = 'Per Unit' THEN SC.dblNetUnits
									WHEN ICI.strCostMethod = 'Amount' THEN 1
								END) 
				,[dblQtyShipped] = (CASE
									WHEN ICI.strCostMethod = 'Per Unit' THEN SC.dblNetUnits
									WHEN ICI.strCostMethod = 'Amount' THEN 1
								END) 
				,[dblDiscount] = 0
				,[dblPrice] = CASE
								WHEN ICI.strCostMethod = 'Per Unit' THEN QM.dblDiscountAmount  * (CASE WHEN QM.dblDiscountAmount < 0 THEN 1 ELSE -1 END)
								WHEN ICI.strCostMethod = 'Amount' THEN 
								-- CASE 
								-- 	WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, CP.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis))) * -1)
								-- 	WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, CP.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis)))
								-- END
								dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, CP.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis))) * -1
							END
				,[ysnRefreshPrice] = 0
				,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,[ysnRecomputeTax] = 1
				,[intContractDetailId] = null --SC.intContractId
				,[intTicketId] = SC.intTicketId
				,[intDestinationGradeId] = SC.intGradeId
				,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN #tmpSCContractPrice CP
				ON ISNULL(SC.intContractId,0) = CP.intContractDetailId
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
				AND QM.strSourceType = 'Scale'
				AND QM.dblDiscountAmount <> 0
		END

	END
	ELSE
	*/
	BEGIN
		--FOR LINE ITEM
		BEGIN
			BEGIN

				----LOAD
				BEGIN
					--- using Non BASIS/HTA COntract
					BEGIN
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
							,intLoadDetailId
						)
						SELECT 
							[strTransactionType] = 'Invoice'
							,[strType] = 'Standard'
							,[strSourceTransaction] = 'Ticket Management'
							,[intSourceId] = SC.intTicketId
							,[strSourceId] = ''
							,[intInvoiceId] = NULL --NULL Value will create new invoice
							,[intEntityCustomerId] = SCLoad.intEntityId
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
							,[intOrderUOMId] = LGD.intItemUOMId
							,[intItemUOMId]  = SC.intItemUOMIdTo
							,[dblQtyOrdered] = LGD.dblQuantity
							,[dblQtyShipped] = SCLoad.dblQty
							,[dblDiscount] = 0
							,[dblPrice] = ISNULL(CTD.dblCashPrice,LGD.dblUnitPrice)
							,[ysnRefreshPrice] = 0
							,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(SCLoad.intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
							,[ysnRecomputeTax] = 1
							,[intContractDetailId] = CTD.intContractDetailId
							,[intTicketId] = SC.intTicketId
							,[intDestinationGradeId] = SC.intGradeId
							,[intDestinationWeightId] = SC.intWeightId
							,intLoadDetailId = LGD.intLoadDetailId
						FROM tblSCTicket SC
						INNER JOIN tblSCTicketLoadUsed SCLoad
							ON SC.intTicketId = SCLoad.intTicketId
						INNER JOIN tblARCustomer AR 
							ON AR.intEntityId = SCLoad.intEntityId
						LEFT JOIN tblEMEntityLocation EM 
							ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
						INNER JOIN tblICItem ICI 
							ON ICI.intItemId = SC.intItemId		
						INNER JOIN tblLGLoadDetail LGD 
							ON LGD.intLoadDetailId = SCLoad.intLoadDetailId 
						LEFT JOIN tblCTContractDetail CTD 
							ON CTD.intContractDetailId = LGD.intSContractDetailId
						LEFT JOIN tblCTContractHeader CTH
							ON CTD.intContractHeaderId = CTH.intContractHeaderId
						WHERE SC.intTicketId = @intTicketId
							AND (CTH.intPricingTypeId <> 2 AND CTH.intPricingTypeId <> 3)
					END

					--- using BASIS/HTA COntract
					BEGIN

						IF OBJECT_ID('tempdb..#tmpLoadBasisContractUsed') IS NOT NULL DROP TABLE #tmpLoadBasisContractUsed

						SELECT
							SCL.intTicketLoadUsedId
							,SCL.dblQty
							,CTD.intContractDetailId
							,SCL.intLoadDetailId
						INTO #tmpLoadBasisContractUsed
						FROM tblSCTicket SC 
						INNER JOIN tblSCTicketLoadUsed SCL
							ON SC.intTicketId = SCL.intTicketId
						INNER JOIN tblLGLoadDetail LD
							ON SCL.intLoadDetailId = LD.intLoadDetailId
						INNER JOIN tblCTContractDetail CTD
							ON LD.intSContractDetailId = CTD.intContractDetailId
						INNER JOIN tblCTContractHeader CTH
							ON CTD.intContractHeaderId = CTH.intContractHeaderId
						WHERE SC.intTicketId = @intTicketId
							AND (CTH.intPricingTypeId = 2 OR CTH.intPricingTypeId = 3)
						ORDER BY intTicketLoadUsedId

						SET @_intTicketLoadUsedId = NULL
						SELECT TOP 1 
							@_intTicketLoadUsedId = intTicketLoadUsedId
							,@_dblQty = dblQty
							,@_intContractDetailId = intContractDetailId
							,@_intLoadDetailId = intLoadDetailId
						FROM #tmpLoadBasisContractUsed
						ORDER BY intTicketLoadUsedId

						WHILE ISNULL(@_intTicketLoadUsedId,0) > 0
						BEGIN
							DELETE FROM @contractBasisPriceTable 
							INSERT INTO @contractBasisPriceTable (
								intContractDetailId 
								,intPriceFixationDetailId
								,dblQuantity 
								,dblPrice 
							)
							EXEC uspSCGetAndAllocateBasisContractUnits @_dblQty,@_intContractDetailId

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
								,intLoadDetailId
							)
							SELECT 
								[strTransactionType] = 'Invoice'
								,[strType] = 'Standard'
								,[strSourceTransaction] = 'Ticket Management'
								,[intSourceId] = SC.intTicketId
								,[strSourceId] = ''
								,[intInvoiceId] = NULL --NULL Value will create new invoice
								,[intEntityCustomerId] = SCLoad.intEntityId
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
								,[intOrderUOMId] = LGD.intItemUOMId
								,[intItemUOMId]  = SC.intItemUOMIdTo
								,[dblQtyOrdered] = LGD.dblQuantity
								,[dblQtyShipped] = SCLC.dblQuantity
								,[dblDiscount] = 0
								,[dblPrice] = SCLC.dblPrice
								,[ysnRefreshPrice] = 0
								,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(SCLoad.intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
								,[ysnRecomputeTax] = 1
								,[intContractDetailId] = CTD.intContractDetailId
								,[intTicketId] = SC.intTicketId
								,[intDestinationGradeId] = SC.intGradeId
								,[intDestinationWeightId] = SC.intWeightId
								,intLoadDetailId = LGD.intLoadDetailId
							FROM tblSCTicket SC
							INNER JOIN tblSCTicketLoadUsed SCLoad
								ON SC.intTicketId = SCLoad.intTicketId
							INNER JOIN tblARCustomer AR 
								ON AR.intEntityId = SCLoad.intEntityId
							LEFT JOIN tblEMEntityLocation EM 
								ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
							INNER JOIN tblICItem ICI 
								ON ICI.intItemId = SC.intItemId		
							INNER JOIN tblLGLoadDetail LGD 
								ON LGD.intLoadDetailId = SCLoad.intLoadDetailId 
							INNER JOIN tblCTContractDetail CTD 
								ON CTD.intContractDetailId = LGD.intSContractDetailId
							INNER JOIN tblCTContractHeader CTH
								ON CTD.intContractHeaderId = CTH.intContractHeaderId
							INNER JOIN @contractBasisPriceTable SCLC
								ON CTD.intContractDetailId = SCLC.intContractDetailId
							WHERE SC.intTicketId = @intTicketId
								AND (CTH.intPricingTypeId = 2 OR CTH.intPricingTypeId = 3)

							--- LOOP iterator
							BEGIN
								IF NOT EXISTS(SELECT TOP 1 1 
												FROM #tmpLoadBasisContractUsed
												WHERE intTicketLoadUsedId > @_intTicketLoadUsedId
												ORDER BY intTicketLoadUsedId)
								BEGIN
									SET @_intTicketLoadUsedId = NULL
								END 
								ELSE
								BEGIN
									SELECT TOP 1 
										@_intTicketLoadUsedId = intTicketLoadUsedId
										,@_dblQty = dblQty
										,@_intContractDetailId = intContractDetailId
										,@_intLoadDetailId = intLoadDetailId
									FROM #tmpLoadBasisContractUsed
									WHERE intTicketLoadUsedId > @_intTicketLoadUsedId
									ORDER BY intTicketLoadUsedId
								END
							END
						END

						
					END
				END

				----CONTRACT
				BEGIN
					--NON BASIS/HTA CONTRACT
					BEGIN
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
							,intLoadDetailId
						)
						SELECT 
							[strTransactionType] = 'Invoice'
							,[strType] = 'Standard'
							,[strSourceTransaction] = 'Ticket Management'
							,[intSourceId] = SC.intTicketId
							,[strSourceId] = ''
							,[intInvoiceId] = NULL --NULL Value will create new invoice
							,[intEntityCustomerId] = SCContract.intEntityId
							,[intCompanyLocationId] = SC.intProcessingLocationId
							,[intCurrencyId] = CTD.intCurrencyId
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
							,[intOrderUOMId] = CTD.intItemUOMId
							,[intItemUOMId]  = SC.intItemUOMIdTo
							,[dblQtyOrdered] = CTD.dblOriginalQty
							,[dblQtyShipped] = SCContract.dblScheduleQty
							,[dblDiscount] = 0
							,[dblPrice] = ISNULL(CTD.dblCashPrice,0)
							,[ysnRefreshPrice] = 0
							,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(SCContract.intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
							,[ysnRecomputeTax] = 1
							,[intContractDetailId] = CTD.intContractDetailId
							,[intTicketId] = SC.intTicketId
							,[intDestinationGradeId] = SC.intGradeId
							,[intDestinationWeightId] = SC.intWeightId
							,intLoadDetailId = NULL
						FROM tblSCTicket SC
						INNER JOIN tblSCTicketContractUsed SCContract
							ON SC.intTicketId = SCContract.intTicketId
						INNER JOIN tblARCustomer AR 
							ON AR.intEntityId = SCContract.intEntityId
						LEFT JOIN tblEMEntityLocation EM 
							ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
						INNER JOIN tblICItem ICI 
							ON ICI.intItemId = SC.intItemId		
						INNER JOIN tblCTContractDetail CTD 
							ON CTD.intContractDetailId = SCContract.intContractDetailId
						INNER JOIN tblCTContractHeader CTH
							ON CTD.intContractHeaderId = CTH.intContractHeaderId
						WHERE SC.intTicketId = @intTicketId	
							AND CTH.intPricingTypeId <> 2 
							AND CTH.intPricingTypeId <> 3
					END

					--BASIS/HTA CONTRACT
					BEGIN

						IF OBJECT_ID('tempdb..#tmpBasisContractUsed') IS NOT NULL DROP TABLE #tmpBasisContractUsed

						SELECT
							intTicketContractUsed 
							,SCC.dblScheduleQty
							,SCC.intContractDetailId
						INTO #tmpBasisContractUsed
						FROM tblSCTicket SC 
						INNER JOIN tblSCTicketContractUsed SCC
							ON SC.intTicketId = SCC.intTicketId
						INNER JOIN tblCTContractDetail CTD
							ON SCC.intContractDetailId = CTD.intContractDetailId
						INNER JOIN tblCTContractHeader CTH
							ON CTD.intContractHeaderId = CTH.intContractHeaderId
						WHERE SC.intTicketId = @intTicketId
							AND (CTH.intPricingTypeId = 2 OR CTH.intPricingTypeId = 3)
						ORDER BY intTicketContractUsed

						SET @_intTicketContractUsed = NULL
						SELECT TOP 1 
							@_intTicketContractUsed = intTicketContractUsed
							,@_dblQty = dblScheduleQty
							,@_intContractDetailId = intContractDetailId
						FROM #tmpBasisContractUsed
						ORDER BY intTicketContractUsed

						WHILE ISNULL(@_intTicketContractUsed,0) > 0
						BEGIN

							INSERT INTO @contractBasisPriceTable (
								intContractDetailId 
								,intPriceFixationDetailId
								,dblQuantity 
								,dblPrice 
							)
							EXEC uspSCGetAndAllocateBasisContractUnits @_dblQty,@_intContractDetailId


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
								,intLoadDetailId
								,intPriceFixationDetailId
							)
							SELECT 
								[strTransactionType] = 'Invoice'
								,[strType] = 'Standard'
								,[strSourceTransaction] = 'Ticket Management'
								,[intSourceId] = SC.intTicketId
								,[strSourceId] = ''
								,[intInvoiceId] = NULL --NULL Value will create new invoice
								,[intEntityCustomerId] = SCContract.intEntityId
								,[intCompanyLocationId] = SC.intProcessingLocationId
								,[intCurrencyId] = CTD.intCurrencyId
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
								,[intOrderUOMId] = CTD.intItemUOMId
								,[intItemUOMId]  = SC.intItemUOMIdTo
								,[dblQtyOrdered] = CTD.dblOriginalQty
								,[dblQtyShipped] = SCBC.dblQuantity
								,[dblDiscount] = 0
								,[dblPrice] = SCBC.dblPrice
								,[ysnRefreshPrice] = 0
								,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(SCContract.intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
								,[ysnRecomputeTax] = 1
								,[intContractDetailId] = CTD.intContractDetailId
								,[intTicketId] = SC.intTicketId
								,[intDestinationGradeId] = SC.intGradeId
								,[intDestinationWeightId] = SC.intWeightId
								,intLoadDetailId = NULL
								,intPriceFixationDetailId
							FROM tblSCTicket SC
							INNER JOIN tblSCTicketContractUsed SCContract
								ON SC.intTicketId = SCContract.intTicketId
							INNER JOIN @contractBasisPriceTable SCBC
								ON SCContract.intContractDetailId = SCBC.intContractDetailId
							INNER JOIN tblARCustomer AR 
								ON AR.intEntityId = SCContract.intEntityId
							LEFT JOIN tblEMEntityLocation EM 
								ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
							INNER JOIN tblICItem ICI 
								ON ICI.intItemId = SC.intItemId		
							INNER JOIN tblCTContractDetail CTD 
								ON CTD.intContractDetailId = SCContract.intContractDetailId
							INNER JOIN tblCTContractHeader CTH
								ON CTD.intContractHeaderId = CTH.intContractHeaderId
							WHERE SC.intTicketId = @intTicketId	
								AND (CTH.intPricingTypeId = 2 OR CTH.intPricingTypeId = 3)

							--- LOOP iterator
							BEGIN
								IF NOT EXISTS(SELECT TOP 1 1 
												FROM #tmpBasisContractUsed
												WHERE intTicketContractUsed > @_intTicketContractUsed
												ORDER BY intTicketContractUsed)
								BEGIN
									SET @_intTicketContractUsed = NULL
								END 
								ELSE
								BEGIN
									SELECT TOP 1 
										@_intTicketContractUsed = intTicketContractUsed
										,@_dblQty = dblScheduleQty
										,@_intContractDetailId = intContractDetailId
									FROM #tmpBasisContractUsed
									ORDER BY intTicketContractUsed
								END
							END
						END
					END
				END

				----STORAGE (DP ONLY)
				BEGIN
					---FOR CHECKing RISK PRICE
					BEGIN
						SELECT TOP 1
							@intTicketCommodityId = intCommodityId
						FROM tblSCTicket
						WHERE intTicketId = @intTicketId

						-- Get default futures market and month for the commodity
						EXEC uspSCGetDefaultFuturesMarketAndMonth @intTicketCommodityId, @intFutureMarketId OUTPUT, @intFutureMonthId OUTPUT;
					END

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
						,[intEntityCustomerId] = SCS.intEntityId
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
						,[intOrderUOMId] = SC.intItemUOMIdTo
						,[intItemUOMId]  = SC.intItemUOMIdTo
						,[dblQtyOrdered] = SCS.dblQty
						,[dblQtyShipped] = SCS.dblQty
						,[dblDiscount] = 0
						,[dblPrice] = (SELECT TOP 1 
											ISNULL(dblSettlementPrice,0) + ISNULL(dblBasis,0)
										FROM dbo.fnRKGetFutureAndBasisPrice(1,@intTicketCommodityId,SeqMonth.strSeqMonth,3,@intFutureMarketId,@intFutureMonthId,SC.intProcessingLocationId,null,0,SC.intItemId,null))
						,[ysnRefreshPrice] = 0
						,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(SCS.intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
						,[ysnRecomputeTax] = 1
						,[intContractDetailId] = SCS.intContractDetailId
						,[intTicketId] = SC.intTicketId
						,[intDestinationGradeId] = SC.intGradeId
						,[intDestinationWeightId] = SC.intWeightId
					FROM tblSCTicket SC
					INNER JOIN tblSCTicketStorageUsed SCS
						ON SC.intTicketId = SCS.intTicketId
					INNER JOIN tblICItem ICI 
						ON ICI.intItemId = SC.intItemId
					INNER JOIN tblSCScaleSetup SCSetup 
						ON SCSetup.intScaleSetupId = SC.intScaleSetupId
					INNER JOIN tblICItemUOM ICUOM
						ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
					LEFT JOIN tblEMEntityLocation EM 
						ON EM.intEntityId = SCS.intEntityId AND ysnDefaultLocation = 1
					INNER JOIN tblGRStorageType GRT
						ON GRT.intStorageScheduleTypeId = SCS.intStorageTypeId
					OUTER APPLY(
						SELECT	
							strSeqMonth = RIGHT(CONVERT(varchar, dtmEndDate, 106),8)
						FROM	tblCTContractDetail 
						WHERE	intContractDetailId = SCS.intContractDetailId 
					) SeqMonth
					WHERE SC.intTicketId = @intTicketId
				END

				----SPOT
				BEGIN
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
						,[intEntityCustomerId] = SCSpot.intEntityId
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
						,[intOrderUOMId] = SC.intItemUOMIdTo
						,[intItemUOMId]  = SC.intItemUOMIdTo
						,[dblQtyOrdered] = SCSpot.dblQty
						,[dblQtyShipped] = SCSpot.dblQty
						,[dblDiscount] = 0
						,[dblPrice] = ISNULL(SCSpot.dblUnitFuture,0) + ISNULL(SCSpot.dblUnitBasis,0)
						,[ysnRefreshPrice] = 0
						,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(SCSpot.intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
						,[ysnRecomputeTax] = 1
						,[intContractDetailId] = NULL
						,[intTicketId] = SC.intTicketId
						,[intDestinationGradeId] = SC.intGradeId
						,[intDestinationWeightId] = SC.intWeightId
					FROM tblSCTicket SC
					INNER JOIN tblSCTicketSpotUsed SCSpot
						ON SC.intTicketId = SCSpot.intTicketId
					LEFT JOIN tblARCustomer AR ON AR.intEntityId = SCSpot.intEntityId
					LEFT JOIN tblEMEntityLocation EM 
						ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
					LEFT JOIN tblICItem ICI 
						ON ICI.intItemId = SC.intItemId		
					WHERE SC.intTicketId = @intTicketId
				END
			END

			DELETE FROM @invoiceItemIntegrationStagingTable 
			INSERT INTO @invoiceItemIntegrationStagingTable (
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
				,intLoadDetailId
			)
			SELECT  
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
				,intLoadDetailId
			FROM @invoiceIntegrationStagingTable
			
		END

		--FOR FREIGHT CHARGES
		BEGIN


			---LOAD
			IF(@intTicketStorageScheduleTypeId = -6)
			BEGIN
			
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
					,[intEntityCustomerId] = Staging.intEntityCustomerId
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
					,[intOrderUOMId]= LDCTC.intItemUOMId
					,[intItemUOMId] = LDCTC.intItemUOMId
					,[dblQtyOrdered] = Staging.dblQtyOrdered 
					,[dblQtyShipped] = Staging.dblQtyShipped 
					,[dblDiscount] = 0
					,[dblPrice] = LDCTC.dblRate 
					,[ysnRefreshPrice] = 0
					,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(Staging.intEntityCustomerId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,[ysnRecomputeTax] = 1
					,[intContractDetailId] = Staging.intContractDetailId
					,[intTicketId] = SC.intTicketId
					,[intDestinationGradeId] = SC.intGradeId
					,[intDestinationWeightId] = SC.intWeightId
				FROM tblSCTicket SC
				INNER JOIN @invoiceItemIntegrationStagingTable Staging
					ON SC.intTicketId = Staging.intSourceId
				INNER JOIN tblSCScaleSetup SCS 
					ON SCS.intScaleSetupId = SC.intScaleSetupId
				LEFT JOIN tblARCustomer AR 
					ON AR.intEntityId = Staging.intEntityCustomerId
				LEFT JOIN tblEMEntityLocation EM 
					ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
				INNER JOIN tblICItem ICI 
					ON ICI.intItemId = SCS.intFreightItemId	
				------******* START Load Contract Cost *****----------------
				INNER JOIN tblLGLoadDetail LD
					ON SC.intLoadDetailId = LD.intLoadDetailId
				INNER JOIN tblCTContractDetail LDCT
					ON LD.intSContractDetailId = LDCT.intContractDetailId
				INNER JOIN tblCTContractCost LDCTC
					ON LDCT.intContractDetailId = LDCTC.intContractDetailId
						AND LDCTC.intItemId = SCS.intFreightItemId
				INNER JOIN tblICItemUOM LDCTCITM		
					ON LDCTCITM.intItemUOMId = LDCTC.intItemUOMId
				------******* END Load Contract Cost *****----------------
				WHERE SC.intTicketId = @intTicketId 
					AND LDCTC.dblRate != 0
					AND LDCTC.ysnPrice = 1
			END
			---CONTRACT
			ELSE IF (@intTicketStorageScheduleTypeId = -2)
			BEGIN
			
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
					,[intEntityCustomerId] = Staging.intEntityCustomerId
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
					,[intOrderUOMId]= CTDC.intItemUOMId
					,[intItemUOMId] = CTDC.intItemUOMId
					,[dblQtyOrdered] = Staging.dblQtyOrdered 
					,[dblQtyShipped] = Staging.dblQtyShipped 
					,[dblDiscount] = 0
					,[dblPrice] = SC.dblFreightRate
					,[ysnRefreshPrice] = 0
					,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(Staging.intEntityCustomerId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,[ysnRecomputeTax] = 1
					,[intContractDetailId] = Staging.intContractDetailId
					,[intTicketId] = SC.intTicketId
					,[intDestinationGradeId] = SC.intGradeId
					,[intDestinationWeightId] = SC.intWeightId
				FROM tblSCTicket SC
				INNER JOIN @invoiceItemIntegrationStagingTable Staging
					ON SC.intTicketId = Staging.intSourceId
				INNER JOIN tblSCTicketContractUsed SCC
					ON SC.intTicketId = SCC.intTicketId
				INNER JOIN tblSCScaleSetup SCS 
					ON SCS.intScaleSetupId = SC.intScaleSetupId
				LEFT JOIN tblARCustomer AR 
					ON AR.intEntityId = Staging.intEntityCustomerId
				LEFT JOIN tblEMEntityLocation EM 
					ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
				INNER JOIN tblICItem ICI 
					ON ICI.intItemId = SCS.intFreightItemId	
				------******* START Contract Cost *****----------------
				INNER JOIN tblCTContractDetail CTD
					ON SC.intContractId = CTD.intContractDetailId
				INNER JOIN tblCTContractCost CTDC
					ON CTD.intContractDetailId = CTDC.intContractDetailId
						AND CTDC.intItemId = SCS.intFreightItemId
				INNER JOIN tblICItemUOM CTCITM		
					ON CTCITM.intItemUOMId = CTDC.intItemUOMId
				------******* END Contract Cost *****----------------
				WHERE SC.intTicketId = @intTicketId 
					AND SC.dblFreightRate != 0
					AND SC.dblFreightRate IS NOT NULL
					AND ysnFarmerPaysFreight = 1
			END
			---OTHERS
			ELSE 
			BEGIN
			
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
					,[intEntityCustomerId] = Staging.intEntityCustomerId
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
					,[intOrderUOMId]= ICUOM.intItemUOMId
					,[intItemUOMId] = ICUOM.intItemUOMId
					,[dblQtyOrdered] = Staging.dblQtyOrdered 
					,[dblQtyShipped] = Staging.dblQtyShipped 
					,[dblDiscount] = 0
					,[dblPrice] = SC.dblFreightRate
					,[ysnRefreshPrice] = 0
					,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(Staging.intEntityCustomerId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,[ysnRecomputeTax] = 1
					,[intContractDetailId] = Staging.intContractDetailId
					,[intTicketId] = SC.intTicketId
					,[intDestinationGradeId] = SC.intGradeId
					,[intDestinationWeightId] = SC.intWeightId
				FROM tblSCTicket SC
				INNER JOIN @invoiceItemIntegrationStagingTable Staging
					ON SC.intTicketId = Staging.intSourceId
				INNER JOIN tblSCTicketContractUsed SCC
					ON SC.intTicketId = SCC.intTicketId
				INNER JOIN tblSCScaleSetup SCS 
					ON SCS.intScaleSetupId = SC.intScaleSetupId
				INNER JOIN tblICItemUOM SCITMUOM
					ON SC.intItemUOMIdTo = SCITMUOM.intItemUOMId
				LEFT JOIN tblARCustomer AR 
					ON AR.intEntityId = Staging.intEntityCustomerId
				LEFT JOIN tblEMEntityLocation EM 
					ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
				INNER JOIN tblICItem ICI 
					ON ICI.intItemId = SCS.intFreightItemId	
				INNER JOIN tblICItemUOM ICUOM
					ON ICI.intItemId = ICUOM.intItemId
						AND ICUOM.intUnitMeasureId =  SCITMUOM.intUnitMeasureId
				WHERE SC.intTicketId = @intTicketId 
					AND SC.dblFreightRate != 0
					AND SC.dblFreightRate IS NOT NULL
					AND ysnFarmerPaysFreight = 1
			END
		END

		--FOR FEE CHARGES
		BEGIN
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
				,[intEntityCustomerId] = Staging.intEntityCustomerId
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
				,[dblQtyOrdered] = Staging.dblQtyOrdered
				,[dblQtyShipped] = Staging.dblQtyShipped
				,[dblDiscount] = 0
				,[dblPrice] = SC.dblTicketFees
				,[ysnRefreshPrice] = 0
				,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(Staging.intEntityCustomerId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,[ysnRecomputeTax] = 1
				,[intContractDetailId] = Staging.intContractDetailId
				,[intTicketId] = SC.intTicketId
				,[intDestinationGradeId] = SC.intGradeId
				,[intDestinationWeightId] = SC.intWeightId
			FROM tblSCTicket SC
			INNER JOIN @invoiceItemIntegrationStagingTable Staging
				ON SC.intTicketId = Staging.intSourceId
			INNER JOIN tblSCScaleSetup SCS 
				ON SCS.intScaleSetupId = SC.intScaleSetupId
			LEFT JOIN tblARCustomer AR 
				ON AR.intEntityId = Staging.intEntityCustomerId
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
			INNER JOIN tblICItem ICI 
				ON ICI.intItemId = SCS.intDefaultFeeItemId		
			WHERE SC.intTicketId = @intTicketId AND SC.dblTicketFees != 0
		END

		--FOR DISCOUNT
		BEGIN
			---Amount
			BEGIN
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
					,[dblQtyOrdered] = 1
					,[dblQtyShipped] = 1
					,[dblDiscount] = 0
					,[dblPrice] = dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis))) * -1
					,[ysnRefreshPrice] = 0
					,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,[ysnRecomputeTax] = 1
					,[intContractDetailId] = SC.intContractId
					,[intTicketId] = SC.intTicketId
					,[intDestinationGradeId] = SC.intGradeId
					,[intDestinationWeightId] = SC.intWeightId
				FROM tblSCTicket SC
				INNER JOIN tblQMTicketDiscount QM 
					ON QM.intTicketId = SC.intTicketId
				INNER JOIN tblGRDiscountScheduleCode GR 
					ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
				INNER JOIN tblARCustomer AR 
					ON AR.intEntityId = SC.intEntityId
				INNER JOIN tblEMEntityLocation EM 
					ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
				INNER JOIN tblICItem ICI 
					ON ICI.intItemId = GR.intItemId		
				LEFT JOIN tblICItemUOM UM 
					ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
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
					AND QM.strSourceType = 'Scale'
					AND QM.dblDiscountAmount <> 0
					AND ICI.strCostMethod = 'Amount' 
			END

			---Per UNIT
			BEGIN
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
					,[intEntityCustomerId] = Staging.intEntityCustomerId
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
					,[dblQtyOrdered] = Staging.dblQtyOrdered
					,[dblQtyShipped] = Staging.dblQtyShipped
					,[dblDiscount] = 0
					,[dblPrice] = QM.dblDiscountAmount
					,[ysnRefreshPrice] = 0
					,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(Staging.intEntityCustomerId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,[ysnRecomputeTax] = 1
					,[intContractDetailId] = Staging.intContractDetailId
					,[intTicketId] = SC.intTicketId
					,[intDestinationGradeId] = SC.intGradeId
					,[intDestinationWeightId] = SC.intWeightId
				FROM tblSCTicket SC
				INNER JOIN @invoiceItemIntegrationStagingTable Staging
					ON SC.intTicketId = Staging.intSourceId
				INNER JOIN tblQMTicketDiscount QM 
					ON QM.intTicketId = SC.intTicketId
				INNER JOIN tblGRDiscountScheduleCode GR 
					ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
				INNER JOIN tblARCustomer AR 
					ON AR.intEntityId = SC.intEntityId
				INNER JOIN tblEMEntityLocation EM 
					ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
				INNER JOIN tblICItem ICI 
					ON ICI.intItemId = GR.intItemId		
				INNER JOIN tblICItemUOM UM 
					ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
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
					AND QM.strSourceType = 'Scale'
					AND QM.dblDiscountAmount <> 0
					AND ICI.strCostMethod = 'Per Unit' 
			END
			
		END
	END

	---CREATE INVOICE
	BEGIN
		SELECT TOP 1 @recCount = COUNT(1) FROM @invoiceIntegrationStagingTable;
		
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

			IF (EXISTS(SELECT TOP 1 1 FROM #tmpSCContractPrice) AND EXISTS(SELECT TOP 1 1 FROM @invoiceIntegrationStagingTable))
			BEGIN
				/* INSERT tblCTPriceFixationDetailAPAR */
				
				INSERT INTO tblCTPriceFixationDetailAPAR (
					intPriceFixationDetailId
					, intInvoiceId
					, intInvoiceDetailId
					, intConcurrencyId
				)
				SELECT intPriceFixationDetailId = PRICE.intPriceFixationDetailId
					, intInvoiceId				= ID.intInvoiceId
					, intInvoiceDetailId		= ID.intInvoiceDetailId
					, intConcurrencyId			= 1
				FROM tblARInvoiceDetail ID
				INNER JOIN #tmpSCContractPrice PRICE 
					ON ID.intContractDetailId = PRICE.intContractDetailId 
						AND ID.dblPrice = PRICE.dblPrice
				WHERE ID.intInvoiceId = @intInvoiceId
				/*Fixes for CT-5248 (Direct Out ticket does not have create IS)*/
				--AND ID.intInventoryShipmentItemId IS NOT NULL
					AND ID.intInventoryShipmentChargeId IS NULL
				
			END

			EXEC uspARReComputeInvoiceAmounts @intInvoiceId

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
	END

	----GENERATE 3RD PARTY PAYABLES
	BEGIN

		EXEC uspSCGenerate3PartyDirectOutPayables 
			@DirectInvoiceLineItem = @invoiceItemIntegrationStagingTable 
			,@intTicketId = @intTicketId
			,@intUserId = @intUserId

	END

_Exit:
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
GO
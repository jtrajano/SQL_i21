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
	,dblQuantity numeric(18,6)
	,dblPrice numeric(18,6)
)


BEGIN TRY
	SELECT 
		@_dblRemainingNetUnits = dblNetUnits
		, @_intPricingTypeId = CD.intPricingTypeId 
		,@intContractHeaderPricingTypeId = CH.intPricingTypeId
		,@intTicketContractDetailId = SC.intContractId
		,@intTicketContractHeaderId = CH.intContractHeaderId
		,@ysnDestinationationWGPosted = ysnDestinationWeightGradePost
		,@_intTicketId = SC.intTicketId
		,@strWhereFinalizedWeight = strWeightFinalized
		,@strWhereFinalizedGrade = strGradeFinalized
	FROM vyuSCTicketScreenView SC
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractId
	INNER JOIN tblCTContractHeader CH	
		ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE SC.intTicketId = @intTicketId

	-- IF(@_intPricingTypeId = 2)
	-- BEGIN
	-- 	INSERT INTO @tblPriceContractAvailableFixation
	-- 	SELECT CT.intContractDetailId, SC.intTicketId, SC.dblNetUnits,CTP.intPriceFixationDetailId,SUM(ISNULL(CTP.dblQuantity,0)) dblPricedQty, SUM(ISNULL(ARID.dblQtyShipped,0)) as dblQtyShipped, SUM(ISNULL(CTP.dblQuantity,0)) - SUM(ISNULL(ARID.dblQtyShipped,0)) dblPricedAvailableQty,CTP.dblCashPrice,CTP.dtmFixationDate FROM vyuCTPriceContractFixationDetail CTP
	-- 	INNER JOIN tblCTPriceFixation CPX
	-- 		ON CPX.intPriceFixationId = CTP.intPriceFixationId
	-- 	INNER JOIN tblCTContractDetail CT
	-- 		ON CPX.intContractDetailId = CT.intContractDetailId
	-- 	INNER JOIN tblSCTicket SC
	-- 		ON SC.intContractId = CT.intContractDetailId
	-- 	LEFT JOIN tblCTPriceFixationDetailAPAR APAR
	-- 		ON APAR.intPriceFixationDetailId = CTP.intPriceFixationDetailId
	-- 	LEFT JOIN tblARInvoiceDetail ARID
	-- 		ON ARID.intInvoiceDetailId = APAR.intInvoiceDetailId
	-- 	WHERE SC.intTicketId = @intTicketId
	-- 	GROUP BY CT.intContractDetailId, CTP.intPriceFixationDetailId, CTP.dblCashPrice,CTP.dtmFixationDate, SC.dblNetUnits, SC.intTicketId
	-- 	ORDER BY CTP.dtmFixationDate;
	-- END


	IF(@intContractHeaderPricingTypeId = 2)
	BEGIN
		INSERT INTO #tmpSCContractPrice
		EXEC uspCTGetContractPrice @intTicketContractHeaderId,@intTicketContractDetailId, @_dblRemainingNetUnits, 'Invoice'
	END



	IF((ISNULL(@strWhereFinalizedWeight,'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedGrade,'Origin') = 'Destination') AND ISNULL(@ysnDestinationationWGPosted,0) = 0)
	BEGIN
		GOTO _Exit
	END

	--Priced Basis
	IF @intContractHeaderPricingTypeId = 2
	BEGIN	
		IF(ISNULL((SELECT SUM(dblQuantity) FROM #tmpSCContractPrice),0) <  @_dblRemainingNetUnits)	
		BEGIN
			GOTO _Exit
		END
		
		--FOR LINE ITEM
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
									WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, CP.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis))) * -1)
									WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, CP.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblUnitPrice + SC.dblUnitBasis)))
								END
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
				AND QM.dblDiscountAmount <> 0
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
			AND ID.intInventoryShipmentItemId IS NOT NULL
			AND ID.intInventoryShipmentChargeId IS NULL
			
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
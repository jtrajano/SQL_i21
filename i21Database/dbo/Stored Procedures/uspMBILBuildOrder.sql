CREATE PROCEDURE [dbo].[uspMBILBuildOrder]
	@intDriverId		AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

-- ++++++ CLEAN-OUT DRIVER's ORDER LIST ++++++ --
DELETE tblMBILOrder WHERE intDriverId = @intDriverId
DELETE tblMBILOrderSite WHERE intDriverId = @intDriverId


-- ++++++ CREATE DRIVER's ORDER LIST ++++++ --
INSERT INTO tblMBILOrder
					SELECT * FROM (
									SELECT 
										intOrderId = A.intDispatchID
										,A.strOrderNumber
										,strOrderStatus = A.strWillCallStatus
										,A.dtmRequestedDate
										,strCustomerNumber = D.strEntityNo
										,D.intEntityId
										,intUserId = A.intUserID
										,strUser = I.strUserName
										,intSiteId = B.intSiteID
										,B.intSiteNumber
										,B.strDescription as strSiteName
										,E.intItemId
										,E.strItemNo
										,E.strDescription as strItemDescription
										,M.intItemUOMId
										,dblQuantity = CASE WHEN ISNULL(A.dblMinimumQuantity,0) = 0 THEN A.dblQuantity ELSE A.dblMinimumQuantity END
										,A.dblPrice
										,F.intContractSeq
										,F.intContractDetailId
										,G.strContractNumber		
										,intTermId = H.intTermID
										,strTermId = H.strTerm
										,A.strComments	
										,intDriverId = A.intDriverID
										,strDriver = J.strEntityNo	
										,intRouteId = K.intRouteId
										,K.strRouteNumber
										,intStopNumber = L.intSequence
										,B.intTaxStateID	
										,N.intShipToId	
										,B.strLocation
										,B.intLocationId
										,O.intFreightTermId
										,Q.strSerialNumber
										,Q.dblTankCapacity
										,intConcurrencyId = A.intConcurrencyId

									FROM tblTMDispatch A
									INNER JOIN tblTMSite B
										ON A.intSiteID = B.intSiteID
									INNER JOIN tblTMCustomer C
										ON B.intCustomerID = C.intCustomerID 
									INNER JOIN tblEMEntity D
										ON C.intCustomerNumber = D.intEntityId
									INNER JOIN tblICItem E
										ON B.intProduct = E.intItemId
									LEFT JOIN vyuCTContractSequence F
										ON A.intContractId = F.intContractDetailId
									LEFT JOIN tblCTContractHeader G
										ON F.intContractHeaderId = G.intContractHeaderId
									LEFT JOIN tblSMTerm H
										ON A.intDeliveryTermID = H.intTermID
									LEFT JOIN tblSMUserSecurity I
										ON A.intUserID = I.intEntityId
									LEFt JOIN tblEMEntity J
										ON A.intDriverID = J.intEntityId
									LEFT JOIN tblLGRoute K
										ON A.intRouteId = K.intRouteId
									LEFT JOIN tblLGRouteOrder L
										ON K.intRouteId = L.intRouteId
											AND A.intDispatchID = L.intDispatchID

									LEFT JOIN tblICItemUOM M
										ON M.intItemId = E.intItemId
											AND M.ysnStockUnit = 1
									LEFT JOIN tblARCustomer N
										ON N.strCustomerNumber = D.strEntityNo
									LEFT JOIN tblEMEntityLocation O
										ON O.intEntityLocationId = N.intShipToId

									LEFT JOIN (
										SELECT 
										AA.intSiteID
										,AA.intDeviceId
										,BB.strSerialNumber
										,BB.dblTankCapacity
										,intRecNo = ROW_NUMBER() OVER ( PARTITION BY intSiteID ORDER BY intSiteDeviceID)
										FROM tblTMSiteDevice AA
										INNER JOIN tblTMDevice BB
										ON AA.intDeviceId = BB.intDeviceId
										INNER JOIN tblTMDeviceType CC
										ON CC.intDeviceTypeId = BB.intDeviceTypeId
										WHERE CC.strDeviceType = 'Tank'
										AND BB.ysnAppliance = 0
									) Q
									ON A.intSiteID = Q.intSiteID
										AND intRecNo = 1
						) tblTMOrder 
  
  WHERE tblTMOrder.intDriverId = @intDriverId AND tblTMOrder.strOrderStatus = 'Open'


-- ++++++ CREATE ORDER's SITE LIST ++++++ --
INSERT INTO tblMBILOrderSite
					SELECT 						
						 [intMBILOrderId]		
						,[intOrderId]			
						,[strOrderNumber]		
						,[strOrderStatus]		
						,[dtmRequestedDate]		
						,[strCustomerNumber]		
						,[intEntityId]			
						,[intUserId]				
						,[strUser]				
						,[intSiteId]				
						,[intSiteNumber]			
						,[strSiteName]			
						,[intContractSeq]		
						,[intContractDetailId]	
						,[strContractNumber]		
						,[intTermId]				
						,[strTermId]				
						,[strComments]			
						,[intDriverId]			
						,[strDriver]				
						,[intRouteId]			
						,[strRouteNumber]		
						,[intStopNumber]			
						,[intTaxStateID]			
						,[intShipToId]			
						,[strLocation]			
						,[intLocationId]			
						,[intFreightTermId]		
						,[strSerialNumber]		
						,[dblTankCapacity]		
						,[intConcurrencyId]		
					FROM
					tblMBILOrder where intDriverId = @intDriverId AND strOrderStatus = 'Open'


-- ++++++ CREATE ORDER's ITEM LIST ++++++ --
INSERT INTO tblMBILOrderItem
					SELECT 
						 A.[intMBILOrderSiteId]
						,B.[intOrderId]		
						,B.[strOrderNumber]	
						,B.[strCustomerNumber]	
						,B.[intEntityId]		
						,B.[intUserId]			
						,B.[strUser]			
						,B.[intSiteId]			
						,B.[intSiteNumber]		
						,B.[strSiteName]		
						,B.[intItemId]			
						,B.[strItemNo]			
						,B.[strItemDescription]
						,B.[intItemUOMId]		
						,B.[dblQuantity]		
						,B.[dblPrice]			
						,B.[intConcurrencyId]	
					FROM
					tblMBILOrderSite A LEFT JOIN tblMBILOrder B ON A.intMBILOrderId = B.intMBILOrderId
					WHERE B.intDriverId = @intDriverId


-- ++++++ ITEM TAX CODE PROCESS ++++++ --
SELECT * INTO #tempDriverOrder FROM (SELECT A.*,B.intMBILOrderItemId FROM tblMBILOrder A LEFT JOIN tblMBILOrderItem B ON A.intOrderId = B.intOrderId WHERE A.intDriverId = @intDriverId) tblOrder


DECLARE  @MBILOrderId					INT				= NULL
		,@ItemId						INT				= NULL
		,@LocationId					INT				= NULL
		,@CustomerId					INT				= NULL	
		,@CustomerLocationId			INT				= NULL	
		,@TransactionDate				DATETIME		= NULL
		,@TaxGroupId					INT				= NULL		
		,@SiteId						INT				= NULL
		,@FreightTermId					INT				= NULL
		,@CardId						INT				= NULL
		,@VehicleId						INT				= NULL
		,@DisregardExemptionSetup		BIT				= 0
		,@ItemUOMId						INT				= NULL
		,@CFSiteId						INT				= NULL
		,@IsDeliver						BIT				= NULL
		,@CurrencyId					INT				= NULL
		,@CurrencyExchangeRateTypeId	INT				= NULL
		,@CurrencyExchangeRate			NUMERIC(18,6)	= NULL



CREATE TABLE #tempOrderTaxCode (
	[intTransactionDetailTaxId]	INT
	,[intInvoiceDetailId]		INT
	,[intTaxGroupMasterId]		INT
	,[intTaxGroupId]			INT
	,[intTaxCodeId]				INT
	,[intTaxClassId]			INT
	,[strTaxableByOtherTaxes]	NVARCHAR(MAX)
	,[strCalculationMethod]		NVARCHAR(MAX)
	,[dblRate]					NUMERIC(18, 6)
	,[dblBaseRate]				NUMERIC(18, 6)
	,[dblExemptionPercent]		NUMERIC(18, 6)
	,[dblTax]					NUMERIC(18, 6)
	,[dblAdjustedTax]			NUMERIC(18, 6)
	,[dblBaseAdjustedTax]		NUMERIC(18, 6)
	,[intSalesTaxAccountId]		INT
	,[ysnSeparateOnInvoice]		BIT
	,[ysnCheckoffTax]			BIT
	,[strTaxCode]				NVARCHAR(MAX)
	,[ysnTaxExempt]				BIT
	,[ysnTaxOnly]				BIT
	,[ysnInvalidSetup]			BIT
	,[strTaxGroup]				NVARCHAR(MAX)
	,[strNotes]					NVARCHAR(MAX)
	,[intUnitMeasureId]			INT
	,[strUnitMeasure]			NVARCHAR(MAX)
);

WHILE EXISTS(SELECT 1 FROM #tempDriverOrder)
BEGIN
	
	SELECT TOP 1 @MBILOrderId					= [intMBILOrderItemId]
				,@ItemId						= [intItemId]
				,@LocationId					= [intLocationId]
				,@CustomerId					= [intEntityId]
				,@CustomerLocationId			= [intShipToId]
				,@TransactionDate				= GETDATE()
				,@TaxGroupId					= [intTaxStateID]
				,@SiteId						= [intSiteId]
				,@FreightTermId					= NULL
				,@CardId						= NULL
				,@VehicleId						= NULL
				,@DisregardExemptionSetup		= 0
				,@ItemUOMId						= [intItemUOMId]
				,@CFSiteId						= NULL
				,@IsDeliver						= NULL
				,@CurrencyId					= NULL
				,@CurrencyExchangeRateTypeId	= NULL
				,@CurrencyExchangeRate			= NULL
			FROM #tempDriverOrder

	INSERT INTO #tempOrderTaxCode ([intTransactionDetailTaxId]
									,[intInvoiceDetailId]
									,[intTaxGroupMasterId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblBaseRate]
									,[dblExemptionPercent]
									,[dblTax]
									,[dblAdjustedTax]
									,[dblBaseAdjustedTax]
									,[intSalesTaxAccountId]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[strTaxCode]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[ysnInvalidSetup]
									,[strTaxGroup]
									,[strNotes]
									,[intUnitMeasureId]
									,[strUnitMeasure])
	EXEC uspARGetItemTaxes @ItemId
						  ,@LocationId
						  ,@CustomerId
						  ,@CustomerLocationId
						  ,@TransactionDate
						  ,@TaxGroupId
						  ,@SiteId
						  ,@FreightTermId
						  ,@CardId
						  ,@VehicleId
						  ,@DisregardExemptionSetup
						  ,@ItemUOMId
						  ,@CFSiteId
						  ,@IsDeliver
						  ,@CurrencyId
						  ,@CurrencyExchangeRateTypeId
						  ,@CurrencyExchangeRate


	INSERT INTO tblMBILOrderTaxCode ([intMBILOrderItemId]
									,[intItemId]
									,[intTransactionDetailTaxId]
									,[intInvoiceDetailId]
									,[intTaxGroupMasterId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblExemptionPercent]
									,[dblTax]
									,[dblAdjustedTax]
									,[dblBaseAdjustedTax]
									,[intSalesTaxAccountId]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[strTaxCode]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[ysnInvalidSetup]
									,[strTaxGroup]
									,[strNotes]
									,[intUnitMeasureId]
									,[strUnitMeasure])

	SELECT							 @MBILOrderId
									,@ItemId
									,[intTransactionDetailTaxId]
									,[intInvoiceDetailId]
									,[intTaxGroupMasterId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblExemptionPercent]
									,[dblTax]
									,[dblAdjustedTax]
									,[dblBaseAdjustedTax]
									,[intSalesTaxAccountId]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[strTaxCode]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[ysnInvalidSetup]
									,[strTaxGroup]
									,[strNotes]
									,[intUnitMeasureId]
									,[strUnitMeasure]
			FROM #tempOrderTaxCode

	DELETE #tempOrderTaxCode
	DELETE #tempDriverOrder WHERE intMBILOrderItemId = @MBILOrderId
END

--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspMBILBuildOrder] 125

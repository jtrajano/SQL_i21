CREATE PROCEDURE [dbo].[uspCTCreateInvoiceDetail]
	@intInvoiceDetailId		INT,
	@intInventoryShipmentId	INT,
	@intInventoryShipmentItemId INT,
	@dblQty					NUMERIC(18,6),
	@dblPrice				NUMERIC(18,6),
	@intUserId				INT,
	@intContractHeaderId	INT,
	@intContractDetailId	INT,
	@NewInvoiceDetailId		INT OUTPUT,
	@intPriceFixationDetailId		INT
AS

BEGIN TRY

	DECLARE		@ErrMsg									NVARCHAR(MAX)

	DECLARE		 @ItemId                                INT
				,@ItemPrepayTypeId                      INT
				,@ItemPrepayRate                        NUMERIC(18,6)
				,@ItemIsBlended                         BIT				= 0
				,@ErrorMessage                          NVARCHAR(250)
				,@RaiseError                            BIT             = 0           
				,@ItemDocumentNumber					NVARCHAR(100)	= NULL               
				,@ItemDescription                       NVARCHAR(500)	= NULL
				,@ItemQtyShipped                        NUMERIC(18,6)	= 0.000000
				,@ItemOrderUOMId                        INT             = NULL
				,@ItemPriceUOMId                        INT             = NULL
				,@ItemQtyOrdered                        NUMERIC(18,6)	= 0.000000
				,@ItemUnitQuantity                      NUMERIC(18,6)	= 1.000000
				,@ItemDiscount                          NUMERIC(18,6)	= 0.000000
				,@ItemTermDiscount                      NUMERIC(18,6)	= 0.000000
				,@ItemTermDiscountBy					NVARCHAR(50)	= NULL
				,@ItemUnitPrice                         NUMERIC(18,6)	= 0.000000    
				,@ItemPricing                           NVARCHAR(250)	= NULL
				,@ItemVFDDocumentNumber                 NVARCHAR(100)	= NULL
				,@RefreshPrice                          BIT             = 0
				,@ItemMaintenanceType                   NVARCHAR(50)	= NULL
				,@ItemFrequency                         NVARCHAR(50)    = NULL
				,@ItemMaintenanceDate                   DATETIME        = NULL
				,@ItemMaintenanceAmount                 NUMERIC(18,6)	= 0.000000
				,@ItemLicenseAmount                     NUMERIC(18,6)	= 0.000000
				,@ItemTaxGroupId                        INT             = NULL
				,@ItemStorageLocationId                 INT             = NULL
				,@ItemCompanyLocationSubLocationId		INT             = NULL
				,@RecomputeTax							BIT             = 1
				,@ItemSCInvoiceId						INT             = NULL
				,@ItemSCInvoiceNumber					NVARCHAR(50)	= NULL
				,@ItemInventoryShipmentItemId			INT             = NULL
				,@ItemInventoryShipmentChargeId			INT             = NULL
				,@ItemShipmentNumber					NVARCHAR(50)	= NULL
				,@ItemRecipeItemId						INT             = NULL
				,@ItemRecipeId							INT             = NULL
				,@ItemSublocationId						INT             = NULL
				,@ItemCostTypeId						INT             = NULL
				,@ItemMarginById						INT             = NULL
				,@ItemCommentTypeId						INT             = NULL
				,@ItemMargin							NUMERIC(18,6)	= NULL
				,@ItemRecipeQty							NUMERIC(18,6)	= NULL
				,@ItemSalesOrderDetailId				INT             = NULL                                                                            
				,@ItemSalesOrderNumber                  NVARCHAR(50)	= NULL
				,@ItemContractHeaderId                  INT				= NULL
				,@ItemContractDetailId                  INT				= NULL  
				,@ItemShipmentId                        INT				= NULL               
				,@ItemShipmentPurchaseSalesContractId	INT				= NULL   
				,@ItemWeightUOMId                       INT             = NULL 
				,@ItemWeight                            NUMERIC(18,6)	= 0.000000             
				,@ItemShipmentGrossWt                   NUMERIC(18,6)	= 0.000000             
				,@ItemShipmentTareWt					NUMERIC(18,6)	= 0.000000              
				,@ItemShipmentNetWt                     NUMERIC(18,6)	= 0.000000                   
				,@ItemTicketId                          INT				= NULL        
				,@ItemTicketHoursWorkedId				INT				= NULL 
				,@ItemCustomerStorageId                 INT				= NULL        
				,@ItemSiteDetailId                      INT				= NULL        
				,@ItemLoadDetailId                      INT				= NULL               
				,@ItemLotId                             INT				= NULL               
				,@ItemOriginalInvoiceDetailId			INT				= NULL        
				,@ItemConversionAccountId				INT				= NULL
				,@ItemSalesAccountId					INT				= NULL
				,@ItemSiteId                            INT				= NULL                                                                            
				,@ItemBillingBy                         NVARCHAR(200)	= NULL
				,@ItemPercentFull                       NUMERIC(18,6)	= 0.000000
				,@ItemNewMeterReading                   NUMERIC(18,6)	= 0.000000
				,@ItemPreviousMeterReading				NUMERIC(18,6)	= 0.000000
				,@ItemConversionFactor                  NUMERIC(18,8)	= 0.00000000
				,@ItemPerformerId                       INT				= NULL
				,@ItemLeaseBilling                      BIT             = 0
				,@ItemVirtualMeterReading				BIT             = 0
				,@EntitySalespersonId                   INT             = NULL
				,@ItemCurrencyExchangeRateTypeId		INT             = NULL
				,@ItemCurrencyExchangeRateId			INT             = NULL
				,@ItemCurrencyExchangeRate				NUMERIC(18,8)	= 1.000000
				,@ItemSubCurrencyId                     INT             = NULL
				,@ItemSubCurrencyRate                   NUMERIC(18,8)	= 1.000000
				,@ItemStorageScheduleTypeId				INT             = NULL
				,@ItemDestinationGradeId				INT             = NULL
				,@ItemDestinationWeightId				INT             = NULL
				,@intScaleUOMId							INT  
				,@ItemPrice								NUMERIC(18,8)  
				,@InvoiceId								INT

		SELECT	TOP 1
				 @InvoiceId								= ARD.intInvoiceId
				,@ItemQtyShipped                        = @dblQty
				--,@ItemQtyOrdered                        = (SELECT TOP 1 dblQuantity FROM tblICInventoryShipmentItem WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId)
				,@ItemQtyOrdered                        = CASE WHEN @intContractDetailId IS NOT NULL
																THEN CTD.dblQuantity
																ELSE ICISI.dblQuantity
																END
				,@ItemUnitPrice                         = @dblPrice
				,@ItemPrice								= @dblPrice
				,@ItemInventoryShipmentItemId			= @intInventoryShipmentItemId
				,@ItemShipmentNumber					= (SELECT TOP 1 strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intInventoryShipmentId)
				
				,@ItemContractHeaderId                  = @intContractHeaderId
				,@ItemContractDetailId                  = @intContractDetailId
				,@ItemId								= ARD.intItemId
				,@ItemPrepayTypeId						= ARD.intPrepayTypeId
				,@ItemPrepayRate						= ARD.dblPrepayRate
				,@ItemIsBlended							= ARD.ysnBlended
				,@ItemDocumentNumber					= ARD.strDocumentNumber
				,@ItemDescription						= ARD.strItemDescription            
				,@ItemOrderUOMId						= ARD.intOrderUOMId
				,@ItemPriceUOMId						= ARD.intPriceUOMId          
				,@ItemUnitQuantity						= ARD.dblUnitQuantity
				,@ItemDiscount							= ARD.dblDiscount
				,@ItemTermDiscount						= ARD.dblItemTermDiscount
				,@ItemTermDiscountBy					= ARD.strItemTermDiscountBy      
				,@ItemPricing							= ARD.strPricing
				,@ItemVFDDocumentNumber					= ARD.strVFDDocumentNumber
				,@ItemMaintenanceType					= ARD.strMaintenanceType
				,@ItemFrequency							= ARD.strFrequency
				,@ItemMaintenanceDate					= ARD.dtmMaintenanceDate
				,@ItemMaintenanceAmount					= ARD.dblMaintenanceAmount
				,@ItemLicenseAmount						= ARD.dblLicenseAmount
				,@ItemTaxGroupId						= ARD.intTaxGroupId
				,@ItemStorageLocationId					= ARD.intStorageLocationId
				,@ItemCompanyLocationSubLocationId		= ARD.intCompanyLocationSubLocationId
				,@ItemSCInvoiceId						= ARD.intSCInvoiceId
				,@ItemSCInvoiceNumber					= ARD.strSCInvoiceNumber
				,@ItemInventoryShipmentChargeId			= NULL
				,@ItemRecipeItemId						= ARD.intRecipeItemId
				,@ItemRecipeId							= ARD.intRecipeId
				,@ItemCostTypeId						= ARD.intCostTypeId
				,@ItemMarginById						= ARD.intMarginById
				,@ItemCommentTypeId						= ARD.intCommentTypeId
				,@ItemMargin							= ARD.dblMargin
				,@ItemSalesOrderDetailId				= NULL
				,@ItemSalesOrderNumber					= ''
				,@ItemShipmentId						= NULL
				,@ItemShipmentPurchaseSalesContractId	= NULL
				,@ItemWeight                            = 1
				,@ItemShipmentGrossWt                   = 0.000000
				,@ItemShipmentTareWt					= 0.000000
				,@ItemShipmentNetWt                     = 0.000000           
				,@ItemTicketId                          = ARD.intTicketId
				,@ItemTicketHoursWorkedId				= NULL
				,@ItemCustomerStorageId                 = ARD.intCustomerStorageId
				,@ItemSiteDetailId                      = ARD.intSiteDetailId
				,@ItemLoadDetailId                      = NULL
				,@ItemLotId                             = NULL
				,@ItemOriginalInvoiceDetailId			= NULL
				,@ItemConversionAccountId				= NULL
				,@ItemSalesAccountId					= NULL
				,@ItemSiteId                            = NULL
				,@ItemBillingBy                         = ''
				,@ItemPercentFull                       = 0.000000
				,@ItemNewMeterReading                   = 0.000000
				,@ItemPreviousMeterReading				= 0.000000
				,@ItemConversionFactor                  = 0.00000000
				,@ItemPerformerId                       = NULL
				,@ItemLeaseBilling                      = 0
				,@ItemVirtualMeterReading				= 0
				,@EntitySalespersonId                   = NULL
				,@ItemCurrencyExchangeRateTypeId		= ARD.intCurrencyExchangeRateTypeId
				,@ItemCurrencyExchangeRateId			= ARD.intCurrencyExchangeRateId
				,@ItemCurrencyExchangeRate				= ARD.dblCurrencyExchangeRate
				,@ItemSubCurrencyId                     = ARD.intSubCurrencyId
				,@ItemSubCurrencyRate                   = ARD.dblSubCurrencyRate
				,@ItemStorageScheduleTypeId				= ARD.intStorageScheduleTypeId
				,@ItemDestinationGradeId				= ARD.intDestinationGradeId
				,@ItemDestinationWeightId				= ARD.intDestinationWeightId
				,@ItemWeightUOMId						= ARD.intItemWeightUOMId
		  

		FROM	tblARInvoiceDetail ARD with (nolock) 
				LEFT JOIN
				tblCTContractDetail CTD with (nolock) 
		ON		CTD.intContractDetailId = @intContractDetailId
				LEFT JOIN
				tblICInventoryShipmentItem ICISI with (nolock) 
		ON		ICISI.intInventoryShipmentItemId = @intInventoryShipmentItemId
		WHERE	ARD.intInvoiceDetailId = @intInvoiceDetailId


		EXEC [uspARInsertTransactionDetail] @InvoiceId, @intUserId


		EXEC	[uspARAddItemToInvoice]
				 @InvoiceId                             =	@InvoiceId
				,@ItemId                                =	@ItemId
				,@ItemPrepayTypeId                      =	@ItemPrepayTypeId
				,@ItemPrepayRate                        =	@ItemPrepayRate
				,@ItemIsBlended                         =	@ItemIsBlended
				,@RaiseError                            =	1           
				,@ItemDocumentNumber					=	@ItemDocumentNumber
				,@ItemDescription                       =	@ItemDescription
				,@ItemOrderUOMId                        =	@ItemOrderUOMId
				,@ItemPriceUOMId                        =	@ItemPriceUOMId
				,@ItemQtyOrdered                        =	@ItemQtyOrdered
				,@ItemUOMId                             =	@intScaleUOMId
				,@ItemQtyShipped                        =	@ItemQtyShipped
				,@ItemUnitQuantity                      =	@ItemUnitQuantity
				,@ItemDiscount                          =	@ItemDiscount
				,@ItemTermDiscount                      =	@ItemTermDiscount
				,@ItemTermDiscountBy					=	@ItemTermDiscountBy
				,@ItemPrice                             =	@ItemPrice
				,@ItemUnitPrice                         =	@ItemUnitPrice
				,@ItemPricing                           =	@ItemPricing
				,@ItemVFDDocumentNumber                 =	@ItemVFDDocumentNumber
				,@RefreshPrice                          =	0
				,@ItemMaintenanceType                   =	@ItemMaintenanceType
				,@ItemFrequency                         =	@ItemFrequency
				,@ItemMaintenanceDate                   =	@ItemMaintenanceDate
				,@ItemMaintenanceAmount                 =	@ItemMaintenanceAmount
				,@ItemLicenseAmount                     =	@ItemLicenseAmount
				,@ItemTaxGroupId                        =	@ItemTaxGroupId
				,@ItemStorageLocationId                 =	@ItemStorageLocationId
				,@ItemCompanyLocationSubLocationId		=	@ItemCompanyLocationSubLocationId
				,@RecomputeTax							=	1
				,@ItemSCInvoiceId						=	@ItemSCInvoiceId
				,@ItemSCInvoiceNumber					=	@ItemSCInvoiceNumber
				,@ItemInventoryShipmentItemId			=	@ItemInventoryShipmentItemId
				,@ItemInventoryShipmentChargeId			=	@ItemInventoryShipmentChargeId
				,@ItemShipmentNumber					=	@ItemShipmentNumber
				,@ItemRecipeItemId						=	@ItemRecipeItemId
				,@ItemRecipeId							=	@ItemRecipeId
				,@ItemSublocationId						=	@ItemSublocationId
				,@ItemCostTypeId						=	@ItemCostTypeId
				,@ItemMarginById						=	@ItemMarginById
				,@ItemCommentTypeId						=	@ItemCommentTypeId
				,@ItemMargin							=	@ItemMargin
				,@ItemRecipeQty							=	@ItemRecipeQty
				,@ItemSalesOrderDetailId				=	@ItemSalesOrderDetailId
				,@ItemSalesOrderNumber					=	@ItemSalesOrderNumber
				,@ContractHeaderId						=	@ItemContractHeaderId
				,@ContractDetailId						=	@ItemContractDetailId
				,@ItemShipmentId						=	@ItemShipmentId
				,@ItemShipmentPurchaseSalesContractId	=	@ItemShipmentPurchaseSalesContractId
				,@ItemWeightUOMId                       =	@ItemWeightUOMId
				,@ItemWeight                            =	@ItemWeight
				,@ItemShipmentGrossWt                   =	@ItemShipmentGrossWt
				,@ItemShipmentTareWt					=	@ItemShipmentTareWt
				,@ItemShipmentNetWt                     =	@ItemShipmentNetWt
				,@ItemTicketId                          =	@ItemTicketId
				,@ItemTicketHoursWorkedId				=	@ItemTicketHoursWorkedId
				,@ItemCustomerStorageId                 =	@ItemCustomerStorageId
				,@ItemSiteDetailId                      =	@ItemSiteDetailId
				,@ItemLoadDetailId                      =	@ItemLoadDetailId
				,@ItemLotId                             =	@ItemLotId
				,@ItemOriginalInvoiceDetailId			=	@ItemOriginalInvoiceDetailId
				,@ItemConversionAccountId				=	@ItemConversionAccountId
				,@ItemSalesAccountId					=	@ItemSalesAccountId
				,@ItemSiteId                            =	@ItemSiteId
				,@ItemBillingBy                         =	@ItemBillingBy
				,@ItemPercentFull                       =	@ItemPercentFull
				,@ItemNewMeterReading                   =	@ItemNewMeterReading
				,@ItemPreviousMeterReading				=	@ItemPreviousMeterReading
				,@ItemConversionFactor                  =	@ItemConversionFactor
				,@ItemPerformerId                       =	@ItemPerformerId
				,@ItemLeaseBilling                      =	@ItemLeaseBilling
				,@ItemVirtualMeterReading				=	@ItemVirtualMeterReading
				,@EntitySalespersonId                   =	@EntitySalespersonId
				,@ItemCurrencyExchangeRateTypeId		=	@ItemCurrencyExchangeRateTypeId
				,@ItemCurrencyExchangeRateId			=	@ItemCurrencyExchangeRateId
				,@ItemCurrencyExchangeRate				=	@ItemCurrencyExchangeRate
				,@ItemSubCurrencyId                     =	@ItemSubCurrencyId
				,@ItemSubCurrencyRate                   =	@ItemSubCurrencyRate
				,@ItemStorageScheduleTypeId				=	@ItemStorageScheduleTypeId
				,@ItemDestinationGradeId				=	@ItemDestinationGradeId
				,@ItemDestinationWeightId				=	@ItemDestinationWeightId
				,@NewInvoiceDetailId					=	@NewInvoiceDetailId	OUTPUT

		-- Check if the contract is destination weights and grades
		/*
		IF EXISTS 
		(
			select top 1 1 
			from tblCTContractHeader ch
			inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
				and wg.strWhereFinalized = 'Destination'
			where intContractHeaderId = @intContractHeaderId
		)
		BEGIN
			-- Summary Log
			DECLARE @contractDetails AS [dbo].[ContractDetailTable]
			EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
									@intContractDetailId 	= 	@intContractDetailId,
									@strSource			 	= 	'Pricing',
									@strProcess		 	    = 	'Priced DWG',
									@contractDetail 		= 	@contractDetails,
									@intUserId				= 	@intUserId,
									@intTransactionId		= 	@intPriceFixationDetailId,
									@dblTransactionQty		= 	@ItemQtyShipped
		END		
		*/

		EXEC dbo.uspARUpdateInvoiceIntegrations @InvoiceId = @InvoiceId, @UserId = @intUserId

		EXEC dbo.uspARReComputeInvoiceTaxes @InvoiceId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO

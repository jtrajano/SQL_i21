IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportReceiptandBill')
	DROP PROCEDURE uspGRImportReceiptandBill
GO
CREATE PROCEDURE uspGRImportReceiptandBill
AS
BEGIN TRY
	
	SET NOCOUNT ON
	
	DECLARE @ErrMsg NVARCHAR(MAX)	
	DECLARE @UserId INT
	DECLARE @InventoryReceiptId           INT
	DECLARE @BillId						  INT
	
	DECLARE 
	 @IRelyAdminKey					      INT
	,@intNonScaleTicketKey                INT
	,@intScaleTicketId					  INT
	,@intPricingTypeId				      INT
	,@intStorageScheduleTypeId			  INT
	,@intReceiptStartingId				  INT
	,@strReceiptNumber                    Nvarchar(100)
	,@intBillStartingId					  INT
	,@strBillId							  Nvarchar(100)

	 SELECT @intReceiptStartingId = intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType ='Inventory Receipt'
	 SELECT @intBillStartingId = intStartingNumberId	FROM tblSMStartingNumber WHERE strTransactionType ='Bill'

	SELECT @IRelyAdminKey =intEntityId FROM tblSMUserSecurity WHERE strUserName='IRELYADMIN'

	SET @UserId = @IRelyAdminKey
	 
	 DECLARE @tblNonScaleTicket AS TABLE
	 (
	     intNonScaleTicketKey        INT IDENTITY(1, 1)
	    ,intScaleTicketId			 INT	
	    ,strSourceType			     NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL	   
		,intPricingTypeId			 INT
		,intStorageScheduleTypeId	 INT
	 )

	   INSERT INTO @tblNonScaleTicket
	   (
	      intScaleTicketId	
		 ,strSourceType
		 ,intPricingTypeId
		 ,intStorageScheduleTypeId	
	   )
		 SELECT 
		 intScaleTicketId				= SC.intTicketId
		,strSourceType					= 'Purchase Contract'		
		,intPricingTypeId				= CD.intPricingTypeId
		,intStorageScheduleTypeId		= SC.intStorageScheduleTypeId
		FROM tblSCTicket SC
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = SC.intContractId
		WHERE SC.strFieldNumber    = 'NonScale' 

	   SELECT @intNonScaleTicketKey = MIN(intNonScaleTicketKey)
	   FROM @tblNonScaleTicket
	   
	   WHILE @intNonScaleTicketKey > 0
	   BEGIN
			
			SET @intScaleTicketId			 =   NULL
			SET @intPricingTypeId			 =   NULL
			SET @intStorageScheduleTypeId	 =   NULL

			SELECT 
			 @intScaleTicketId = SC.intScaleTicketId
			,@intPricingTypeId=SC.intPricingTypeId
			,@intStorageScheduleTypeId = intStorageScheduleTypeId
			FROM @tblNonScaleTicket SC
			WHERE intNonScaleTicketKey = @intNonScaleTicketKey
		
		IF @intStorageScheduleTypeId = -2
		BEGIN

         IF @intPricingTypeId =2
		 BEGIN
					SET @strReceiptNumber = NULL

					EXEC dbo.uspSMGetStartingNumber 
					 @intReceiptStartingId
					,@strReceiptNumber OUTPUT
								
			INSERT INTO tblICInventoryReceipt
			(
			 strReceiptType
			,intSourceType
			,intEntityVendorId
			,intTransferorId
			,intLocationId
			,strReceiptNumber
			,dtmReceiptDate
			,intCurrencyId
			,intSubCurrencyCents
			,intBlanketRelease
			,strVendorRefNo
			,strBillOfLading
			,intShipViaId
			,intShipFromId
			,intReceiverId
			,strVessel
			,intFreightTermId
			,intShiftNumber
			,dblInvoiceAmount
			,ysnPrepaid
			,ysnInvoicePaid
			,intCheckNo
			,dtmCheckDate
			,intTrailerTypeId
			,dtmTrailerArrivalDate
			,dtmTrailerArrivalTime
			,strSealNo
			,strSealStatus
			,dtmReceiveTime
			,dblActualTempReading
			,intShipmentId
			,intTaxGroupId
			,ysnPosted
			,intCreatedUserId
			,intEntityId
			,intConcurrencyId
			,strActualCostId
			,strReceiptOriginId
			,strWarehouseRefNo
			,ysnOrigin
			,intSourceInventoryReceiptId
			,dtmCreated
			,dtmLastFreeWhseDate
			)
			SELECT
			 strReceiptType				  = 'Purchase Contract'
			,intSourceType				  = 1
			,intEntityVendorId			  = SC.intEntityId
			,intTransferorId			  = NULL
			,intLocationId				  = SC.intProcessingLocationId
			,strReceiptNumber			  = @strReceiptNumber
			,dtmReceiptDate				  = SC.dtmTicketDateTime
			,intCurrencyId				  = SC.intCurrencyId
			,intSubCurrencyCents		  = 1
			,intBlanketRelease			  = NULL
			,strVendorRefNo				  = 'TKT-'+LTRIM(SC.strTicketNumber)
			,strBillOfLading			  = NULL
			,intShipViaId				  = NULL
			,intShipFromId				  = Vendor.intShipFromId
			,intReceiverId				  = @UserId
			,strVessel					  = NULL
			,intFreightTermId			  = NULL
			,intShiftNumber				  = NULL
			,dblInvoiceAmount			  = SC.dblUnitBasis * SC.dblNetUnits
			,ysnPrepaid					  = 0
			,ysnInvoicePaid				  = 0
			,intCheckNo					  = NULL
			,dtmCheckDate				  = NULL
			,intTrailerTypeId			  = NULL
			,dtmTrailerArrivalDate		  = NULL
			,dtmTrailerArrivalTime		  = NULL
			,strSealNo					  = NULL
			,strSealStatus				  = NULL
			,dtmReceiveTime				  = NULL
			,dblActualTempReading		  = NULL
			,intShipmentId				  = NULL
			,intTaxGroupId				  = NULL
			,ysnPosted					  = 1
			,intCreatedUserId			  = @UserId
			,intEntityId				  = @UserId
			,intConcurrencyId			  = 1
			,strActualCostId			  = NULL
			,strReceiptOriginId			  = NULL
			,strWarehouseRefNo			  = NULL
			,ysnOrigin					  = 1
			,intSourceInventoryReceiptId  = NULL
			,dtmCreated					  = SC.dtmTicketDateTime
			,dtmLastFreeWhseDate          = NULL    
			FROM tblSCTicket SC
			JOIN tblAPVendor Vendor ON Vendor.intEntityId = SC.intEntityId
			WHERE SC.intTicketId = @intScaleTicketId
			
			SET @InventoryReceiptId = SCOPE_IDENTITY();

			INSERT INTO tblICInventoryReceiptItem
			(
			  intInventoryReceiptId
			 ,intLineNo
			 ,intOrderId
			 ,intSourceId
			 ,intItemId
			 ,intContainerId
			 ,intSubLocationId
			 ,intStorageLocationId
			 ,intOwnershipType
			 ,dblOrderQty
			 ,dblBillQty
			 ,dblOpenReceive
			 ,intLoadReceive
			 ,dblReceived
			 ,intUnitMeasureId
			 ,intWeightUOMId
			 ,intCostUOMId
			 ,dblUnitCost
			 ,dblUnitRetail
			 ,ysnSubCurrency
			 ,dblLineTotal
			 ,intGradeId
			 ,dblGross
			 ,dblNet
			 ,dblTax
			 ,intDiscountSchedule
			 ,ysnExported
			 ,dtmExportedDate
			 ,intSort
			 ,intConcurrencyId
			 ,strComments
			 ,intTaxGroupId
			 ,intSourceInventoryReceiptItemId
			 ,dblQtyReturned
			 ,dblGrossReturned
			 ,dblNetReturned
			 ,intForexRateTypeId
			 ,dblForexRate
			 ,ysnLotWeightsRequired
			 ,strChargesLink
			 ,strItemType
			 ,intParentItemLinkId
			 ,intChildItemLinkId
			)
			SELECT 
			 intInventoryReceiptId				= @InventoryReceiptId
			,intLineNo							= CD.intContractDetailId
			,intOrderId							= CD.intContractHeaderId
			,intSourceId						= SC.intTicketId
			,intItemId							= SC.intItemId
			,intContainerId						= NULL
			,intSubLocationId					= NULL
			,intStorageLocationId				= NULL
			,intOwnershipType					= 1
			,dblOrderQty						= 0
			,dblBillQty							= 0
			,dblOpenReceive						= SC.dblNetUnits
			,intLoadReceive						= 0
			,dblReceived						= SC.dblNetUnits
			,intUnitMeasureId					= UOM.intItemUOMId
			,intWeightUOMId						= UOM.intItemUOMId
			,intCostUOMId						= UOM.intItemUOMId
			,dblUnitCost						= SC.dblUnitBasis
			,dblUnitRetail						= 0
			,ysnSubCurrency						= 0
			,dblLineTotal						= SC.dblNetUnits * SC.dblUnitBasis
			,intGradeId							= NULL
			,dblGross							= SC.dblNetUnits
			,dblNet								= SC.dblNetUnits
			,dblTax								= 0 
			,intDiscountSchedule				= SC.intDiscountSchedule
			,ysnExported						= NULL
			,dtmExportedDate					= NULL
			,intSort							= 1
			,intConcurrencyId					= 1
			,strComments						= NULL
			,intTaxGroupId						= NULL
			,intSourceInventoryReceiptItemId   	= NULL
			,dblQtyReturned						= 0
			,dblGrossReturned					= 0
			,dblNetReturned						= 0
			,intForexRateTypeId					= NULL
			,dblForexRate						= NULL
			,ysnLotWeightsRequired				= 0
			,strChargesLink						= NULL
			,strItemType						= NULL
			,intParentItemLinkId				= NULL
			,intChildItemLinkId					= NULL
			FROM tblSCTicket SC
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = SC.intContractId
			JOIN tblICItemUOM UOM ON UOM.intItemId = CD.intItemId AND UOM.ysnStockUnit =1
			WHERE SC.intTicketId = @intScaleTicketId
			
			INSERT INTO tblICInventoryReceiptCharge
			(
			  intInventoryReceiptId
			 ,intContractId
			 ,intContractDetailId
			 ,intChargeId
			 ,ysnInventoryCost
			 ,strCostMethod
			 ,dblRate
			 ,intCostUOMId
			 ,ysnSubCurrency
			 ,intCurrencyId
			 ,dblExchangeRate
			 ,intCent
			 ,dblAmount
			 ,strAllocateCostBy
			 ,ysnAccrue
			 ,intEntityVendorId
			 ,ysnPrice
			 ,dblAmountBilled
			 ,dblAmountPaid
			 ,dblAmountPriced
			 ,intSort
			 ,dblTax
			 ,intConcurrencyId
			 ,intTaxGroupId
			 ,intForexRateTypeId
			 ,dblForexRate
			 ,dblQuantity
			 ,dblQuantityBilled
			 ,dblQuantityPriced
			 ,strChargesLink
			)
			SELECT 
			  intInventoryReceiptId  = @InventoryReceiptId
			 ,intContractId			 = CD.intContractHeaderId
			 ,intContractDetailId	 = CD.intContractDetailId
			 ,intChargeId			 = Item.intItemId
			 ,ysnInventoryCost		 = 1
			 ,strCostMethod			 = Item.strCostMethod
			 ,dblRate				 = CASE WHEN Item.strCostMethod='Amount' THEN 0 ELSE QM.dblDiscountDue END
			 ,intCostUOMId			 = UOM.intItemUOMId
			 ,ysnSubCurrency		 = 0
			 ,intCurrencyId			 = SC.intCurrencyId
			 ,dblExchangeRate		 = 1
			 ,intCent				 = NULL
			 ,dblAmount				 = QM.dblDiscountDue * SC.dblNetUnits
			 ,strAllocateCostBy		 = 'Unit'
			 ,ysnAccrue				 = CASE WHEN QM.dblDiscountDue < 0 THEN 1 ELSE 0 END
			 ,intEntityVendorId		 = SC.intEntityId
			 ,ysnPrice				 = CASE WHEN QM.dblDiscountDue > 0 THEN 1 ELSE 0 END
			 ,dblAmountBilled		 = 0
			 ,dblAmountPaid			 = 0
			 ,dblAmountPriced		 = 0
			 ,intSort				 = NULL
			 ,dblTax				 = 0
			 ,intConcurrencyId		 = 1
			 ,intTaxGroupId			 = NULL
			 ,intForexRateTypeId	 = NULL
			 ,dblForexRate			 = NULL
			 ,dblQuantity			 = 1
			 ,dblQuantityBilled		 = 0
			 ,dblQuantityPriced		 = 0
			 ,strChargesLink		 = NULL
			 FROM tblSCTicket SC
			 JOIN tblCTContractDetail CD ON CD.intContractDetailId = SC.intContractId
			 JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = SC.intTicketId AND QM.strSourceType ='Scale'
			 JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
			 JOIN tblICItem Item ON Item.intItemId = DCode.intItemId
			 JOIN tblICItemUOM UOM ON UOM.intItemId = CD.intItemId AND UOM.ysnStockUnit =1
			 WHERE SC.intTicketId = @intScaleTicketId	
			
			UPDATE tblSCTicket SET intInventoryReceiptId = @InventoryReceiptId
			WHERE  intTicketId = @intScaleTicketId

		 END
		 
		 IF @intPricingTypeId =1
		 BEGIN
			
					SET @strBillId = NULL

					EXEC dbo.uspSMGetStartingNumber 
					 @intBillStartingId
					,@strBillId OUTPUT

			INSERT INTO tblAPBill
			(
			 intBillBatchId
			,strVendorOrderNumber
			,intTermsId
			,intTransactionReversed
			,intCommodityId
			,intBankInfoId
			,ysnPrepayHasPayment
			,dtmDate
			,dtmDueDate
			,intAccountId
			,strReference
			,strApprovalNotes
			,strRemarks
			,strComment
			,dblTotal
			,dbl1099
			,dblSubtotal
			,ysnPosted
			,ysnPaid
			,strBillId
			,dblAmountDue
			,dtmDatePaid
			,dtmApprovalDate
			,dtmDiscountDate
			,dtmDeferredInterestDate
			,dtmInterestAccruedThru
			,intUserId
			,intConcurrencyId
			,dtmBillDate
			,intEntityId
			,intEntityVendorId
			,dblWithheld
			,dblDiscount
			,dblTax
			,dblPayment
			,dblInterest
			,intTransactionType
			,intPurchaseOrderId
			,strPONumber
			,strShipToAttention
			,strShipToAddress
			,strShipToCity
			,strShipToState
			,strShipToZipCode
			,strShipToCountry
			,strShipToPhone
			,strShipFromAttention
			,strShipFromAddress
			,strShipFromCity
			,strShipFromState
			,strShipFromZipCode
			,strShipFromCountry
			,strShipFromPhone
			,intShipFromId
			,intDeferredVoucherId
			,intPayToAddressId
			,intVoucherDifference
			,intShipToId
			,intShipViaId
			,intStoreLocationId
			,intContactId
			,intOrderById
			,intCurrencyId
			,intSubCurrencyCents
			,ysnApproved
			,ysnForApproval
			,ysnOrigin
			,ysnDeleted
			,ysnDiscountOverride
			,ysnReadyForPayment
			,ysnRecurring
			,ysnExported
			,ysnForApprovalSubmitted
			,ysnOldPrepayment
			,dtmDateDeleted
			,dtmExportedDate
			,dtmDateCreated
			)
			SELECT
			 intBillBatchId			  = NULL
			,strVendorOrderNumber	  = 'TKT-'+LTRIM(SC.strTicketNumber)
			,intTermsId				  = Vendor.intTermsId
			,intTransactionReversed	  = NULL
			,intCommodityId			  = NULL
			,intBankInfoId			  = NULL
			,ysnPrepayHasPayment	  = 0
			,dtmDate				  = SC.dtmTicketDateTime
			,dtmDueDate				  = SC.dtmTicketDateTime
			,intAccountId			  = CL.intAPAccount
			,strReference			  = NULL
			,strApprovalNotes		  = NULL
			,strRemarks				  = NULL
			,strComment				  = NULL
			,dblTotal				  = SC.dblUnitPrice * SC.dblNetUnits
			,dbl1099				  = 0
			,dblSubtotal			  = SC.dblUnitPrice * SC.dblNetUnits
			,ysnPosted				  = 1
			,ysnPaid				  = 0
			,strBillId				  = @strBillId
			,dblAmountDue			  = SC.dblUnitPrice * SC.dblNetUnits
			,dtmDatePaid			  = NULL
			,dtmApprovalDate		  = NULL
			,dtmDiscountDate		  = NULL
			,dtmDeferredInterestDate  = NULL
			,dtmInterestAccruedThru	  = NULL
			,intUserId				  = NULL
			,intConcurrencyId		  = 1
			,dtmBillDate			  = SC.dtmTicketDateTime
			,intEntityId			  = @UserId
			,intEntityVendorId		  = SC.intEntityId
			,dblWithheld			  = 0
			,dblDiscount			  = 0
			,dblTax					  = 0
			,dblPayment				  = 0
			,dblInterest			  = 0
			,intTransactionType		  = 1
			,intPurchaseOrderId		  = NULL
			,strPONumber			  = NULL
			,strShipToAttention		  = NULL
			,strShipToAddress		  = CL.strAddress
			,strShipToCity			  = CL.strCity
			,strShipToState			  = CL.strStateProvince
			,strShipToZipCode		  = CL.strZipPostalCode
			,strShipToCountry		  = CL.strCountry
			,strShipToPhone			  = CL.strPhone
			,strShipFromAttention	  = NULL
			,strShipFromAddress		  = B.strAddress
			,strShipFromCity		  = B.strCity
			,strShipFromState		  = B.strState
			,strShipFromZipCode		  = B.strZipCode
			,strShipFromCountry		  = B.strCountry
			,strShipFromPhone		  = ''
			,intShipFromId			  = Vendor.intShipFromId
			,intDeferredVoucherId	  = NULL
			,intPayToAddressId		  = Vendor.intShipFromId
			,intVoucherDifference	  = NULL
			,intShipToId			  = CL.intCompanyLocationId
			,intShipViaId			  = NULL
			,intStoreLocationId		  = CL.intCompanyLocationId
			,intContactId			  = NULL
			,intOrderById			  = @UserId
			,intCurrencyId			  = SC.intCurrencyId
			,intSubCurrencyCents	  = 1
			,ysnApproved			  = 0
			,ysnForApproval			  = 0
			,ysnOrigin				  = 1
			,ysnDeleted				  = 0
			,ysnDiscountOverride	  = 0
			,ysnReadyForPayment		  = 0
			,ysnRecurring			  = 0
			,ysnExported			  = NULL
			,ysnForApprovalSubmitted  = 0
			,ysnOldPrepayment		  = 0
			,dtmDateDeleted			  = NULL
			,dtmExportedDate		  = NULL
			,dtmDateCreated			  = SC.dtmTicketDateTime
			FROM tblSCTicket SC
			JOIN tblAPVendor Vendor ON Vendor.intEntityId = SC.intEntityId
			JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SC.intProcessingLocationId
			LEFT JOIN [tblEMEntityLocation]  B ON B.[intEntityId] = Vendor.intEntityId AND B.ysnDefaultLocation=1
			WHERE SC.intTicketId = @intScaleTicketId

			SET @BillId = SCOPE_IDENTITY();		

			INSERT INTO tblAPBillDetail
			(
				 intBillId
				,strMiscDescription
				,strComment
				,intAccountId
				,intUnitOfMeasureId
				,intCostUOMId
				,intWeightUOMId
				,intItemId
				,intInventoryReceiptItemId
				,intDeferredVoucherId
				,intInventoryReceiptChargeId
				,intContractCostId
				,intPaycheckHeaderId
				,intPurchaseDetailId
				,intContractHeaderId
				,intContractDetailId
				,intCustomerStorageId
				,intStorageLocationId
				,intLocationId
				,intLoadDetailId
				,intLoadId
				,intScaleTicketId
				,intCCSiteDetailId
				,intPrepayTypeId
				,dblTotal
				,intConcurrencyId
				,dblQtyContract
				,dblContractCost
				,dblQtyOrdered
				,dblQtyReceived
				,dblDiscount
				,dblCost
				,dblOldCost
				,dblLandedCost
				,dblRate
				,dblTax
				,dblActual
				,dblDifference
				,dblPrepayPercentage
				,dblWeightUnitQty
				,dblCostUnitQty
				,dblUnitQty
				,dblNetWeight
				,dblWeight
				,dblVolume
				,dblNetShippedWeight
				,dblWeightLoss
				,dblFranchiseWeight
				,dblClaimAmount
				,dbl1099
				,dtmExpectedDate
				,int1099Form
				,int1099Category
				,ysn1099Printed
				,ysnRestricted
				,ysnSubCurrency
				,intLineNo
				,intTaxGroupId
				,intInventoryShipmentChargeId
				,intCurrencyExchangeRateTypeId
				,intCurrencyId
				,strBillOfLading
				,intContractSeq
				,intInvoiceId
				,intBuybackChargeId
			)
			SELECT  
					intBillId					   = @BillId
				   ,strMiscDescription			   = NULL
				   ,strComment					   = NULL
				   ,intAccountId				   = CL.intAPAccount
				   ,intUnitOfMeasureId			   = UOM.intItemUOMId
				   ,intCostUOMId				   = UOM.intItemUOMId
				   ,intWeightUOMId				   = UOM.intItemUOMId
				   ,intItemId					   = SC.intItemId
				   ,intInventoryReceiptItemId	   = NULL
				   ,intDeferredVoucherId		   = NULL
				   ,intInventoryReceiptChargeId	   = NULL
				   ,intContractCostId			   = NULL
				   ,intPaycheckHeaderId			   = NULL
				   ,intPurchaseDetailId			   = NULL
				   ,intContractHeaderId			   = CD.intContractHeaderId
				   ,intContractDetailId			   = CD.intContractDetailId
				   ,intCustomerStorageId		   = NULL
				   ,intStorageLocationId		   = NULL
				   ,intLocationId				   = NULL
				   ,intLoadDetailId				   = NULL
				   ,intLoadId					   = NULL
				   ,intScaleTicketId			   = SC.intTicketId
				   ,intCCSiteDetailId			   = NULL
				   ,intPrepayTypeId				   = NULL
				   ,dblTotal					   = SC.dblUnitPrice * SC.dblNetUnits
				   ,intConcurrencyId			   = 1
				   ,dblQtyContract				   = 0
				   ,dblContractCost				   = 0
				   ,dblQtyOrdered				   = SC.dblNetUnits
				   ,dblQtyReceived				   = SC.dblNetUnits
				   ,dblDiscount					   = 0
				   ,dblCost						   = SC.dblUnitPrice
				   ,dblOldCost					   = NULL
				   ,dblLandedCost				   = 0
				   ,dblRate						   = 1
				   ,dblTax						   = 0 
				   ,dblActual					   = 0
				   ,dblDifference				   = 0
				   ,dblPrepayPercentage			   = 0
				   ,dblWeightUnitQty			   = 1
				   ,dblCostUnitQty				   = 1
				   ,dblUnitQty					   = 1
				   ,dblNetWeight				   = SC.dblNetUnits
				   ,dblWeight					   = 0
				   ,dblVolume					   = 0
				   ,dblNetShippedWeight			   = 0
				   ,dblWeightLoss				   = 0
				   ,dblFranchiseWeight			   = 0
				   ,dblClaimAmount				   = 0
				   ,dbl1099						   = 0
				   ,dtmExpectedDate				   = NULL
				   ,int1099Form					   = 0
				   ,int1099Category				   = 0
				   ,ysn1099Printed				   = 0
				   ,ysnRestricted				   = 0
				   ,ysnSubCurrency				   = 0
				   ,intLineNo					   = 1
				   ,intTaxGroupId				   = NULL 
				   ,intInventoryShipmentChargeId   = NULL
				   ,intCurrencyExchangeRateTypeId  = NULL
				   ,intCurrencyId				   = SC.intCurrencyId
				   ,strBillOfLading				   = NULL
				   ,intContractSeq				   = CD.intContractSeq
				   ,intInvoiceId				   = NULL
				   ,intBuybackChargeId			   = NULL				   				   			
					FROM tblSCTicket SC
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = SC.intContractId
					JOIN tblICItemUOM UOM ON UOM.intItemId = CD.intItemId AND UOM.ysnStockUnit =1
					JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SC.intProcessingLocationId
					WHERE SC.intTicketId = @intScaleTicketId

		 END
		
		END
		ELSE IF @intStorageScheduleTypeId = -3
		BEGIN
				
				SET @strBillId = NULL
				
				EXEC dbo.uspSMGetStartingNumber 
				 @intBillStartingId
				,@strBillId OUTPUT

				INSERT INTO tblAPBill
				(
				 intBillBatchId
				,strVendorOrderNumber
				,intTermsId
				,intTransactionReversed
				,intCommodityId
				,intBankInfoId
				,ysnPrepayHasPayment
				,dtmDate
				,dtmDueDate
				,intAccountId
				,strReference
				,strApprovalNotes
				,strRemarks
				,strComment
				,dblTotal
				,dbl1099
				,dblSubtotal
				,ysnPosted
				,ysnPaid
				,strBillId
				,dblAmountDue
				,dtmDatePaid
				,dtmApprovalDate
				,dtmDiscountDate
				,dtmDeferredInterestDate
				,dtmInterestAccruedThru
				,intUserId
				,intConcurrencyId
				,dtmBillDate
				,intEntityId
				,intEntityVendorId
				,dblWithheld
				,dblDiscount
				,dblTax
				,dblPayment
				,dblInterest
				,intTransactionType
				,intPurchaseOrderId
				,strPONumber
				,strShipToAttention
				,strShipToAddress
				,strShipToCity
				,strShipToState
				,strShipToZipCode
				,strShipToCountry
				,strShipToPhone
				,strShipFromAttention
				,strShipFromAddress
				,strShipFromCity
				,strShipFromState
				,strShipFromZipCode
				,strShipFromCountry
				,strShipFromPhone
				,intShipFromId
				,intDeferredVoucherId
				,intPayToAddressId
				,intVoucherDifference
				,intShipToId
				,intShipViaId
				,intStoreLocationId
				,intContactId
				,intOrderById
				,intCurrencyId
				,intSubCurrencyCents
				,ysnApproved
				,ysnForApproval
				,ysnOrigin
				,ysnDeleted
				,ysnDiscountOverride
				,ysnReadyForPayment
				,ysnRecurring
				,ysnExported
				,ysnForApprovalSubmitted
				,ysnOldPrepayment
				,dtmDateDeleted
				,dtmExportedDate
				,dtmDateCreated
				)
				SELECT
				 intBillBatchId			  = NULL
				,strVendorOrderNumber	  = 'TKT-'+LTRIM(SC.strTicketNumber)
				,intTermsId				  = Vendor.intTermsId
				,intTransactionReversed	  = NULL
				,intCommodityId			  = NULL
				,intBankInfoId			  = NULL
				,ysnPrepayHasPayment	  = 0
				,dtmDate				  = SC.dtmTicketDateTime
				,dtmDueDate				  = SC.dtmTicketDateTime
				,intAccountId			  = CL.intAPAccount
				,strReference			  = NULL
				,strApprovalNotes		  = NULL
				,strRemarks				  = NULL
				,strComment				  = NULL
				,dblTotal				  = SC.dblUnitPrice * SC.dblNetUnits
				,dbl1099				  = 0
				,dblSubtotal			  = SC.dblUnitPrice * SC.dblNetUnits
				,ysnPosted				  = 1
				,ysnPaid				  = 0
				,strBillId				  = @strBillId
				,dblAmountDue			  = SC.dblUnitPrice * SC.dblNetUnits
				,dtmDatePaid			  = NULL
				,dtmApprovalDate		  = NULL
				,dtmDiscountDate		  = NULL
				,dtmDeferredInterestDate  = NULL
				,dtmInterestAccruedThru	  = NULL
				,intUserId				  = NULL
				,intConcurrencyId		  = 1
				,dtmBillDate			  = SC.dtmTicketDateTime
				,intEntityId			  = @UserId
				,intEntityVendorId		  = SC.intEntityId
				,dblWithheld			  = 0
				,dblDiscount			  = 0
				,dblTax					  = 0
				,dblPayment				  = 0
				,dblInterest			  = 0
				,intTransactionType		  = 1
				,intPurchaseOrderId		  = NULL
				,strPONumber			  = NULL
				,strShipToAttention		  = NULL
				,strShipToAddress		  = CL.strAddress
				,strShipToCity			  = CL.strCity
				,strShipToState			  = CL.strStateProvince
				,strShipToZipCode		  = CL.strZipPostalCode
				,strShipToCountry		  = CL.strCountry
				,strShipToPhone			  = CL.strPhone
				,strShipFromAttention	  = NULL
				,strShipFromAddress		  = B.strAddress
				,strShipFromCity		  = B.strCity
				,strShipFromState		  = B.strState
				,strShipFromZipCode		  = B.strZipCode
				,strShipFromCountry		  = B.strCountry
				,strShipFromPhone		  = ''
				,intShipFromId			  = Vendor.intShipFromId
				,intDeferredVoucherId	  = NULL
				,intPayToAddressId		  = Vendor.intShipFromId
				,intVoucherDifference	  = NULL
				,intShipToId			  = CL.intCompanyLocationId
				,intShipViaId			  = NULL
				,intStoreLocationId		  = CL.intCompanyLocationId
				,intContactId			  = NULL
				,intOrderById			  = @UserId
				,intCurrencyId			  = SC.intCurrencyId
				,intSubCurrencyCents	  = 1
				,ysnApproved			  = 0
				,ysnForApproval			  = 0
				,ysnOrigin				  = 1
				,ysnDeleted				  = 0
				,ysnDiscountOverride	  = 0
				,ysnReadyForPayment		  = 0
				,ysnRecurring			  = 0
				,ysnExported			  = NULL
				,ysnForApprovalSubmitted  = 0
				,ysnOldPrepayment		  = 0
				,dtmDateDeleted			  = NULL
				,dtmExportedDate		  = NULL
				,dtmDateCreated			  = SC.dtmTicketDateTime
				FROM tblSCTicket SC
				JOIN tblAPVendor Vendor ON Vendor.intEntityId = SC.intEntityId
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SC.intProcessingLocationId
				LEFT JOIN [tblEMEntityLocation]  B ON B.[intEntityId] = Vendor.intEntityId AND B.ysnDefaultLocation=1
				WHERE SC.intTicketId = @intScaleTicketId
				
				SET @BillId = SCOPE_IDENTITY();
				
				INSERT INTO tblAPBillDetail
				(
					 intBillId
					,strMiscDescription
					,strComment
					,intAccountId
					,intUnitOfMeasureId
					,intCostUOMId
					,intWeightUOMId
					,intItemId
					,intInventoryReceiptItemId
					,intDeferredVoucherId
					,intInventoryReceiptChargeId
					,intContractCostId
					,intPaycheckHeaderId
					,intPurchaseDetailId
					,intContractHeaderId
					,intContractDetailId
					,intCustomerStorageId
					,intStorageLocationId
					,intLocationId
					,intLoadDetailId
					,intLoadId
					,intScaleTicketId
					,intCCSiteDetailId
					,intPrepayTypeId
					,dblTotal
					,intConcurrencyId
					,dblQtyContract
					,dblContractCost
					,dblQtyOrdered
					,dblQtyReceived
					,dblDiscount
					,dblCost
					,dblOldCost
					,dblLandedCost
					,dblRate
					,dblTax
					,dblActual
					,dblDifference
					,dblPrepayPercentage
					,dblWeightUnitQty
					,dblCostUnitQty
					,dblUnitQty
					,dblNetWeight
					,dblWeight
					,dblVolume
					,dblNetShippedWeight
					,dblWeightLoss
					,dblFranchiseWeight
					,dblClaimAmount
					,dbl1099
					,dtmExpectedDate
					,int1099Form
					,int1099Category
					,ysn1099Printed
					,ysnRestricted
					,ysnSubCurrency
					,intLineNo
					,intTaxGroupId
					,intInventoryShipmentChargeId
					,intCurrencyExchangeRateTypeId
					,intCurrencyId
					,strBillOfLading
					,intContractSeq
					,intInvoiceId
					,intBuybackChargeId
				)
				 SELECT  
			   	 intBillId					   = @BillId
			    ,strMiscDescription			   = NULL
			    ,strComment					   = NULL
			    ,intAccountId				   = CL.intAPAccount
			    ,intUnitOfMeasureId			   = UOM.intItemUOMId
			    ,intCostUOMId				   = UOM.intItemUOMId
			    ,intWeightUOMId				   = UOM.intItemUOMId
			    ,intItemId					   = SC.intItemId
			    ,intInventoryReceiptItemId	   = NULL
			    ,intDeferredVoucherId		   = NULL
			    ,intInventoryReceiptChargeId   = NULL
			    ,intContractCostId			   = NULL
			    ,intPaycheckHeaderId		   = NULL
			    ,intPurchaseDetailId		   = NULL
			    ,intContractHeaderId		   = NULL
			    ,intContractDetailId		   = NULL
			    ,intCustomerStorageId		   = NULL
			    ,intStorageLocationId		   = NULL
			    ,intLocationId				   = NULL
			    ,intLoadDetailId			   = NULL
			    ,intLoadId					   = NULL
			    ,intScaleTicketId			   = SC.intTicketId
			    ,intCCSiteDetailId			   = NULL
			    ,intPrepayTypeId			   = NULL
			    ,dblTotal					   = SC.dblUnitPrice * SC.dblNetUnits
			    ,intConcurrencyId			   = 1
			    ,dblQtyContract				   = 0
			    ,dblContractCost			   = 0
			    ,dblQtyOrdered				   = SC.dblNetUnits
			    ,dblQtyReceived				   = SC.dblNetUnits
			    ,dblDiscount				   = 0
			    ,dblCost					   = SC.dblUnitPrice
			    ,dblOldCost					   = NULL
			    ,dblLandedCost				   = 0
			    ,dblRate					   = 1
			    ,dblTax						   = 0 
			    ,dblActual					   = 0
			    ,dblDifference				   = 0
			    ,dblPrepayPercentage		   = 0
			    ,dblWeightUnitQty			   = 1
			    ,dblCostUnitQty				   = 1
			    ,dblUnitQty					   = 1
			    ,dblNetWeight				   = SC.dblNetUnits
			    ,dblWeight					   = 0
			    ,dblVolume					   = 0
			    ,dblNetShippedWeight		   = 0
			    ,dblWeightLoss				   = 0
			    ,dblFranchiseWeight			   = 0
			    ,dblClaimAmount				   = 0
			    ,dbl1099					   = 0
			    ,dtmExpectedDate			   = NULL
			    ,int1099Form				   = 0
			    ,int1099Category			   = 0
			    ,ysn1099Printed				   = 0
			    ,ysnRestricted				   = 0
			    ,ysnSubCurrency				   = 0
			    ,intLineNo					   = 1
			    ,intTaxGroupId				   = NULL 
			    ,intInventoryShipmentChargeId  = NULL
			    ,intCurrencyExchangeRateTypeId = NULL
			    ,intCurrencyId				   = SC.intCurrencyId
			    ,strBillOfLading			   = NULL
			    ,intContractSeq				   = NULL
			    ,intInvoiceId				   = NULL
			    ,intBuybackChargeId			   = NULL				   				   			
			   FROM tblSCTicket SC
			   JOIN tblICItemUOM UOM ON UOM.intItemId = SC.intItemId AND UOM.ysnStockUnit =1
			   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SC.intProcessingLocationId
			   WHERE SC.intTicketId = @intScaleTicketId

		END

		UPDATE tblSCTicket SET strFieldNumber    = ''
		WHERE  intTicketId = @intScaleTicketId

	   SELECT @intNonScaleTicketKey = MIN(intNonScaleTicketKey)
	   FROM @tblNonScaleTicket 
	   WHERE intNonScaleTicketKey > @intNonScaleTicketKey
	   
	   END
	   	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH 

GO
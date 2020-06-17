CREATE VIEW [dbo].[vyuARGetInvoiceDetail]
AS
SELECT intInvoiceDetailId					= INV.intInvoiceDetailId
	 , intInvoiceId							= INV.intInvoiceId
	 , strDocumentNumber					= INV.strDocumentNumber
	 , intItemId							= INV.intItemId
	 , intPrepayTypeId						= INV.intPrepayTypeId
	 , dblPrepayRate						= INV.dblPrepayRate
	 , strItemDescription					= INV.strItemDescription
	 , dblQtyOrdered						= INV.dblQtyOrdered
	 , intOrderUOMId						= INV.intOrderUOMId
	 , dblQtyShipped						= INV.dblQtyShipped
	 , intItemUOMId							= INV.intItemUOMId
	 , intPriceUOMId						= INV.intPriceUOMId
	 , dblItemWeight						= INV.dblItemWeight
	 , intItemWeightUOMId					= INV.intItemWeightUOMId
	 , dblDiscount							= INV.dblDiscount
	 , dblItemTermDiscount					= INV.dblItemTermDiscount
	 , strItemTermDiscountBy				= INV.strItemTermDiscountBy
	 , dblItemTermDiscountAmount			= INV.dblItemTermDiscountAmount
	 , dblBaseItemTermDiscountAmount		= INV.dblBaseItemTermDiscountAmount
	 , dblItemTermDiscountExemption			= INV.dblItemTermDiscountExemption
	 , dblBaseItemTermDiscountExemption		= INV.dblBaseItemTermDiscountExemption
	 , dblTermDiscountRate					= INV.dblTermDiscountRate
	 , ysnTermDiscountExempt				= INV.ysnTermDiscountExempt
	 , dblPrice								= INV.dblPrice
	 , dblBasePrice							= INV.dblBasePrice
	 , dblUnitPrice							= INV.dblUnitPrice
	 , dblBaseUnitPrice						= INV.dblBaseUnitPrice
	 , dblOriginalGrossPrice				= INV.dblOriginalGrossPrice
	 , dblBaseOriginalGrossPrice			= INV.dblBaseOriginalGrossPrice
	 , dblComputedGrossPrice				= INV.dblComputedGrossPrice
	 , dblBaseComputedGrossPrice			= INV.dblBaseComputedGrossPrice
	 , strPricing							= INV.strPricing
	 , dblTotalTax							= INV.dblTotalTax
	 , dblBaseTotalTax						= INV.dblBaseTotalTax
	 , dblTotal								= INV.dblTotal
	 , dblBaseTotal							= INV.dblBaseTotal
	 , intCurrencyExchangeRateTypeId		= INV.intCurrencyExchangeRateTypeId
	 , intCurrencyExchangeRateId			= INV.intCurrencyExchangeRateId
	 , dblCurrencyExchangeRate				= INV.dblCurrencyExchangeRate
	 , intSubCurrencyId						= INV.intSubCurrencyId
	 , dblSubCurrencyRate					= INV.dblSubCurrencyRate
	 , ysnRestricted						= INV.ysnRestricted
	 , ysnReturned							= INV.ysnReturned
	 , intAccountId							= INV.intAccountId
	 , intCOGSAccountId						= INV.intCOGSAccountId
	 , intSalesAccountId					= INV.intSalesAccountId
	 , intInventoryAccountId				= INV.intInventoryAccountId
	 , intServiceChargeAccountId			= INV.intServiceChargeAccountId
	 , strMaintenanceType					= INV.strMaintenanceType
	 , strFrequency							= INV.strFrequency
	 , dtmMaintenanceDate					= INV.dtmMaintenanceDate
	 , dblMaintenanceAmount					= INV.dblMaintenanceAmount
	 , dblBaseMaintenanceAmount				= INV.dblBaseMaintenanceAmount
	 , dblLicenseAmount						= INV.dblLicenseAmount
	 , dblBaseLicenseAmount					= INV.dblBaseLicenseAmount
	 , intTaxGroupId						= INV.intTaxGroupId
	 , intStorageLocationId					= INV.intStorageLocationId
	 , intCompanyLocationSubLocationId		= INV.intCompanyLocationSubLocationId
	 , intSCInvoiceId						= INV.intSCInvoiceId
	 , strSCInvoiceNumber					= INV.strSCInvoiceNumber
	 , intInventoryShipmentItemId			= INV.intInventoryShipmentItemId
	 , intInventoryShipmentChargeId			= INV.intInventoryShipmentChargeId
	 , strShipmentNumber					= INV.strShipmentNumber
	 , intSalesOrderDetailId				= INV.intSalesOrderDetailId
	 , strSalesOrderNumber					= INV.strSalesOrderNumber
	 , intContractHeaderId					= INV.intContractHeaderId
	 , intContractDetailId					= INV.intContractDetailId
	 , intItemContractHeaderId				= INV.intItemContractHeaderId
	 , intItemContractDetailId				= INV.intItemContractDetailId
	 , intItemCategoryId					= INV.intItemCategoryId
	 , intCategoryId						= INV.intCategoryId
	 , dblContractBalance					= ISNULL(CT.dblBalance, 0)
	 , dblItemContractBalance				= ISNULL(ICT.dblBalance, 0)
	 , dblContractAvailable					= INV.dblContractAvailable
	 , intShipmentId						= INV.intShipmentId
	 , intShipmentPurchaseSalesContractId	= INV.intShipmentPurchaseSalesContractId
	 , dblShipmentGrossWt					= INV.dblShipmentGrossWt
	 , dblShipmentTareWt					= INV.dblShipmentTareWt
	 , dblShipmentNetWt						= INV.dblShipmentNetWt
	 , dblUnitQuantity						= INV.dblUnitQuantity
	 , intTicketId							= INV.intTicketId
	 , intTicketHoursWorkedId				= INV.intTicketHoursWorkedId
	 , intCustomerStorageId					= INV.intCustomerStorageId
	 , intSiteDetailId						= INV.intSiteDetailId
	 , intLoadDetailId						= INV.intLoadDetailId
	 , intLotId								= INV.intLotId
	 , intSiteId							= INV.intSiteId
	 , strBillingBy							= INV.strBillingBy
	 , dblPercentFull						= INV.dblPercentFull
	 , dblNewMeterReading					= INV.dblNewMeterReading
	 , dblPreviousMeterReading				= INV.dblPreviousMeterReading
	 , dblConversionFactor					= INV.dblConversionFactor
	 , intPerformerId						= INV.intPerformerId
	 , ysnLeaseBilling						= INV.ysnLeaseBilling
	 , ysnVirtualMeterReading				= INV.ysnVirtualMeterReading
	 , intSCBudgetId						= INV.intSCBudgetId
	 , strSCBudgetDescription				= INV.strSCBudgetDescription
	 , intEntitySalespersonId				= INV.intEntitySalespersonId
	 , ysnBlended							= INV.ysnBlended
	 , intRecipeId							= INV.intRecipeId
	 , intSubLocationId						= INV.intSubLocationId
	 , intCostTypeId						= INV.intCostTypeId
	 , intMarginById						= INV.intMarginById
	 , intCommentTypeId						= INV.intCommentTypeId
	 , intRecipeItemId						= INV.intRecipeItemId
	 , dblMargin							= INV.dblMargin
	 , dblRecipeQuantity					= INV.dblRecipeQuantity
	 , intStorageScheduleTypeId				= INV.intStorageScheduleTypeId
	 , intDestinationGradeId				= INV.intDestinationGradeId
	 , intDestinationWeightId				= INV.intDestinationWeightId
	 , intConcurrencyId						= INV.intConcurrencyId
	 , strVFDDocumentNumber					= INV.strVFDDocumentNumber
	 , strRebateSubmitted					= INV.strRebateSubmitted COLLATE Latin1_General_CI_AS
	 , dblRebateAmount						= INV.dblRebateAmount
	 , dblBaseRebateAmount					= INV.dblBaseRebateAmount
	 , strBuybackSubmitted					= INV.strBuybackSubmitted COLLATE Latin1_General_CI_AS
	 , dblBuybackAmount						= INV.dblBuybackAmount
	 , dblBaseBuybackAmount					= INV.dblBaseBuybackAmount
	 , intLicenseAccountId					= INV.intLicenseAccountId
	 , intMaintenanceAccountId				= INV.intMaintenanceAccountId
	 , strUnitMeasure						= ISNULL(IOUM.strUnitMeasure, '')
     , intUnitMeasureId						= IOUM.intUnitMeasureId
	 , strPriceUnitMeasure					= ISNULL(POUM.strUnitMeasure, '')
     , strOrderUnitMeasure					= ISNULL(OOUM.strUnitMeasure, '')
     , strWeightUnitMeasure					= ISNULL(WOUM.strUnitMeasure, '')
	 , strSalespersonId						= ISNULL(SPER.strSalespersonId, '')
	 , strSiteNumber						= ISNULL(CSITE.strSiteNumber, '') COLLATE Latin1_General_CI_AS
     , strContractNumber					= ISNULL(CT.strContractNumber, '')	 
	 , intContractSeq						= CT.intContractSeq
	 , strItemContractNumber				= ISNULL(ICTH.strContractNumber, '')
	 , intItemContractSeq					= ICT.intLineNo
     , dblOriginalQty						= INV.dblQtyShipped
     , dblOriginalPrice						= INV.dblPrice
     , intOriginalItemUOMId					= INV.intItemUOMId
     , strTaxGroup							= ISNULL(TAXGROUP.strTaxGroup, '')
     , strSalesAccountId					= ISNULL(GL.strAccountId, '')
     , strSalespersonName					= ISNULL(SPER.strSalespersonName, '')
     , intPricingTypeId						= CT.intPricingTypeId
     , strPricingType						= ISNULL(CT.strPricingType, '')
     , strStorageLocation					= ISNULL(ICSLOC.strName, '')
     , strSubLocation						= ISNULL(SMSLOC.strSubLocationName, '')
     , strPrepayType						= CASE WHEN INV.intPrepayTypeId = 1 THEN 'Standard' 
												   WHEN INV.intPrepayTypeId = 2 THEN 'Unit' 
												   WHEN INV.intPrepayTypeId = 3 THEN 'Percentage' 
												   ELSE '0'
											  END COLLATE Latin1_General_CI_AS
     , strStorageTypeDescription			= ISNULL(GRSTYPE.strStorageTypeDescription, '')
     , strCurrency							= ISNULL(CUR.strCurrency, '')
     , dblDefaultFull						= ISNULL( ITMNO.dblDefaultFull, 0.0)
     , ysnAvailableTM						= ITMNO.ysnAvailableTM
     , strItemNo							= ISNULL(ITMNO.strItemNo, '')
     , strItemType							= ISNULL(ITMNO.strType, '')
     , strRequired							= ISNULL(ITMNO.strRequired, '')
     , strBundleType						= ISNULL(ITMNO.strBundleType, '')
	 , strLotTracking						= ISNULL(ITMNO.strLotTracking, '')
     , dblOriginalLicenseAmount				= CASE WHEN ITM.strType =  'Software' THEN dblSalePrice ELSE 0 END
     , dblOriginalMaintenanceAmount			= CASE WHEN ITM.strType = 'Software' THEN
												CASE WHEN ITM.strMaintenanceCalculationMethod = 'Percentage' THEN INV.dblLicenseAmount * dblMaintenanceRatePercentage 
												     ELSE INV.dblLicenseAmount * dblMaintenanceRate END
											  ELSE 0 END
     , dblDiscountAmount					= CASE WHEN ISNULL(INV.dblDiscount, 0) > 0 THEN  ((INV.dblQtyShipped * INV.dblPrice) * (INV.dblDiscount / 100)) ELSE 0 END
     , strTicketNumber						= ISNULL(TICKET.strTicketNumber, '')
     , strCustomerReference					= ISNULL(TICKET.strCustomerReference, '')
     , strDestinationGrade					= ISNULL(GRADE.strWeightGradeDesc, '')
     , strDestinationWeight					= ISNULL(DWEIGHT.strWeightGradeDesc, '')
     , strCurrencyExchangeRateType			= ISNULL(RTYPE.strCurrencyExchangeRateType, '')
     , intOriginDestWeight					= DWEIGHT.intOriginDest
	 , strAddonDetailKey					= INV.strAddonDetailKey
     , ysnAddonParent						= INV.ysnAddonParent
	 , ysnItemContract						= INV.ysnItemContract
	 , dblAddOnQuantity						= INV.dblAddOnQuantity
	 , dblPriceAdjustment					= INV.dblPriceAdjustment
	 , strBOLNumberDetail					= INV.strBOLNumberDetail
	 , strCategoryCode						= ICATEGORY.strCategoryCode
	 , strCategoryDescription				= ICATEGORY.strDescription
	 , ysnHasPricingLayer                   = CASE WHEN ISNULL(APAR.intInvoiceDetailId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
FROM tblARInvoice PINV WITH(NOLOCK)
JOIN tblARInvoiceDetail INV ON INV.intInvoiceId = PINV.intInvoiceId 
LEFT JOIN (
	SELECT intItemUOMId
		 , strUnitMeasure
		 , intUnitMeasureId 
	FROM vyuARItemUOM WITH(NOLOCK)
) IOUM ON INV.intItemUOMId = IOUM.intItemUOMId
LEFT JOIN (
	SELECT intItemUOMId
	     , strUnitMeasure 
	FROM vyuARItemUOM WITH(NOLOCK)
) POUM ON INV.intPriceUOMId = POUM.intItemUOMId	
LEFT JOIN (
	SELECT intItemUOMId
		 , strUnitMeasure 
	FROM vyuAROrderUOM WITH(NOLOCK)
) OOUM ON INV.intOrderUOMId = OOUM.intItemUOMId
LEFT JOIN (
	SELECT intItemUOMId
		 , strUnitMeasure 
	FROM vyuARItemWUOM WITH(NOLOCK)
) WOUM ON INV.intItemWeightUOMId = WOUM.intItemUOMId
LEFT JOIN (
	SELECT intEntityId			= A.intEntityId
		 , strSalespersonId		= CASE WHEN B.strSalespersonId = '' THEN A.strEntityNo ELSE B.strSalespersonId END
		 , strSalespersonName	= A.strName
	FROM tblEMEntity A WITH(NOLOCK)
	JOIN tblARSalesperson B WITH(NOLOCK) ON A.intEntityId = B.intEntityId
) SPER ON ISNULL(INV.intEntitySalespersonId, INV.intPerformerId) = SPER.intEntityId
LEFT JOIN (
	SELECT intSiteID		= intSiteID
		 , strSiteNumber	= REPLACE(STR([intSiteNumber], 4), SPACE(1), '0') 
	FROM tblTMSite  WITH(NOLOCK)
) CSITE ON INV.intSiteId = CSITE.intSiteID
LEFT JOIN ( 
	SELECT intContractDetailId
		 , strContractNumber
		 , intContractSeq
		 , dblBalance
		 , PT.intPricingTypeId
		 , PT.strPricingType				
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH	ON CH.intContractHeaderId	= CD.intContractHeaderId
							   AND CD.intPricingTypeId		NOT IN(4,7)
	JOIN tblCTPricingType PT ON PT.intPricingTypeId	 =	CD.intPricingTypeId
) CT ON INV.intContractDetailId = CT.intContractDetailId
LEFT JOIN ( 
	SELECT intItemContractDetailId		 
		 , intLineNo
		 , dblBalance
	FROM tblCTItemContractDetail ICD
) ICT ON INV.intItemContractDetailId = ICT.intItemContractDetailId
LEFT JOIN (
	SELECT intItemContractHeaderId
		 , strContractNumber
	FROM tblCTItemContractHeader
) ICTH ON INV.intItemContractHeaderId = ICTH.intItemContractHeaderId
LEFT JOIN ( 
	SELECT intTaxGroupId
		 , strTaxGroup
	FROM tblSMTaxGroup WITH(NOLOCK)
) TAXGROUP ON INV.intTaxGroupId = TAXGROUP.intTaxGroupId
LEFT JOIN (
	SELECT intAccountId
	     , strAccountId 
	FROM tblGLAccount WITH(NOLOCK)
) GL ON INV.intSalesAccountId = GL.intAccountId
LEFT JOIN ( 
	SELECT intStorageLocationId
		 , strName
	FROM tblICStorageLocation WITH(NOLOCK)
) ICSLOC ON INV.intStorageLocationId = ICSLOC.intStorageLocationId
LEFT JOIN (
	SELECT intCompanyLocationSubLocationId
		 , strSubLocationName
	FROM tblSMCompanyLocationSubLocation WITH(NOLOCK)
) SMSLOC ON INV.intCompanyLocationSubLocationId = SMSLOC.intCompanyLocationSubLocationId
LEFT JOIN (
	SELECT intStorageScheduleTypeId
		 , strStorageTypeDescription
	FROM tblGRStorageType WITH(NOLOCK)
) GRSTYPE ON INV.intStorageScheduleTypeId = GRSTYPE.intStorageScheduleTypeId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency 
	FROM tblSMCurrency WITH(NOLOCK)
) CUR ON INV.intSubCurrencyId = CUR.intCurrencyID
LEFT JOIN (
	SELECT intItemId
		 , strItemNo
		 , strBundleType
		 , strType
		 , strLotTracking
		 , strModule
		 , strRequired
		 , strMaintenanceCalculationMethod
		 , dblDefaultFull
		 , ysnAvailableTM							
	FROM tblICItem ICITM WITH(NOLOCK)
	LEFT JOIN tblSMModule MODULE WITH(NOLOCK) ON ICITM.intModuleId = MODULE.intModuleId
) ITMNO ON INV.intItemId = ITMNO.intItemId
LEFT JOIN ( 
	SELECT intItemId			= ICITM.intItemId
		 , intItemLocationId	= ICPRICING.intItemLocationId
		 , strType				= ICITM.strType
		 , dblSalePrice			= ISNULL(ICPRICING.dblSalePrice, 0)
		 , dblMaintenanceRate	= ISNULL(dblMaintenanceRate, 0)
		 , intLocationId		= CLOC.intLocationId
		 , dblMaintenanceRatePercentage = (ISNULL(dblMaintenanceRate, 0) / 100)		 
		 , strMaintenanceCalculationMethod
	FROM tblICItem ICITM WITH(NOLOCK) 				
	LEFT JOIN tblICItemLocation CLOC WITH(NOLOCK) ON ICITM.intItemId = CLOC.intItemId					
	LEFT JOIN tblICItemPricing ICPRICING WITH(NOLOCK) ON ICITM.intItemId = ICPRICING.intItemId 
													  AND CLOC.intItemLocationId = ICPRICING.intItemLocationId				
) ITM ON INV.intItemId = ITM.intItemId 
     AND ITM.intLocationId = PINV.intCompanyLocationId
LEFT JOIN (
	SELECT intTicketId
		 , strTicketNumber
		, strCustomerReference		
	FROM tblSCTicket WITH(NOLOCK)
) TICKET ON INV.intTicketId = TICKET.intTicketId
LEFT JOIN (
	SELECT intWeightGradeId
		 , strWeightGradeDesc 
	FROM tblCTWeightGrade WITH(NOLOCK)
) GRADE ON INV.intDestinationGradeId = GRADE.intWeightGradeId	
LEFT JOIN (
	SELECT intWeightGradeId
		 , strWeightGradeDesc
		 , intOriginDest
	FROM vyuARDestinationWeight WITH(NOLOCK)
) DWEIGHT ON INV.intDestinationWeightId = DWEIGHT.intWeightGradeId
LEFT JOIN (
	SELECT intCurrencyExchangeRateTypeId
		 , strCurrencyExchangeRateType
	FROM tblSMCurrencyExchangeRateType WITH(NOLOCK)
) RTYPE ON INV.intCurrencyExchangeRateTypeId = RTYPE.intCurrencyExchangeRateTypeId
LEFT JOIN (
	SELECT intCategoryId
		 , strCategoryCode
		 , strDescription
	FROM tblICCategory WITH(NOLOCK)
) ICATEGORY ON INV.intCategoryId = ICATEGORY.intCategoryId
LEFT JOIN (
	SELECT intInvoiceDetailId
	FROM tblCTPriceFixationDetailAPAR WITH (NOLOCK)	
	WHERE intInvoiceDetailId IS NOT NULL
	GROUP BY intInvoiceDetailId
) APAR ON INV.intInvoiceDetailId = APAR.intInvoiceDetailId
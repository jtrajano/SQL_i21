CREATE VIEW [dbo].[vyuARGetInvoiceDetail]
	AS 
	
	
	
SELECT 
	INV.intInvoiceDetailId,
	INV.intInvoiceId,
	INV.strDocumentNumber,
	INV.intItemId,
	INV.intPrepayTypeId,
	INV.dblPrepayRate,
	INV.strItemDescription,
	INV.dblQtyOrdered,
	INV.intOrderUOMId,
	INV.dblQtyShipped,
	INV.intItemUOMId,
	INV.intPriceUOMId,
	INV.dblItemWeight,
	INV.intItemWeightUOMId,
	INV.dblDiscount,
	INV.dblItemTermDiscount,	
	INV.strItemTermDiscountBy,
	INV.dblItemTermDiscountAmount,
	INV.dblBaseItemTermDiscountAmount,
	INV.dblItemTermDiscountExemption,
	INV.dblBaseItemTermDiscountExemption,
	INV.dblTermDiscountRate,
	INV.ysnTermDiscountExempt,
	INV.dblPrice,
	INV.dblBasePrice,
	INV.dblUnitPrice,
	INV.dblBaseUnitPrice,
	INV.strPricing,
	INV.dblTotalTax,
	INV.dblBaseTotalTax,
	INV.dblTotal,
	INV.dblBaseTotal,
	INV.intCurrencyExchangeRateTypeId,
	INV.intCurrencyExchangeRateId,
	INV.dblCurrencyExchangeRate,
	INV.intSubCurrencyId,
	INV.dblSubCurrencyRate,
	INV.ysnRestricted,
	INV.intAccountId,
	INV.intCOGSAccountId,
	INV.intSalesAccountId,
	INV.intInventoryAccountId,
	INV.intServiceChargeAccountId,
	INV.strMaintenanceType,
	INV.strFrequency,
	INV.dtmMaintenanceDate,
	INV.dblMaintenanceAmount,
	INV.dblBaseMaintenanceAmount,
	INV.dblLicenseAmount,
	INV.dblBaseLicenseAmount,
	INV.intTaxGroupId,
	INV.intStorageLocationId,
	INV.intCompanyLocationSubLocationId,
	INV.intSCInvoiceId,
	INV.strSCInvoiceNumber,
	INV.intInventoryShipmentItemId,
	INV.intInventoryShipmentChargeId,
	INV.strShipmentNumber,
	INV.intSalesOrderDetailId,
	INV.strSalesOrderNumber,
	INV.intContractHeaderId,
	INV.intContractDetailId,
	INV.dblContractBalance,
	INV.dblContractAvailable,
	INV.intShipmentId,
	INV.intShipmentPurchaseSalesContractId,
	INV.dblShipmentGrossWt,
	INV.dblShipmentTareWt,
	INV.dblShipmentNetWt,
	INV.dblUnitQuantity,
	INV.intTicketId,
	INV.intTicketHoursWorkedId,
	INV.intCustomerStorageId,
	INV.intSiteDetailId,
	INV.intLoadDetailId,
	INV.intLotId,
	INV.intSiteId,
	INV.strBillingBy,
	INV.dblPercentFull,
	INV.dblNewMeterReading,
	INV.dblPreviousMeterReading,
	INV.dblConversionFactor,
	INV.intPerformerId,
	INV.ysnLeaseBilling,
	INV.ysnVirtualMeterReading,
	INV.intSCBudgetId,
	INV.strSCBudgetDescription,
	INV.intEntitySalespersonId,
	INV.ysnBlended,
	INV.intRecipeId,
	INV.intSubLocationId,
	INV.intCostTypeId,
	INV.intMarginById,
	INV.intCommentTypeId,
	INV.intRecipeItemId,
	INV.dblMargin,
	INV.dblRecipeQuantity,
	INV.intStorageScheduleTypeId,
	INV.intDestinationGradeId,
	INV.intDestinationWeightId,
	INV.intConcurrencyId,
	INV.strVFDDocumentNumber,
	INV.strRebateSubmitted,
	INV.dblRebateAmount,
	INV.dblBaseRebateAmount,
	INV.strBuybackSubmitted,
	INV.dblBuybackAmount,
	INV.dblBaseBuybackAmount,


	strUnitMeasure = isnull(IOUM.strUnitMeasure, ''),
    intUnitMeasureId =  IOUM.intUnitMeasureId,
	strPriceUnitMeasure = isnull(POUM.strUnitMeasure, ''),
    strOrderUnitMeasure = isnull(OOUM.strUnitMeasure, ''),
    strWeightUnitMeasure =  isnull(WOUM.strUnitMeasure, ''),
	strSalespersonId =  isnull(SPER.strSalespersonId, ''),

	strSiteNumber =  isnull(CSITE.strSiteNumber, ''),
    strContractNumber =  isnull(CT.strContractNumber, ''),
	intContractSeq =  CT.intContractSeq,
    dblOriginalQty =  INV.dblQtyShipped,
    dblOriginalPrice = INV.dblPrice,
    intOriginalItemUOMId = INV.intItemUOMId,
    strTaxGroup = isnull(TAXGROUP.strTaxGroup, ''),
    strSalesAccountId = isnull(GL.strAccountId, ''),
    strSalespersonName = isnull(SPER.strSalespersonName, ''),
    intPricingTypeId = CT.intPricingTypeId,
    strPricingType = isnull(CT.strPricingType, ''),
    strStorageLocation = isnull(ICSLOC.strName, ''),
    strSubLocation = isnull(SMSLOC.strSubLocationName, ''),
    strPrepayType = CASE WHEN INV.intPrepayTypeId = 1 THEN 'Standard' 
						WHEN INV.intPrepayTypeId = 2 THEN 'Unit' 
						WHEN INV.intPrepayTypeId = 3 THEN 'Percentage' 
					ELSE '0'
					END,
    strStorageTypeDescription = isnull(GRSTYPE.strStorageTypeDescription, ''),
    strCurrency = isnull(CUR.strCurrency, ''),
    dblDefaultFull = ISNULL( ITMNO.dblDefaultFull, 0.0),
    ysnAvailableTM = ITMNO.ysnAvailableTM,
    strItemNo = isnull(ITMNO.strItemNo, ''),
    strItemType = isnull(ITMNO.strType, ''),
    strRequired = isnull(ITMNO.strRequired, ''),
    strBundleType = isnull(ITMNO.strBundleType, ''),
	strLotTracking = isnull(ITMNO.strLotTracking, ''),
    dblOriginalLicenseAmount = CASE WHEN ITM.strType =  'Software' THEN dblSalePrice ELSE 0 END,
    dblOriginalMaintenanceAmount =  CASE WHEN ITM.strType = 'Software' THEN
										CASE WHEN ITM.strMaintenanceCalculationMethod = 'Percentage' THEN 
											INV.dblLicenseAmount * dblMaintenanceRatePercentage 
										ELSE  INV.dblLicenseAmount * dblMaintenanceRate END
									ELSE 0 END,
    dblDiscountAmount = CASE WHEN ISNULL(INV.dblDiscount, 0) > 0 THEN  ((INV.dblQtyShipped * INV.dblPrice) * (INV.dblDiscount / 100)) ELSE 0 END,
    strTicketNumber = isnull(TICKET.strTicketNumber, ''),
    strCustomerReference = isnull(TICKET.strCustomerReference, ''),
    strDestinationGrade = isnull(GRADE.strWeightGradeDesc, ''),
    strDestinationWeight = isnull(DWEIGHT.strWeightGradeDesc, ''),
    strCurrencyExchangeRateType = isnull(RTYPE.strCurrencyExchangeRateType, ''),
    intOriginDestWeight = DWEIGHT.intOriginDest,
	strAddonDetailKey,
    ysnAddonParent
FROM  ( SELECT intInvoiceId, intCompanyLocationId 
			FROM tblARInvoice WITH(NOLOCK) ) PINV		
	JOIN tblARInvoiceDetail INV
		ON INV.intInvoiceId = PINV.intInvoiceId 
	LEFT JOIN (SELECT intItemUOMId, strUnitMeasure, intUnitMeasureId 
				FROM vyuARItemUOM WITH(NOLOCK) ) IOUM
		ON INV.intItemUOMId = IOUM.intItemUOMId
	LEFT JOIN (SELECT intItemUOMId, strUnitMeasure 
				FROM vyuARItemUOM WITH(NOLOCK)) POUM
		ON INV.intPriceUOMId = POUM.intItemUOMId	
	LEFT JOIN (SELECT intItemUOMId, strUnitMeasure 
				FROM vyuAROrderUOM WITH(NOLOCK)) OOUM
		ON INV.intOrderUOMId = OOUM.intItemUOMId
	LEFT JOIN (SELECT intItemUOMId, strUnitMeasure 
				FROM vyuARItemWUOM WITH(NOLOCK)) WOUM
		ON INV.intItemWeightUOMId = WOUM.intItemUOMId
	LEFT JOIN ( SELECT A.intEntityId, 
						strSalespersonId = CASE WHEN B.strSalespersonId = '0' THEN A.strEntityNo ELSE B.strSalespersonId END ,
						strSalespersonName = A.strName
				FROM tblEMEntity A  WITH(NOLOCK)
					JOIN tblARSalesperson B  WITH(NOLOCK) ON
					A.intEntityId = B.[intEntityId]) SPER
		ON INV.intEntitySalespersonId = SPER.intEntityId
	LEFT JOIN ( SELECT intSiteID, 
						[strSiteNumber] = REPLACE(STR([intSiteNumber], 4), SPACE(1), '0') 
				FROM tblTMSite  WITH(NOLOCK)) CSITE
		ON INV.intSiteId = CSITE.intSiteID
	LEFT JOIN ( SELECT intContractDetailId, strContractNumber, intContractSeq,
					PT.intPricingTypeId, PT.strPricingType
				
				FROM tblCTContractDetail				CD
				JOIN	tblCTContractHeader				CH	ON  CH.intContractHeaderId				=   CD.intContractHeaderId
														AND CH.intContractTypeId				=	2
														AND CD.intPricingTypeId				NOT IN	(4,7)
				JOIN	tblCTPricingType				PT	ON  PT.intPricingTypeId					=	CD.intPricingTypeId
				
				) CT
		ON INV.intContractDetailId = CT.intContractDetailId
	LEFT JOIN ( SELECT intTaxGroupId, strTaxGroup
				FROM tblSMTaxGroup WITH(NOLOCK)) TAXGROUP	
		ON INV.intTaxGroupId = TAXGROUP.intTaxGroupId
	LEFT JOIN ( SELECT intAccountId, strAccountId 
				FROM tblGLAccount WITH(NOLOCK)) GL
		ON INV.intAccountId = GL.intAccountId
	LEFT JOIN ( SELECT intStorageLocationId, strName
				FROM tblICStorageLocation WITH(NOLOCK)) ICSLOC
		ON INV.intStorageLocationId = ICSLOC.intStorageLocationId
	LEFT JOIN ( SELECT intCompanyLocationSubLocationId, strSubLocationName
				FROM tblSMCompanyLocationSubLocation WITH(NOLOCK)) SMSLOC
		ON INV.intCompanyLocationSubLocationId = SMSLOC.intCompanyLocationSubLocationId
	LEFT JOIN ( SELECT intStorageScheduleTypeId, strStorageTypeDescription
				FROM tblGRStorageType WITH(NOLOCK)) GRSTYPE
		ON INV.intStorageScheduleTypeId = GRSTYPE.intStorageScheduleTypeId
	LEFT JOIN (SELECT intCurrencyID, strCurrency 
				FROM tblSMCurrency WITH(NOLOCK)) CUR
		ON INV.intSubCurrencyId = CUR.intCurrencyID
	LEFT JOIN (SELECT		intItemId,				strItemNo,
								strBundleType,			strType,
								strLotTracking,			strModule,				
								strRequired,			strMaintenanceCalculationMethod,
								dblDefaultFull,			ysnAvailableTM							
				FROM tblICItem ICITM WITH(NOLOCK)
					LEFT JOIN tblSMModule MODULE WITH(NOLOCK)
						ON ICITM.intModuleId = MODULE.intModuleId) ITMNO
		ON INV.intItemId = ITMNO.intItemId
	LEFT JOIN ( SELECT		ICITM.intItemId,		ICPRICING.intItemLocationId,
								strType,				strMaintenanceCalculationMethod,					
								dblSalePrice = ISNULL(ICPRICING.dblSalePrice, 0),
								dblMaintenanceRate = ISNULL(dblMaintenanceRate, 0),
								dblMaintenanceRatePercentage = (ISNULL(dblMaintenanceRate, 0) / 100),
								intLocationId
			FROM tblICItem ICITM WITH(NOLOCK) 				
				LEFT JOIN tblICItemLocation CLOC WITH(NOLOCK)  
					ON ICITM.intItemId = CLOC.intItemId					
				LEFT JOIN tblICItemPricing ICPRICING WITH(NOLOCK) 
					ON ICITM.intItemId = ICPRICING.intItemId 
						AND CLOC.intItemLocationId = ICPRICING.intItemLocationId
				
		) ITM
		ON INV.intItemId = ITM.intItemId AND ITM.intLocationId = PINV.intCompanyLocationId
	LEFT JOIN (SELECT intTicketId, strTicketNumber, strCustomerReference		
			FROM tblSCTicket WITH(NOLOCK)) TICKET
		ON INV.intTicketId = TICKET.intTicketId
	LEFT JOIN ( SELECT intWeightGradeId, strWeightGradeDesc 
			FROM tblCTWeightGrade WITH(NOLOCK)) GRADE
		ON INV.intDestinationGradeId = GRADE.intWeightGradeId	
	LEFT JOIN ( SELECT intWeightGradeId, strWeightGradeDesc, intOriginDest
			FROM vyuARDestinationWeight WITH(NOLOCK)) DWEIGHT
		ON INV.intDestinationWeightId = DWEIGHT.intWeightGradeId
	LEFT JOIN ( SELECT intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType
			FROM tblSMCurrencyExchangeRateType WITH(NOLOCK)) RTYPE
		ON INV.intCurrencyExchangeRateTypeId = RTYPE.intCurrencyExchangeRateTypeId
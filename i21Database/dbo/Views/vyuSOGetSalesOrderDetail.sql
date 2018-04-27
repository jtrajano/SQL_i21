CREATE VIEW [dbo].[vyuSOGetSalesOrderDetail]
	AS 
	
	
SELECT 

		SO.intSalesOrderDetailId,
        SO.intSalesOrderId,
        SO.intItemId,
        SO.strItemDescription,
        SO.strComments,
        SO.intItemUOMId,
        SO.dblQtyShipped,
        SO.dblQtyOrdered,
        SO.dblQtyAllocated,
        SO.dblDiscount,
        SO.dblItemTermDiscount,
        SO.strItemTermDiscountBy,
        SO.dblPrice,
        SO.dblBasePrice,
        SO.strPricing,
        SO.dblTotalTax,
        SO.dblBaseTotalTax,
        SO.dblTotal,
        SO.dblBaseTotal,
        SO.intAccountId,
        SO.intCOGSAccountId,
        SO.intSalesAccountId,
        SO.intInventoryAccountId,
        SO.intStorageLocationId,
        SO.strMaintenanceType,
        SO.strFrequency,
        SO.dtmMaintenanceDate,
        SO.dblMaintenanceAmount,
        SO.dblBaseMaintenanceAmount,
        SO.dblLicenseAmount,
        SO.dblBaseLicenseAmount,
        SO.intContractHeaderId,
        SO.intContractDetailId,
        SO.dblContractBalance,
        SO.dblContractAvailable,
        SO.ysnBlended,
        SO.intTaxGroupId,
        SO.intRecipeId,
        SO.intSubLocationId,
        SO.dblItemWeight,
        SO.dblOriginalItemWeight,
        SO.intItemWeightUOMId,
        SO.intCostTypeId,
        SO.intMarginById,
        SO.intCommentTypeId,
        SO.intRecipeItemId,
        SO.dblMargin,
        SO.dblRecipeQuantity,
        SO.intCustomerStorageId,
        SO.intStorageScheduleTypeId,
        SO.intConcurrencyId,
        SO.strVFDDocumentNumber,
        SO.intCurrencyExchangeRateTypeId,
        SO.intCurrencyExchangeRateId,
        SO.dblCurrencyExchangeRate,
        strItemNo = ITM.strItemNo,
        strBundleType = ITM.strBundleType,
        strUnitMeasure = ITMUOM.strUnitMeasure,
        intUnitMeasureId = ITMUOM.intUnitMeasureId,

        strWeightUnitMeasure = ITMWUOM.strUnitMeasure,
        strStorageLocation = SLOC.strName,
        strContractNumber = CDET.strContractNumber,
        intContractSeq = CDET.intContractSeq,
        strItemType = ITM.strType,
        strLotTracking = ITM.strLotTracking,
        strModule = ITM.strModule,
        dblOriginalQty = SO.dblQtyOrdered,
        dblOriginalPrice = SO.dblPrice,
        intOriginalItemUOMId = SO.intItemUOMId,
        strTaxGroup = TAXGRP.strTaxGroup,
        intPricingTypeId = CDET.intPricingTypeId,
        strPricingType = CDET.strPricingType,
        ysnLoad = CDET.ysnLoad,
        strCurrency = CUR.strCurrency,
        dblOriginalLicenseAmount = CASE WHEN ITM.strType =  'Software' THEN dblSalePrice ELSE 0 END,
        dblOriginalMaintenanceAmount = CASE WHEN ITM.strType = 'Software' THEN
											CASE WHEN ITM.strMaintenanceCalculationMethod = 'Percentage' THEN 
												dblMaintenanceRatePercentage 
											ELSE  dblMaintenanceRate END
										ELSE 0 END,
        dblDiscountAmount = CASE WHEN ISNULL(SO.dblDiscount, 0) > 0 THEN  ((SO.dblQtyOrdered * SO.dblPrice) * (SO.dblDiscount / 100)) ELSE 0 END,
        strStorageTypeDescription = STORAGETYPE.strStorageTypeDescription,
        strRequired = ITM.strRequired,
        strCurrencyExchangeRateType = CURTYPE.strCurrencyExchangeRateType

	
	from tblSOSalesOrderDetail SO
		INNER JOIN ( SELECT intSalesOrderId, intCompanyLocationId 
			FROM tblSOSalesOrder  WITH(NOLOCK) ) OSO
		ON SO.intSalesOrderId = OSO.intSalesOrderId 
		LEFT JOIN ( SELECT		ICITM.intItemId,		strItemNo,
								strBundleType,			strType,
								strLotTracking,			ICPRICING.intItemLocationId,
								strModule,				strRequired,
								strMaintenanceCalculationMethod,
								dblSalePrice = ISNULL(ICPRICING.dblSalePrice, 0),
								dblMaintenanceRate = ISNULL(dblMaintenanceRate, 0),
								dblMaintenanceRatePercentage = ISNULL(dblSalePrice, 0) * (ISNULL(dblMaintenanceRate, 0) / 100)
			FROM tblICItem ICITM WITH(NOLOCK) 
				LEFT JOIN tblICItemPricing ICPRICING WITH(NOLOCK) 
					ON ICITM.intItemId = ICPRICING.intItemId 
				LEFT JOIN tblSMModule MODULE WITH(NOLOCK)
					ON ICITM.intModuleId = MODULE.intModuleId
		) ITM
		ON SO.intItemId = ITM.intItemId-- AND ITM.intItemLocationId = OSO.intCompanyLocationId

		LEFT JOIN ( SELECT		intItemUOMId,			strUnitMeasure,
								intUnitMeasureId
			FROM vyuARItemUOM WITH(NOLOCK)) ITMUOM
		ON SO.intItemUOMId = ITMUOM.intItemUOMId
		
		LEFT JOIN ( SELECT		intItemWeightUOMId,		strUnitMeasure 
			FROM vyuARItemWUOM  WITH(NOLOCK)) ITMWUOM
		ON SO.intItemWeightUOMId = ITMWUOM.intItemWeightUOMId

		LEFT JOIN ( SELECT		intStorageLocationId,	strName 
			FROM tblICStorageLocation  WITH(NOLOCK)) SLOC
		ON SO.intStorageLocationId = SLOC.intStorageLocationId

		LEFT JOIN ( SELECT		intContractDetailId,	strContractNumber,
								intContractSeq,			intPricingTypeId,
								strPricingType,			ysnLoad
			FROM vyuARCustomerContract WITH(NOLOCK)) CDET
		ON SO.intContractDetailId = CDET.intContractDetailId
		LEFT JOIN ( SELECT		intTaxGroupId,			strTaxGroup 
			FROM tblSMTaxGroup ) TAXGRP
		ON SO.intTaxGroupId = TAXGRP.intTaxGroupId
		LEFT JOIN ( SELECT		intCurrencyExchangeRateTypeId,
								strCurrencyExchangeRateType
			FROM tblSMCurrencyExchangeRateType WITH(NOLOCK) ) CURTYPE
		ON SO.intCurrencyExchangeRateTypeId = CURTYPE.intCurrencyExchangeRateTypeId
		LEFT JOIN ( SELECT		intCurrencyID,			strCurrency
			FROM tblSMCurrency WITH(NOLOCK)) CUR
		ON SO.intSubCurrencyId = CUR.intCurrencyID 
		LEFT JOIN ( SELECT		intStorageScheduleTypeId,	
								strStorageTypeDescription
			FROM tblGRStorageType ) STORAGETYPE
		ON SO.intStorageScheduleTypeId = STORAGETYPE.intStorageScheduleTypeId

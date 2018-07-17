CREATE VIEW [dbo].[vyuAPRptTaxReport]
AS

SELECT APB.strBillId
	   ,APB.dtmDate
	   ,APB.strVendorOrderNumber
	   ,ISNULL(V.strVendorId, E.strEntityNo)  as strVendorId 
	   ,E.strName 
	   ,ISNULL(V.strVendorId, E.strEntityNo) + ' ' + E.strName AS strVendorName
	   ,C.strCompanyName
	   ,C.strCompanyAddress
	   ,APB.intCurrencyId
	   ,SMC.strCurrency
	   ,SMC.strDescription
	   ,TAXDETAIL.*
	   ,dblTaxDifference = (TAXDETAIL.dblAdjustedTax - TAXDETAIL.dblTax) * [dbo].[fnAPGetVoucherAmountMultiplier](APB.intTransactionType)
	   ,dblTaxAmount     = TAXTOTAL.dblTotalTax--TAXDETAIL.dblAdjustedTax * [dbo].[fnAPGetVoucherAmountMultiplier](APB.intTransactionType)
	   ,dblNonTaxable    = (CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 THEN  (TAXDETAIL.dblSubTotal) / ISNULL(TAXTOTAL.intTaxCodeCount, 1.000000) ELSE 0.000000 END) * [dbo].[fnAPGetVoucherAmountMultiplier](APB.intTransactionType)
	   ,dblTaxable       = TAXDETAIL.dblSubTotal--(CASE WHEN TAXDETAIL.dblAdjustedTax > 0.000000 THEN  (TAXDETAIL.dblSubTotal) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) ELSE 0.000000 END) * [dbo].[fnAPGetVoucherAmountMultiplier](APB.intTransactionType)
	   ,dblTotalVoucher  = APB.dblTotal * [dbo].[fnARGetInvoiceAmountMultiplier](APB.intTransactionType)
	   ,dblTaxCollected  = ISNULL(APB.dblTax, 0) * [dbo].[fnAPGetVoucherAmountMultiplier](APB.intTransactionType)
FROM dbo.tblAPBill APB
INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId
LEFT JOIN  dbo.tblSMCurrency SMC ON SMC.intCurrencyID = APB.intCurrencyId
OUTER APPLY (SELECT TOP 1 strCompanyName
						, strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
			 FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) C
INNER JOIN (
SELECT DISTINCT TC.intTaxCodeId
				 , TC.strTaxAgency
				 , TC.strTaxCode				 
				 , strTaxCodeDescription = TC.strDescription
				 , TC.intTaxClassId
				 , TCS.strTaxClass
				 , TC.strCountry
				 , TC.strState
				 , TC.strCounty
				 , TC.strCity
				 , TC.intSalesTaxAccountId
				 , SalesTaxAccount		= SA.strAccountId
				 , TC.intPurchaseTaxAccountId
				 , PurchaseTaxAccount	= ISNULL(PA.strAccountId, '')
				 , BDT.strCalculationMethod
				 , BDT.dblRate
				 , BD.intBillId				 
				 , intItemId			= ITEMDETAIL.intItemId
				 , strItemNo			= ITEMDETAIL.strItemNo
				 , dblCost				= BD.dblCost
				 , dblQtyReceived		= BD.dblQtyReceived
				 , dblSubTotal			= BD.dblTotal
				 , intCategoryId		= ITEMDETAIL.intCategoryId
				 , strItemCategory		= ITEMDETAIL.strCategoryCode
				 , BDT.dblAdjustedTax	 				 				 
				 , BDT.dblTax
				 , BD.intBillDetailId
				 , dblTotalAdjustedTax  = SUM(BDT.dblAdjustedTax)
				 , dblTotalTax			= SUM(BDT.dblTax)
			FROM dbo.tblSMTaxCode TC WITH (NOLOCK)
			INNER JOIN dbo.tblSMTaxClass TCS ON  TC.intTaxClassId = TCS.intTaxClassId
			LEFT OUTER JOIN (SELECT intAccountId
									, strAccountId 
								FROM dbo.tblGLAccount WITH (NOLOCK)
			) SA ON TC.intPurchaseTaxAccountId = SA.intAccountId
			LEFT OUTER JOIN (SELECT intAccountId
									, strAccountId 
								FROM dbo.tblGLAccount WITH (NOLOCK)
			) PA ON TC.intPurchaseTaxAccountId = PA.intAccountId
			LEFT OUTER JOIN (SELECT intBillDetailId
									, intTaxCodeId
									, strCalculationMethod
									, dblRate
									, dblAdjustedTax = CASE WHEN ysnTaxExempt = 1 then 0 else dblAdjustedTax end
									, dblTax 
								FROM dbo.tblAPBillDetailTax WITH (NOLOCK)
			) BDT ON TC.intTaxCodeId = BDT.intTaxCodeId 
			INNER JOIN (SELECT intBillId
								, intItemId
								, intBillDetailId
								, dblCost
								, dblQtyReceived
								, dblTotal
								, intTaxGroupId
						FROM dbo.tblAPBillDetail WITH (NOLOCK)
			) BD ON BDT.intBillDetailId = BD.intBillDetailId	
			OUTER APPLY (SELECT TOP 1 intItemId
									, ICI.intCategoryId
									, strItemNo
									, strCategoryCode
							FROM dbo.tblICItem ICI WITH (NOLOCK)
							LEFT JOIN (SELECT intCategoryId
											, strCategoryCode 
									FROM dbo.tblICCategory WITH (NOLOCK)
							) ICC ON ICI.intCategoryId = ICC.intCategoryId
							WHERE BD.intItemId = ICI.intItemId) ITEMDETAIL	
	WHERE BDT.dblTax != 0
	GROUP BY
				 BD.intBillDetailId
				,TC.intTaxCodeId
				,TC.strTaxAgency
				,TC.strTaxCode
				,TC.strDescription
				,TC.intTaxClassId
				,TCS.strTaxClass
				,TC.strCountry
				,TC.strState
				,TC.strCounty
				,TC.strCity
				,TC.intSalesTaxAccountId
				,SA.strAccountId
				,TC.intPurchaseTaxAccountId
				,ISNULL(PA.strAccountId, '')	
				,BDT.strCalculationMethod
				,BDT.dblRate
				,BDT.dblAdjustedTax
				,BDT.dblTax
				,ITEMDETAIL.intItemId
				,BD.dblCost
				,BD.dblQtyReceived
				,BD.intBillId
				,BD.dblTotal
				,ITEMDETAIL.strItemNo
				,ITEMDETAIL.intCategoryId
				,ITEMDETAIL.strCategoryCode
) TAXDETAIL  ON APB.intBillId = TAXDETAIL.intBillId
LEFT OUTER JOIN (SELECT intBillDetailId
				      , dblTotalAdjustedTax	= SUM(CASE WHEN ysnTaxExempt = 1 then 0 else dblAdjustedTax end)
				      , dblTotalTax			= SUM(dblTax)
					  , intTaxCodeCount		= COUNT(intBillDetailTaxId )
				 FROM dbo.tblAPBillDetailTax WITH (NOLOCK)
				 GROUP BY intBillDetailId
) TAXTOTAL ON TAXDETAIL.intBillDetailId = TAXTOTAL.intBillDetailId
WHERE 
	APB.ysnPosted = 1 and APB.dblTax <> 0
GO
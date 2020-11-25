﻿CREATE PROCEDURE uspLGGetWeightClaimsDebitNoteReport 
	@xmlParam NVARCHAR(MAX) = NULL
AS
DECLARE @intWeightClaimId INT
DECLARE @xmlDocumentId INT
DECLARE @strUserName NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @strCompanyName NVARCHAR(100)
	,@strCompanyAddress NVARCHAR(100)
	,@strContactName NVARCHAR(50)
	,@strCounty NVARCHAR(25)
	,@strCity NVARCHAR(25)
	,@strState NVARCHAR(50)
	,@strZip NVARCHAR(12)
	,@strCountry NVARCHAR(25)
	,@strPhone NVARCHAR(50)
	,@ysnPrintLogo BIT
	,@intLaguageId			INT
	,@strExpressionLabelName	NVARCHAR(50) = 'Expression'
	,@strMonthLabelName		NVARCHAR(50) = 'Month'

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
	)

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
	,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)
    
INSERT INTO @temp_xml_table
SELECT	*  
FROM	OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)  
WITH (  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50)  
)  

SELECT @intWeightClaimId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intWeightClaimId'

SELECT @intLaguageId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intSrLanguageId'

SELECT @intLoadId = intLoadId
FROM tblLGWeightClaim
WHERE intWeightClaimId = @intWeightClaimId

SELECT TOP 1 @ysnPrintLogo = ISNULL(ysnPrintLogo, 0)
FROM tblLGCompanyPreference

/*Declared variables for translating expression*/
declare @via nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'via'),'via');
declare @Voucher nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Voucher'),'Voucher');
declare @Invoice nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Invoice'),'Invoice');
declare @strVoucherBankInfo1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Please transfer this amount in our favor with'),'Please transfer this amount in our favor with');
declare @strVoucherBankInfo2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'IBAN'),'IBAN');
declare @strVoucherBankInfo3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Swift'),'Swift');

SELECT TOP 1 @strCompanyName = tblSMCompanySetup.strCompanyName
	,@strCompanyAddress = tblSMCompanySetup.strAddress
	,@strContactName = tblSMCompanySetup.strContactName
	,@strCounty = tblSMCompanySetup.strCounty
	,@strCity = tblSMCompanySetup.strCity
	,@strState = tblSMCompanySetup.strState
	,@strZip = tblSMCompanySetup.strZip
	,@strCountry = isnull(rtCompanyTranslation.strTranslation,tblSMCompanySetup.strCountry)
	,@strPhone = tblSMCompanySetup.strPhone
FROM tblSMCompanySetup
left join tblSMCountry				rtCompanyCountry on lower(rtrim(ltrim(rtCompanyCountry.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
left join tblSMScreen				rtCompanyScreen on rtCompanyScreen.strNamespace = 'i21.view.Country'
left join tblSMTransaction			rtCompanyTransaction on rtCompanyTransaction.intScreenId = rtCompanyScreen.intScreenId and rtCompanyTransaction.intRecordId = rtCompanyCountry.intCountryID
left join tblSMReportTranslation	rtCompanyTranslation on rtCompanyTranslation.intLanguageId = @intLaguageId and rtCompanyTranslation.intTransactionId = rtCompanyTransaction.intTransactionId and rtCompanyTranslation.strFieldName = 'Country'

SELECT DISTINCT WC.intWeightClaimId
	,WC.intLoadId
	,strWeightClaimNumber = WC.strReferenceNumber
	,strCompanyName = @strCompanyName
	,strCompanyAddress = @strCompanyAddress
	,strCompanyContactName = @strContactName
	,strCompanyCounty = @strCounty
	,strCompanyCity = @strCity
	,strCompanyState = @strState
	,strCompanyZip = @strZip
	,strCompanyCountry = @strCountry
	,strCompanyPhone = @strPhone
	,strCityStateZip = @strCity + ', ' + @strState + ', ' + @strZip + ', '
	,strCityAndDate = @strCity + ', '+ DATENAME(dd,WC.dtmTransDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,WC.dtmTransDate),3)),LEFT(DATENAME(MONTH,WC.dtmTransDate),3)) + ' ' + DATENAME(yyyy,WC.dtmTransDate)
	,strTransDate = dbo.fnConvertDateToReportDateFormat(WC.dtmTransDate, 0)
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,strCustomerName = E.strName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,strCountry = isnull(rtELTranslation.strTranslation,EL.strCountry)
	,strVendorAddress = E.strName + CHAR(13) + EL.strAddress + CHAR(13) + EL.strZipCode + ' ' + EL.strCity + CHAR(13) + EL.strState + ' ' + isnull(rtELTranslation.strTranslation,EL.strCountry)
	,B.strBillId
	,strShippingLine = @via + ' ' + ShippingLine.strName
	,L.strMVessel
	,L.strPackingDescription
	,CH.strContractNumber
	,CH.dtmContractDate
	,strContractDate = dbo.fnConvertDateToReportDateFormat(CH.dtmContractDate, 0)
	,CH.strCustomerContract
	,CH.dblQuantity
	,strCommodityUnitMeasure = CMUM.strUnitMeasure
	,strContractQuantityInfo = LTRIM(dbo.fnRemoveTrailingZeroes(CH.dblQuantity)) + ' ' + CMUM.strUnitMeasure
	,BA.strBankAccountNo
	,BA.strIBAN
	,BA.strSWIFT
	,BA.strBankName
	,B.strRemarks
	,dblTotalClaimAmount = ROUND(SUM(WCD.dblClaimAmount), 2)
	,strMemoType = CASE 
		WHEN WCD.intBillId IS NOT NULL
			THEN @Voucher
		WHEN WCD.intInvoiceId IS NOT NULL
			THEN @Invoice
		END
	,strVoucherBankInfo = @strVoucherBankInfo1 + ': ' + CHAR(13) + CHAR(13) + BA.strBankName + CHAR(13) + @strVoucherBankInfo2 + ' : ' + ISNULL(BA.strIBAN, '') + CHAR(13) + @strVoucherBankInfo3 + ' : ' + ISNULL(BA.strSWIFT, '')
	,blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo')
	,blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo')
	,blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')
	,blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
	,dblFromNet = ISNULL(WCD.dblFromNet, 0)
	,dblToGross = COALESCE(WCD.dblToGross, WCD.dblToNet, 0)
	,dblToTare = ISNULL(WCD.dblToTare, 0)
	,dblToNet = ISNULL(WCD.dblToNet, 0)
	,dblWeightDifference = (ISNULL(WCD.dblFromNet,0) - ISNULL(WCD.dblToNet,0))
	,strUnitMeasure = isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure)
	,strUnitMeasureSymbol = WUOM.strSymbol
	,strWeightInfo = LTRIM(dbo.fnRemoveTrailingZeroes(WCD.dblFromNet)) + ' ' + isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure)
	,dblGross = ISNULL(LD.dblGross, 0)
	,dblTare = ISNULL(LD.dblTare, 0)
	,dblNet = ISNULL(LD.dblNet, 0)
	,strLoadWeightUnitMeasure = isnull(rtUMTranslation.strTranslation,UM.strUnitMeasure)
	,dblFranchise = ISNULL(WG.dblFranchise, 0)
	,dblFranchiseWt = ISNULL(WCD.dblFranchiseWt, 0)
	,dblClaimableWt = ABS(WCD.dblClaimableWt)
	,WCD.dblUnitPrice
	,WCD.intCurrencyId
	,CU.strCurrency
	,strPriceInfo = LTRIM(CU.strCurrency) + ' ' + LTRIM(dbo.fnRemoveTrailingZeroes(WCD.dblUnitPrice))
	,strPriceUOM = isnull(rtPRUTranslation.strTranslation,PRU.strUnitMeasure)
	,strPriceUOMInfo = '/'+ LTRIM(isnull(rtPRUTranslation.strTranslation,PRU.strUnitMeasure))
	,WCD.dblClaimAmount
	,strClaimCurrency = CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END
	,strTotalAmountInfo = LTRIM(CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END) + ' ' + CONVERT(NVARCHAR(50), CONVERT(DECIMAL(10, 2), ROUND(WCD.dblClaimAmount,2)))
	,I.strItemNo
	,strItemDescription = isnull(rtITranslation.strTranslation,I.strDescription)
	,strInvoiceNo = VIN.strVendorOrderNumber
	,dblReceivedGross = CASE WHEN (IRI.dblGross IS NOT NULL) THEN IRI.dblGross - ISNULL(IRN.dblGross, 0) ELSE LD.dblGross END
	,dblReceivedNet = CASE WHEN (IRI.dblNet IS NOT NULL) THEN IRI.dblNet - ISNULL(IRN.dblNet, 0) ELSE LD.dblNet END
	,dblReceivedTare = CASE WHEN (IRI.dblNet IS NOT NULL) THEN
						(ISNULL(IRI.dblGross - ISNULL(IRN.dblGross, 0),0) - ISNULL(IRI.dblNet - ISNULL(IRN.dblNet, 0),0))
						ELSE LD.dblTare END
	,WC.dtmActualWeighingDate
	,VEN.strTaxNumber
	,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
	,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)	
FROM tblLGWeightClaim WC
JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity E ON E.intEntityId = WCD.intPartyEntityId
JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN (
	SELECT TOP 1 LOD.intPCompanyLocationId
		,LOD.intPContractDetailId
		,LOD.intVendorEntityId
		,LOD.intVendorEntityLocationId
		,LOD.intLoadId
		,LOD.intCustomerEntityId
		,LOD.intCustomerEntityLocationId
		,LOD.dblGross
		,LOD.dblTare
		,LOD.dblNet
		,LOD.intItemUOMId
		,LOD.intWeightItemUOMId
		,LOD.intLoadDetailId
	FROM tblLGLoadDetail LOD
	WHERE LOD.intLoadId = @intLoadId
	) LD ON WCD.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId 
	AND ((LD.intVendorEntityId = WCD.intPartyEntityId AND EL.ysnDefaultLocation = 1)
		OR (LD.intVendorEntityId <> WCD.intPartyEntityId 
			AND ((intVendorEntityLocationId IS NOT NULL AND EL.intEntityLocationId = LD.intVendorEntityLocationId)
				OR (intVendorEntityLocationId IS NULL AND EL.ysnDefaultLocation = 1))))
LEFT JOIN tblAPBill B ON B.intBillId = WCD.intBillId
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = B.intBankInfoId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblAPVendor VEN ON VEN.intEntityId = E.intEntityId
LEFT JOIN tblICCommodityUnitMeasure CMU ON CMU.intCommodityUnitMeasureId = CH.intCommodityUOMId
LEFT JOIN tblICUnitMeasure CMUM ON CMUM.intUnitMeasureId = CMU.intUnitMeasureId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM PUM ON PUM.intItemUOMId = WCD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure PRU ON PRU.intUnitMeasureId = PUM.intUnitMeasureId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
LEFT JOIN tblSMCurrency MCU ON MCU.intCurrencyID = CU.intMainCurrencyId
OUTER APPLY (SELECT TOP 1 strVendorOrderNumber FROM tblAPBill v1 
			INNER JOIN tblAPBillDetail v2 ON v1.intBillId = v2.intBillId 
			WHERE v2.intContractDetailId = CD.intContractDetailId
			AND v1.intTransactionType = 1) VIN
OUTER APPLY (
		SELECT dblNet = SUM(ReceiptItem.dblNet) 
			   ,dblGross = SUM(ReceiptItem.dblGross)
		FROM tblICInventoryReceiptItem ReceiptItem
		JOIN tblICInventoryReceipt RI ON RI.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE RI.strReceiptType <> 'Inventory Return'
			AND intSourceId = LD.intLoadDetailId
			AND intLineNo = CD.intContractDetailId
			AND intOrderId = CH.intContractHeaderId
			AND L.intPurchaseSale IN (1, 3)
		) IRI
OUTER APPLY (SELECT dblNet = SUM(IRI.dblNet) 
					,dblGross = SUM(IRI.dblGross)
			 FROM tblICInventoryReceipt IR 
				JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
				WHERE IR.strReceiptType = 'Inventory Return'
				AND IRI.intSourceId = LD.intLoadDetailId 
				AND IRI.intLineNo = CD.intContractDetailId
				AND IRI.intOrderId = CH.intContractHeaderId 
				AND L.intPurchaseSale IN (1, 3)
		) IRN

left join tblSMCountry				rtELCountry on lower(rtrim(ltrim(rtELCountry.strCountry))) = lower(rtrim(ltrim(EL.strCountry)))
left join tblSMScreen				rtELScreen on rtELScreen.strNamespace = 'i21.view.Country'
left join tblSMTransaction			rtELTransaction on rtELTransaction.intScreenId = rtELScreen.intScreenId and rtELTransaction.intRecordId = rtELCountry.intCountryID
left join tblSMReportTranslation	rtELTranslation on rtELTranslation.intLanguageId = @intLaguageId and rtELTranslation.intTransactionId = rtELTransaction.intTransactionId and rtELTranslation.strFieldName = 'Country'
	
left join tblSMScreen				rtWUOMScreen on rtWUOMScreen.strNamespace = 'Inventory.view.ReportTranslation'
left join tblSMTransaction			rtWUOMTransaction on rtWUOMTransaction.intScreenId = rtWUOMScreen.intScreenId and rtWUOMTransaction.intRecordId = WUOM.intUnitMeasureId
left join tblSMReportTranslation	rtWUOMTranslation on rtWUOMTranslation.intLanguageId = @intLaguageId and rtWUOMTranslation.intTransactionId = rtWUOMTransaction.intTransactionId and rtWUOMTranslation.strFieldName = 'Name'
	
left join tblSMScreen				rtUMScreen on rtUMScreen.strNamespace = 'Inventory.view.ReportTranslation'
left join tblSMTransaction			rtUMTransaction on rtUMTransaction.intScreenId = rtUMScreen.intScreenId and rtUMTransaction.intRecordId = UM.intUnitMeasureId
left join tblSMReportTranslation	rtUMTranslation on rtUMTranslation.intLanguageId = @intLaguageId and rtUMTranslation.intTransactionId = rtUMTransaction.intTransactionId and rtUMTranslation.strFieldName = 'Name'
	
left join tblSMScreen				rtPRUScreen on rtPRUScreen.strNamespace = 'Inventory.view.ReportTranslation'
left join tblSMTransaction			rtPRUTransaction on rtPRUTransaction.intScreenId = rtPRUScreen.intScreenId and rtPRUTransaction.intRecordId = PRU.intUnitMeasureId
left join tblSMReportTranslation	rtPRUTranslation on rtPRUTranslation.intLanguageId = @intLaguageId and rtPRUTranslation.intTransactionId = rtPRUTransaction.intTransactionId and rtPRUTranslation.strFieldName = 'Name'

left join tblSMScreen				rtIScreen on rtIScreen.strNamespace = 'Inventory.view.Item'
left join tblSMTransaction			rtITransaction on rtITransaction.intScreenId = rtIScreen.intScreenId and rtITransaction.intRecordId = I.intItemId
left join tblSMReportTranslation	rtITranslation on rtITranslation.intLanguageId = @intLaguageId and rtITranslation.intTransactionId = rtITransaction.intTransactionId and rtITranslation.strFieldName = 'Description'
	
CROSS APPLY tblLGCompanyPreference CP
WHERE WC.intWeightClaimId = @intWeightClaimId
GROUP BY WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber
	,WC.dtmTransDate
	,L.intLoadId
	,CH.strContractNumber
	,CH.dtmContractDate
	,CH.strCustomerContract
	,CH.dblQuantity
	,CMUM.strUnitMeasure
	,L.strLoadNumber
	,E.intEntityId
	,E.strName
	,VEN.strTaxNumber
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,B.strBillId
	,ShippingLine.strName
	,L.strMVessel
	,L.strPackingDescription
	,BA.strBankAccountNo
	,BA.strSWIFT
	,BA.strIBAN
	,BA.strBankName
	,B.strRemarks
	,WCD.intBillId
	,WCD.intInvoiceId
	,CP.ysnFullHeaderLogo
	,WCD.dblFromNet
	,WCD.dblToGross
	,WCD.dblToTare
	,WCD.dblToNet
	,WUOM.strUnitMeasure
	,WUOM.strSymbol
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,UM.strUnitMeasure
	,WCD.dblFranchise
	,WG.dblFranchise
	,WCD.dblFranchiseWt
	,WCD.dblClaimableWt
	,WCD.dblUnitPrice
	,WCD.intCurrencyId
	,CU.strCurrency
	,WCD.dblClaimAmount
	,CU.ysnSubCurrency
	,MCU.strCurrency
	,I.strItemNo
	,I.strDescription
	,B.strVendorOrderNumber	
	,IRI.dblGross
	,IRI.dblNet
	,IRN.dblGross
	,IRN.dblNet
	,WC.dtmActualWeighingDate
	,VIN.strVendorOrderNumber
	,PRU.strUnitMeasure
	,rtELTranslation.strTranslation
	,rtWUOMTranslation.strTranslation
	,rtUMTranslation.strTranslation
	,rtPRUTranslation.strTranslation
	,rtITranslation.strTranslation
	,CP.intReportLogoHeight
	,CP.intReportLogoWidth

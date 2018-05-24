-----------------uspLGGetWeightClaimsCreditNoteReport
CREATE PROCEDURE uspLGGetWeightClaimsCreditNoteReport 
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

/*Declared variables for translating expression*/
declare @via nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'via'),'via');
declare @Voucher nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Voucher'),'Voucher');
declare @Invoice nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Invoice'),'Invoice');

SELECT DISTINCT WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber AS strWeightClaimNumber
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strContactName AS strCompanyContactName
	,@strCounty AS strCompanyCounty
	,@strCity AS strCompanyCity
	,@strState AS strCompanyState
	,@strZip AS strCompanyZip
	,@strCountry AS strCompanyCountry
	,@strPhone AS strCompanyPhone
	,@strCity + ', ' + @strState + ', ' + @strZip + ', ' AS strCityStateZip
	--,@strCity + ', '+ CONVERT(NVARCHAR,GETDATE(),106) AS strCityAndDate
	,@strCity + ', '+ DATENAME(dd,getdate()) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,format(getdate(),'MMM')),format(getdate(),'MMM')) + ' ' + DATENAME(yyyy,getdate()) AS strCityAndDate
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,E.strName AS strCustomerName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,strCountry = isnull(rtELTranslation.strTranslation,EL.strCountry)
	,E.strName + CHAR(13) + EL.strAddress + CHAR(13) + EL.strZipCode + ' ' + EL.strCity + CHAR(13) + EL.strState + ' ' + isnull(rtELTranslation.strTranslation,EL.strCountry) AS strCustomerAddress
	,INV.intInvoiceId
	,INV.strInvoiceNumber
	,@via + ' ' + ShippingLine.strName AS strShippingLine
	,L.strMVessel
	,CH.strContractNumber
	,CH.strCustomerContract
	,ROUND(SUM(WCD.dblClaimAmount), 2) dblTotalClaimAmount
	,CASE 
		WHEN WCD.intBillId IS NOT NULL
			THEN @Voucher
		WHEN WCD.intInvoiceId IS NOT NULL
			THEN @Invoice
		END strMemoType
	--,'Please transfer this amount in our favor with: ' + CHAR(13) + BA.strBankName + CHAR(13) + 'IBAN : ' + ISNULL(BA.strIBAN, '') + CHAR(13) + 'Swift : ' + ISNULL(BA.strSWIFT, '') AS	strVoucherBankInfo
	,dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo
	,dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo
	,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
	,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
	,WCD.dblFromNet
	,WCD.dblToNet
	,(ISNULL(WCD.dblFromNet,0) - ISNULL(WCD.dblToNet,0)) dblWeightDifference
	,strUnitMeasure = isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure)
	,LTRIM(dbo.fnRemoveTrailingZeroes(WCD.dblFromNet)) + ' ' + isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure) AS strWeightInfo
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,isnull(rtUMTranslation.strTranslation,UM.strUnitMeasure) AS strLoadWeightUnitMeasure
	,WCD.dblFranchise
	,WCD.dblFranchiseWt
	,ABS(WCD.dblClaimableWt) dblClaimableWt
	,WCD.dblUnitPrice
	,WCD.intCurrencyId
	,CU.strCurrency
	,LTRIM(CU.strCurrency) + ' ' + LTRIM(dbo.fnRemoveTrailingZeroes(WCD.dblUnitPrice)) AS strPriceInfo
	,isnull(rtPRUTranslation.strTranslation,PRU.strUnitMeasure) AS strPriceUOM
	,'/'+ LTRIM(isnull(rtPRUTranslation.strTranslation,PRU.strUnitMeasure)) AS strPriceUOMInfo
	,WCD.dblClaimAmount
	,CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END AS strClaimCurrency
	,LTRIM(CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END) + ' ' + dbo.fnRemoveTrailingZeroes(ROUND(WCD.dblClaimAmount,2)) AS strTotalAmountInfo
	,I.strItemNo
	,isnull(rtITranslation.strTranslation,I.strDescription) AS strItemDescription
	--,B.strVendorOrderNumber AS strInvoiceNo
	--,IRI.dblGross AS dblReceivedGross
	--,IRI.dblNet AS dblReceivedNet
	--,(ISNULL(IRI.dblGross,0) - ISNULL(IRI.dblNet,0)) AS dblReceivedTare
	,WC.dtmActualWeighingDate
	,INV.strComments
	,CUS.strVatNumber
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
	) LD ON LD.intCustomerEntityId = E.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ISNULL(LD.intCustomerEntityLocationId, E.intDefaultLocationId)
LEFT JOIN tblARInvoice INV ON INV.intInvoiceId = WCD.intInvoiceId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblARCustomer CUS ON CUS.intEntityId = E.intEntityId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM PUM ON PUM.intItemUOMId = WCD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure PRU ON PRU.intUnitMeasureId = PUM.intUnitMeasureId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
LEFT JOIN tblSMCurrency MCU ON MCU.intCurrencyID = CU.intMainCurrencyId

left join tblSMCountry				rtELCountry on lower(rtrim(ltrim(rtELCountry.strCountry))) = lower(rtrim(ltrim(EL.strCountry)))
left join tblSMScreen				rtELScreen on rtELScreen.strNamespace = 'i21.view.Country'
left join tblSMTransaction			rtELTransaction on rtELTransaction.intScreenId = rtELScreen.intScreenId and rtELTransaction.intRecordId = rtELCountry.intCountryID
left join tblSMReportTranslation	rtELTranslation on rtELTranslation.intLanguageId = @intLaguageId and rtELTranslation.intTransactionId = rtELTransaction.intTransactionId and rtELTranslation.strFieldName = 'Country'
		
left join tblSMScreen				rtWUOMScreen on rtWUOMScreen.strNamespace = 'Inventory.view.InventoryUOM'
left join tblSMTransaction			rtWUOMTransaction on rtWUOMTransaction.intScreenId = rtWUOMScreen.intScreenId and rtWUOMTransaction.intRecordId = WUOM.intUnitMeasureId
left join tblSMReportTranslation	rtWUOMTranslation on rtWUOMTranslation.intLanguageId = @intLaguageId and rtWUOMTranslation.intTransactionId = rtWUOMTransaction.intTransactionId and rtWUOMTranslation.strFieldName = 'UOM'
		
left join tblSMScreen				rtUMScreen on rtUMScreen.strNamespace = 'Inventory.view.InventoryUOM'
left join tblSMTransaction			rtUMTransaction on rtUMTransaction.intScreenId = rtUMScreen.intScreenId and rtUMTransaction.intRecordId = UM.intUnitMeasureId
left join tblSMReportTranslation	rtUMTranslation on rtUMTranslation.intLanguageId = @intLaguageId and rtUMTranslation.intTransactionId = rtUMTransaction.intTransactionId and rtUMTranslation.strFieldName = 'UOM'
		
left join tblSMScreen				rtPRUScreen on rtPRUScreen.strNamespace = 'Inventory.view.InventoryUOM'
left join tblSMTransaction			rtPRUTransaction on rtPRUTransaction.intScreenId = rtPRUScreen.intScreenId and rtPRUTransaction.intRecordId = PRU.intUnitMeasureId
left join tblSMReportTranslation	rtPRUTranslation on rtPRUTranslation.intLanguageId = @intLaguageId and rtPRUTranslation.intTransactionId = rtPRUTransaction.intTransactionId and rtPRUTranslation.strFieldName = 'UOM'

left join tblSMScreen				rtIScreen on rtIScreen.strNamespace = 'Inventory.view.Item'
left join tblSMTransaction			rtITransaction on rtITransaction.intScreenId = rtIScreen.intScreenId and rtITransaction.intRecordId = I.intItemId
left join tblSMReportTranslation	rtITranslation on rtITranslation.intLanguageId = @intLaguageId and rtITranslation.intTransactionId = rtITransaction.intTransactionId and rtITranslation.strFieldName = 'Description'
	
CROSS APPLY tblLGCompanyPreference CP
WHERE WC.intWeightClaimId = @intWeightClaimId
GROUP BY WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber
	,L.intLoadId
	,CH.strContractNumber
	,CH.strCustomerContract
	,L.strLoadNumber
	,E.intEntityId
	,E.strName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,ShippingLine.strName
	,L.strMVessel
	,WCD.intBillId
	,WCD.intInvoiceId
	,CP.ysnFullHeaderLogo
	,WCD.dblFromNet
	,WCD.dblToNet
	,WUOM.strUnitMeasure
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,UM.strUnitMeasure
	,WCD.dblFranchise
	,WCD.dblFranchise
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
	,WC.dtmActualWeighingDate
	,PRU.strUnitMeasure
	,INV.intInvoiceId
	,INV.strInvoiceNumber
	,INV.strComments
	,CUS.strVatNumber
	,rtELTranslation.strTranslation
	,rtWUOMTranslation.strTranslation
	,rtUMTranslation.strTranslation
	,rtPRUTranslation.strTranslation
	,rtITranslation.strTranslation

/*
CREATE PROCEDURE uspLGGetWeightClaimsCreditNoteReport 
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

SELECT @intWeightClaimId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intWeightClaimId'

SELECT @intLoadId = intLoadId
FROM tblLGWeightClaim
WHERE intWeightClaimId = @intWeightClaimId

SELECT TOP 1 @ysnPrintLogo = ISNULL(ysnPrintLogo, 0)
FROM tblLGCompanyPreference

SELECT TOP 1 @strCompanyName = strCompanyName
	,@strCompanyAddress = strAddress
	,@strContactName = strContactName
	,@strCounty = strCounty
	,@strCity = strCity
	,@strState = strState
	,@strZip = strZip
	,@strCountry = strCountry
	,@strPhone = strPhone
FROM tblSMCompanySetup

SELECT DISTINCT WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber AS strWeightClaimNumber
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strContactName AS strCompanyContactName
	,@strCounty AS strCompanyCounty
	,@strCity AS strCompanyCity
	,@strState AS strCompanyState
	,@strZip AS strCompanyZip
	,@strCountry AS strCompanyCountry
	,@strPhone AS strCompanyPhone
	,@strCity + ', ' + @strState + ', ' + @strZip + ', ' AS strCityStateZip
	,@strCity + ', '+ CONVERT(NVARCHAR,GETDATE(),106) AS strCityAndDate
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,E.strName AS strCustomerName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,E.strName + CHAR(13) + EL.strAddress + CHAR(13) + EL.strZipCode + ' ' + EL.strCity + CHAR(13) + EL.strState + ' ' + EL.strCountry AS strCustomerAddress
	,INV.intInvoiceId
	,INV.strInvoiceNumber
	,'via ' + ShippingLine.strName AS strShippingLine
	,L.strMVessel
	,CH.strContractNumber
	,CH.strCustomerContract
	,ROUND(SUM(WCD.dblClaimAmount), 2) dblTotalClaimAmount
	,CASE 
		WHEN WCD.intBillId IS NOT NULL
			THEN 'Voucher'
		WHEN WCD.intInvoiceId IS NOT NULL
			THEN 'Invoice'
		END strMemoType
	--,'Please transfer this amount in our favor with: ' + CHAR(13) + BA.strBankName + CHAR(13) + 'IBAN : ' + ISNULL(BA.strIBAN, '') + CHAR(13) + 'Swift : ' + ISNULL(BA.strSWIFT, '') AS	strVoucherBankInfo
	,dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo
	,dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo
	,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
	,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
	,WCD.dblFromNet
	,WCD.dblToNet
	,(ISNULL(WCD.dblFromNet,0) - ISNULL(WCD.dblToNet,0)) dblWeightDifference
	,WUOM.strUnitMeasure
	,LTRIM(dbo.fnRemoveTrailingZeroes(WCD.dblFromNet)) + ' ' + WUOM.strUnitMeasure AS strWeightInfo
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,UM.strUnitMeasure AS strLoadWeightUnitMeasure
	,WCD.dblFranchise
	,WCD.dblFranchiseWt
	,ABS(WCD.dblClaimableWt) dblClaimableWt
	,WCD.dblUnitPrice
	,WCD.intCurrencyId
	,CU.strCurrency
	,LTRIM(CU.strCurrency) + ' ' + LTRIM(dbo.fnRemoveTrailingZeroes(WCD.dblUnitPrice)) AS strPriceInfo
	,PRU.strUnitMeasure AS strPriceUOM
	,'/'+ LTRIM(PRU.strUnitMeasure) AS strPriceUOMInfo
	,WCD.dblClaimAmount
	,CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END AS strClaimCurrency
	,LTRIM(CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END) + ' ' + dbo.fnRemoveTrailingZeroes(ROUND(WCD.dblClaimAmount,2)) AS strTotalAmountInfo
	,I.strItemNo
	,I.strDescription AS strItemDescription
	--,B.strVendorOrderNumber AS strInvoiceNo
	--,IRI.dblGross AS dblReceivedGross
	--,IRI.dblNet AS dblReceivedNet
	--,(ISNULL(IRI.dblGross,0) - ISNULL(IRI.dblNet,0)) AS dblReceivedTare
	,WC.dtmActualWeighingDate
	,INV.strComments
	,CUS.strVatNumber
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
	) LD ON LD.intCustomerEntityId = E.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ISNULL(LD.intCustomerEntityLocationId, E.intDefaultLocationId)
LEFT JOIN tblARInvoice INV ON INV.intInvoiceId = WCD.intInvoiceId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblARCustomer CUS ON CUS.intEntityId = E.intEntityId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM PUM ON PUM.intItemUOMId = WCD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure PRU ON PRU.intUnitMeasureId = PUM.intUnitMeasureId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
LEFT JOIN tblSMCurrency MCU ON MCU.intCurrencyID = CU.intMainCurrencyId
CROSS APPLY tblLGCompanyPreference CP
WHERE WC.intWeightClaimId = @intWeightClaimId
GROUP BY WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber
	,L.intLoadId
	,CH.strContractNumber
	,CH.strCustomerContract
	,L.strLoadNumber
	,E.intEntityId
	,E.strName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,ShippingLine.strName
	,L.strMVessel
	,WCD.intBillId
	,WCD.intInvoiceId
	,CP.ysnFullHeaderLogo
	,WCD.dblFromNet
	,WCD.dblToNet
	,WUOM.strUnitMeasure
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,UM.strUnitMeasure
	,WCD.dblFranchise
	,WCD.dblFranchise
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
	,WC.dtmActualWeighingDate
	,PRU.strUnitMeasure
	,INV.intInvoiceId
	,INV.strInvoiceNumber
	,INV.strComments
	,CUS.strVatNumber
*/
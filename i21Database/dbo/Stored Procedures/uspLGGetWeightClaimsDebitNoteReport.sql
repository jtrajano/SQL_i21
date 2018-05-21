CREATE PROCEDURE uspLGGetWeightClaimsDebitNoteReport 
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
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,E.strName AS strCustomerName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,E.strName + CHAR(13) + EL.strAddress + CHAR(13) + EL.strZipCode + ' ' + EL.strCity + CHAR(13) + EL.strState + ' ' + EL.strCountry AS strVendorAddress
	,B.strBillId
	,'via ' + ShippingLine.strName AS strShippingLine
	,L.strMVessel
	,CH.strContractNumber
	,CH.strCustomerContract
	,BA.strBankAccountNo
	,BA.strIBAN
	,BA.strSWIFT
	,BA.strBankName
	,B.strRemarks
	,ROUND(SUM(WCD.dblClaimAmount), 2) dblTotalClaimAmount
	,CASE 
		WHEN WCD.intBillId IS NOT NULL
			THEN 'Voucher'
		WHEN WCD.intInvoiceId IS NOT NULL
			THEN 'Invoice'
		END strMemoType
	,'Please transfer this amount in our favor with: ' + CHAR(13) + BA.strBankName + CHAR(13) + 'IBAN : ' + ISNULL(BA.strIBAN, '') + CHAR(13) + 'Swift : ' + ISNULL(BA.strSWIFT, '') AS	strVoucherBankInfo
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
	,WCD.dblClaimAmount
	,CASE WHEN CU.ysnSubCurrency = 1 THEN MCU.strCurrency ELSE CU.strCurrency END AS strClaimCurrency
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,B.strVendorOrderNumber AS strInvoiceNo
	,IRI.dblGross AS dblReceivedGross
	,IRI.dblNet AS dblReceivedNet
	,(ISNULL(IRI.dblGross,0) - ISNULL(IRI.dblNet,0)) AS dblReceivedTare
	,WC.dtmActualWeighingDate
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
	) LD ON ISNULL(LD.intVendorEntityId, LD.intCustomerEntityId) = E.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ISNULL(LD.intVendorEntityLocationId, E.intDefaultLocationId)
LEFT JOIN tblAPBill B ON B.intBillId = WCD.intBillId
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = B.intBankInfoId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
LEFT JOIN tblSMCurrency MCU ON MCU.intCurrencyID = CU.intMainCurrencyId
LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intSourceId = LD.intLoadDetailId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
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
	,B.strBillId
	,ShippingLine.strName
	,L.strMVessel
	,BA.strBankAccountNo
	,BA.strSWIFT
	,BA.strIBAN
	,BA.strBankName
	,B.strRemarks
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
	,B.strVendorOrderNumber	
	,IRI.dblGross
	,IRI.dblNet
	,WC.dtmActualWeighingDate
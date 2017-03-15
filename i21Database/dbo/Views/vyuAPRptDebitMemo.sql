CREATE VIEW [dbo].[vyuAPRptDebitMemo]
AS 

SELECT 
	(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](strCompanyName, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone))
	,strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup), A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone))
	,A.intBillId
	,A.strBillId
	,E.strAccountId
	,D.strContractNumber
	,D2.intContractSeq
	,D2.strERPPONumber
	,ISNULL(H.strDescription, C2.strMiscDescription) strMiscDescription
	,ISNULL(H.strItemNo, C2.strMiscDescription) strItemNo
	,CASE WHEN C2.intWeightUOMId > 0 THEN K2.strUnitMeasure
		WHEN C2.intUnitOfMeasureId > 0 THEN F2.strUnitMeasure
		ELSE 'Each' END AS strUnitMeasure
	,CASE WHEN C2.intWeightUOMId > 0 THEN C2.dblNetWeight
			ELSE C2.dblQtyReceived
		END AS dblQtyReceived
	,C2.dblCost
	,G2.strUnitMeasure AS strCostUOM
	,C2.dblTotal
	,CASE WHEN C2.ysnSubCurrency = 1 THEN I.strCurrency ELSE J.strCurrency END AS strCurrency
	,L.strName AS strContactName
	,L.strEmail AS strContactEmail
	,M.strBillOfLading
	,ISNULL(N2.strCountry,V.strDescription) AS strCountryOrigin
	,P.strSubLocationName strLPlant
	,strDateLocation = Q.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 107)
	,U.strBankName
	,S.strBankAccountHolder
	,S.strIBAN
	,S.strSWIFT
	,T.strTerm
	,A.strRemarks
	,U.strCountry + ', ' + U.strCity + ' ' + U.strState AS strBankAddress
 	,(SELECT blbFile FROM tblSMUpload WHERE intAttachmentId = 
	(	
	  SELECT TOP 1
	  intAttachmentId
	  FROM tblSMAttachment
	  WHERE strScreen = 'SystemManager.CompanyPreference'
	  AND strComment = 'Footer'
	  ORDER BY intAttachmentId DESC
	)) AS strFooter
FROM tblAPBill A
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityVendorId = B2.intEntityId) ON A.intEntityVendorId = B.intEntityVendorId
INNER JOIN tblAPBillDetail C2 ON A.intBillId = C2.intBillId
INNER JOIN tblGLAccount E ON C2.intAccountId = E.intAccountId
LEFT JOIN tblICItem H ON C2.intItemId = H.intItemId
LEFT JOIN tblICInventoryReceipt M INNER JOIN tblICInventoryReceiptItem M2 ON M.intInventoryReceiptId = M2.intInventoryReceiptId
	ON C2.intInventoryReceiptItemId = M2.intInventoryReceiptItemId
LEFT JOIN tblCTContractHeader D INNER JOIN tblCTContractDetail D2 ON D.intContractHeaderId = D2.intContractHeaderId
	ON C2.intContractHeaderId = D.intContractHeaderId AND C2.intContractDetailId = D2.intContractDetailId
LEFT JOIN tblICItemContract N INNER JOIN tblSMCountry N2 ON N.intCountryId = N2.intCountryID
	ON D2.intItemContractId = N.intItemContractId
LEFT JOIN tblICCommodityAttribute V ON V.intCommodityAttributeId = H.intOriginId
LEFT JOIN (tblICItemUOM F INNER JOIN tblICUnitMeasure F2 ON F.intUnitMeasureId = F2.intUnitMeasureId) ON C2.intUnitOfMeasureId = F.intItemUOMId
LEFT JOIN (tblICItemUOM G INNER JOIN tblICUnitMeasure G2 ON G.intUnitMeasureId = G2.intUnitMeasureId) ON C2.intCostUOMId = G.intItemUOMId
LEFT JOIN (tblICItemUOM K INNER JOIN tblICUnitMeasure K2 ON K.intUnitMeasureId = K2.intUnitMeasureId) ON C2.intWeightUOMId = K.intItemUOMId
LEFT JOIN tblSMCurrency J ON A.intCurrencyId = J.intCurrencyID
LEFT JOIN tblSMCurrency I ON I.intMainCurrencyId = A.intCurrencyId AND I.ysnSubCurrency = 1
LEFT JOIN tblEMEntity L ON A.intEntityId = L.intEntityId
LEFT JOIN tblSMCompanyLocationSubLocation P ON D2.intSubLocationId = P.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation Q ON A.intStoreLocationId = Q.intCompanyLocationId
LEFT JOIN tblCMBankAccount S ON S.intBankAccountId = A.intBankInfoId
LEFT JOIN tblCMBank U ON U.intBankId = S.intBankId
LEFT JOIN tblSMTerm T ON A.intTermsId = T.intTermID
WHERE A.intTransactionType = 3

CREATE VIEW [dbo].[vyuAPRptDebitMemo]
AS 

SELECT 
	(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone))
	,strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup), A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone))
	,A.intBillId
	,A.strBillId
	,E.strAccountId
	,D.strContractNumber
	,D2.intContractSeq
	,ISNULL(H.strDescription, C2.strMiscDescription) strMiscDescription
	,CASE WHEN C2.intWeightUOMId > 0 THEN K2.strUnitMeasure
		WHEN C2.intUnitOfMeasureId > 0 THEN F2.strUnitMeasure
		ELSE 'Each' END AS strUnitMeasure
	,C2.dblQtyReceived
	,C2.dblCost
	,CASE WHEN C2.intCostUOMId > 0 THEN G2.strUnitMeasure
		WHEN C2.intWeightUOMId > 0 THEN K2.strUnitMeasure
		WHEN C2.intUnitOfMeasureId > 0 THEN F2.strUnitMeasure
		ELSE 'Each' END AS strCostUOM
	,C2.dblTotal
	,CASE WHEN C2.ysnSubCurrency = 1 THEN I.strCurrency ELSE J.strCurrency END AS strCurrency
	,L.strName AS strContactName
	,L.strEmail AS strContactEmail
FROM tblAPBill A
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityVendorId = B2.intEntityId) ON A.intEntityVendorId = B.intEntityVendorId
INNER JOIN tblAPBillDetail C2 ON A.intBillId = C2.intBillId
INNER JOIN tblGLAccount E ON C2.intAccountId = E.intAccountId
LEFT JOIN tblICItem H ON C2.intItemId = H.intItemId
LEFT JOIN tblCTContractHeader D INNER JOIN tblCTContractDetail D2 ON D.intContractHeaderId = D2.intContractHeaderId
	ON C2.intContractHeaderId = D.intContractHeaderId AND C2.intContractDetailId = D2.intContractDetailId
LEFT JOIN (tblICItemUOM F INNER JOIN tblICUnitMeasure F2 ON F.intUnitMeasureId = F2.intUnitMeasureId) ON C2.intUnitOfMeasureId = F.intItemUOMId
LEFT JOIN (tblICItemUOM G INNER JOIN tblICUnitMeasure G2 ON G.intUnitMeasureId = G2.intUnitMeasureId) ON C2.intCostUOMId = G.intItemUOMId
LEFT JOIN (tblICItemUOM K INNER JOIN tblICUnitMeasure K2 ON K.intUnitMeasureId = K2.intUnitMeasureId) ON C2.intWeightUOMId = K.intItemUOMId
LEFT JOIN tblSMCurrency J ON A.intCurrencyId = J.intCurrencyID
LEFT JOIN tblSMCurrency I ON I.intMainCurrencyId = A.intCurrencyId AND I.ysnSubCurrency = 1
LEFT JOIN tblEMEntity L ON A.intContactId = L.intEntityId
WHERE A.intTransactionType = 3

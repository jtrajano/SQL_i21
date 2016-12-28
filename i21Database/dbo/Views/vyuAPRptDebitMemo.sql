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
	,C2.strMiscDescription
	,C2.dblCost
	,C2.intUnitOfMeasureId
	,F2.strUnitMeasure
	,C2.dblQtyReceived
	,C2.intCostUOMId
	,G2.strUnitMeasure AS strCostUOM
	,C2.dblTotal
FROM tblAPBill A
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityVendorId = B2.intEntityId) ON A.intEntityVendorId = B.intEntityVendorId
INNER JOIN tblAPBillDetail C2 ON A.intBillId = C2.intBillId
INNER JOIN tblGLAccount E ON C2.intAccountId = E.intAccountId
LEFT JOIN tblCTContractHeader D INNER JOIN tblCTContractDetail D2 ON D.intContractHeaderId = D2.intContractHeaderId
	ON C2.intContractHeaderId = D.intContractHeaderId AND C2.intContractDetailId = D2.intContractDetailId
LEFT JOIN (tblICItemUOM F INNER JOIN tblICUnitMeasure F2 ON F.intUnitMeasureId = F2.intUnitMeasureId) ON C2.intUnitOfMeasureId = F.intItemUOMId
LEFT JOIN (tblICItemUOM G INNER JOIN tblICUnitMeasure G2 ON G.intUnitMeasureId = G2.intUnitMeasureId) ON C2.intCostUOMId = G.intItemUOMId
WHERE A.intTransactionType = 3

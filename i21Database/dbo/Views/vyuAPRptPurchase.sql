CREATE VIEW [dbo].[vyuAPRptPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.dtmExpectedDate
,A.intVendorId
,A.strPurchaseOrderNumber
,A.strVendorOrderNumber
,A.strReference
,C.strVendorId 
,strShipTo =  (CASE WHEN LEN(A.strShipToAttention) <> 0 THEN CHAR(32) + 'Attn: ' + A.strShipToAttention + CHAR(13) + CHAR (10) else '' end +    
  CASE WHEN LEN(A.strShipToAddress) <> 0 THEN CHAR(32) + Replace(A.strShipToAddress,char(10), ' ') + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipToCity) <> 0 THEN CHAR(32) + A.strShipToCity + ','  else '' end +    
 CASE WHEN LEN(A.strShipToState) <> 0 THEN CHAR(32) + A.strShipToState + ',' else  '' end +    
 CASE WHEN LEN(A.strShipToZipCode) <> 0 THEN CHAR(32) + A.strShipToZipCode + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipToCountry) <> 0 THEN CHAR(32) + A.strShipToCountry + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipToPhone) <> 0 THEN CHAR(32) + A.strShipToPhone + CHAR(13) + CHAR (10) else '' end)
 ,strBillTo = (CASE WHEN LEN(A.strBillToAttention) <> 0 THEN CHAR(32) + 'Attn: ' + A.strBillToAttention + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strBillToAddress) <> 0 THEN CHAR(32) + REPLACE(A.strBillToAddress,char(10), ' ') + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strBillToCity) <> 0 THEN CHAR(32) + A.strBillToCity + ','  else '' end +    
 CASE WHEN LEN(A.strBillToState) <> 0 THEN CHAR(32) + A.strBillToState + ',' else  '' end +    
 CASE WHEN LEN(A.strBillToZipCode) <> 0 THEN CHAR(32) + A.strBillToZipCode + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strBillToCountry) <> 0 THEN CHAR(32) + A.strBillToCountry + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strBillToPhone) <> 0 THEN CHAR(32) + A.strBillToPhone + CHAR(13) + CHAR (10) else '' end)
 ,intShipViaId
 ,strShipVia = (SELECT strShipVia FROM dbo.tblSMShipVia WHERE intShipViaID = intShipViaID)
 ,intTermsId
 ,strTerm = (SELECT strTerm FROM dbo.tblSMTerm WHERE intTermID = intTermsId)
 ,B.dblQtyOrdered
 ,B.dblCost
 ,B.dblDiscount
 ,A.dblTotal
 ,A.dblSubtotal
 ,A.dblTax
 ,A.dblShipping
 ,D.intItemId
 ,D.strItemNo
 ,D.strDescription
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor C ON A.intVendorId = C.intVendorId
	LEFT JOIN dbo.tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN dbo.tblICItem D ON B.intItemId = D.intItemId
	
	
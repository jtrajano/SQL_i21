CREATE VIEW [dbo].[vyuAPRptPurchase]
WITH SCHEMABINDING
AS 
SELECT 
(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
,A.intPurchaseId
,A.dtmDate
,A.dtmExpectedDate
,A.intVendorId
,A.strPurchaseOrderNumber
,A.strVendorOrderNumber
,A.strReference
,C.strVendorId 
,RTRIM(LTRIM(C.strVendorId)) + ' - ' + C1.strName AS strVendorName
,strShipTo =  (CASE WHEN LEN(A.strShipToAttention) <> 0 THEN CHAR(32) + 'Attn: ' + A.strShipToAttention + CHAR(13) + CHAR (10) else '' end +    
  CASE WHEN LEN(A.strShipToAddress) <> 0 THEN CHAR(32) + Replace(A.strShipToAddress,char(10), ' ') + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipToCity) <> 0 THEN CHAR(32) + A.strShipToCity + ','  else '' end +    
 CASE WHEN LEN(A.strShipToState) <> 0 THEN CHAR(32) + A.strShipToState + ',' else  '' end +    
 CASE WHEN LEN(A.strShipToZipCode) <> 0 THEN CHAR(32) + A.strShipToZipCode + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipToCountry) <> 0 THEN CHAR(32) + A.strShipToCountry + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipToPhone) <> 0 THEN CHAR(32) + A.strShipToPhone + CHAR(13) + CHAR (10) else '' end)
 ,strShipFrom = (CASE WHEN LEN(A.strShipFromAttention) <> 0 THEN CHAR(32) + 'Attn: ' + A.strShipFromAttention + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipFromAddress) <> 0 THEN CHAR(32) + REPLACE(A.strShipFromAddress,char(10), ' ') + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipFromCity) <> 0 THEN CHAR(32) + A.strShipFromCity + ','  else '' end +    
 CASE WHEN LEN(A.strShipFromState) <> 0 THEN CHAR(32) + A.strShipFromState + ',' else  '' end +    
 CASE WHEN LEN(A.strShipFromZipCode) <> 0 THEN CHAR(32) + A.strShipFromZipCode + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipFromCountry) <> 0 THEN CHAR(32) + A.strShipFromCountry + CHAR(13) + CHAR (10) else '' end +    
 CASE WHEN LEN(A.strShipFromPhone) <> 0 THEN CHAR(32) + A.strShipFromPhone + CHAR(13) + CHAR (10) else '' end)
 ,intShipViaId
 ,strShipVia = (SELECT strShipVia FROM dbo.tblSMShipVia WHERE intShipViaID = A.intShipViaId)
 ,intTermsId
 ,strTerm = (SELECT strTerm FROM dbo.tblSMTerm WHERE intTermID = A.intTermsId)
 ,B.dblQtyOrdered
 ,B.dblCost
 ,B.dblDiscount / 100 AS dblDiscount
 ,B.dblTotal AS dblDetailTotal
 ,A.dblTotal
 ,A.dblSubtotal
 ,A.dblTax
 ,A.dblShipping
 ,D.intItemId
 ,D.strItemNo
 ,D.strDescription
 ,E.strUnitMeasure
FROM dbo.tblPOPurchase A
	INNER JOIN (dbo.tblAPVendor C INNER JOIN dbo.tblEntity C1 ON C.intEntityId = C1.intEntityId)
			ON A.intVendorId = C.intVendorId
	LEFT JOIN dbo.tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN dbo.tblICItem D ON B.intItemId = D.intItemId
	INNER JOIN (dbo.tblICItemUOM E1 
				INNER JOIN dbo.tblICUnitMeasure E ON E1.intUnitMeasureId = E.intUnitMeasureId)
				ON B.intUnitOfMeasureId = E1.intItemUOMId
	
	
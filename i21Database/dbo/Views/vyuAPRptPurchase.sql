﻿CREATE VIEW [dbo].[vyuAPRptPurchase]
WITH SCHEMABINDING
AS 
SELECT 
	(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
	,A.intPurchaseId
	,A.dtmDate
	,A.dtmExpectedDate
	,A.[intEntityVendorId]
	,A.strPurchaseOrderNumber
	,A.strVendorOrderNumber
	,A.strReference
	,C.strVendorId 
	,RTRIM(LTRIM(C.strVendorId)) + ' - ' + C1.strName AS strVendorName
	,strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup), A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone))
	,strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](C1.strName,NULL, A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone))
	,intShipViaId
	,strShipVia = (SELECT strShipVia FROM dbo.tblSMShipVia WHERE [intEntityShipViaId] = A.intShipViaId)
	,intTermsId
	,strTerm = (SELECT strTerm FROM dbo.tblSMTerm WHERE intTermID = A.intTermsId)
	,B.dblQtyOrdered
	,E.strUnitMeasure
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
FROM dbo.tblPOPurchase A
	INNER JOIN (dbo.tblAPVendor C INNER JOIN dbo.tblEntity C1 ON C.intEntityVendorId = C1.intEntityId)
			ON A.[intEntityVendorId] = C.intEntityVendorId
	LEFT JOIN dbo.tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN dbo.tblICItem D ON B.intItemId = D.intItemId
	INNER JOIN (dbo.tblICItemUOM E1 
				INNER JOIN dbo.tblICUnitMeasure E ON E1.intUnitMeasureId = E.intUnitMeasureId)
				ON B.intUnitOfMeasureId = E1.intItemUOMId
	

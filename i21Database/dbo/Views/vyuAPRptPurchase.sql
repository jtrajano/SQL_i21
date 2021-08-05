﻿CREATE VIEW [dbo].[vyuAPRptPurchase]

AS 
SELECT 
	compSetup.strCompanyName AS strCompanyName
	,A.intPurchaseId
	,A.dtmDate
	,A.dtmExpectedDate
	,A.[intEntityVendorId]
	,A.strPurchaseOrderNumber
	,A.strVendorOrderNumber
	,A.strReference
	,C.strVendorId 
	,RTRIM(LTRIM(C.strVendorId)) + ' - ' + C1.strName AS strVendorName
	,strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,compSetup.strCompanyName, A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone) COLLATE Latin1_General_CI_AS)
	,strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](C1.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone) COLLATE Latin1_General_CI_AS)
	,intShipViaId
	,strShipVia = shipVia.strShipVia
	,A.intTermsId
	,strTerm = term.strTerm
	,B.dblQtyOrdered
	,E.strUnitMeasure
	,A.dblTotalWeight
	,B.dblCost
	,B.dblDiscount / 100 AS dblDiscount
	,B.dblTotal AS dblDetailTotal
	,B.dblStandardWeight
	,A.dblTotal
	,A.dblSubtotal
	,A.dblTax
	,A.dblShipping
	,D.intItemId
	,D.strItemNo
	,B.strMiscDescription AS strDescription
	,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) COLLATE Latin1_General_CI_AS as strCompanyAddress
	,F.strFreightTerm
FROM dbo.tblPOPurchase A
	INNER JOIN (dbo.tblAPVendor C INNER JOIN dbo.tblEMEntity C1 ON C.[intEntityId] = C1.intEntityId)
			ON A.[intEntityVendorId] = C.[intEntityId]
	CROSS JOIN tblSMCompanySetup compSetup
	LEFT JOIN dbo.tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	LEFT JOIN dbo.tblICItem D ON B.intItemId = D.intItemId
	LEFT JOIN (dbo.tblICItemUOM E1 
				INNER JOIN dbo.tblICUnitMeasure E ON E1.intUnitMeasureId = E.intUnitMeasureId)
				ON B.intUnitOfMeasureId = E1.intItemUOMId
	LEFT JOIN tblSMFreightTerms F ON F.intFreightTermId = A.intFreightTermId
	LEFT JOIN tblSMTerm term ON term.intTermID = A.intTermsId
	LEFT JOIN tblSMShipVia shipVia ON shipVia.intEntityId = A.intShipViaId
	

CREATE VIEW [dbo].[vyuAP1099Summary]
AS
SELECT DISTINCT
      strVendorId = C.strVendorId
	, intEntityVendorId = C.intEntityId
	, strCompanyAddress = (SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) 
	, strCompanyName =(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup)
    , strVendorCompanyName = dbo.fnAPRemoveSpecialChars(REPLACE((CASE WHEN ISNULL(C2.str1099Name,'') <> '' THEN dbo.fnTrimX(C2.str1099Name) ELSE dbo.fnTrimX(C2.strName) END), '&', 'and'))  COLLATE Latin1_General_CI_AS 
    , strAddress = SUBSTRING(REPLACE(REPLACE(dbo.fnTrimX(D.strAddress), CHAR(10), ' ') , CHAR(13), ' '),0,40) COLLATE Latin1_General_CI_AS  --max char 40       
	, strPayeeName= SUBSTRING(C2.strName, 0, 40)
	, strCity = ISNULL(dbo.fnTrimX(strCity), '')  COLLATE Latin1_General_CI_AS  
	, strState = ISNULL(dbo.fnTrimX(strState), '') COLLATE Latin1_General_CI_AS   
	, strZip = ISNULL(dbo.fnTrimX(strZipCode), '') COLLATE Latin1_General_CI_AS   
    , strZipState = (CASE WHEN LEN(D.strCity) <> 0 THEN dbo.fnTrimX(D.strCity) ELSE '' END +               
					 CASE WHEN LEN(D.strState) <> 0 THEN ', ' + dbo.fnTrimX(D.strState) ELSE '' END +               
					 CASE WHEN LEN(D.strZipCode) <> 0 THEN ', ' + dbo.fnTrimX(D.strZipCode) ELSE '' END)  COLLATE Latin1_General_CI_AS            
    , strFederalTaxId = C2.strFederalTaxId
	, dbl1099Amount = (A.dblTotal + A.dblTax)
	, dbl1099AmountPaid = (B.dblPayment)
	, dblDifference = CASE WHEN (B.dblPayment) > 0 THEN  (A.dblTotal + A.dblTax) -  (B.dblPayment) ELSE 0 END
    , intYear = YEAR(ISNULL(B2.dtmDatePaid, B.dtmDate))
	, A.int1099Form
	, A.int1099Category
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
    ON B.intBillId = A.intBillId
LEFT JOIN vyuAPBillPayment B2
	ON B.intBillId = B2.intBillId   
LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity C2 ON C.intEntityId = C2.intEntityId)
    ON C.intEntityId = B.intEntityVendorId
LEFT JOIN [tblEMEntityLocation] D
	ON C.intEntityId = D.intEntityId AND D.ysnDefaultLocation = 1     
WHERE ((B.ysnPosted = 1) OR B.intTransactionType = 9) AND A.int1099Form <> 0
GO
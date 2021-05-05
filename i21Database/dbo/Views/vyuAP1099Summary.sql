CREATE VIEW [dbo].[vyuAP1099Summary]
AS
SELECT --DISTINCT
      strVendorId = C.strVendorId
	, intEntityVendorId = C.intEntityId
	, strCompanyAddress = dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) COLLATE Latin1_General_CI_AS
	, strCompanyName = compSetup.strCompanyName
    , strVendorCompanyName = dbo.fnAPRemoveSpecialChars(REPLACE((CASE WHEN ISNULL(C2.str1099Name,'') <> '' THEN dbo.fnTrimX(C2.str1099Name) ELSE dbo.fnTrimX(C2.strName) END), '&', 'and'))  COLLATE Latin1_General_CI_AS 
    , strAddress = SUBSTRING(REPLACE(REPLACE(dbo.fnTrimX(D.strAddress), CHAR(10), ' ') , CHAR(13), ' '),0,40) COLLATE Latin1_General_CI_AS  --max char 40       
	, strPayeeName= SUBSTRING(C2.strName, 0, 40)
	, strCity = ISNULL(dbo.fnTrimX(D.strCity), '')  COLLATE Latin1_General_CI_AS  
	, strState = ISNULL(dbo.fnTrimX(D.strState), '') COLLATE Latin1_General_CI_AS   
	, strZip = ISNULL(dbo.fnTrimX(D.strZipCode), '') COLLATE Latin1_General_CI_AS   
    , strZipState = (CASE WHEN LEN(D.strCity) <> 0 THEN dbo.fnTrimX(D.strCity) ELSE '' END +               
					 CASE WHEN LEN(D.strState) <> 0 THEN ', ' + dbo.fnTrimX(D.strState) ELSE '' END +               
					 CASE WHEN LEN(D.strZipCode) <> 0 THEN ', ' + dbo.fnTrimX(D.strZipCode) ELSE '' END)  COLLATE Latin1_General_CI_AS            
    , strFederalTaxId = C2.strFederalTaxId
	-- , dbl1099Amount = (A.dblTotal + A.dblTax)
	, dbl1099Amount = (CASE WHEN patRef.intBillId IS NULL AND A.int1099Form = 4
						THEN (A.dblTotal + A.dblTax) / B.dblTotal  --* ISNULL(B2.dblPayment,A.dbl1099)
						ELSE A.dbl1099
						END)
						* (CASE WHEN B.intTransactionType = 3 THEN -1 ELSE 1 END)
	, dbl1099AmountPaid = --(B2.dblPayment)
						(CASE WHEN patRef.intBillId IS NULL AND A.int1099Form = 4
						THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
						ELSE A.dbl1099
						END)
	, dblDifference = CASE WHEN (B2.dblPayment) > 0 THEN  --(A.dblTotal + A.dblTax) 
					(
						(CASE WHEN patRef.intBillId IS NULL AND A.int1099Form = 4
						THEN (A.dblTotal + A.dblTax) / B.dblTotal  --* ISNULL(B2.dblPayment,A.dbl1099)
						ELSE A.dbl1099
						END)
						* (CASE WHEN B.intTransactionType = 3 THEN -1 ELSE 1 END)
					)
					-  (CASE WHEN patRef.intBillId IS NULL AND A.int1099Form = 4
						THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
						ELSE A.dbl1099
						END) 
					ELSE 0 END
    , intYear = YEAR(ISNULL(B2.dtmDatePaid, B.dtmDate))
	, A.int1099Form
	, A.int1099Category
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
    ON B.intBillId = A.intBillId
CROSS JOIN tblSMCompanySetup compSetup
-- LEFT JOIN vyuAPBillPayment B2
-- 	ON B.intBillId = B2.intBillId   
LEFT JOIN (
	SELECT
		P2.intBillId
		,P2.dblPayment
		,P.dtmDatePaid
	FROM tblAPPayment P
	INNER JOIN tblAPPaymentDetail P2 ON P.intPaymentId = P2.intPaymentId
	WHERE P.ysnPosted = 1
) B2 ON B.intBillId = B2.intBillId
LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity C2 ON C.intEntityId = C2.intEntityId)
    ON C.intEntityId = B.intEntityVendorId
LEFT JOIN [tblEMEntityLocation] D
	ON C.intEntityId = D.intEntityId AND D.ysnDefaultLocation = 1     
LEFT JOIN tblPATRefundCustomer patRef ON patRef.intBillId = B.intBillId
WHERE ((B.ysnPosted = 1 AND B2.dblPayment IS NOT NULL) OR B.intTransactionType = 9) AND A.int1099Form <> 0
AND (C2.ysnPrint1099 = 1 OR patRef.intBillId IS NOT NULL)
GO
﻿CREATE VIEW [dbo].[vyuAP1099]
AS
SELECT
      C.strVendorId
	, C.[intEntityId]
    , strVendorCompanyName = dbo.fnAPRemoveSpecialChars(REPLACE((CASE WHEN ISNULL(C2.str1099Name,'') <> '' THEN dbo.fnTrimX(C2.str1099Name) ELSE dbo.fnTrimX(C2.strName) END), '&', 'and'))  COLLATE Latin1_General_CI_AS 
    , strAddress = SUBSTRING(REPLACE(REPLACE(dbo.fnTrimX(D.strAddress), CHAR(10), ' ') , CHAR(13), ' '),0,40) COLLATE Latin1_General_CI_AS  --max char 40       
	, SUBSTRING(C2.strName, 0, 40) AS strPayeeName  --max char 40
	, ISNULL(dbo.fnTrimX(strCity), '')  COLLATE Latin1_General_CI_AS  strCity
	, ISNULL(dbo.fnTrimX(strState), '') COLLATE Latin1_General_CI_AS  strState 
	, ISNULL(dbo.fnTrimX(strZipCode), '') COLLATE Latin1_General_CI_AS  strZip 
    , strZipState = (CASE WHEN LEN(D.strCity) <> 0 THEN dbo.fnTrimX(D.strCity) ELSE '' END +               
       CASE WHEN LEN(D.strState) <> 0 THEN ', ' + dbo.fnTrimX(D.strState) ELSE '' END +               
       CASE WHEN LEN(D.strZipCode) <> 0 THEN ', ' + dbo.fnTrimX(D.strZipCode) ELSE '' END)  COLLATE Latin1_General_CI_AS            
    , C2.strFederalTaxId
	, dblCropInsurance = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 1 --'Crop Insurance Proceeds'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
	, dblDirectSales = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 2--'Direct Sales'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
	ELSE 0 END    
    , dblParachutePayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 3--'Excess Golden Parachute Payments'     
		 THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
	, dblFederalIncome = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 4--'Federal Income Tax Withheld'     
		 THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END     
    , dblBoatsProceeds = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 5--'Fishing Boat Proceeds '     
	     THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
    , dblGrossProceedsAtty = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 6--'Gross Proceeds Paid to an Attorney'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END   
	, dblMedicalPayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 7--'Medical and Health Care Payments'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
    , dblNonemployeeCompensation = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 8--'Nonemployee Compensation'     
	    THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
	, dblOtherIncome = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 9--'Other Income'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END      
    , dblRents = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 10--'Rents'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
    , dblRoyalties = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 11--'Royalties'     
		THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
    , dblSubstitutePayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 12--'Substitute Payments in Lieu of Dividends or Interest '     
	    THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
	, dbl1099INT = CASE WHEN A.int1099Form = 2--1099 INT
	    THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
	, dbl1099B = CASE WHEN A.int1099Form = 3--1099 B
	    THEN (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END   
	, dbl1099 = (A.dbl1099 + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
    , intYear = YEAR(ISNULL(B2.dtmDatePaid, B.dtmDate))
	, A.int1099Form
	, A.int1099Category
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
    ON B.intBillId = A.intBillId
LEFT JOIN vyuAPBillPayment B2
	ON B.intBillId = B2.intBillId   
LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity C2 ON C.[intEntityId] = C2.intEntityId)
    ON C.[intEntityId] = B.intEntityVendorId
LEFT JOIN [tblEMEntityLocation] D
	ON C.[intEntityId] = D.intEntityId AND D.ysnDefaultLocation = 1     
WHERE ((B.ysnPosted = 1 AND B2.dblPayment IS NOT NULL) OR B.intTransactionType = 9) AND A.int1099Form <> 0
AND C2.ysnPrint1099 = 1


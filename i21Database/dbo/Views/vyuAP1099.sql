CREATE VIEW [dbo].[vyuAP1099]
AS
SELECT
      C.strVendorId
	, C.intEntityVendorId
    , strVendorCompanyName = dbo.fnAPRemoveSpecialChars(REPLACE(C2.strName, '&', 'and'))         
    , strAddress = REPLACE(REPLACE(D.strAddress, CHAR(10), ' ') , CHAR(13), ' ')         
    , strZip = (CASE WHEN LEN(D.strCity) <> 0 THEN D.strCity ELSE '' END +               
       CASE WHEN LEN(D.strState) <> 0 THEN ', ' + D.strState ELSE '' END +               
       CASE WHEN LEN(D.strZipCode) <> 0 THEN ', ' + D.strZipCode ELSE '' END)              
    , C2.strFederalTaxId
	, dblCropInsurance = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 1 --'Crop Insurance Proceeds'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END    
	, dblDirectSales = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 2--'Direct Sales'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
	ELSE 0 END    
    , dblParachutePayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 3--'Excess Golden Parachute Payments'     
		 THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END  
	, dblFederalIncome = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 4--'Federal Income Tax Withheld'     
		 THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END     
    , dblBoatsProceeds = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 5--'Fishing Boat Proceeds '     
	     THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END  
    , dblGrossProceedsAtty = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 6--'Gross Proceeds Paid to an Attorney'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END   
	, dblMedicalPayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 7--'Medical and Health Care Payments'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END    
    , dblNonemployeeCompensation = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 8--'Nonemployee Compensation'     
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END  
	, dblOtherIncome = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 9--'Other Income'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END      
    , dblRents = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 10--'Rents'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END    
    , dblRoyalties = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 11--'Royalties'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END    
    , dblSubstitutePayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 12--'Substitute Payments in Lieu of Dividends or Interest '     
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END    
	, dbl1099INT = CASE WHEN A.int1099Form = 2--1099 INT
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END  
	, dbl1099B = CASE WHEN A.int1099Form = 3--1099 B
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dblTotal)
     ELSE 0 END   
    , intYear = YEAR(ISNULL(B2.dtmDatePaid, B.dtmDate))
	, A.int1099Form
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
    ON B.intBillId = A.intBillId
LEFT JOIN vyuAPBillPayment B2
	ON B.intBillId = B2.intBillId   
LEFT JOIN (tblAPVendor C INNER JOIN tblEntity C2 ON C.intEntityVendorId = C2.intEntityId)
    ON C.intEntityVendorId = B.intEntityVendorId
LEFT JOIN tblEntityLocation D
	ON C.intEntityVendorId = D.intEntityId AND D.ysnDefaultLocation = 1     
WHERE ((B.ysnPosted = 1 AND B2.dblPayment IS NOT NULL) OR B.intTransactionType = 9) AND A.int1099Form <> 0


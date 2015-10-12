CREATE VIEW [dbo].[vyuAP1099MISC]
AS

SELECT              
     C.strVendorId              
    , strCompanyName = dbo.fnAPRemoveSpecialChars(REPLACE(C2.strName, '&', 'and'))         
    , strAddress = REPLACE(REPLACE(D.strAddress, CHAR(10), ' ') , CHAR(13), ' ')         
    , strZip = (CASE WHEN LEN(D.strCity) <> 0 THEN D.strCity ELSE '' END +               
       CASE WHEN LEN(D.strState) <> 0 THEN ', ' + D.strState ELSE '' END +               
       CASE WHEN LEN(D.strZipCode) <> 0 THEN ', ' + D.strZipCode ELSE '' END)              
    , A.str1099         
    , C.strTaxID as strVendorTaxID     
    , dblRents = CASE WHEN A.str1099Category = 'Rents'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblRoyalties = CASE WHEN A.str1099Category = 'Royalties'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblOtherIncome = CASE WHEN A.str1099Category = 'Other Income'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblFederalIncome = CASE WHEN A.str1099Category = 'Federal Income Tax Withheld'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblBoatsProceeds = CASE WHEN A.str1099Category = 'Fishing Boat Proceeds '     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblMedicalPayments = CASE WHEN A.str1099Category = 'Medical and Health Care Payments'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblNonemployeeCompensation = CASE WHEN A.str1099Category = 'Nonemployee Compensation'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblSubstitutePayments = CASE WHEN A.str1099Category = 'Substitute Payments in Lieu of Dividends or Interest '     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblCropInsurance = CASE WHEN A.str1099Category = 'Crop Insurance Proceeds'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblParachutePayments = CASE WHEN A.str1099Category = 'Excess Golden Parachute Payments'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END    
    , dblGrossProceedsAtty = CASE WHEN A.str1099Category = 'Gross Proceeds Paid to an Attorney'     
     THEN A.dblTotal / B.dblTotal * B2.dblPayment
     ELSE 0 END   
 , dblDirectSales = CASE WHEN A.str1099Category = 'Direct Sales'     
  THEN A.dblTotal / B.dblTotal * B2.dblPayment
  ELSE 0 END    
    , intBillYear = YEAR(B2.dtmDatePaid)       
    , dblTotalPayment = A.dblTotal / B.dblTotal * B2.dblPayment
 , B.strBillId      
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
    ON B.intBillId = A.intBillId
INNER JOIN vyuAPBillPayment B2
	ON B.intBillId = B2.intBillId   
LEFT JOIN (tblAPVendor C INNER JOIN tblEntity C2 ON C.intEntityVendorId = C2.intEntityId)
    ON C.intEntityVendorId = B.intEntityVendorId
LEFT JOIN tblEntityLocation D
	ON C.intEntityVendorId = D.intEntityId AND D.ysnDefaultLocation = 1     
WHERE B.ysnPosted = 1

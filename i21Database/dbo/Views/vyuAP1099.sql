CREATE VIEW [dbo].[vyuAP1099]
AS
SELECT
      dbo.fnTrim(C.strVendorId) COLLATE Latin1_General_CI_AS AS strVendorId
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
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
	, dblDirectSales = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 2--'Direct Sales'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
	ELSE 0 END    
    , dblParachutePayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 3--'Excess Golden Parachute Payments'     
		 THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
	, dblFederalIncome = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 4--'Federal Income Tax Withheld'     
		 THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END     
    , dblBoatsProceeds = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 5--'Fishing Boat Proceeds '     
	     THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
    , dblGrossProceedsAtty = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 6--'Gross Proceeds Paid to an Attorney'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END   
	, dblMedicalPayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 7--'Medical and Health Care Payments'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
    , dblNonemployeeCompensation = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 8--'Nonemployee Compensation'     
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
	, dblOtherIncome = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 9--'Other Income'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END      
    , dblRents = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 10--'Rents'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
    , dblRoyalties = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 11--'Royalties'     
		THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
    , dblSubstitutePayments = CASE WHEN A.int1099Form = 1 AND A.int1099Category = 12--'Substitute Payments in Lieu of Dividends or Interest '     
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END    
	, dbl1099INT = CASE WHEN A.int1099Form = 2--1099 INT
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END  
	, dbl1099B = CASE WHEN A.int1099Form = 3--1099 B
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END
	, dbl1099K = CASE WHEN A.int1099Form = 6--1099 K
	    THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
     ELSE 0 END
	, dblDividends = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 1
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END 
	, dblNonpatronage = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 2
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblPerUnit = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 3
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblFederalTax = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 4
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblRedemption = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 5
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblDomestic = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 6
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblInvestments = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 7
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblOpportunity = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 8
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblAMT = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 9
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END
	, dblOther = CASE WHEN A.int1099Form = 4  AND A.int1099Category = 10
	    THEN 
			CASE WHEN patRef.intBillId IS NULL THEN (A.dblTotal + A.dblTax) ELSE A.dbl1099 END
     ELSE 0 END 	 	           
	, dblOrdinaryDividends = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 0--'OrdinaryDividends'     
		THEN  (A.dblTotal + A.dblTax)
     ELSE 0 END  
	 , dblQualified = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 1--'Qualified'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END  
	 , dblCapitalGain = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 2--'CapitalGain'     
		THEN (A.dblTotal + A.dblTax)
     ELSE 0 END  
	 , dblUnrecapGain = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 3--'UnrecapGain'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END
	, dblSection1202 = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 4--'Section1202'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END
	, dblCollectibles = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 5--'Collectibles'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END
	, dblNonDividends = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 6--'NonDividends'     
		THEN (A.dblTotal + A.dblTax)
     ELSE 0 END
	, dblFITW = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 7--'FITW'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END
	, dblInvestment = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 8--'Investment'     
		THEN (A.dblTotal + A.dblTax)
     ELSE 0 END
	, dblForeignTax = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 9--'ForeignTax'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END
	, dblForeignCountry = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 10--'ForeignCountry'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END   
	, dblCash = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 11--'Cash Liquidation'     
		THEN (A.dblTotal + A.dblTax)
     ELSE 0 END 
	, dblNonCash = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 12--'Non Cash Liquidation'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END      
	, dblExempt = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 13--'Exempt Interest Dividends'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END
	, dblPrivate = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 14--'Private Activity Dividends'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END 
	, dblState = CASE WHEN A.int1099Form = 5 AND A.int1099Category = 15--'State Tax Withheld'     
		THEN (A.dblTotal + A.dblTax) 
     ELSE 0 END   
	, dbl1099 = CASE WHEN patRef.intBillId IS NULL AND A.int1099Form = 4
				THEN (A.dblTotal + A.dblTax) / B.dblTotal  * ISNULL(B2.dblPayment,A.dbl1099)
				ELSE A.dbl1099
				END
    , intYear = YEAR(ISNULL(B2.dtmDatePaid, B.dtmDate))
	, A.int1099Form
	, A.int1099Category
	, CASE WHEN B.intTransactionType = 9 THEN B.dtmDate ELSE B2.dtmDatePaid END AS dtmDate
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
    ON B.intBillId = A.intBillId
--LEFT JOIN vyuAPBillPayment B2
--	ON B.intBillId = B2.intBillId   
LEFT JOIN (
	SELECT
		P2.intBillId
		,P2.dblPayment
		,P.dtmDatePaid
	FROM tblAPPayment P
	INNER JOIN tblAPPaymentDetail P2 ON P.intPaymentId = P2.intPaymentId
	WHERE P.ysnPosted = 1
) B2 ON B.intBillId = B2.intBillId
LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity C2 ON C.[intEntityId] = C2.intEntityId)
    ON C.[intEntityId] = B.intEntityVendorId
LEFT JOIN [tblEMEntityLocation] D
	ON C.[intEntityId] = D.intEntityId AND D.ysnDefaultLocation = 1     
LEFT JOIN tblPATRefundCustomer patRef ON patRef.intBillId = B.intBillId
WHERE 
	((B.ysnPosted = 1 AND B2.dblPayment IS NOT NULL) 
AND A.int1099Form <> 0
AND (C2.ysnPrint1099 = 1 OR patRef.intBillId IS NOT NULL)
AND	B.intTransactionType IN (1,3,14))
OR B.intTransactionType = 9 
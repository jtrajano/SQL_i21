
CREATE VIEW  vyuExportARBalancesTripleEFormat
AS
SELECT 
 CustomerCode = dbo.fnCFPadString(ISNULL(vyuARCustomerInquiry.strCustomerNumber, 0) , 10, '0', 'left') 
,[Name] = vyuARCustomerInquiry.strCustomerName
,FirstName = ''
,LastName = ''
,MainPhone = vyuARCustomerInquiry.strPhone1
,Address1 = (SELECT TOP 1
		Record
		FROM [fnCFSplitString](vyuARCustomerInquiry.strAddress,CHAR(10)) 
		WHERE RecordKey = 1)
,Address2 = (SELECT TOP 1
		Record
		FROM [fnCFSplitString](vyuARCustomerInquiry.strAddress,CHAR(10)) 
		WHERE RecordKey = 2)		
,Address3 = (SELECT TOP 1
		Record
		FROM [fnCFSplitString](vyuARCustomerInquiry.strAddress,CHAR(10)) 
		WHERE RecordKey = 3)	
,City = vyuARCustomerInquiry.strCity
,[State] = vyuARCustomerInquiry.strState
,ZipCode = vyuARCustomerInquiry.strZipCode
,Balance = cast(ROUND(ISNULL(vyuARCustomerInquiry.dblTotalDue, 0.0),2)as numeric(18,2))
,AllowCharge = CASE WHEN tblARCustomer.ysnCreditHold = 1 THEN 'false' 
				   ELSE
						CASE WHEN tblARCustomer.strCreditCode = 'Reject Orders' OR tblARCustomer.strCreditCode = 'Always Hold' THEN 'false'  
							ELSE
								CASE 
									WHEN tblARCustomer.dblCreditLimit = 0 THEN 'false'
									WHEN tblARCustomer.dblCreditLimit > 0 THEN 'true'
								END
						END
			  END
,CreditLimit = cast(ROUND(ISNULL(tblARCustomer.dblCreditLimit, 0.0),2)as numeric(18,2))
,ValidateDrivers = 'false'
,ValidateVehicles = 'false'
,SalesTaxExempt =  (SELECT CASE WHEN COUNT(1) > 0 THEN 'true' ELSE 'false' END 
					FROM tblARCustomerTaxingTaxException
					INNER JOIN tblSMTaxClass
					ON tblARCustomerTaxingTaxException.intTaxClassId = tblSMTaxClass.intTaxClassId
					INNER JOIN tblSMTaxReportType
					ON tblSMTaxReportType.intTaxReportTypeId = tblSMTaxClass.intTaxReportTypeId
					WHERE 'State Sales Tax' = tblSMTaxReportType.strType 
					AND tblARCustomerTaxingTaxException.intEntityCustomerId = tblARCustomer.intEntityId)  
,CustomerCategory = ''
,TermsDescription = vyuARCustomerInquiry.strTerm
,TermsDaysDue = (SELECT TOP 1
					CASE WHEN strType = 'Standard' THEN ISNULL(intBalanceDue,0) ELSE 30 END
				 FROM tblSMTerm WHERE tblSMTerm.intTermID = vyuARCustomerInquiry.intTermsId
				)
,FinanceChargeExempt = ISNULL((
	SELECT TOP 1
	CASE WHEN ISNULL(dblServiceChargeAPR,0) = 0 THEN 'true'
	WHEN ISNULL(dblServiceChargeAPR,0) <> 0 THEN 'false'
	END
	FROM tblARServiceCharge
	WHERE tblARServiceCharge.intServiceChargeId = tblARCustomer.intServiceChargeId
	),'false')
,PONumberRequiredForCustomerCharge = 'false'
FROM vyuARCustomerInquiry
INNER JOIN tblARCustomer 
ON vyuARCustomerInquiry.intEntityCustomerId = tblARCustomer.intEntityId



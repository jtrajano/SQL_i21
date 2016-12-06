CREATE VIEW [dbo].[vyuPRPaycheckHistory]
AS
SELECT DISTINCT	PC.intPaycheckId, 
				PC.strPaycheckId, 
				PC.[intEntityEmployeeId], 
				PC.dtmPayDate,
				CASE WHEN (PC.ysnDirectDeposit = 1) THEN CASE WHEN PC.ysnVoid = 1 THEN 'Voided Direct Deposit' ELSE 'Direct Deposit' END  ELSE CM.strReferenceNo END AS strReferenceNo, 
				PC.dblGross,
				PC.dblNetPayTotal, 
				PC.dblTaxTotal,
				PC.dblDeductionTotal,
				PC.ysnPosted
		   FROM dbo.tblPRPaycheck PC
	 INNER JOIN	dbo.tblCMBankTransaction CM  
			 ON PC.strReferenceNo = CM.strReferenceNo
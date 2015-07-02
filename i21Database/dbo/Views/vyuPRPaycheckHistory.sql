CREATE VIEW [dbo].[vyuPRPaycheckHistory]
AS
SELECT DISTINCT	PC.intPaycheckId, 
				PC.strPaycheckId, 
				PC.intEmployeeId, 
				PC.dtmPayDate,
				CM.strReferenceNo, 
				PC.dblGross,
				PC.dblNetPayTotal, 
				PC.dblTaxTotal,
				PC.dblDeductionTotal,
				PC.ysnPosted
		   FROM dbo.tblPRPaycheck PC
	 INNER JOIN	dbo.tblCMBankTransaction CM  
			 ON PC.strReferenceNo = CM.strReferenceNo
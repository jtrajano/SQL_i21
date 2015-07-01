CREATE VIEW [dbo].[vyuPRPaycheckHistory]
AS
SELECT      PC.intPaycheckId, 
			PC.strPaycheckId, 
			PC.intEmployeeId, 
			PC.dtmPayDate, 
			PC.intBankAccountId,  
			CM.strBankAccountNo, 
			PC.dblGross,
			PC.dblNetPayTotal, 
			PC.dblTaxTotal,
			PC.dblDeductionTotal,
			PC.ysnPosted
FROM        dbo.tblPRPaycheck PC
INNER JOIN	dbo.tblCMBankAccount CM  ON PC.intBankAccountId = CM.intBankAccountId
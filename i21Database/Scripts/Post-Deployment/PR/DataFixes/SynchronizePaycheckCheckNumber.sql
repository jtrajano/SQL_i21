/*
* Synchronizes Paycheck's check number with its corresponding Bank 
* Transaction Entry. Only affects checks that are already printed and comitted.
*/

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheck'))
BEGIN

EXEC ('UPDATE tblPRPaycheck SET
		strReferenceNo = (SELECT strReferenceNo FROM tblCMBankTransaction 
							WHERE strTransactionId = tblPRPaycheck.strPaycheckId
							AND dtmCheckPrinted IS NOT NULL)
		,ysnPrinted = 1
		WHERE ysnPosted = 1 AND ysnVoid = 0
			AND strReferenceNo <> (SELECT strReferenceNo FROM tblCMBankTransaction 
									WHERE strTransactionId = tblPRPaycheck.strPaycheckId
									AND dtmCheckPrinted IS NOT NULL)
	  ')

END


--REPLACE ALL Transaction Date to Cleared Date in bank file format detail with bank statement type
GO

UPDATE A SET strFieldName = 'Cleared Date' from tblCMBankFileFormatDetail A join tblCMBankFileFormat B on
A.intBankFileFormatId = B.intBankFileFormatId 
WHERE intBankFileType =3 
AND strFieldName = 'tblCMBankTransaction.dtmDate'

GO

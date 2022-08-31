CREATE VIEW vyuCMBSBankFileFormatDropDown
AS
SELECT 
A.intBankFileFormatId,
strName,
strError
FROM tblCMBankFileFormat A
OUTER APPLY(

    SELECT TOP 1 strError FROM dbo.fnCMGetBSBankFileFormatStatus()
    WHERE BankFileFormatId = A.intBankFileFormatId
)U
WHERE A.intBankFileType = 3
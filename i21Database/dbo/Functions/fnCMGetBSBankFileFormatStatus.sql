CREATE FUNCTION fnCMGetBSBankFileFormatStatus()
RETURNS TABLE
AS 
RETURN (
    SELECT BankFileFormatId , 'Amount and Credit/Debit should not exists at them time in a bank statement file format' COLLATE Latin1_General_CI_AS  strError  FROM vyuCMBSBankFileFormatStatus WHERE 
    (Amount & ( Debit | Credit ))  = 1 AND ISNULL(ysnSystemGenerated,0) = 0
    UNION
    SELECT BankFileFormatId , 'Bank File Statement  should have Amount OR Credit/Debit field(s).'  COLLATE Latin1_General_CI_AS  strError  FROM vyuCMBSBankFileFormatStatus WHERE 
    (Amount  | ( Debit & Credit )) = 0  AND ISNULL(ysnSystemGenerated,0) = 0
    UNION
    SELECT BankFileFormatId , 'Bank File Statement  should have Check Number field.'  COLLATE Latin1_General_CI_AS  strError  FROM vyuCMBSBankFileFormatStatus WHERE 
    CheckNumber = 0 AND ISNULL(ysnSystemGenerated,0) = 0
    UNION
    SELECT BankFileFormatId , 'Bank File Statement  should have Bank Account Number field.'  COLLATE Latin1_General_CI_AS  strError  FROM vyuCMBSBankFileFormatStatus WHERE 
    BankAccountNo = 0  AND ISNULL(ysnSystemGenerated,0) = 0
    UNION
    SELECT BankFileFormatId , 'Bank File Statement  should have Bank Description field.'  COLLATE Latin1_General_CI_AS  strError  FROM vyuCMBSBankFileFormatStatus WHERE 
    BankDescription = 0  AND ISNULL(ysnSystemGenerated,0) = 0
    UNION
    SELECT BankFileFormatId , 'Bank File Statement  should have Cleared Date field.'  COLLATE Latin1_General_CI_AS  strError  FROM vyuCMBSBankFileFormatStatus WHERE 
    ClearDate = 0  AND ISNULL(ysnSystemGenerated,0) = 0
)






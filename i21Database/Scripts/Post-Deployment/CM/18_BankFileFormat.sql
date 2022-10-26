

--REPLACE ALL Transaction Date to Cleared Date in bank file format detail with bank statement type
GO

UPDATE A SET strFieldName = 'Cleared Date' from tblCMBankFileFormatDetail A join tblCMBankFileFormat B on
A.intBankFileFormatId = B.intBankFileFormatId 
WHERE intBankFileType =3 
AND strFieldName = 'tblCMBankTransaction.dtmDate'

GO

IF NOT EXISTS (SELECT 1 FROM tblCMBankFileFormat WHERE strName = 'BAI')
BEGIN
    DECLARE @ID int
    INSERT INTO tblCMBankFileFormat ( strName, intBankFileType, intFileFormat, ysnSystemGenerated)
    SELECT 'BAI', 3,1,1

    SELECT @ID = SCOPE_IDENTITY()

    INSERT INTO tblCMBankFileFormatDetail (intBankFileFormatId, intRecordType, intFieldNo, intFieldLength, intFieldType, strFieldDescription, strFieldName, strFieldFormat, ysnFieldActive, intConcurrencyId)
    SELECT 
    @ID,	1,	1,	0,	5,	'Record Code',	'16',							'',			1,	1  UNION SELECT
    @ID,	1,	2,	0,	5,	'Type Code',	'',								'',			1,	1  UNION SELECT
    @ID,	1,	3,	0,	2,	'',             'tblCMBankTransaction.dblAmount','',			1,	1  UNION SELECT
    @ID,	1,	4,	0,	5,	'Funds Type'	,'','',										1,	1  UNION SELECT
    @ID,	1,	5,	0,	2,	'Cleared Date',	'tblCMBankTransaction.dtmDate',	'yyMMdd',	1,	1  UNION SELECT
    @ID,	1,	6,	0,	2,	'',             'tblCMBankTransaction.dtmDate',	'HHmm',		1,	1  UNION SELECT
    @ID,	1,	7,	0,	5,	'Bank Reference #','',							'',			1,	1  UNION SELECT
    @ID,	1,	8,	0,	5,	'Customer Reference #','', '',								1,	1  UNION SELECT
    @ID,	1,	9,	0,	2,	'','Bank Description', '',									1,	1  
END

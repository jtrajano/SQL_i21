--This script will do the following.
--1. Transfer data from tblAPTempTerms to tblAPTermsImported
--2. DROP tblAPTempTerms

IF EXISTS (SELECT 1
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND TABLE_NAME = 'tblAPTempVendor')
BEGIN

	EXEC('
	INSERT INTO tblAPImportedVendors
	SELECT * FROM tblAPTempVendor

	DROP TABLE tblAPTempVendor
	DROP TABLE tblAPInvalidTransaction
	')

END
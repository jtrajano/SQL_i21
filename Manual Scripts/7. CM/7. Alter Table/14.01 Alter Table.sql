
/*
	Modify date: Dec. 17, 2013
	Description: 
	
	Add new column on tblCMBankAccount as a link column back to the origin system. 
	No need to collate to Latin1_General_CI_ASthe column since it must follow the collation used by the origin system. 	
*/

IF COL_LENGTH('tblCMBankAccount','strCbkNo') IS NULL
BEGIN 
	ALTER TABLE tblCMBankAccount
		ADD strCbkNo NVARCHAR(2) NULL 
END
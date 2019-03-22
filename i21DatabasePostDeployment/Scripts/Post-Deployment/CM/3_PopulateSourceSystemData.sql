-- Purpose: 
-- Since a new field (strSourceSystem) is added, it will populate the source system indicator from the origin system to the bank transaction table.
-- The strSourceSystem is used to determine the transaction type from the origin.
-- The field is NULL when the transaction is created from i21.  

print('/*******************  BEGIN Populate Source System Field *******************/')

IF (OBJECT_ID (N'dbo.apchkmst_origin', N'U') IS NOT NULL)
    EXEC('
		UPDATE tblCMBankTransaction
		SET		strSourceSystem = i.apchk_src_sys COLLATE Latin1_General_CI_AS
		FROM	apchkmst_origin i INNER JOIN dbo.tblCMBankTransaction f
					ON f.strLink = ( CAST(i.apchk_cbk_no AS NVARCHAR(2)) 
									+ CAST(i.apchk_rev_dt AS NVARCHAR(10)) 
									+ CAST(i.apchk_trx_ind AS NVARCHAR(1)) 
									+ CAST(i.apchk_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS 
		WHERE	f.strSourceSystem IS NULL    
    ')
GO

print('/*******************  END Populate Source System Field *******************/')
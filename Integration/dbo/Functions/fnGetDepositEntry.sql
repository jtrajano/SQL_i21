-- This function will return all the record that is a Deposit Entry transaction. 
-- Otherwise, it will none. 
IF	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
		IF OBJECT_ID (N''dbo.fnGetDepositEntry'', N''FN'') IS NOT NULL
			DROP FUNCTION dbo.fnGetDepositEntry;
	')

	EXEC ('
		CREATE  FUNCTION [dbo].[fnGetDepositEntry]()
			RETURNS @OriginDepositEntrty TABLE 
			(
				strLink NVARCHAR(100) COLLATE Latin1_General_CI_AS
			)
		AS
		BEGIN
			INSERT @OriginDepositEntrty
				SELECT
							( CAST(a.apchk_cbk_no AS NVARCHAR(2)) 
											+ CAST(a.apchk_rev_dt AS NVARCHAR(10)) 
											+ CAST(a.apchk_trx_ind AS NVARCHAR(1)) 
											+ CAST(a.apchk_chk_no AS NVARCHAR(8))
								) COLLATE Latin1_General_CI_AS
							FROM	dbo.apchkmst a INNER JOIN dbo.aptrxmst b
										ON a.apchk_cbk_no = b.aptrx_cbk_no
										AND a.apchk_chk_no = b.aptrx_chk_no
										AND a.apchk_trx_ind = b.aptrx_trans_type			
										AND a.apchk_rev_dt = b.aptrx_chk_rev_dt
										AND a.apchk_vnd_no = b.aptrx_vnd_no
							WHERE	 b.aptrx_trans_type = ''O'' -- Other CW transactions
			RETURN
		END		
	')
END

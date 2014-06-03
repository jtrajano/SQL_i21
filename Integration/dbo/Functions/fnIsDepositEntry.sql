-- This function will return true if the a record is a Deposit Entry transaction. 
-- Otherwise, it will return false. 
IF	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
		IF OBJECT_ID (N''dbo.fnIsDepositEntry'', N''FN'') IS NOT NULL
			DROP FUNCTION dbo.fnIsDepositEntry;
	')

	EXEC ('
		CREATE FUNCTION [dbo].[fnIsDepositEntry](
			@strLink AS NVARCHAR(50)
		)
			RETURNS BIT 
		AS
		BEGIN 

			DECLARE @isDepositEntry AS BIT = 0

			SELECT	TOP 1 
					@isDepositEntry = 1
			FROM	dbo.apchkmst a INNER JOIN dbo.aptrxmst b
						ON a.apchk_cbk_no = b.aptrx_cbk_no
						AND a.apchk_chk_no = b.aptrx_chk_no
						AND a.apchk_trx_ind = b.aptrx_trans_type			
						AND a.apchk_rev_dt = b.aptrx_chk_rev_dt
						AND a.apchk_vnd_no = b.aptrx_vnd_no
			WHERE	@strLink = ( CAST(a.apchk_cbk_no AS NVARCHAR(2)) 
									+ CAST(a.apchk_rev_dt AS NVARCHAR(10)) 
									+ CAST(a.apchk_trx_ind AS NVARCHAR(1)) 
									+ CAST(a.apchk_chk_no AS NVARCHAR(8))
						) COLLATE Latin1_General_CI_AS
					AND b.aptrx_trans_type = ''O'' -- Other CW transactions

			/* Note: 
			aptrx-trans-type pic x.
				* C=Credit Memo
				* I=Invoice
				* J=Adjustment
				* O=Other CW transactions
				* P=Payment
				* R=Reverse Invoices/Credits
				* V=Void Payment
			*/
	
			RETURN ISNULL(@isDepositEntry, 0) 
		END 		
	')
END

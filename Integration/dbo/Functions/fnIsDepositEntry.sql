-- This function will return true if the a record is a Deposit Entry transaction. 
-- Otherwise, it will return false. 
-- 
-- Usage:
-- 1. It is used in the triggers for apchkmst. If record is a deposit entry, the record is not synchronized with Cash Management. 
IF OBJECT_ID (N'dbo.fnIsDepositEntry', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fnIsDepositEntry;
GO

IF	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
		CREATE FUNCTION [dbo].[fnIsDepositEntry](
			@cbk_no AS CHAR(2)
			,@chk_no AS CHAR(8)
			,@trx_ind AS CHAR(1)
			,@rev_dt AS INT
			,@vnd_no AS CHAR(10)
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
			WHERE	a.apchk_cbk_no = @cbk_no
					AND a.apchk_chk_no = @chk_no
					AND a.apchk_trx_ind = @trx_ind
					AND a.apchk_rev_dt = @rev_dt
					AND a.apchk_vnd_no = @vnd_no
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
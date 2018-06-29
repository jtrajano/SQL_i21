
-- Create a stub view that can be used if the Origin Integration is not established. 
CREATE VIEW [dbo].[vyuCMOriginDepositEntry]
AS

SELECT 
    [aptrx_vnd_no] = CAST(NULL AS CHAR(10)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_ivc_no] = CAST(NULL AS CHAR(18)) COLLATE SQL_Latin1_General_CP1_CS_AS 
	,[aptrx_sys_rev_dt] = CAST(NULL AS INT)
	,[aptrx_sys_time] = CAST(NULL AS INT)
	,[aptrx_cbk_no] = CAST(NULL AS CHAR(2)) COLLATE SQL_Latin1_General_CP1_CS_AS 
	,[aptrx_chk_no] = CAST(NULL AS CHAR(8)) COLLATE SQL_Latin1_General_CP1_CS_AS 
	,[aptrx_trans_type] = CAST(NULL AS CHAR) COLLATE SQL_Latin1_General_CP1_CS_AS 
	,[aptrx_batch_no] = CAST(NULL AS SMALLINT)
	,[aptrx_pur_ord_no] = CAST(NULL AS CHAR(8)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_po_rcpt_seq] = CAST(NULL AS CHAR(4)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_ivc_rev_dt] = CAST(NULL AS INT)
	,[aptrx_disc_rev_dt] = CAST(NULL AS INT)
	,[aptrx_due_rev_dt] = CAST(NULL AS INT)
	,[aptrx_chk_rev_dt] = CAST(NULL AS INT)
	,[aptrx_gl_rev_dt] = CAST(NULL AS INT)
	,[aptrx_disc_pct] = CAST(NULL AS DECIMAL(4, 2))
	,[aptrx_orig_amt] = CAST(NULL AS DECIMAL(11, 2))
	,[aptrx_disc_amt] = CAST(NULL AS DECIMAL(11, 2))
	,[aptrx_wthhld_amt] = CAST(NULL AS DECIMAL(11, 2))
	,[aptrx_net_amt] = CAST(NULL AS DECIMAL(11, 2))
	,[aptrx_1099_amt] = CAST(NULL AS DECIMAL(11, 2))
	,[aptrx_comment] = CAST(NULL AS CHAR(30)) COLLATE SQL_Latin1_General_CP1_CS_AS 
	,[aptrx_orig_type] = CAST(NULL AS CHAR) COLLATE SQL_Latin1_General_CP1_CS_AS 
	,[aptrx_name] = CAST(NULL AS CHAR(50)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_recur_yn] = CAST(NULL AS CHAR) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_currency] = CAST(NULL AS CHAR(3)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_currency_rt] = CAST(NULL AS DECIMAL(15, 8))
	,[aptrx_currency_cnt] = CAST(NULL AS CHAR(8)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_user_id] = CAST(NULL AS CHAR(16)) COLLATE SQL_Latin1_General_CP1_CS_AS
	,[aptrx_user_rev_dt] = CAST(NULL AS INT)	
WHERE 1 = 0
    
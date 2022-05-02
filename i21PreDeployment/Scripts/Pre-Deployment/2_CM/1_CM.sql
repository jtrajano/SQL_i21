
IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	--Drop apcbkmst_origin if exist in preparation for sp_rename
	IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst_origin' and TABLE_TYPE = N'BASE TABLE')
	BEGIN
		DROP TABLE apcbkmst_origin
	END

	EXEC sp_rename 'apcbkmst', 'apcbkmst_origin'
END
GO

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	--Drop apchkmst_origin if exist in preparation for sp_rename
	IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst_origin' and TABLE_TYPE = N'BASE TABLE')
	BEGIN
		DROP TABLE apchkmst_origin
	END

	EXEC sp_rename 'apchkmst', 'apchkmst_origin'
END
GO

IF OBJECT_ID (N'dbo.apchkmst', N'U')  IS NULL AND  OBJECT_ID (N'dbo.apchkmst_origin', N'U')  IS NULL
BEGIN
		CREATE TABLE [dbo].[apcbkmst_origin] (
		[apcbk_no]                 CHAR (2)        NOT NULL,
		[apcbk_currency]           CHAR (3)        NULL,
		[apcbk_password]           CHAR (16)       NULL,
		[apcbk_desc]               CHAR (30)       NULL,
		[apcbk_bank_acct_no]       CHAR (20)       NULL,
		[apcbk_comment]            CHAR (30)       NULL,
		[apcbk_show_bal_yn]        CHAR (1)        NULL,
		[apcbk_prompt_align_yn]    CHAR (1)        NULL,
		[apcbk_chk_clr_ord_dn]     CHAR (1)        NULL,
		[apcbk_import_export_yn]   CHAR (1)        NULL,
		[apcbk_export_cbk_no]      CHAR (2)        NULL,
		[apcbk_stmt_lock_rev_dt]   INT             NULL,
		[apcbk_gl_close_rev_dt]    INT             NULL,
		[apcbk_bal]                DECIMAL (11, 2) NULL,
		[apcbk_next_chk_no]        INT             NULL,
		[apcbk_next_eft_no]        INT             NULL,
		[apcbk_check_format_cs]    CHAR (1)        NULL,
		[apcbk_laser_down_lines]   TINYINT         NULL,
		[apcbk_prtr_checks]        CHAR (80)       NULL,
		[apcbk_auto_assign_trx_yn] CHAR (1)        NULL,
		[apcbk_next_trx_no]        INT             NULL,
		[apcbk_transit_route]      INT             NULL,
		[apcbk_ach_company_id]     CHAR (10)       NULL,
		[apcbk_ach_bankname]       CHAR (23)       NULL,
		[apcbk_gl_cash]            DECIMAL (16, 8) NULL,
		[apcbk_gl_ap]              DECIMAL (16, 8) NULL,
		[apcbk_gl_disc]            DECIMAL (16, 8) NULL,
		[apcbk_gl_wthhld]          DECIMAL (16, 8) NULL,
		[apcbk_gl_curr]            DECIMAL (16, 8) NULL,
		[apcbk_active_yn]          CHAR (1)        NULL,
		[apcbk_bnk_no]             CHAR (4)        NULL,
		[apcbk_user_id]            CHAR (16)       NULL,
		[apcbk_user_rev_dt]        INT             NULL,
		[A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
		CONSTRAINT [k_apcbkmst] PRIMARY KEY NONCLUSTERED ([apcbk_no] ASC)
	);
	CREATE UNIQUE CLUSTERED INDEX [Iapcbkmst0]
		ON [dbo].[apcbkmst_origin]([apcbk_no] ASC);
END



--RENAME Bank Transfer columns 
IF COL_LENGTH('tblCMBankTransfer', 'dblRate') IS NOT NULL
BEGIN
	EXEC sp_rename 'dbo.tblCMBankTransfer.dblRate', 'dblRateAmountTo', 'COLUMN';  
	EXEC sp_rename 'dbo.tblCMBankTransfer.dblHistoricRate', 'dblRateAmountFrom', 'COLUMN';  
END




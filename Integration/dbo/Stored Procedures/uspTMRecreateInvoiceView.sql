GO
	PRINT 'START OF CREATING [uspTMRecreateInvoiceView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateInvoiceView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateInvoiceView
GO

CREATE PROCEDURE uspTMRecreateInvoiceView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwivcmst')
	BEGIN
		DROP VIEW vwivcmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG'	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwivcmst]
					AS
					SELECT
						vwivc_bill_to_cus		=	agivc_bill_to_cus  COLLATE Latin1_General_CI_AS
						,vwivc_ivc_no			=	agivc_ivc_no COLLATE Latin1_General_CI_AS
						,vwivc_loc_no			=	agivc_loc_no COLLATE Latin1_General_CI_AS
						,vwivc_type				=	CAST(agivc_type AS CHAR(4)) COLLATE Latin1_General_CI_AS
						,vwivc_status			=	CAST(agivc_status AS CHAR(3)) COLLATE Latin1_General_CI_AS
						,vwivc_rev_dt			=	agivc_rev_dt
						,vwivc_comment			=	agivc_comment COLLATE Latin1_General_CI_AS
						,vwivc_po_no			=	agivc_po_no COLLATE Latin1_General_CI_AS
						,vwivc_sold_to_cus		=	agivc_sold_to_cus COLLATE Latin1_General_CI_AS
						,vwivc_slsmn_no			=	CAST(agivc_slsmn_no AS CHAR(4)) COLLATE Latin1_General_CI_AS
						,vwivc_slsmn_tot		=	agivc_slsmn_tot
						,vwivc_net_amt			=	agivc_net_amt
						,vwivc_slstx_amt		=	CAST(agivc_slstx_amt AS DECIMAL(18,6))
						,vwivc_srvchr_amt		=	agivc_srvchr_amt
						,vwivc_disc_amt			=	CAST(agivc_disc_amt AS DECIMAL(18,6))
						,vwivc_amt_paid			=	agivc_amt_paid
						,vwivc_bal_due			=	agivc_bal_due
						,vwivc_pend_disc		=	CAST(agivc_pend_disc AS DECIMAL(18,6))
						,vwivc_no_payments		=	CAST(agivc_no_payments AS INT)
						,vwivc_adj_inv_yn		=	agivc_adj_inv_yn COLLATE Latin1_General_CI_AS
						,vwivc_srvchr_cd		=	CAST(agivc_srvchr_cd AS INT)
						,vwivc_disc_rev_dt		=	agivc_disc_rev_dt
						,vwivc_net_rev_dt		=	agivc_net_rev_dt
						,vwivc_src_sys			=	CAST(agivc_src_sys AS CHAR(4)) COLLATE Latin1_General_CI_AS
						,vwivc_orig_rev_dt		=	agivc_orig_rev_dt
						,vwivc_split_no			=	agivc_split_no  COLLATE Latin1_General_CI_AS
						,vwivc_pd_days_old		=	CAST(agivc_pd_days_old AS INT)
						,vwivc_currency			=	CAST(agivc_currency AS CHAR(4))  COLLATE Latin1_General_CI_AS
						,vwivc_currency_rt		=	agivc_currency_rt
						,vwivc_currency_cnt		=	agivc_currency_cnt  COLLATE Latin1_General_CI_AS
						,vwivc_eft_ivc_paid_yn	=	agivc_eft_ivc_paid_yn COLLATE Latin1_General_CI_AS
						,vwivc_terms_code		=	CAST(agivc_terms_code AS CHAR(4)) COLLATE Latin1_General_CI_AS
						,vwivc_pay_type			=	CAST(agivc_pay_type AS CHAR(4)) COLLATE Latin1_General_CI_AS
						,vwivc_user_id			=	agivc_user_id COLLATE Latin1_General_CI_AS
						,vwivc_user_rev_dt		=	agivc_user_rev_dt
						,A4GLIdentity			=	CAST(A4GLIdentity   AS INT)
					FROM agivcmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT') = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwivcmst]
					AS
					SELECT
						vwivc_bill_to_cus		=	ptivc_cus_no COLLATE Latin1_General_CI_AS
						,vwivc_ivc_no			=	CAST(ptivc_invc_no AS CHAR(8))   COLLATE Latin1_General_CI_AS
						,vwivc_loc_no			=	ptivc_loc_no COLLATE Latin1_General_CI_AS
						,vwivc_type				=	CAST(NULL AS CHAR(4))   COLLATE Latin1_General_CI_AS
						,vwivc_status			=	CAST(ptivc_sold_by AS CHAR(3))   COLLATE Latin1_General_CI_AS
						,vwivc_rev_dt			=	NULL
						,vwivc_comment			=	ptivc_comment  COLLATE Latin1_General_CI_AS 
						,vwivc_po_no			=	ptivc_po_no COLLATE Latin1_General_CI_AS
						,vwivc_sold_to_cus		=	ptivc_sold_to COLLATE Latin1_General_CI_AS
						,vwivc_slsmn_no			=	CAST(NULL AS CHAR(4))   COLLATE Latin1_General_CI_AS
						,vwivc_slsmn_tot		=	ptivc_sold_by_tot
						,vwivc_net_amt			=	ptivc_net
						,vwivc_slstx_amt		=	CAST(ptivc_sales_tax AS DECIMAL(18,6)) 
						,vwivc_srvchr_amt		=	CAST(0.00 AS DECIMAL(18,6))  
						,vwivc_disc_amt			=	CAST(ptivc_disc_amt AS DECIMAL(18,6))  
						,vwivc_amt_paid			=	ptivc_amt_applied
						,vwivc_bal_due			=	ptivc_bal_due
						,vwivc_pend_disc		=	CAST(ptivc_pend_disc AS DECIMAL(18,6)) 
						,vwivc_no_payments		=	CAST(ptivc_no_payments AS INT)
						,vwivc_adj_inv_yn		=	ptivc_adj_inv_yn COLLATE Latin1_General_CI_AS
						,vwivc_srvchr_cd		=	CAST(0 AS INT)  
						,vwivc_disc_rev_dt		=	NULL
						,vwivc_net_rev_dt		=	NULL
						,vwivc_src_sys			=	CAST(NULL AS CHAR(4))   COLLATE Latin1_General_CI_AS
						,vwivc_orig_rev_dt		=	NULL
						,vwivc_split_no			=	CAST(NULL AS CHAR(4))    COLLATE Latin1_General_CI_AS
						,vwivc_pd_days_old		=	CAST(0 AS INT) 
						,vwivc_currency			=	CAST(NULL AS CHAR(4))  COLLATE Latin1_General_CI_AS
						,vwivc_currency_rt		=	CAST(0.00 AS DECIMAL(18,6))
						,vwivc_currency_cnt		=	CAST(NULL AS CHAR(8))   COLLATE Latin1_General_CI_AS
						,vwivc_eft_ivc_paid_yn	=	ptivc_eft_ivc_paid_yn COLLATE Latin1_General_CI_AS
						,vwivc_terms_code		=	CAST(NULL AS CHAR(4))  COLLATE Latin1_General_CI_AS
						,vwivc_pay_type			=	CAST(NULL AS CHAR(4))  COLLATE Latin1_General_CI_AS
						,vwivc_user_id			=	CAST(NULL AS CHAR(16))   COLLATE Latin1_General_CI_AS
						,vwivc_user_rev_dt		=	NULL
						,A4GLIdentity			=	CAST(A4GLIdentity   AS INT)
					FROM ptivcmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwivcmst]
			AS
			SELECT
				vwivc_bill_to_cus		=	C.strCustomerNumber  COLLATE Latin1_General_CI_AS
				,vwivc_ivc_no			=	A.strInvoiceNumber  COLLATE Latin1_General_CI_AS
				,vwivc_loc_no			=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_type				=	A.strTransactionType COLLATE Latin1_General_CI_AS
				,vwivc_status			=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_rev_dt			=	0
				,vwivc_comment			=	A.strComments COLLATE Latin1_General_CI_AS
				,vwivc_po_no			=	A.strPONumber COLLATE Latin1_General_CI_AS
				,vwivc_sold_to_cus		=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_slsmn_no			=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_slsmn_tot		=	0.0
				,vwivc_net_amt			=	0.0
				,vwivc_slstx_amt		=	0.0
				,vwivc_srvchr_amt		=	0.0
				,vwivc_disc_amt			=	0.0
				,vwivc_amt_paid			=	0.0
				,vwivc_bal_due			=	0.0
				,vwivc_pend_disc		=	0.0
				,vwivc_no_payments		=	0
				,vwivc_adj_inv_yn		=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_srvchr_cd		=	0
				,vwivc_disc_rev_dt		=	0
				,vwivc_net_rev_dt		=	0
				,vwivc_src_sys			=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_orig_rev_dt		=	0
				,vwivc_split_no			=	''''  COLLATE Latin1_General_CI_AS
				,vwivc_pd_days_old		=	0
				,vwivc_currency			=	''''  COLLATE Latin1_General_CI_AS
				,vwivc_currency_rt		=	0.0
				,vwivc_currency_cnt		=	''''  COLLATE Latin1_General_CI_AS
				,vwivc_eft_ivc_paid_yn	=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_terms_code		=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_pay_type			=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_user_id			=	'''' COLLATE Latin1_General_CI_AS
				,vwivc_user_rev_dt		=	0
				,A4GLIdentity			=	0
			FROM tblARInvoice A
			LEFT JOIN tblEMEntity B
				ON A.intEntityCustomerId = B.intEntityId
			INNER JOIN tblARCustomer C
				ON B.intEntityId = C.intEntityId
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateInvoiceView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateInvoiceView'
GO 
	EXEC ('uspTMRecreateInvoiceView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateInvoiceView'
GO
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ptjddmst') RETURN

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuGLPTDrillDownDifference')
	DROP VIEW vyuGLPTDrillDownDifference
GO

IF  (SELECT TOP 1 ysnLegacyIntegration FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) = 1

BEGIN

EXEC ('
		CREATE VIEW [dbo].[vyuGLPTDrillDownDifference]
		AS SELECT A.ptjdd_src_no, A.ptjdd_src_seq, ptjdd_acct_no, A.ptjdd_period, A.ptjdd_tran_amt_Total_PerAccountId, B.glije_amt_Total_PerAccountId, (A.ptjdd_tran_amt_Total_PerAccountId - B.glije_amt_Total_PerAccountId) AS Difference
   FROM(
   SELECT ptjdd_period,ptjdd_acct_no, ptjdd_src_seq, ptjdd_src_no, SUM(ptjdd_tran_amt) AS ptjdd_tran_amt_Total_PerAccountId
   FROM ptjddmst
   GROUP BY ptjdd_period,ptjdd_acct_no, ptjdd_src_no, ptjdd_src_seq) AS A
	   INNER JOIN
	   (
   SELECT glije_period, glije_acct_no, glije_src_sys, glije_src_no, SUM(glije_amt) AS glije_amt_Total_PerAccountId
   FROM tblGLIjemst
   WHERE glije_src_sys = ''PT''
   GROUP BY glije_period, glije_acct_no, glije_src_sys, glije_src_no) AS B
	   ON A.ptjdd_acct_no = B.glije_acct_no
   WHERE A.ptjdd_src_seq = B.glije_src_no AND 
		 A.ptjdd_acct_no = B.glije_acct_no AND 
		 A.ptjdd_tran_amt_Total_PerAccountId <> glije_amt_Total_PerAccountId
   GROUP BY A.ptjdd_src_no, A.ptjdd_src_seq, A.ptjdd_acct_no, A.ptjdd_period,A.ptjdd_tran_amt_Total_PerAccountId, B.glije_amt_Total_PerAccountId
				'
				
      )

END
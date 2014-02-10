IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwpxcycmst')
	DROP VIEW vwpxcycmst

GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'TX' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwpxcycmst]
		AS
		SELECT  pxcyc_cycle_id AS vwpxcyc_cycle_id
				, CAST(pxcyc_seq_no as INT) AS vwpxcyc_seq_no
				, pxcyc_rpt_state AS vwpxcyc_rpt_state
				, pxcyc_rpt_form AS vwpxcyc_rpt_form
				, pxcyc_rpt_sched AS vwpxcyc_rpt_sched
				, CAST(pxcyc_number_copies as INT)AS vwpxcyc_number_copies
				, pxcyc_user_id AS vwpxcyc_user_id
				, pxcyc_user_rev_dt AS vwpxcyc_user_rev_dt
				, pxsel_rpt_sched_name as vwpxsel_rpt_sched_name
				, CAST(A.A4GLIdentity as INT) AS vwA4GLIdentity
		FROM dbo.pxcycmst A 
		INNER JOIN pxselmst B ON A.pxcyc_rpt_state = B.pxsel_rpt_state 
		AND A.pxcyc_rpt_sched = B.pxsel_rpt_sched 
		AND A.pxcyc_rpt_form = B.pxsel_rpt_form where pxcyc_number_copies <> 0
		')
GO


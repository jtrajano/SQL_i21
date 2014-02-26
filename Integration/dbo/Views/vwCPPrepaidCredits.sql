IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPrepaidCredits')
	DROP VIEW vwCPPrepaidCredits
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPrepaidCredits]
		AS
		select 
			A4GLIdentity = row_number() over (order by agcrd_loc_no)
			,agcrd_cus_no
			,agcrd_loc_no
			,agcrd_cred_ind
			,agcrd_ref_no
			,agcrd_rev_dt = (case len(convert(varchar, agcrd_rev_dt)) when 8 then convert(date, cast(convert(varchar, agcrd_rev_dt) AS CHAR(12)), 112) else null end)
			,sum(agcrd_amt - agcrd_amt_used) as agcrd_amt
		from agcrdmst
		where
			(agcrd_cred_ind = ''P'')
			and (agcrd_amt - agcrd_amt_used <> 0)
		group by
			agcrd_cus_no
			,agcrd_loc_no
			,agcrd_cred_ind
			,agcrd_ref_no
			,agcrd_rev_dt
		')
GO

-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPrepaidCredits]
		AS
		select 
			A4GLIdentity = row_number() over (order by ptcrd_loc_no)
			,agcrd_cus_no = ptcrd_cus_no
			,agcrd_loc_no = ptcrd_loc_no
			,agcrd_cred_ind = ptcrd_cred_ind
			,agcrd_ref_no = ptcrd_invc_no
			,agcrd_rev_dt = (case len(convert(varchar, ptcrd_rev_dt)) when 8 then convert(date, cast(convert(varchar, ptcrd_rev_dt) AS CHAR(12)), 112) else null end)
			,sum(ptcrd_amt - ptcrd_amt_used) as agcrd_amt
		from ptcrdmst --agcrdmst
		where
			(ptcrd_cred_ind = ''P'')
			and (ptcrd_amt - ptcrd_amt_used <> 0)
		group by
			ptcrd_cus_no
			,ptcrd_loc_no
			,ptcrd_cred_ind
			,ptcrd_invc_no
			,ptcrd_rev_dt
		')
GO 

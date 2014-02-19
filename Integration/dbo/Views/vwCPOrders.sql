IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPOrders')
	DROP VIEW vwCPOrders

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPOrders]
		AS
		SELECT DISTINCT
			a.A4GLIdentity
			,a.agord_ord_no
			,agord_ord_rev_dt = (case len(convert(varchar, a.agord_ord_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agord_ord_rev_dt) AS CHAR(12)), 112) else null end)
			,a.agord_type
			,a.agord_bill_to_split
			,a.agord_loc_no
			,b.agtrm_desc
			,a.agord_po_no
			,agord_order_total = (case a.agord_ship_type + a.agord_type when ''IO'' then a.agord_ship_total else a.agord_order_total end)
			,a.agord_line_no
			,a.agord_bill_to_cus
			,a.agord_ship_type
			,a.agord_ship_total
			,a.agord_ivc_no
		FROM
			agordmst AS a
		INNER JOIN
			agtrmmst AS b
			ON a.agord_terms_cd = b.agtrm_key_n
		WHERE
			(a.agord_line_no = 1)
			AND (a.agord_type <> ''Q'')
		')

GO

-- PETRO VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPOrders]
		AS
			SELECT DISTINCT
			A4GLIdentity =  0 --a.A4GLIdentity
			,agord_ord_no =  null --a.agord_ord_no
			,agord_ord_rev_dt = null --(case len(convert(varchar, a.agord_ord_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agord_ord_rev_dt) AS CHAR(12)), 112) else null end)
			,agord_type = null --a.agord_type
			,agord_bill_to_split = null--a.agord_bill_to_split
			,agord_loc_no = null --a.agord_loc_no
			,agtrm_desc = null --b.agtrm_desc
			,agord_po_no = null --a.agord_po_no
			,agord_order_total = null --a.agord_order_total
			,agord_line_no = null --a.agord_line_no
			,agord_bill_to_cus = null --a.agord_bill_to_cus
			,agord_ship_type = null--a.agord_ship_type
			,agord_ship_total = null --a.agord_ship_total
			,agord_ivc_no = null --a.agord_ivc_no
		--FROM
		--	agordmst AS a
		--INNER JOIN
		--	agtrmmst AS b
		--	ON a.agord_terms_cd = b.agtrm_key_n
		--WHERE
		--	(a.agord_line_no = 1)
		--	AND (a.agord_type <> ''Q'')
		')
GO
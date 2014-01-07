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
	,a.agord_order_total
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
	--(a.agord_cus_no = @agord_cus_no)
	--AND (a.agord_ord_rev_dt >= @agord_ord_rev_dt_to)
	--AND (a.agord_ord_rev_dt <= @agord_ord_rev_dt_from)
	(a.agord_line_no = 1)
	--AND (a.agord_type LIKE @agord_type)
	AND (a.agord_type <> 'Q')
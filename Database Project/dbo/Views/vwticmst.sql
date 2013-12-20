CREATE VIEW [dbo].[vwticmst]
AS
SELECT
vwtic_ship_total	= CAST(0 AS DECIMAL(18,6))
,vwtic_cus_no	= CAST('' AS CHAR(10))
,vwtic_type	= CAST('' AS CHAR(1))

CREATE VIEW [dbo].[vwpyemst]
AS
SELECT 
vwpye_amt	= agpye_amt
,vwpye_cus_no	=agpye_cus_no
from
agpyemst
CREATE VIEW [dbo].[vyuSMBEExportCashDiscount]
AS 

SELECT 
strTermCode AS code		--Terms Code	None-30
,ISNULL(intDiscountDay,0) AS days1		--Discount Days	10
,ISNULL(dblDiscountEP,0) AS percent1	--Discount for Early Payment	0.03
,0.00 AS perUnit1	--Not Used. Default to value	0.00	
,0 AS days2		--Not Used. Default to value	0
,0.00AS percent2	--Not Used. Default to value	0.0
,0.00 AS perUnit2	--Not Used. Default to value	0.00
,0 AS days3		--Not Used. Default to value	0
,0.00 AS percent3	--Not Used. Default to value	0.0
,0.00 AS perUnit3	--Not Used. Default to value	0.00
FROM tblSMTerm

GO




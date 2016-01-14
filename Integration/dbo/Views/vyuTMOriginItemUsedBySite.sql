GO
PRINT  'BEGIN Create vyuTMOriginItemUsedBySite'

GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginItemUsedBySite')
	DROP VIEW vyuTMOriginItemUsedBySite
GO

EXEC('
CREATE VIEW [dbo].[vyuTMOriginItemUsedBySite]
AS
SELECT 
	A.*
	,intId = CAST(ROW_NUMBER() OVER(ORDER BY strItemNo) AS INT)
FROM
(
	SELECT DISTINCT
		strItemNo = A.vwitm_no
		,strDescription = A.vwitm_desc
		,intConcurrencyId = 0
	FROM vwitmmst A
	INNER JOIN tblTMSite B
		ON A.A4GLIdentity = B.intProduct
) A
')

GO
PRINT  'END Create vyuTMOriginItemUsedBySite'

GO
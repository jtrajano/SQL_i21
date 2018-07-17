GO
PRINT  'BEGIN Create vyuTMOriginItemUsedBySite'

GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginItemUsedBySite')
	DROP VIEW vyuTMOriginItemUsedBySite
GO
IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
BEGIN
	EXEC('
	CREATE VIEW [dbo].[vyuTMOriginItemUsedBySite]
	AS
	SELECT 
		A.*
		,intId = CAST(ROW_NUMBER() OVER(ORDER BY strItemNo) AS INT)
	FROM
	(
		SELECT DISTINCT
			strItemNo = A.vwitm_no COLLATE Latin1_General_CI_AS
			,strDescription = A.vwitm_desc COLLATE Latin1_General_CI_AS
			,intConcurrencyId = 0
		FROM vwitmmst A
		INNER JOIN tblTMSite B
			ON A.A4GLIdentity = B.intProduct
	) A
	')
END
GO
PRINT  'END Create vyuTMOriginItemUsedBySite'

GO
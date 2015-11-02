-- Pre deployment fix for non-unique Commodity Codes prior to 15.4 builds
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE name = 'tblICCommodity')
BEGIN

	EXEC ('
		UPDATE tblICCommodity
		SET strCommodityCode = strCommodityCode + CAST(intCommodityId AS NVARCHAR)
		WHERE strCommodityCode IN (
			SELECT strCommodityCode FROM tblICCommodity
			GROUP BY strCommodityCode
			HAVING COUNT(*) > 1
		)
	')

END
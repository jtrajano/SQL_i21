CREATE PROCEDURE [dbo].[uspICCommodityPositionReport]	
	@ysnGetHeader bit  = 0,
	@dtmDate date = null,
	@strLocationName nvarchar(max) = '',
	@ysnLocationLicensed bit = null,
	@intUserId int = NULL,
	@strPermission nvarchar(max) = ''
as
BEGIN
	DECLARE @Columns VARCHAR(MAX)
	SELECT @Columns = COALESCE(@Columns + ', ','') + QUOTENAME(strCommodityCode)
	FROM
	   (
		SELECT DISTINCT strCommodityCode 
		FROM   tblICCommodity 
	   ) AS C

	-- Create the temp table for the location filter. 
	IF OBJECT_ID('tempdb..#tmpCommodityPositionLocationFilter') IS NULL  
	BEGIN 
		CREATE TABLE #tmpCommodityPositionLocationFilter (
			intCompanyLocationId INT NULL 
		)
	END 

	IF LTRIM(RTRIM(ISNULL(@strLocationName, ''))) <> ''
	BEGIN 
		DECLARE @locationFilter_XML AS XML = CAST('<root><ID>' + REPLACE(@strLocationName, ',', '</ID><ID>') + '</ID><root>' AS XML) 	
		INSERT INTO #tmpCommodityPositionLocationFilter (
			intCompanyLocationId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @locationFilter_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpCommodityPositionLocationFilter WHERE intCompanyLocationId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpCommodityPositionLocationFilter)
	INSERT INTO #tmpCommodityPositionLocationFilter (intCompanyLocationId) VALUES (NULL) 

	-- Create the temp table for the permission location filter. 
	IF OBJECT_ID('tempdb..#tmpCommodityPositionPermissionLocationFilter') IS NULL  
	BEGIN 
		CREATE TABLE #tmpCommodityPositionPermissionLocationFilter (
			intCompanyLocationId INT NULL 
		)
	END 

	IF LTRIM(RTRIM(ISNULL(@strPermission, ''))) <> ''
	BEGIN 
		DECLARE @locationPermissionFilter_XML AS XML = CAST('<root><ID>' + REPLACE(@strPermission, ',', '</ID><ID>') + '</ID><root>' AS XML) 	
		INSERT INTO #tmpCommodityPositionPermissionLocationFilter (
			intCompanyLocationId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @locationPermissionFilter_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpCommodityPositionPermissionLocationFilter WHERE intCompanyLocationId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpCommodityPositionPermissionLocationFilter)
	INSERT INTO #tmpCommodityPositionPermissionLocationFilter (intCompanyLocationId) VALUES (NULL) 
	
	DECLARE @sqlStmt NVARCHAR(MAX) = N'
		SELECT 
			*
		FROM (
			SELECT %top
				com.strCommodityCode
				,cl.intCompanyLocationId
				,cl.strLocationName 
				, dblQty = 
					ROUND(
						ISNULL(t.dblQty, 0) + ISNULL(storage.dblQty, 0) 
						, ISNULL(com.intDecimalDPR, 2)
					)
				, dtmDate = @dtmDate
				, ysnLicensed = cl.ysnLicensed
			FROM 
				tblICItem i inner join tblICItemLocation il
					on i.intItemId = il.intItemId
				inner join tblSMCompanyLocation cl
					on cl.intCompanyLocationId = il.intLocationId 
					and (
						cl.ysnLicensed = @ysnLocationLicensed
						OR @ysnLocationLicensed IS NULL 
					)
				inner join tblICCommodity com
					on com.intCommodityId = i.intCommodityId

				inner join #tmpCommodityPositionLocationFilter locationFilter
					on cl.intCompanyLocationId = locationFilter.intCompanyLocationId
					or locationFilter.intCompanyLocationId IS NULL 			 

				inner join #tmpCommodityPositionPermissionLocationFilter permissionFilter
					on cl.intCompanyLocationId = permissionFilter.intCompanyLocationId
					or permissionFilter.intCompanyLocationId IS NULL 
					
				cross apply (
					select 
						dblQty = 
							ROUND (
								SUM (
									dbo.fnICConvertUOMtoStockUnit (
										t.intItemId
										,t.intItemUOMId
										,t.dblQty
									)
								)
								, ISNULL(com.intDecimalDPR, 2)
							)
					from 
						tblICInventoryTransaction t 
					where 
						t.intItemId = i.intItemId
						and t.intItemLocationId = il.intItemLocationId 
						and t.ysnIsUnposted = 0
						and (
							FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT)) OR @dtmDate IS NULL
						)
				) t 
				outer apply (
					select 
						dblQty = 
							ROUND (
								SUM (
									dbo.fnICConvertUOMtoStockUnit (
										storage.intItemId
										,storage.intItemUOMId
										,storage.dblQty
									)
								)
								, ISNULL(com.intDecimalDPR, 2)
							)					
					from 
						tblICInventoryTransactionStorage storage 
					where 
						storage.intItemId = i.intItemId
						and storage.intItemLocationId = il.intItemLocationId 
						and storage.ysnIsUnposted = 0
						and (
							FLOOR(CAST(storage.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT)) OR @dtmDate IS NULL
						)
				) storage
		) AS s	
		PIVOT (
			SUM( dblQty)
			FOR strCommodityCode IN (' + @Columns + ')
		) AS PVT
		ORDER BY 
			PVT.strLocationName'


	IF @ysnGetHeader = 1
	BEGIN 
		SET @dtmDate = NULL 
		SET @ysnLocationLicensed = NULL
		SET @sqlStmt = REPLACE(@sqlStmt, '%top', 'TOP 1')

		EXEC sp_executesql 
			@sqlStmt
			,N'@dtmDate DATETIME, @ysnLocationLicensed BIT, @strLocationName NVARCHAR(MAX), @strPermission NVARCHAR(MAX)'
			,@dtmDate = @dtmDate, @ysnLocationLicensed = @ysnLocationLicensed, @strLocationName = @strLocationName, @strPermission = @strPermission
	END 
	ELSE
	BEGIN 
		SET @sqlStmt = REPLACE(@sqlStmt, '%top', '')

		EXEC sp_executesql 
			@sqlStmt
			,N'@dtmDate DATETIME, @ysnLocationLicensed BIT, @strLocationName NVARCHAR(MAX), @strPermission NVARCHAR(MAX)'
			,@dtmDate = @dtmDate, @ysnLocationLicensed = @ysnLocationLicensed, @strLocationName = @strLocationName, @strPermission = @strPermission
	END 		
END
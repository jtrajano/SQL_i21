CREATE PROCEDURE [dbo].[uspWHGetScannedObject]
	@Scan NVARCHAR(64), 
	@AddressID INT = NULL, 
	@intCompanyLocationId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @UnitCount INT
	DECLARE @ContainerCount INT
	DECLARE @MaterialCount INT
	DECLARE @SKUCount INT
	DECLARE @OrderCount INT
	DECLARE @tblICStorageLocation NVARCHAR(MAX)
	DECLARE @UnitSum NVARCHAR(MAX)
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @NoofContainers INT
	DECLARE @intStorageLocationId INT

	--DECLARE @intCompanyLocationId int  
	SET @ErrMsg = ''
	SET @UnitCount = 0
	SET @ContainerCount = 0
	SET @MaterialCount = 0
	SET @SKUCount = 0
	SET @OrderCount = 0
	SET @tblICStorageLocation = ''
	SET @UnitSum = ''
	SET @NoofContainers = 0
	SET @intStorageLocationId = 0

	--Check if this is a tblICStorageLocation label              
	SELECT @UnitCount = COUNT(*)
	FROM tblICStorageLocation u
	JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
	WHERE strName = @Scan

	IF @UnitCount > 0
	BEGIN
		SELECT @intStorageLocationId = intStorageLocationId
		FROM tblICStorageLocation
		WHERE strName = @Scan

		SELECT @NoofContainers = Count(*)
		FROM tblWHContainer
		WHERE intStorageLocationId = @intStorageLocationId
	END

	--Check if this is a container label              
	SELECT @ContainerCount = COUNT(*)
	FROM tblWHContainer c
	JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
	WHERE strContainerNo = @Scan
		--AND l.intCompanyLocationId = @intCompanyLocationId

	-- SELECT @intCompanyLocationId= intCompanyLocationId FROM tblSMCompanyLocationSubLocation l WHERE l.AddressID = @AddressID  
	--Check if this is a tblICItem label       
	SELECT @MaterialCount = COUNT(*)
	FROM tblICItem m
	WHERE strItemNo = @Scan

	--Check if this is a SKU label      
	SELECT @SKUCount = COUNT(*)
	FROM tblWHSKU s
	INNER JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
	INNER JOIN tblICStorageLocation u ON c.intStorageLocationId = u.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
	WHERE strSKUNo = @Scan
		--AND l.intCompanyLocationId = @intCompanyLocationId

	SELECT @OrderCount = COUNT(*)
	FROM tblWHOrderHeader Oh
	JOIN tblWHOrderLineItem Oli ON Oli.intOrderHeaderId = Oh.intOrderHeaderId
	WHERE strBOLNo = @Scan

	IF (@UnitCount + @ContainerCount + @MaterialCount + @SKUCount) > = 100
	BEGIN
		RAISERROR ('Too much data. Use iMake on the PC.', 16, 1)
	END

--	SELECT 'Count' TableName, @UnitCount [Matching Units], @ContainerCount [Matching Containers], @MaterialCount [Matching Materials], @SKUCount [Matching SKUs], @OrderCount [Matching Orders]

	IF @UnitCount > 0
	BEGIN
		--SELECT 'NoofPallets' TableName, @NoofContainers [No of Containers]

		SELECT 'tblICStorageLocation' TableName, ' ' [WH], u.strName [UnitName], c.strContainerNo [ContNo], m.strItemNo [MaterialName], m.strDescription [MaterialDesc], s.strSKUNo [SKUNo], s.dblQty [SKUQty], s.strLotCode [LotCode], @NoofContainers [NoofContainers]
		FROM tblICStorageLocation u
		JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
		LEFT OUTER JOIN tblWHContainer c ON c.intStorageLocationId = u.intStorageLocationId
		LEFT OUTER JOIN tblWHSKU s ON s.intContainerId = c.intContainerId
		LEFT OUTER JOIN tblICItem m ON m.intItemId = s.intItemId
		WHERE strName = @Scan
			--AND u.intLocationId = @intCompanyLocationId
	END

	IF @ContainerCount > 0
	BEGIN
		SELECT 'tblWHContainer' TableName, ' ' [WH], u.strName [UnitName], c.strContainerNo [ContNo], m.strItemNo [MaterialName], m.strDescription [MaterialDesc], s.strSKUNo [SKUNo], s.strLotCode [LotCode], s.dblQty
		FROM tblICStorageLocation u
		JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
		INNER JOIN tblWHContainer c ON c.intStorageLocationId = u.intStorageLocationId
		LEFT OUTER JOIN tblWHSKU s ON s.intContainerId = c.intContainerId
		LEFT OUTER JOIN tblICItem m ON m.intItemId = s.intItemId
		WHERE c.strContainerNo = @Scan
		--	AND u.intLocationId = @intCompanyLocationId
	END

	IF @MaterialCount > 0
	BEGIN
		SELECT @tblICStorageLocation = STUFF((
					SELECT DISTINCT ',[' + u.strName + ']'
					FROM tblICItem m
					LEFT JOIN tblWHSKU s ON m.intItemId = s.intItemId
					LEFT JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
					LEFT JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
					JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
					WHERE (
							u.intLocationId = @intCompanyLocationId
							AND (m.strItemNo = @Scan)
							)
					GROUP BY m.intItemId, u.strName
					FOR XML PATH('')
					), 1, 1, '')

		SELECT @UnitSum = '(' + STUFF((
					SELECT DISTINCT '+ ISNULL([' + u.strName + '],0)'
					FROM tblICItem m
					LEFT JOIN tblWHSKU s ON m.intItemId = s.intItemId
					LEFT JOIN tblWHContainer c ON s.intContainerId = c.intContainerId
					LEFT JOIN tblICStorageLocation u ON c.intStorageLocationId = u.intStorageLocationId
					JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
					WHERE (
							u.intLocationId = @intCompanyLocationId
							AND (m.strItemNo = @Scan)
							)
					GROUP BY m.intItemId, u.strName
					FOR XML path('')
					), 1, 1, '') + ')'

		IF @tblICStorageLocation = ''
			SET @SQL = ' SELECT ''MATERIAL'' TableName, [MaterialName],[MaterialDesc],[UNITS/PALLET],' + @tblICStorageLocation + ',' + CONVERT(NVARCHAR(MAX), @UnitSum) + ' [Total dblQty]  FROM(      
						   SELECT               
						   m.strItemNo [MaterialName],               
						   m.strDescription [MaterialDesc],               
						   (ISNULL(s.intUnitsPerLayer * s.intLayersPerPallet,m.intUnitPerLayer * m.intLayerPerPallet)) [UNITS/PALLET],      
						   u.strName AS [UnitName],      
						   SUM(ISNULL(s.dblQty,0)) [TOTALSKUQTY]      
						   FROM tblICItem m              
						   INNER JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId AND (m.strItemNo =''' + @Scan + 
										''')        
						   LEFT JOIN tblWHSKU s ON s.intItemId = m.intItemId      
						   LEFT JOIN tblWHContainer c ON c.intContainerId = s.intContainerId       
						   LEFT JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId       
						   lEFT JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId=u.intSubLocationId    
						   WHERE u.intLocationId = ' + CONVERT(NVARCHAR, @intCompanyLocationId) + '  
						   GROUP BY strName,strItemNo,m.strDescription,m.UnitPerLayer,m.LayerPerPallet,s.UnitPerLayer,s.LayerPerPallet) AS t      
						   PIVOT      
						   (MIN([TOTALSKUQTY]) FOR strName IN (' + @tblICStorageLocation + ')) AS PVT'
								ELSE
									SET @SQL = 'SELECT ''MATERIAL'' TableName,              
						   m.strItemNo [MaterialName],               
						   m.strDescription [MaterialDesc],               
						   (Isnull(s.intUnitsPerLayer * s.intLayersPerPallet,m.intUnitPerLayer * m.intLayerPerPallet)) [UNITS/PALLET],      
						   u.strName [UnitName],      
						   SUM(ISNULL(s.dblQty,0)) [TOTALSKUQTY]      
						   FROM tblICItem m              
						   INNER JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId AND (m.strItemNo=''' + @Scan + ''')        
						   LEFT JOIN tblWHSKU s ON s.intItemId = m.intItemId      
						   LEFT JOIN tblWHContainer c ON c.intContainerId = s.intContainerId       
						   LEFT JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId       
						   JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId=u.intSubLocationId     
						   WHERE u.intLocationId = ' + CONVERT(NVARCHAR, @intCompanyLocationId) + 
										'  
						   GROUP BY strName,strItemNo,m.strDescription,s.intUnitsPerLayer,s.intLayersPerPallet,m.intUnitPerLayer,m.intLayerPerPallet'

		EXECUTE sp_executesql @SQL
	END

	IF @SKUCount > 0
	BEGIN
		SELECT 'SKU' TableName, u.strName [UnitName], c.strContainerNo [ContNo], m.strItemNo [MaterialName], m.strDescription [MaterialDesc], s.strSKUNo [SKUNo], s.dblQty [SKUQty], s.strLotCode [LotCode]
		FROM tblWHSKU s
		INNER JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
		INNER JOIN tblICStorageLocation u ON c.intStorageLocationId = u.intStorageLocationId
		LEFT OUTER JOIN tblICItem m ON m.intItemId = s.intItemId
		JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
		WHERE s.strSKUNo = @Scan
--			AND u.intLocationId = @intCompanyLocationId -- SR 580        
	END

	IF @OrderCount > 0
	BEGIN
		DECLARE @DirectionKey INT

		SELECT @DirectionKey = intOrderDirectionId
		FROM tblWHOrderHeader
		WHERE strBOLNo = @Scan

		IF (@DirectionKey = 1) --Inbound        
		BEGIN
			SELECT MIN(TableName) TableName, MIN([BOLNo.]) [BOLNo.], [Description], MIN(Qty) Qty, SUM([Checked_In]) [Checked_In]
			FROM (
				SELECT 'Order' TableName, MAX(h.strBOLNo) [BOLNo.], MAX(m.strDescription) [Description], CAST(MAX(li.dblQty) AS NUMERIC(18,6)) [Qty], CASE 
						WHEN ISNULL(mm.intLastUpdateId, '') = 'EDI 856'
							OR ISNULL(MIN(mm.intLastUpdateId), '') = 'AUTO'
							OR ISNULL(MIN(mm.intLastUpdateId), '') = ''
							THEN 0
						ELSE CAST(ISNULL(SUM(s2.dblQty ), 0) AS NUMERIC(18,6))
						END [Checked_In]
				FROM tblWHOrderLineItem li
				INNER JOIN tblICItem m ON m.intItemId = li.intItemId
				INNER JOIN tblWHOrderHeader h ON h.intOrderHeaderId = li.intOrderHeaderId
				LEFT OUTER JOIN tblWHOrderManifest mm ON mm.intOrderLineItemId = li.intOrderLineItemId
				LEFT OUTER JOIN tblWHSKU s2 ON s2.intSKUId = mm.intSKUId
				WHERE h.strBOLNo = @Scan
				GROUP BY m.strItemNo, mm.intLastUpdateId
				) t
			GROUP BY [Description]
		END
		ELSE --Outbound        
		BEGIN
			SELECT 'Order' TableName, MAX(h.strBOLNo) [BOLNo.], MAX(m.strDescription) [Description], CAST(MAX(li.dblQty) AS NUMERIC(18,6)) [Qty], CAST(ISNULL(SUM(t.dblQty), 0) AS NUMERIC(18,6)) [Allocated], CAST(ISNULL(SUM(s2.dblQty), 0) AS NUMERIC(18,6)) [Picked]
			FROM tblWHOrderLineItem li
			INNER JOIN tblICItem m ON m.intItemId = li.intItemId
			INNER JOIN tblWHOrderHeader h ON h.intOrderHeaderId = li.intOrderHeaderId
			LEFT OUTER JOIN tblWHSKU s ON s.intItemId = li.intItemId
			LEFT OUTER JOIN tblWHTask t ON t.intSKUId = s.intSKUId
				AND t.strTaskNo = h.strBOLNo
			LEFT OUTER JOIN tblWHOrderManifest mm ON mm.intOrderLineItemId = li.intOrderLineItemId
				AND mm.intSKUId = t.intSKUId
			LEFT OUTER JOIN tblWHSKU s2 ON s2.intItemId = li.intItemId
				AND s2.intSKUId = mm.intSKUId
			WHERE h.strBOLNo = @Scan
			GROUP BY m.strItemNo
		END
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @ErrMsg != ''
	BEGIN
		SET @ErrMsg = 'uspWHGetScannedObject: ' + @ErrMsg

		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
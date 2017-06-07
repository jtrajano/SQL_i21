DECLARE @Count INT = 0
SELECT @Count = COUNT([object_id]) FROM sys.tables WHERE object_id IN (object_id('tblICItem'), object_id('tblSMCountry'), object_id('tblICCommodityAttribute'))

IF @Count = 3
BEGIN
	EXEC (N'DECLARE @ItemOrigin TABLE (intItemId INT, intOriginId INT PRIMARY KEY (intItemId, intOriginId))
	INSERT INTO @ItemOrigin (intItemId, intOriginId)
	SELECT i.intItemId, i.intOriginId
	FROM tblICItem i
	WHERE i.intOriginId IS NOT NULL

	UPDATE tblICItem SET intOriginId = NULL WHERE intOriginId IS NOT NULL

	IF (OBJECT_ID(''FK_tblICItem_tblSMCountry'', ''F'') IS NOT NULL)
	BEGIN
		ALTER TABLE tblICItem
		DROP CONSTRAINT FK_tblICItem_tblSMCountry
	END

	--ALTER TABLE tblICItem
	--ADD CONSTRAINT FK_tblICItem_tblICCommodityAttribute
	--FOREIGN KEY (intOriginId) REFERENCES tblICCommodityAttribute(intCommodityAttributeId);

	UPDATE i
	SET i.intOriginId = o.intOriginId
	FROM tblICItem i
		INNER JOIN @ItemOrigin o ON o.intItemId = i.intItemId
		INNER JOIN tblICCommodityAttribute a ON a.intCommodityAttributeId = o.intOriginId
	WHERE i.intOriginId IS NULL')
END

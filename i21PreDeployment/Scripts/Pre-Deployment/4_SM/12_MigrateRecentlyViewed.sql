IF (EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE UPPER(TABLE_NAME) = 'TBLSMRECENTLYVIEWED'))
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSMRECENTLYVIEWED' AND UPPER(COLUMN_NAME) = 'INTLOGID')
	BEGIN
		ALTER TABLE tblSMLog ADD intRecentlyViewedId INT NULL
		ALTER TABLE tblSMRecentlyViewed ADD intLogId INT NULL

		PRINT('START MIGRATING RECENTLY VIEWED')

		EXEC('
				INSERT INTO tblSMLog (strType, dtmDate, intEntityId, strRoute, intConcurrencyId, intRecentlyViewedId)
				SELECT ''Recently Viewed'', dtmDateEntered, intEntityId, strRoute, 1, intRecentlyViewedId from tblSMRecentlyViewed;
		')

		EXEC('
				UPDATE tblSMRecentlyViewed
				SET intLogId = B.intLogId
				FROM tblSMLog B
				WHERE tblSMRecentlyViewed.intRecentlyViewedId = B.intRecentlyViewedId;		
		')
	
		PRINT('END MIGRATIMG RECENTLY VIEWED')

		PRINT('START DROPING COLUMNS RECENTLY VIEWED')

		ALTER TABLE tblSMRecentlyViewed DROP CONSTRAINT FK_tblSMRecentlyViewed_tblEMEntity_intEntityId
		ALTER TABLE tblSMLog DROP COLUMN intRecentlyViewedId
		ALTER TABLE tblSMRecentlyViewed DROP COLUMN intEntityId
		ALTER TABLE tblSMRecentlyViewed DROP COLUMN strRoute
		ALTER TABLE tblSMRecentlyViewed DROP COLUMN dtmDateEntered
		ALTER TABLE tblSMRecentlyViewed DROP COLUMN dtmDateModified

		PRINT('END DROPING COLUMNS RECENTLY VIEWED')
	END
END
CREATE TABLE tblMFItemGradeDiff (
	intGradeDiffId INT identity(1, 1) CONSTRAINT PK_tblMFItemGradeDiff_intGradeDiffId PRIMARY KEY
	,intItemId INT
	,dblGradeDiff Numeric(18,6)
	,intCreatedUserId INT 
	,dtmCreated DATETIME CONSTRAINT DF_tblMFItemGradeDiff_dtmCreated DEFAULT GetDate()
	,intLastModifiedUserId INT 	
	,dtmLastModified DATETIME CONSTRAINT DF_tblMFItemGradeDiff_dtmLastModified DEFAULT GetDate()
	,intConcurrencyId INT CONSTRAINT DF_tblMFItemGradeDiff_intConcurrencyId DEFAULT 0
	)

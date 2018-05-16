CREATE TABLE tblMFItemGradeDiff (
	intGradeDiffId INT identity(1, 1) CONSTRAINT PK_tblMFItemGradeDiff_intGradeDiffId PRIMARY KEY
	,intItemId INT CONSTRAINT UQ_tblMFItemGradeDiff_intItemId UNIQUE
	,dblGradeDiff Numeric(18,6)
	,ysnZeroCost BIT CONSTRAINT DF_tblMFItemGradeDiff_ysnZeroCost DEFAULT 0
	,intCreatedUserId INT 
	,dtmCreated DATETIME CONSTRAINT DF_tblMFItemGradeDiff_dtmCreated DEFAULT GetDate()
	,intLastModifiedUserId INT 	
	,dtmLastModified DATETIME CONSTRAINT DF_tblMFItemGradeDiff_dtmLastModified DEFAULT GetDate()
	,intConcurrencyId INT CONSTRAINT DF_tblMFItemGradeDiff_intConcurrencyId DEFAULT 0
	)

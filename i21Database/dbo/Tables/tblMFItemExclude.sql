CREATE TABLE tblMFItemExclude (
	intItemId int
	,ysnExcludeInDemandView Bit CONSTRAINT [DF_tblMFItemExclude_ysnExcludeInDemandView] DEFAULT 0
	)


CREATE TABLE dbo.tblMFForecastItemType (
	intForecastItemTypeId INT
	,strType CHAR(1) NOT NULL
	,strBackColorName NVARCHAR(50)
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFForecastItemType_intForecastItemTypeId PRIMARY KEY (intForecastItemTypeId)
	)

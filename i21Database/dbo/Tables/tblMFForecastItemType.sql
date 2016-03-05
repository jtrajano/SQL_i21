CREATE TABLE dbo.tblMFForecastItemType (
	intForecastItemTypeId INT
	,strType CHAR(1) COLLATE Latin1_General_CI_AS NOT NULL
	,strBackColorName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFForecastItemType_intForecastItemTypeId PRIMARY KEY (intForecastItemTypeId)
	)

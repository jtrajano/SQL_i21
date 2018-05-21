CREATE TABLE dbo.tblMFForecastItemValue (
	intForecastItemValueId INT IDENTITY(1, 1) NOT NULL
	,intYear INT NOT NULL
	,intForecastItemTypeId INT NOT NULL
	,intItemId INT NOT NULL
	,dblJan NUMERIC(18, 6) NOT NULL
	,dblFeb NUMERIC(18, 6) NOT NULL
	,dblMar NUMERIC(18, 6) NOT NULL
	,dblApr NUMERIC(18, 6) NOT NULL
	,dblMay NUMERIC(18, 6) NOT NULL
	,dblJun NUMERIC(18, 6) NOT NULL
	,dblJul NUMERIC(18, 6) NOT NULL
	,dblAug NUMERIC(18, 6) NOT NULL
	,dblSep NUMERIC(18, 6) NOT NULL
	,dblOct NUMERIC(18, 6) NOT NULL
	,dblNov NUMERIC(18, 6) NOT NULL
	,dblDec NUMERIC(18, 6) NOT NULL
	,dblTotal AS (dblJan + dblFeb + dblMar + dblApr + dblMay + dblJun + dblJul + dblAug + dblSep + dblOct + dblNov + dblDec) Persisted NOT NULL
	,dblMonthlyAvg AS Round((dblJan + dblFeb + dblMar + dblApr + dblMay + dblJun + dblJul + dblAug + dblSep + dblOct + dblNov + dblDec) / 12, 4) Persisted NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,intCompanyId INT NULL
	,CONSTRAINT PK_tblMFForecastValue_intForecastItemValueId PRIMARY KEY (intForecastItemValueId)
	,CONSTRAINT FK_tblMFForecastItemValue_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFForecastItemValue_tblMFForecastItemType_intForecastItemTypeId FOREIGN KEY (intForecastItemTypeId) REFERENCES tblMFForecastItemType(intForecastItemTypeId)
	)

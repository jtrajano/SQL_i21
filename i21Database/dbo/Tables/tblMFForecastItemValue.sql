CREATE TABLE dbo.tblMFForecastItemValue (
	intForecastItemValueId INT IDENTITY(1, 1) NOT NULL
	,intYear INT NOT NULL
	,intForecastItemTypeId INT NOT NULL
	,intItemId INT NOT NULL
	,intJAN NUMERIC(18, 6) NOT NULL
	,intFEB NUMERIC(18, 6) NOT NULL
	,intMAR NUMERIC(18, 6) NOT NULL
	,intAPR NUMERIC(18, 6) NOT NULL
	,intMAY NUMERIC(18, 6) NOT NULL
	,intJUN NUMERIC(18, 6) NOT NULL
	,intJUL NUMERIC(18, 6) NOT NULL
	,intAUG NUMERIC(18, 6) NOT NULL
	,intSEP NUMERIC(18, 6) NOT NULL
	,intOCT NUMERIC(18, 6) NOT NULL
	,intNOV NUMERIC(18, 6) NOT NULL
	,intDEC NUMERIC(18, 6) NOT NULL
	,intTotal AS (intJAN + intFEB + intMAR + intAPR + intMAY + intJUN + intJUL + intAUG + intSEP + intOCT + intNOV + intDEC) Persisted NOT NULL
	,dblMonthlyAvg AS Round((intJAN + intFEB + intMAR + intAPR + intMAY + intJUN + intJUL + intAUG + intSEP + intOCT + intNOV + intDEC) / 12, 4) Persisted NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFForecastValue_intForecastItemValueId PRIMARY KEY (intForecastItemValueId)
	,CONSTRAINT FK_tblMFForecastItemValue_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFForecastItemValue_tblMFForecastItemType_intForecastItemTypeId FOREIGN KEY (intForecastItemTypeId) REFERENCES tblMFForecastItemType(intForecastItemTypeId)
	)

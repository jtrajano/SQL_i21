CREATE TABLE tblSMCityLeadtimeStaging
(
	intCityLeadtimeStagingId	INT IDENTITY(1,1) PRIMARY KEY, 
	intCityId					INT NOT NULL,
	strStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmDate						DATETIME NULL
)
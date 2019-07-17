CREATE TABLE tblMFDemandHeader (
	intDemandHeaderId INT NOT NULL IDENTITY
	,intConcurrencyId INT NOT NULL
	,strDemandNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmDate DATETIME NOT NULL
	,intBookId INT
	,intSubBookId INT

	,CONSTRAINT [PK_tblMFDemandHeader] PRIMARY KEY (intDemandHeaderId)
	,CONSTRAINT [UK_tblMFDemandHeader_strDemandName] UNIQUE (strDemandName)
	,CONSTRAINT [FK_tblMFDemandHeader_tblCTBook_intBookId] FOREIGN KEY (intBookId) REFERENCES [tblCTBook](intBookId)
	,CONSTRAINT [FK_tblMFDemandHeader_tblCTSubBook_intSubBookId] FOREIGN KEY (intSubBookId) REFERENCES [tblCTSubBook](intSubBookId)
	)

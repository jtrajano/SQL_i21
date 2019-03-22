CREATE TABLE tblMFItemOwnerDetail (
	intItemOwnerDetailId INT NOT NULL identity(1, 1)
	,intLotId INT NOT NULL
	,intItemId INT NOT NULL
	,intOwnerId INT NOT NULL
	,dtmFromDate DATETIME NOT NULL
	,dtmToDate DATETIME
	,intCompanyId INT NULL
	,CONSTRAINT PK_tblMFItemOwnerDetail PRIMARY KEY (intItemOwnerDetailId)
	,CONSTRAINT FK_tblMFItemOwnerDetail_tblICLot FOREIGN KEY (intLotId) REFERENCES tblICLot(intLotId)
	,CONSTRAINT FK_tblMFItemOwnerDetail_tblICItem FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFItemOwnerDetail_tblEMEntity FOREIGN KEY (intOwnerId) REFERENCES tblEMEntity(intEntityId)
	)

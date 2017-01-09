CREATE TABLE tblMFItemOwner (
	intItemOwnerId INT NOT NULL identity(1, 1)
	,intOwnerId INT NOT NULL
	,intItemId INT NOT NULL
	,intReceivedLife INT
	,CONSTRAINT PK_tblMFItemOwner PRIMARY KEY (intItemOwnerId)
	,CONSTRAINT FK_tblMFItemOwner_tblICItem FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFItemOwner_tblEMEntity FOREIGN KEY (intOwnerId) REFERENCES tblEMEntity(intEntityId)
	)

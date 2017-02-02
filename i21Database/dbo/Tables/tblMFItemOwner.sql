﻿CREATE TABLE tblMFItemOwner (
	intItemOwnerId INT NOT NULL IDENTITY(1, 1)
	,intConcurrencyId INT NULL CONSTRAINT [DF_tblMFItemOwner_intConcurrencyId] DEFAULT 0
	,intItemId INT NOT NULL
	,intOwnerId INT NOT NULL
	,intReceivedLife INT

	,intCreatedUserId [int] NULL
	,dtmCreated [datetime] NULL CONSTRAINT [DF_tblMFItemOwner_dtmCreated] DEFAULT GetDate()
	,intLastModifiedUserId [int] NULL
	,dtmLastModified [datetime] NULL CONSTRAINT [DF_tblMFItemOwner_dtmLastModified] DEFAULT GetDate()

	,CONSTRAINT PK_tblMFItemOwner PRIMARY KEY (intItemOwnerId)
	,CONSTRAINT [AK_tblMFItemOwner_intItemId_intOwnerId] UNIQUE ([intItemId],[intOwnerId])
	,CONSTRAINT FK_tblMFItemOwner_tblICItem FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFItemOwner_tblEMEntity FOREIGN KEY (intOwnerId) REFERENCES tblEMEntity(intEntityId)
	)

CREATE TABLE dbo.tblMFProcessCycleCountSession (
	intCycleCountSessionId INT IDENTITY(1, 1) NOT NULL
	,intSubLocationId INT NOT NULL
	,intUserId INT NOT NULL
	,dtmSessionStartDateTime DATETIME NOT NULL
	,dtmSessionEndDateTime DATETIME NULL
	,ysnCycleCountCompleted BIT NOT NULL
	,intWorkOrderId INT
	,CONSTRAINT PK_tblMFProcessCycleCountSession_intCycleCountSessionId PRIMARY KEY (intCycleCountSessionId)
	,CONSTRAINT FK_tblMFProcessCycleCountSession_intCompanyLocationSubLocationId_intSubLocationId FOREIGN KEY (intSubLocationId) REFERENCES dbo.tblSMCompanyLocationSubLocation(intCompanyLocationSubLocationId)
	,CONSTRAINT FK_tblMFProcessCycleCountSession_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId)
	)

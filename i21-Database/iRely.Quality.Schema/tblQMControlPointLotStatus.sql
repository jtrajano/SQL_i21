CREATE TABLE tblQMControlPointLotStatus (
	intControlPointLotStatusId INT Identity(1, 1)
	,intControlPointId INT NOT NULL
	,intCurrentLotStatusId INT NOT NULL
	,intLotStatusId INT NOT NULL
	,ysnApprove BIT NOT NULL
	,CONSTRAINT [PK_tblQMControlPointLotStatus] PRIMARY KEY (intControlPointLotStatusId)
	,CONSTRAINT [FK_tblQMControlPointLotStatus_tblQMControlPoint] FOREIGN KEY (intControlPointId) REFERENCES tblQMControlPoint(intControlPointId) ON DELETE CASCADE
	,CONSTRAINT [FK_tblQMControlPointLotStatus_tblICLotStatus_intCurrentLotStatusId] FOREIGN KEY (intCurrentLotStatusId) REFERENCES tblICLotStatus(intLotStatusId)
	,CONSTRAINT [FK_tblQMControlPointLotStatus_tblICLotStatus_intLotStatusId] FOREIGN KEY (intLotStatusId) REFERENCES tblICLotStatus(intLotStatusId)
	)
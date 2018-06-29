CREATE TABLE tblMFScheduleChangeoverFactorDetail (
	intChangeoverFactorDetailId INT NOT NULL identity(1,1)
	,intChangeoverFactorId INT NOT NULL
	,intFromScheduleGroupId INT NOT NULL
	,intToScheduleGroupId INT NOT NULL
	,dblChangeoverTime NUMERIC(18, 6) NOT NULL
	,dblChangeoverCost NUMERIC(18, 6) NULL
	,dtmCreated DATETIME NULL
	,intCreatedUserId INT NULL
	,dtmLastModified DATETIME NULL
	,intLastModifiedUserId INT NULL
	,intConcurrencyId INT NULL
	,CONSTRAINT PK_tblMFScheduleChangeoverFactorDetail_intChangeoverFactorDetailId PRIMARY KEY (intChangeoverFactorDetailId)
	,CONSTRAINT UQ_tblMFScheduleChangeoverFactorDetail_intChangeoverFactorId_intFromScheduleGroupId_intToScheduleGroupId UNIQUE (
		intChangeoverFactorId
		,intFromScheduleGroupId
		,intToScheduleGroupId
		)
	,CONSTRAINT FK_tblMFScheduleChangeoverFactorDetail_tblMFScheduleChangeoverFactor_intChangeoverFactorId FOREIGN KEY (intChangeoverFactorId) REFERENCES tblMFScheduleChangeoverFactor(intChangeoverFactorId) ON DELETE CASCADE
	,CONSTRAINT FK_tblMFScheduleChangeoverFactorDetail_tblMFScheduleGroup_intFromScheduleGroupId FOREIGN KEY (intFromScheduleGroupId) REFERENCES tblMFScheduleGroup(intScheduleGroupId)
	,CONSTRAINT FK_tblMFScheduleChangeoverFactorDetail_tblMFScheduleGroup_intToScheduleGroupId FOREIGN KEY (intToScheduleGroupId) REFERENCES tblMFScheduleGroup(intScheduleGroupId)
	)
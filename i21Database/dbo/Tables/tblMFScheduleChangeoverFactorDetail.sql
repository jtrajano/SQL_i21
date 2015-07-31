﻿CREATE TABLE tblMFScheduleChangeoverFactorDetail (
	intChangeoverFactorDetailId INT NOT NULL
	,intChangeoverFactorId INT NOT NULL
	,intFromScheduleGroupId INT NOT NULL
	,intToScheduleGroupId INT NOT NULL
	,dblChangeoverTime NUMERIC(18, 6) NOT NULL
	,dblChangeoverCost NUMERIC(18, 6) NULL
	,CONSTRAINT PK_tblMFScheduleChangeoverFactorDetail_intChangeoverFactorDetailId PRIMARY KEY (intChangeoverFactorDetailId)
	,CONSTRAINT FK_tblMFScheduleChangeoverFactorDetail_tblMFScheduleChangeoverFactor_intChangeoverFactorId FOREIGN KEY (intChangeoverFactorId) REFERENCES tblMFScheduleChangeoverFactor(intChangeoverFactorId)
	,CONSTRAINT FK_tblMFScheduleChangeoverFactorDetail_tblMFScheduleGroup_intFromScheduleGroupId FOREIGN KEY (intFromScheduleGroupId) REFERENCES tblMFScheduleGroup(intScheduleGroupId)
	,CONSTRAINT FK_tblMFScheduleChangeoverFactorDetail_tblMFScheduleGroup_intToScheduleGroupId FOREIGN KEY (intToScheduleGroupId) REFERENCES tblMFScheduleGroup(intScheduleGroupId)
	)
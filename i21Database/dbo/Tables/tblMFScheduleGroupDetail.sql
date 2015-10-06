﻿CREATE TABLE tblMFScheduleGroupDetail (
	intScheduleGroupDetailId INT NOT NULL identity(1,1)
	,intScheduleGroupId INT
	,strGroupValue NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intConcurrencyId	INT CONSTRAINT [DF_tblMFScheduleGroupDetail_intConcurrencyId] DEFAULT 0
	,CONSTRAINT PK_tblMFScheduleGroupDetail_intScheduleGroupDetailId PRIMARY KEY (intScheduleGroupDetailId)
	,CONSTRAINT FK_tblMFScheduleGroupDetail_tblMFScheduleGroup_intScheduleGroupId FOREIGN KEY (intScheduleGroupId) REFERENCES tblMFScheduleGroup(intScheduleGroupId)
	)

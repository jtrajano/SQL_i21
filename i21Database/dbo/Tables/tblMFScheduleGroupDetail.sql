CREATE TABLE tblMFScheduleGroupDetail (
	intScheduleGroupDetailId INT NOT NULL
	,intScheduleGroupId INT
	,strGroupValue NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFScheduleGroupDetail_intScheduleGroupDetailId PRIMARY KEY (intScheduleGroupDetailId)
	,CONSTRAINT FK_tblMFScheduleGroupDetail_tblMFScheduleGroup_intScheduleGroupId FOREIGN KEY (intScheduleGroupId) REFERENCES tblMFScheduleGroup(intScheduleGroupId)
	)

CREATE TABLE [dbo].[tblMFDowntime]
(
	intDowntimeId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFDowntime_intConcurrencyId DEFAULT 0,
	intShiftActivityId INT NOT NULL,
	intReasonCodeId INT NOT NULL,
	intDowntime INT NOT NULL,
	strExplanation NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmShiftStartTime DATETIME,
	dtmShiftEndTime DATETIME,
	ysnReduceavailabletime BIT NOT NULL CONSTRAINT DF_tblMFDowntime_ysnReduceavailabletime DEFAULT 0, 

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFDowntime_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFDowntime_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFDowntime PRIMARY KEY (intDowntimeId), 
	CONSTRAINT FK_tblMFDowntime_tblMFShiftActivity FOREIGN KEY (intShiftActivityId) REFERENCES tblMFShiftActivity(intShiftActivityId) ON DELETE CASCADE,
	CONSTRAINT FK_tblMFDowntime_tblMFReasonCode FOREIGN KEY (intReasonCodeId) REFERENCES tblMFReasonCode(intReasonCodeId)
)
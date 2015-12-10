CREATE TABLE [dbo].[tblMFReasonCode]
(
	intReasonCodeId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFReasonCode_intConcurrencyId DEFAULT 0,
	strReasonCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnReduceavailabletime BIT NOT NULL CONSTRAINT DF_tblMFReasonCode_ysnReduceavailabletime DEFAULT 0, 
	ysnExplanationrequired BIT NOT NULL CONSTRAINT DF_tblMFReasonCode_ysnExplanationrequired DEFAULT 0, 

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFReasonCode_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFReasonCode_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFReasonCode PRIMARY KEY (intReasonCodeId),
	CONSTRAINT AK_tblMFReasonCode_strReasonCode UNIQUE (strReasonCode)
)
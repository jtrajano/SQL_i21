CREATE TABLE [dbo].[tblMFReasonCode]
(
	intReasonCodeId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFReasonCode_intConcurrencyId DEFAULT 0,
	strReasonCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnReduceavailabletime BIT NOT NULL CONSTRAINT DF_tblMFReasonCode_ysnReduceavailabletime DEFAULT 0,
	ysnExplanationrequired BIT NOT NULL CONSTRAINT DF_tblMFReasonCode_ysnExplanationrequired DEFAULT 0,
	
	ysnDefault BIT NOT NULL CONSTRAINT DF_tblMFReasonCode_ysnDefault DEFAULT 0,
	intReasonTypeId INT NOT NULL,
	intTransactionTypeId INT,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFReasonCode_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFReasonCode_dtmLastModified DEFAULT GetDate(),
	ysnAutoCreated bit CONSTRAINT DF_tblMFReasonCode_ysnAutoCreated Default 0,
	CONSTRAINT PK_tblMFReasonCode PRIMARY KEY (intReasonCodeId),
	CONSTRAINT AK_tblMFReasonCode_strReasonCode_intReasonTypeId_intTransactionTypeId UNIQUE (
		strReasonCode,
		intReasonTypeId,intTransactionTypeId),
	CONSTRAINT FK_tblMFReasonCode_tblMFReasonType FOREIGN KEY (intReasonTypeId) REFERENCES tblMFReasonType(intReasonTypeId),
	CONSTRAINT FK_tblMFReasonCode_tblICInventoryTransactionType FOREIGN KEY (intTransactionTypeId) REFERENCES tblICInventoryTransactionType(intTransactionTypeId)
)
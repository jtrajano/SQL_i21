CREATE TABLE [dbo].[tblCTEventNotificationLog]
(
	intEventNotificationLogId [int] IDENTITY(1,1) NOT NULL,
	intContractEventId	INT, 
	intEventId		INT,
	strEventName	NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strAlertType	NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strNotificationType	NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	ysnSummarized	BIT,
	ysnActive		BIT,
	dtmExpectedEventDate DATETIME,
	intDaysToRemind	INT,
	strReminderCondition	NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	dtmNotified DATETIME,
	intAlertFrequency	INT,
	strSubject			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS ,
	strMailContent		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS ,
	strMailTo			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS ,
	strNotificationStatus	NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strStatusMessage	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intConcurrencyId	INT NOT NULL, 
	
	CONSTRAINT [PK_tblCTAction_intEventNotificationLogId] PRIMARY KEY CLUSTERED (intEventNotificationLogId ASC)
)

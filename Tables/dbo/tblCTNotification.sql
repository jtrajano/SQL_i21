CREATE TABLE [dbo].[tblCTNotification]
(
	intNotificationId int IDENTITY(1,1) NOT NULL,
	strNotificationType  nvarchar(100) COLLATE Latin1_General_CI_AS,
	strTo  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strCC  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strBCC  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strSubject  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strMessage  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strMessageType  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strTitle   nvarchar(500) COLLATE Latin1_General_CI_AS,
	strTransactionNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,
	ysnSent BIT,
	strErrorMsg  nvarchar(MAX) COLLATE Latin1_General_CI_AS,
	strScheme  nvarchar(200) COLLATE Latin1_General_CI_AS,
	strAuthority  nvarchar(200) COLLATE Latin1_General_CI_AS,
	strApplicationPath  nvarchar(200) COLLATE Latin1_General_CI_AS,
	strToken  nvarchar(200) COLLATE Latin1_General_CI_AS,
	intConcurrencyId INT NOT NULL, 
	CONSTRAINT PK_tblCTNotification_intNotificationId PRIMARY KEY CLUSTERED (intNotificationId ASC)
)

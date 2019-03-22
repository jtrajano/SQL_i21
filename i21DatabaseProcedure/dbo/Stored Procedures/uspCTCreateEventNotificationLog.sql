CREATE PROCEDURE [dbo].[uspCTCreateEventNotificationLog]
	@strMailContent			NVARCHAR(MAX),
	@strMailTo				NVARCHAR(MAX),
	@strContractEventId		NVARCHAR(MAX),
	@strNotificationStatus	NVARCHAR(MAX),
	@strStatusMessage		NVARCHAR(MAX)
AS

BEGIN
	DECLARE  @ContractEventId TABLE
	(
		intId				INT IDENTITY(1,1),
		intContractEventId	INT
	)
	INSERT INTO @ContractEventId
	SELECT CAST(Item AS INT) FROM dbo.fnSplitString(@strContractEventId,',')
	
	IF NOT EXISTS(SELECT * FROM @ContractEventId WHERE intContractEventId > 0)
	BEGIN
		INSERT	INTO tblCTEventNotificationLog
		(dtmNotified,strMailContent,strMailTo,strNotificationStatus,strStatusMessage,intConcurrencyId)
		SELECT	GETDATE(),@strMailContent,@strMailTo,@strNotificationStatus,@strStatusMessage,1
		RETURN
	END
	
	INSERT	INTO tblCTEventNotificationLog
	(		intContractEventId,intEventId,strEventName,strAlertType,strNotificationType,ysnSummarized,ysnActive,dtmExpectedEventDate,
			intDaysToRemind,strReminderCondition,dtmNotified,intAlertFrequency,strSubject,strMailContent,strMailTo,strNotificationStatus,
			strStatusMessage,intConcurrencyId
	)
	SELECT	CE.intContractEventId,EV.intEventId,EV.strEventName,EV.strAlertType,EV.strNotificationType,EV.ysnSummarized,EV.ysnActive,CE.dtmExpectedEventDate,
			EV.intDaysToRemind,EV.strReminderCondition,GETDATE(),EV.intAlertFrequency,EV.strSubject,@strMailContent,@strMailTo,@strNotificationStatus,
			@strStatusMessage,1
	FROM	tblCTContractEvent	CE
	JOIN	@ContractEventId	ID	ON	ID.intContractEventId	=	CE.intContractEventId
	JOIN	tblCTEvent			EV	ON	EV.intEventId			=	CE.intEventId
END

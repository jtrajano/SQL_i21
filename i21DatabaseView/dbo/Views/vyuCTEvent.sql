﻿CREATE VIEW [dbo].[vyuCTEvent]

AS 

	SELECT	EV.intEventId,
			EV.strEventName,
			EV.strEventDescription,
			EV.intActionId,
			EV.strAlertType,
			EV.strNotificationType,
			EV.ysnSummarized,
			EV.ysnActive,
			EV.intDaysToRemind,
			EV.strReminderCondition,
			EV.intAlertFrequency,
			EV.strSubject,
			EV.strMessage,
			EV.intConcurrencyId,

			AC.strActionName,
			AC.strInternalCode,
			AC.strRoute,

			dbo.fnCTGetEventRecipientEmail(EV.intEventId) COLLATE Latin1_General_CI_AS  AS strEmailIds,
			dbo.fnCTGetEventRecipientId(EV.intEventId) COLLATE Latin1_General_CI_AS AS strUserIds

	 FROM	tblCTEvent	EV	LEFT
	 JOIN	tblCTAction	AC	ON	AC.intActionId	=	EV.intActionId

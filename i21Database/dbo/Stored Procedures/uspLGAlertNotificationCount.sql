CREATE PROCEDURE [dbo].[uspLGAlertNotificationCount]
	@intEntityId INT
AS

BEGIN TRY

	DECLARE @NotificationTypeEvent TABLE
	(
		intEventId	INT,
		strNotificationType NVARCHAR(100)	
	)

	DECLARE @ErrMsg	NVARCHAR(MAX)

	INSERT INTO @NotificationTypeEvent
	SELECT	intEventId,
			CASE	WHEN	strEventName =  'Unconfirmed contract'					THEN	'Unconfirmed'
					WHEN	strEventName =  'Contract without a sequence'			THEN	'Empty'	
					WHEN	strEventName =	'Unsubmitted Contract Alert'			THEN	'Unsubmitted'
					WHEN	strEventName =  'Unsigned Contract Alert'				THEN	'Unsigned'
					WHEN	strEventName =  'Approved Contract Mail Not Sent'		THEN	'Approved Not Sent'
					WHEN	strEventName =  'Contract Without Shipping Instruction'	THEN	'Contracts w/o shipping instruction'
					WHEN	strEventName =  'Contracts w/o TC'						THEN	'Contracts w/o TC'
					WHEN	strEventName =  'Contracts w/o 4C'						THEN	'Contracts w/o 4C'
					WHEN	strEventName =  'Contract Without Weight Claim'			THEN	'Contracts w/o weight claim'
					WHEN	strEventName =  'Weight Claims w/o Debit Note'			THEN	'Weight claims w/o debit note'
					WHEN	strEventName =  'Contract Without Document'				THEN	'Contracts w/o document'
					WHEN	strEventName =  'Contract Without Shipping Advice'		THEN	'Contracts w/o shipping advice'
					ELSE	strEventName
			END
	FROM tblCTEvent

	SELECT *
	FROM (
		SELECT COUNT(1) intCount
			,'intContractWithoutShippingInstructionCount' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Contracts w/o shipping instruction' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
	
		UNION ALL
	
		SELECT COUNT(1) intCount
			,'intContractsWithoutTCCount' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Contracts w/o TC' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
	
		UNION ALL
	
		SELECT COUNT(1) intCount
			,'intContractsWithout4CCount' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Contracts w/o 4C' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
	
		UNION ALL
	
		SELECT COUNT(1) intCount
			,'intWeightClaimsWithoutDebitNoteCount' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Weight claims w/o debit note' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
	
		UNION ALL
	
		SELECT COUNT(1) intCount
			,'intContractsWithoutWeightClaimCount' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Contracts w/o weight claim' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
	
		UNION ALL
	
		SELECT COUNT(1) intCount
			,'intContractsWithoutDocumentCount' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Contracts w/o document' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
	
		UNION ALL
	
		SELECT COUNT(1) intCount
			,'intContractsWithoutShippingAdvice' AS strNotificationCount
		FROM vyuLGNotifications NF
		JOIN @NotificationTypeEvent	NE	ON	NE.strNotificationType	=	NF.strType COLLATE Latin1_General_CI_AS
		LEFT JOIN vyuCTEventRecipientFilter	RF	ON	RF.intEventId	=	NE.intEventId AND RF.intEntityId	=	@intEntityId
		WHERE strType = 'Contracts w/o shipping advice' AND NF.strCommodityCode = ISNULL(RF.strCommodity,NF.strCommodityCode)
		) t
	PIVOT(MIN(intCount) FOR strNotificationCount IN (
				intContractsWithout4CCount
				,intContractsWithoutTCCount
				,intContractWithoutShippingInstructionCount
				,intWeightClaimsWithoutDebitNoteCount
				,intContractsWithoutWeightClaimCount
				,intContractsWithoutDocumentCount
				,intContractsWithoutShippingAdvice
				)) g

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
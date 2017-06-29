CREATE VIEW [dbo].[vyuCTEventRecipientFilter]

AS 

SELECT	RF.*,
		EY.strName strEntityName,
		EV.strEventName,
		CY.strCommodityCode	AS	strCommodity,
		CASE	WHEN	EV.strEventName =  'Unconfirmed contract'				THEN	'Unconfirmed'
				WHEN	EV.strEventName =  'Contract without a sequence'		THEN	'Empty'	
				WHEN	EV.strEventName =	'Unsubmitted Contract Alert'		THEN	'Unsubmitted'
				WHEN	EV.strEventName =  'Unsigned Contract Alert'			THEN	'Unsigned'
				WHEN	EV.strEventName =  'Approved Contract Mail Not Sent'	THEN	'Approved Not Sent'
		END AS strNotificationType

FROM	tblCTEventRecipientFilter	RF
JOIN	tblEMEntity		EY	ON	EY.intEntityId		=	RF.intEntityId
JOIN	tblCTEvent		EV	ON	EV.intEventId		=	RF.intEventId 
JOIN	tblICCommodity	CY	ON	CY.intCommodityId	=	RF.intCommodityId
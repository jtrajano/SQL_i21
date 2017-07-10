CREATE VIEW [dbo].[vyuCTEventRecipientFilter]

AS 

SELECT	RF.*,
		EY.strName strEntityName,
		EV.strEventName,
		CY.strCommodityCode	AS	strCommodity,
		CASE	WHEN	EV.strEventName =  'Unconfirmed contract'					THEN	'Unconfirmed'
				WHEN	EV.strEventName =  'Contract without a sequence'			THEN	'Empty'	
				WHEN	EV.strEventName =  'Unsubmitted Contract Alert'				THEN	'Unsubmitted'
				WHEN	EV.strEventName =  'Unsigned Contract Alert'				THEN	'Unsigned'
				WHEN	EV.strEventName =  'Approved Contract Mail Not Sent'		THEN	'Approved Not Sent'
				WHEN	EV.strEventName =  'Contract Without Shipping Instruction'	THEN	'Contracts w/o shipping instruction'
				WHEN	EV.strEventName =  'Contracts w/o TC'						THEN	'Contracts w/o TC'
				WHEN	EV.strEventName =  'Contracts w/o 4C'						THEN	'Contracts w/o 4C'
				WHEN	EV.strEventName =  'Contract Without Weight Claim'			THEN	'Contracts w/o weight claim'
				WHEN	EV.strEventName =  'Weight Claims w/o Debit Note'			THEN	'Weight claims w/o debit note'
				WHEN	EV.strEventName =  'Contract Without Document'				THEN	'Contracts w/o document'
				WHEN	EV.strEventName =  'Contract Without Shipping Advice'		THEN	'Contracts w/o shipping advice'
				ELSE	EV.strEventName
		END AS strNotificationType

FROM	tblCTEventRecipientFilter	RF
JOIN	tblEMEntity		EY	ON	EY.intEntityId		=	RF.intEntityId
JOIN	tblCTEvent		EV	ON	EV.intEventId		=	RF.intEventId 
JOIN	tblICCommodity	CY	ON	CY.intCommodityId	=	RF.intCommodityId
CREATE VIEW [dbo].[vyuSCTicketTypeView]
AS SELECT 
	SCType.intTicketTypeId
	,SCType.intTicketPoolId
    ,SCType.intListTicketTypeId
    ,SCType.ysnTicketAllowed
    ,SCType.intNextTicketNumber
    ,SCType.intDiscountSchedule
    ,SCType.intDistributionMethod
    ,SCType.ysnSelectByPO
    ,SCType.intSplitInvoiceOption
    ,SCType.intContractRequired
    ,SCType.intOverrideTicketCopies
    ,SCType.ysnPrintAtKiosk
    ,SCType.ynsVerifySplitMethods
    ,SCType.ysnOverrideSingleTicketSeries
    ,SCList.intTicketType
	,CASE
		WHEN SCList.strTicketType = 'All' THEN 'All'
		ELSE SCList.strTicketType
	END as strTicketType
	,SCList.strInOutIndicator
    ,SCType.intTransferWeight
FROM tblSCTicketType SCType
LEFT JOIN tblSCListTicketTypes SCList ON SCType.intListTicketTypeId = SCList.intTicketTypeId
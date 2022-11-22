CREATE VIEW [dbo].[vyuHDTimeEntrySummaryDetail]
AS

SELECT       intTicketHoursWorkedId
			,intTicketId
			,intAgentId
			,intAgentEntityId
			,intHours
			,dblHours
			,dblEstimatedHours
			,dtmDate
			,dtmStartTime 
			,dtmEndTime  
			,dblRate
			,strDescription
			,strJIRALink
			,intInvoiceId
			,dtmInvoiceDate
			,intBillId
			,ysnBillable
			,ysnReimburseable
			,ysnBilled 
			,dtmBilled
			,intCreatedUserId
			,intCreatedUserEntityId
			,dtmCreated
			,intJobCodeId
			,intCurrencyId
			,intCurrencyExchangeRateTypeId
			,dblCurrencyRate
			,intItemId
			,intItemUOMId
			,strAgent
			,strInvoiceNumber
			,strVoucherNumber
			,strCreatedUserName
			,strJobCode
			,strCurrency
			,strCurrencyExchangeRateType
			,strDate
			,strInvoiceDate
			,strItemNo
			,intTimeEntryId
			,strTicketNumber
			,intCustomerId
			,dblExtendedRate
			,dblBaseAmount
			,strProjectName
			,intProjectId
			,ysnVendor
			,strServiceType
			,ysnTimeOff
			,strName 
			,ysnOverride
			,intAgentTimeEntryPeriodDetailSummaryId
			,intBillable = CASE WHEN ysnBillable = CONVERT(BIT, 0)
									THEN 0
								ELSE 1
							END
FROM vyuHDTicketHoursWorked TicketHoursWorked
		INNER JOIN tblHDTimeEntryPeriod TimeEntryPeriod
ON TimeEntryPeriod.strFiscalYear = DATEPART(YEAR, dtmDate)

GO
CREATE VIEW [dbo].[vyuARBillableHoursForImport]
AS 
SELECT intEntityId					= C.[intEntityId]
	 , strCustomerNumber			= C.[strCustomerNumber]
	 , strName						= E.[strName]
	 , intTicketId					= T.[intTicketId]
	 , strTicketNumber				= T.[strTicketNumber]
	 , strSubject					= HW.[strDescription]
	 , intTicketHoursWorkedId		= HW.[intTicketHoursWorkedId]
	 , intAgentEntityId				= HW.[intAgentEntityId]
	 , strAgentName					= U.[strName]
	 , dtmBilled					= GETDATE()
	 , dtmDate						= HW.[dtmDate]
	 , intInvoiceId					= HW.[intInvoiceId]
	 , intJobCodeId					= IC.intItemId
	 , strJobCode					= IC.strItemNo
	 , intCompanyLocationId         = ISNULL(EML.[intWarehouseId], CL.intCompanyLocationId)
	 , intItemId					= HW.[intItemId]
	 , intItemUOMId					= HW.[intItemUOMId] 
	 , strItemNo					= IC.[strItemNo]
	 , intHours						= HW.[intHours]
	 , dblPrice						= HW.[dblRate]
	 , dblTotal						= HW.[intHours] * HW.[dblRate]
	 , intCurrencyId				= NULLIF(HW.[intCurrencyId], 0)
	 , intCurrencyExchangeRateTypeId = NULLIF(HW.[intCurrencyExchangeRateTypeId], 0)
	 , dblCurrencyExchangeRate		= CASE WHEN HW.[dblCurrencyRate] = 0 THEN 1.00 ELSE HW.[dblCurrencyRate] END
	 , intSubCurrencyId				= NULLIF(HW.[intCurrencyId], 0)
	 , dblSubCurrencyRate			= HW.[dblCurrencyRate]
	 , intEntityWarehouseId			= EML.[intWarehouseId]
	 , intTimeEntryPeriodDetailId	= CASE WHEN HW.ysnLegacyWeek = 1 THEN 0 ELSE BillingPeriod.intTimeEntryPeriodDetailId END
	 , strPeriodDisplay				= BillingPeriod.strPeriodDisplay
	 , strApprovalStatus			= CASE WHEN ApprovalInfo.strStatus = 'Approved' OR ApprovalInfo.strStatus = 'No Need for Approval' OR ApprovalInfo.strStatus = 'Approved with Modifications'
												THEN 'Approved'
											ELSE 'Not Yet Approved'
									  END 
	 , ysnLegacyWeek				= HW.ysnLegacyWeek
	 , strCurrency					= Currency.strCurrency
	 , dblBaseAmount				= (CASE WHEN (ISNULL(HW.[intHours], 0.00) = 0.00 OR ISNULL(HW.[dblRate],0.00) = 0.00) 
													THEN 0.00 
												ELSE HW.[intHours] * HW.[dblRate] * (CASE WHEN ISNULL(HW.[dblCurrencyRate], 0.00) = 0.00 THEN 1.00 ELSE HW.[dblCurrencyRate] END)
									   END)
FROM dbo.tblHDTicketHoursWorked HW WITH (NOLOCK)
INNER JOIN (
	SELECT intItemId
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) IC ON HW.[intItemId] = IC.[intItemId]
INNER JOIN (
	SELECT intTicketId
		 , intCustomerId
		 , strTicketNumber
	FROM dbo.tblHDTicket WITH (NOLOCK)
) T ON HW.[intTicketId] = T.[intTicketId]
INNER JOIN (
	SELECT intEntityId
		 , strCustomerNumber
	FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON T.[intCustomerId] = C.[intEntityId]
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON C.[intEntityId] = E.[intEntityId]	
LEFT JOIN (
	SELECT intEntityId
		 , intWarehouseId
	FROM tblEMEntityLocation EL WITH (NOLOCK)
	INNER JOIN tblSMCompanyLocation CLL ON EL.intWarehouseId = CLL.intCompanyLocationId
	WHERE ysnDefaultLocation = 1 
	  AND CLL.ysnLocationActive = 1
) EML ON E.[intEntityId] = EML.[intEntityId]
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK) 
) U ON HW.[intAgentEntityId] = U.[intEntityId]
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency
	FROM tblSMCurrency WITH (NOLOCK) 
) Currency ON Currency.intCurrencyID = HW.[intCurrencyId]
OUTER APPLY (
	SELECT TOP 1 intCompanyLocationId 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	WHERE ysnLocationActive = 1
) CL
OUTER APPLY(
	SELECT TOP 1	 BillingPeriod.strPeriodDisplay
					,BillingPeriod.intTimeEntryPeriodDetailId
	FROM vyuHDTimeEntryBillingPeriod BillingPeriod
	WHERE BillingPeriod.dtmBillingPeriodStart <= HW.dtmDate AND
		  BillingPeriod.dtmBillingPeriodEnd >= HW.dtmDate

) BillingPeriod
OUTER APPLY(
	SELECT TOP 1 TimeEntry.intTimeEntryId
	FROM tblHDTimeEntry TimeEntry
	WHERE TimeEntry.intTimeEntryPeriodDetailId = BillingPeriod.intTimeEntryPeriodDetailId AND
		  TimeEntry.intEntityId = HW.intAgentEntityId
	ORDER BY intTimeEntryId DESC
) TimeEntry
OUTER APPLY(
	SELECT  strStatus = Approval.strStatus 
	FROM tblSMApproval Approval
			INNER JOIN tblSMScreen Screen
	ON Approval.intScreenId = Screen.intScreenId
			INNER JOIN tblSMTransaction SMTransaction
	ON Approval.intTransactionId = SMTransaction.intTransactionId
	WHERE Screen.strScreenName = 'Time Entry' AND
		  SMTransaction.intRecordId = TimeEntry.intTimeEntryId AND
		  Approval.ysnCurrent = 1
) ApprovalInfo
WHERE HW.[ysnBillable] = 1
  AND HW.[ysnBilled] = 0
  AND (HW.[intInvoiceId] IS NULL OR HW.[intInvoiceId] = 0)
  AND ISNULL(HW.dblRate, 0) <> 0
  AND ISNULL(HW.intHours, 0) <> 0
  AND LOWER(IC.strItemNo) <> 'holiday'
GO
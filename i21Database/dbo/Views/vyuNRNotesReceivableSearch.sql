CREATE VIEW [dbo].[vyuNRNotesReceivableSearch]
AS 
SELECT intNoteId
	 , intCustomerId
	 , CUSTOMER.strCustomerName
	 , strNoteNumber
	 , NOTE.intDescriptionId
	 , ND.strDescriptionName
	 , strNoteType
	 , dblCreditLimit
	 , dtmMaturityDate
	 , ysnWriteOff
	 , strSchdDescription
	 , intSchdInterval
	 , intSchdMonthFreq
	 , ysnSchdForcePayment
	 , dblSchdForcePaymentAmt
	 , dblSchdLateFee
	 , dtmSchdStartDate
	 , dtmSchdEndDate
	 , strSchdLateFeeUnit
	 , strSchdLateAppliedOn
	 , intSchdGracePeriod
	 , strUCCFileRefNo
	 , dtmUCCFiledOn
	 , dtmUCCLastRenewalOn
	 , dtmUCCReleasedOn
	 , strUCCComment
FROM dbo.tblNRNote NOTE WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
		 , strCustomerName = strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) CUSTOMER ON NOTE.intCustomerId = CUSTOMER.intEntityId
INNER JOIN (
	SELECT intDescriptionId
		 , strDescriptionName
	FROM dbo.tblNRNoteDescription WITH (NOLOCK)
) ND ON NOTE.intDescriptionId = ND.intDescriptionId 

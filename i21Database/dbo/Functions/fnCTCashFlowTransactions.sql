CREATE FUNCTION [dbo].[fnCTCashFlowTransactions]
(
	 @dtmDateFrom datetime = null
	 ,@dtmDateTo  datetime = null
)
RETURNS @CTCashFlowTransactions TABLE(
	intTransactionId INT,
	strTransactionId NVARCHAR(100),
	strTransactionType NVARCHAR(100),
	intCurrencyId INT,
	dtmDate DATETIME,
	dblAmount NUMERIC(18,6),
	intBankAccountId INT null,
	intGLAccountId INT null,
	intCompanyLocationId INT
)
AS 
BEGIN 
	insert into @CTCashFlowTransactions (
		intTransactionId
		,strTransactionId
		,strTransactionType
		,intCurrencyId
		,dtmDate
		,dblAmount
		,intBankAccountId
		,intGLAccountId
		,intCompanyLocationId
	)
	select
		intTransactionId  = cd.intContractDetailId
		,strTransactionId = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
		,strTransactionType = ct.strContractType
		,intCurrencyId  = cd.intInvoiceCurrencyId
		,dtmDate = cd.dtmCashFlowDate
		,dblAmount = (((cd.dblBalance - isnull(dblScheduleQty,0)) / cd.dblQuantity) * cd.dblTotalCost) * (case when isnull(cu.intCurrencyID,0) <> cd.intInvoiceCurrencyId and isnull(cm.intCurrencyID,0) <> cd.intInvoiceCurrencyId then cd.dblRate else (case when cd.intInvoiceCurrencyId = isnull(cm.intCurrencyID,0) then 1 else 100 end) end) 
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		join tblCTContractType ct on ct.intContractTypeId = ch.intContractTypeId
		cross apply (select intScreenId from tblSMScreen where strNamespace = 'ContractManagement.view.contract' and strModule = 'Contract Management') screen
		left join tblSMTransaction txn on txn.intRecordId = ch.intContractHeaderId and txn.intScreenId = screen.intScreenId
		left join tblSMCurrency cu on cu.intCurrencyID = cd.intCurrencyId
		left join tblSMCurrency cm on cm.intCurrencyID = cu.intMainCurrencyId
	where
		cd.intContractStatusId in (1,4)
		and cd.dblCashPrice is not null
		and isnull(txn.strApprovalStatus,'Approved') in ('Approved','No Need for Approval','Approved with Modifications')
		and cd.dblBalance - isnull(dblScheduleQty,0) > 0
		and isnull(cd.dtmCashFlowDate,cd.dtmEndDate) >= isnull(@dtmDateFrom,isnull(cd.dtmCashFlowDate,cd.dtmEndDate))
		and isnull(cd.dtmCashFlowDate,cd.dtmEndDate) <= isnull(@dtmDateTo,isnull(cd.dtmCashFlowDate,cd.dtmEndDate))

	 RETURN  	
END
GO
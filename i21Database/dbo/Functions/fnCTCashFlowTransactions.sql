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
	intCompanyLocationId INT,
	ysnCost BIT default 0
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
		,ysnCost
	)
	select
		intTransactionId  = cd.intContractDetailId
		,strTransactionId = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
		,strTransactionType = ct.strContractType
		,intCurrencyId  = cd.intInvoiceCurrencyId
		,dtmDate = isnull(cd.dtmCashFlowDate,cd.dtmEndDate)
		,dblAmount = (((cd.dblBalance - isnull(dblScheduleQty,0)) / cd.dblQuantity) * cd.dblTotalCost) * (case when isnull(cu.intCurrencyID,0) <> cd.intInvoiceCurrencyId and isnull(cm.intCurrencyID,0) <> cd.intInvoiceCurrencyId then cd.dblRate else (case when cd.intInvoiceCurrencyId = isnull(cm.intCurrencyID,0) then 1 else 100 end) end) 
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
		,ysnCost = 0
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

	union all

	select
		intTransactionId  = cd.intContractDetailId
		,strTransactionId = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
		,strTransactionType = ct.strContractType
		,intCurrencyId  = cd.intInvoiceCurrencyId
		,dtmDate = isnull(cd.dtmCashFlowDate,cd.dtmEndDate)
		,dblAmount = dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId,QU.intUnitMeasureId,QUB.intUnitMeasureId,((cd.dblBalance - isnull(cd.dblScheduleQty,0))) * ((sp.dblLastSettle + cd.dblBasis) / (case when cb.intMainCurrencyId is null then 1 else 100 end))) * (case when isnull(cu.intCurrencyID,0) <> cd.intInvoiceCurrencyId and isnull(cm.intCurrencyID,0) <> cd.intInvoiceCurrencyId then cd.dblRate else (case when cd.intInvoiceCurrencyId = isnull(cm.intCurrencyID,0) then 1 else 100 end) end) 
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
		,ysnCost = 0
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		join tblCTContractType ct on ct.intContractTypeId = ch.intContractTypeId
		cross apply (select intScreenId from tblSMScreen where strNamespace = 'ContractManagement.view.contract' and strModule = 'Contract Management') screen
		left join tblSMTransaction txn on txn.intRecordId = ch.intContractHeaderId and txn.intScreenId = screen.intScreenId
		left join tblSMCurrency cu on cu.intCurrencyID = cd.intCurrencyId
		left join tblSMCurrency cm on cm.intCurrencyID = cu.intMainCurrencyId
		LEFT JOIN tblICItemUOM QU ON QU.intItemUOMId = cd.intItemUOMId	
		LEFT JOIN tblICItemUOM QUB ON QUB.intItemUOMId = cd.intBasisUOMId
		left join tblSMCurrency cb on cb.intCurrencyID = cd.intBasisCurrencyId
		cross apply (
			select
				fspm.dblLastSettle
			from
				tblRKFuturesSettlementPrice sp
				join tblRKCommodityMarketMapping cmm on cmm.intFutureMarketId = sp.intFutureMarketId
				join tblRKFutSettlementPriceMarketMap fspm on fspm.intFutureSettlementPriceId = sp.intFutureSettlementPriceId
			where
				sp.strPricingType = 'Mark to Market' COLLATE Latin1_General_CS_AS
				and sp.intCommodityMarketId = cmm.intCommodityMarketId
				and cmm.intCommodityId = ch.intCommodityId and sp.intFutureMarketId = cd.intFutureMarketId and fspm.intFutureMonthId = cd.intFutureMonthId
		)sp
	where
		cd.intContractStatusId in (1,4)
		and cd.intPricingTypeId = 2
		and isnull(txn.strApprovalStatus,'Approved') in ('Approved','No Need for Approval','Approved with Modifications')
		and cd.dblBalance - isnull(dblScheduleQty,0) > 0
		and isnull(cd.dtmCashFlowDate,cd.dtmEndDate) >= isnull(@dtmDateFrom,isnull(cd.dtmCashFlowDate,cd.dtmEndDate))
		and isnull(cd.dtmCashFlowDate,cd.dtmEndDate) <= isnull(@dtmDateTo,isnull(cd.dtmCashFlowDate,cd.dtmEndDate))
		and isnull(sp.dblLastSettle,0) > 0

	UNION ALL

	select
		intTransactionId  = cd.intContractDetailId
		,strTransactionId = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
		,strTransactionType = ct.strContractType
		,intCurrencyId  = cd.intInvoiceCurrencyId
		,dtmDate = isnull(cd.dtmCashFlowDate,cd.dtmEndDate)
		,dblAmount = c.dblAmount
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
		,ysnCost = 1
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		join tblCTContractType ct on ct.intContractTypeId = ch.intContractTypeId
		cross apply (select intScreenId from tblSMScreen where strNamespace = 'ContractManagement.view.contract' and strModule = 'Contract Management') screen
		left join tblSMTransaction txn on txn.intRecordId = ch.intContractHeaderId and txn.intScreenId = screen.intScreenId
		left join tblSMCurrency cu on cu.intCurrencyID = cd.intCurrencyId
		left join tblSMCurrency cm on cm.intCurrencyID = cu.intMainCurrencyId
		cross apply (
			SELECT
				CD1.intContractDetailId
				,dblAmount = sum(
					(
						CASE
							WHEN CC.strCostMethod = 'Per Unit'
							THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD1.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD1.dblQuantity)*CC.dblRate
							WHEN CC.strCostMethod = 'Amount'
							THEN CC.dblRate * isnull(CC.dblFX,1)
							WHEN CC.strCostMethod = 'Per Container'
							THEN(CC.dblRate * (
									case
										when isnull(CD1.intNumberOfContainers,1) = 0
										then 1
										else isnull(CD1.intNumberOfContainers,1)
									end
								)
							)
							WHEN CC.strCostMethod = 'Percentage'
							THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD1.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD1.dblQuantity)*CD1.dblCashPrice*CC.dblRate/100
						END
					)
					/
					(
						case
							when isnull(CY.ysnSubCurrency,convert(bit,0)) = convert(bit,1)
							then isnull(CY.intCent,1)
							else 1
						end
					)	
				)
			FROM
				tblCTContractCost CC
				JOIN tblCTContractDetail CD1	ON CD1.intContractDetailId = CC.intContractDetailId	
				LEFT JOIN tblICItemUOM QU ON QU.intItemUOMId = CD1.intItemUOMId	
				LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CC.intItemUOMId	
				LEFT JOIN tblICItemUOM CM ON CM.intUnitMeasureId = IU.intUnitMeasureId AND CM.intItemId = CD1.intItemId	
				LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = CD1.intPriceItemUOMId
				LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CC.intCurrencyId
			WHERE
				CD1.intContractDetailId = cd.intContractDetailId
			GROUP BY
				CD1.intContractDetailId
		) c
	where
		cd.intContractStatusId in (1,4)
		and isnull(txn.strApprovalStatus,'Approved') in ('Approved','No Need for Approval','Approved with Modifications')
		and cd.dblBalance - isnull(dblScheduleQty,0) > 0
		and isnull(cd.dtmCashFlowDate,cd.dtmEndDate) >= isnull(@dtmDateFrom,isnull(cd.dtmCashFlowDate,cd.dtmEndDate))
		and isnull(cd.dtmCashFlowDate,cd.dtmEndDate) <= isnull(@dtmDateTo,isnull(cd.dtmCashFlowDate,cd.dtmEndDate))
		and isnull(c.dblAmount,0) > 0

	 RETURN  	
END
GO
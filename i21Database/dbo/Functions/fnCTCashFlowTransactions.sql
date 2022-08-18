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
	ysnCost BIT default 0,
	intBankId  INT null
)
AS 
BEGIN 
	
	Declare @ysnEnableBudgetForBasisPricing BIT
	SELECT TOP 1 @ysnEnableBudgetForBasisPricing = ysnEnableBudgetForBasisPricing FROM tblCTCompanyPreference

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
		,intBankId
	)
	select
		intTransactionId  = cd.intContractDetailId
		,strTransactionId = ch.strContractNumber + '-' + convert(nvarchar(20),cd.intContractSeq)
		,strTransactionType = ct.strContractType
		,intCurrencyId  = cd.intInvoiceCurrencyId
		,dtmDate = isnull(cd.dtmCashFlowDate,cd.dtmEndDate)
		,dblAmount = (((cd.dblBalance - isnull(dblScheduleQty,0)) / cd.dblQuantity) * cd.dblTotalCost) * (case when isnull(cu.intCurrencyID,0) <> cd.intInvoiceCurrencyId and isnull(cm.intCurrencyID,0) <> cd.intInvoiceCurrencyId then cd.dblRate else (case when cd.intInvoiceCurrencyId = isnull(cm.intCurrencyID,cd.intCurrencyId) then 1 else 100 end) end) 
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
		,ysnCost = 0
		,cd.intBankId
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
		,dblAmount = dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId,QU.intUnitMeasureId,QUB.intUnitMeasureId,((cd.dblBalance - isnull(cd.dblScheduleQty,0))) * ((sp.dblLastSettle + cd.dblBasis) / (case when cb.intMainCurrencyId is null then 1 else 100 end))) * (case when isnull(cu.intCurrencyID,0) <> cd.intInvoiceCurrencyId and isnull(cm.intCurrencyID,0) <> cd.intInvoiceCurrencyId then cd.dblRate else (case when cd.intInvoiceCurrencyId = isnull(cm.intCurrencyID,cd.intCurrencyId) then 1 else 100 end) end) 
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
		,ysnCost = 0
		,cd.intBankId
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
			select top 1
				fspm.dblLastSettle
			from
				tblRKFuturesSettlementPrice sp
				join tblRKCommodityMarketMapping cmm on cmm.intFutureMarketId = sp.intFutureMarketId
				join tblRKFutSettlementPriceMarketMap fspm on fspm.intFutureSettlementPriceId = sp.intFutureSettlementPriceId
			where
				sp.strPricingType = 'Mark to Market' COLLATE Latin1_General_CS_AS
				and sp.intCommodityMarketId = cmm.intCommodityMarketId
				and cmm.intCommodityId = ch.intCommodityId and sp.intFutureMarketId = cd.intFutureMarketId and fspm.intFutureMonthId = cd.intFutureMonthId
			order by sp.dtmPriceDate desc
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
		,dblAmount = (c.dblAmount / cd.dblQuantity) * (isnull(cd.dblBalance,0) - isnull(dblScheduleQty,0))
		,intBankAccountId = cd.intBankAccountId
		,intGLAccountId = null
		,intCompanyLocationId = cd.intCompanyLocationId
		,ysnCost = 1
		,cd.intBankId
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
							--THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD1.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD1.dblQuantity)*CC.dblRate
							THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD1.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD1.dblQuantity)*CC.dblRate * CASE WHEN CD1.intCurrencyId != CD1.intInvoiceCurrencyId THEN  ISNULL(CC.dblFX, 1) ELSE 1 END

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
							) * CASE WHEN CD1.intCurrencyId != CD1.intInvoiceCurrencyId THEN  ISNULL(CC.dblFX, 1) ELSE 1 END
							WHEN CC.strCostMethod = 'Percentage'
							THEN 
								
									CASE WHEN CD1.intPricingTypeId <> 2 THEN
										dbo.fnCTConvertQuantityToTargetItemUOM(CD1.intItemId, QU.intUnitMeasureId, PU.intUnitMeasureId, CD1.dblQuantity) 
										* (CD1.dblCashPrice / (CASE WHEN ISNULL(CY2.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(CY2.intCent, 1) ELSE 1 END))
										* CC.dblRate/100 * ISNULL(CC.dblFX, 1)
									ELSE
										CASE WHEN @ysnEnableBudgetForBasisPricing = CONVERT(BIT, 1) THEN  
											CD1.dblTotalBudget  * (CC.dblRate/100) * ISNULL(CC.dblFX, 1)
										ELSE
											dbo.fnCTConvertQuantityToTargetItemUOM(CD1.intItemId, QU.intUnitMeasureId, PU.intUnitMeasureId, CD1.dblQuantity) 
											* ((FSPM.dblLastSettle + CD1.dblBasis) / (CASE WHEN ISNULL(CY2.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(CY2.intCent, 1) ELSE 1 END))
											* CC.dblRate/100 * ISNULL(CC.dblFX, 1)
										END
									END

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
				LEFT JOIN	tblSMCurrency		CY2	ON	CY2.intCurrencyID		=	CD1.intCurrencyId
				LEFT JOIN  (
					select intFutureMarketId, MAX(intFutureSettlementPriceId) intFutureSettlementPriceId, MAX( dtmPriceDate) dtmPriceDate
					from tblRKFuturesSettlementPrice a
					Group by intFutureMarketId, intCommodityMarketId
	
				) FSP on FSP.intFutureMarketId = CD1.intFutureMarketId
				LEFT JOIN tblRKFutSettlementPriceMarketMap FSPM on FSPM.intFutureSettlementPriceId = FSP.intFutureSettlementPriceId and CD1.intFutureMonthId = FSPM.intFutureMonthId
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
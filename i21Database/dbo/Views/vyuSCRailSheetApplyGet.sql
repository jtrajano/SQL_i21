CREATE VIEW [dbo].[vyuSCRailSheetApplyGet]
	AS
	select 
	
		RailSheetApply.intRailSheetApplyId
		,RailSheetApply.intApplyType
		,RailSheetApply.intRailSheetId
		,RailSheetApply.intSort
		,RailSheetApply.dblBasis
		,RailSheetApply.dblFutures
		,RailSheetApply.dblUnits
		
		,ContractDetail.intContractDetailId
		,dblSeqCost = ContractDetail.dblCashPrice 
		,ContractHeader.intContractHeaderId
		,ContractHeader.strContractNumber
		

		,PricingType.strPricingType
		,ysnDPContract = cast(case when PricingType.intPricingTypeId = 5 then 1 else 0 end as bit)


		,RailSheetApply.intConcurrencyId
		,RailSheet.intEntityId
		from tblSCRailSheetApply RailSheetApply
		join tblSCRailSheet RailSheet
			on RailSheetApply.intRailSheetId = RailSheet.intRailSheetId
		left join tblCTContractDetail ContractDetail
			on RailSheetApply.intContractDetailId = ContractDetail.intContractDetailId
		left join tblCTContractHeader ContractHeader
			on ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
		left join tblCTPricingType PricingType
			on ContractHeader.intPricingTypeId = PricingType.intPricingTypeId
go

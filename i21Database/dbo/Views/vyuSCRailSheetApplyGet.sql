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
		
		, Ticket.strTicketNumber AS strTicketNumber
		from tblSCRailSheetApply RailSheetApply
		join tblSCRailSheet RailSheet
			on RailSheetApply.intRailSheetId = RailSheet.intRailSheetId
		LEFT JOIN tblSCRailSheetTicketApply RailSheetTicketApply
			ON RailSheetApply.intRailSheetApplyId = RailSheetTicketApply.intRailSheetApplyId
		LEFT JOIN tblSCRailSheetTicket RailSheetTicket
			ON RailSheetTicketApply.intRailSheetTicketId = RailSheetTicket.intRailSheetTicketId
		LEFT JOIN tblSCTicket Ticket
			ON RailSheetTicket.intTicketId = Ticket.intTicketId
		left join tblCTContractDetail ContractDetail
			on RailSheetApply.intContractDetailId = ContractDetail.intContractDetailId
		left join tblCTContractHeader ContractHeader
			on ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
		left join tblCTPricingType PricingType
			on ContractHeader.intPricingTypeId = PricingType.intPricingTypeId
		
go

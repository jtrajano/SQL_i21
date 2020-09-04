CREATE VIEW [dbo].[vyuCTSequenceTransactions]
	AS
		select
			t.intId
			,t.intContractDetailId
			,t.dtmTransactionDate
			,t.strTransactionType
			,t.strTransactionReference
			,t.intTransactionReferenceId
			,t.dblContracted
			,t.dblTransactionQuantity
			,dblBalance =	(
								case
								when isnull(t.ysnLoad,0) = 1
								then t.dblBalance * t.dblQuantityPerLoad
								else t.dblBalance
								end
							)
			,dblApplied =	(
								case
								when isnull(t.ysnLoad,0) = 1
								then t.dblApplied * t.dblQuantityPerLoad
								else t.dblApplied
								end
							)
			,dblScheduled = (
								case
								when isnull(t.ysnLoad,0) = 1
								then t.dblScheduled * t.dblQuantityPerLoad
								else t.dblScheduled
								end
							)
			,dblAvailable = (
								case
								when isnull(t.ysnLoad,0) = 1
								then t.dblAvailable * t.dblQuantityPerLoad
								else t.dblAvailable
								end
							)
			,t.dblCommulativeSchedule
			,t.intUserId
			,t.strUserName
		from
			(
			select
				intId						=	convert(int,row_number() over (order by uh.dtmTransactionDate))
				,uh.intContractDetailId
				,uh.dtmTransactionDate
				,strTransactionType			=	uh.strScreenName
				,strTransactionReference	=	(
													case
													when uh.intExternalHeaderId < 1 and uh.strScreenName = 'Auto - Scale'
													then t.strTicketNumber
													else uh.strNumber
													end
												)
				,intTransactionReferenceId	=	(
													case
													when uh.intExternalHeaderId < 1
													then uh.intExternalId
													else uh.intExternalHeaderId
													end
												)
				,dblContracted				=	cd.dblQuantity
				,uh.dblTransactionQuantity
				,uh.dblBalance
				,dblApplied					=	(
													case
													when uh.strScreenName in ('Inventory Shipment','Inventory Receipt','Settle Storage')
													then (uh.dblTransactionQuantity * -1)
													else null
													end
												)
				,dblScheduled				=	(
													case
													when uh.dblTransactionQuantity < 0
													then null
													else uh.dblTransactionQuantity
													end
												)
				,dblAvailable				=	uh.dblBalance - uh.dblNewValue
				,dblCommulativeSchedule		=	uh.dblNewValue
				,uh.intUserId
				,strUserName				=	en.strName
				,ch.ysnLoad
				,ch.dblQuantityPerLoad
			from
				tblCTSequenceUsageHistory uh
				join tblCTContractDetail cd on cd.intContractDetailId = uh.intContractDetailId
				join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
				left join tblSCTicket t on t.intTicketId = uh.intExternalId
				join tblEMEntity en on en.intEntityId = uh.intUserId
			where 
				(
					uh.strFieldName = 'Scheduled Quantity'
					or (
						uh.strFieldName = 'Balance'
						and uh.strScreenName = 'Settle Storage'
					)
				)
			)t
		where t.dblApplied is not null or t.dblScheduled is not null
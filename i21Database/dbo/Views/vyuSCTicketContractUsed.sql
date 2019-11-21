CREATE VIEW [dbo].[vyuSCTicketContractUsed]
	AS 
    
select 
    a.intTicketContractUsed as intId, 
    a.intTicketId,  
    b.intContractHeaderId,
    b.intContractDetailId,
    c.strContractNumber, 
    d.strContractType 

from tblSCTicketContractUsed a
	join tblCTContractDetail b
		on a.intContractDetailId = b.intContractDetailId
	join tblCTContractHeader c
		on b.intContractHeaderId = c.intContractHeaderId
	join tblCTContractType d
		on c.intContractTypeId = d.intContractTypeId



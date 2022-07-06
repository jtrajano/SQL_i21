CREATE VIEW [dbo].[vyuSCRestApiTicketContracts]
AS
SELECT e.strName strEntityName, ch.strContractNumber, i.strItemNo, u.strUnitMeasure strItemUOM, iu.intItemUOMId,
	cd.intContractSeq, cd.intContractDetailId, ch.intContractHeaderId, e.intEntityId, tcu.intTicketId, tcu.intTicketContractUsed
FROM tblSCTicketContractUsed tcu
LEFT JOIN tblEMEntity e ON e.intEntityId = tcu.intEntityId
LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = tcu.intContractDetailId
LEFT JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblICItem i ON i.intItemId = cd.intItemId
LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = cd.intItemUOMId
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
CREATE VIEW [dbo].[vyuCTContractCostView]
AS 

SELECT cc.intContractCostId, cc.intContractDetailId, cc.intConcurrencyId, cc.intItemId, cc.intVendorId, cc.strCostMethod, cc.intCurrencyId,
	cc.dblRate, cc.intItemUOMId, cc.dblFX, cc.ysnAccrue, cc.ysnMTM, cc.ysnPrice, i.strItemNo, i.strDescription strItemDescription,
	um.strUnitMeasure strUOM, e.strName strVendorName, cd.intContractHeaderId, iu.intUnitMeasureId, cd.intContractSeq, c.strCurrency,
	ch.strContractNumber + ' - ' + LTRIM(cd.intContractSeq) strContractSeq
FROM tblCTContractCost cc
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = cc.intContractDetailId
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	INNER JOIN tblICItem i ON i.intItemId = cc.intItemId
	LEFT OUTER JOIN	tblICItemUOM iu ON iu.intItemUOMId = cc.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	LEFT OUTER JOIN tblSMCurrency c ON c.intCurrencyID = cc.intCurrencyId
	LEFT OUTER JOIN tblEMEntity e ON e.intEntityId = cc.intVendorId
	LEFT OUTER JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId
		AND et.strType = 'Vendor'

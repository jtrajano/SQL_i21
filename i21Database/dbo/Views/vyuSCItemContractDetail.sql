CREATE VIEW [dbo].[vyuSCItemContractDetail]
AS 
	SELECT  
		A.intItemContractHeaderId
		,B.intItemContractDetailId
		,B.intItemId
		,B.intItemUOMId
		,A.strContractNumber
		,A.intEntityId
		,C.strName 
		,B.intContractStatusId
		,A.intContractTypeId
		,D.strItemNo
		,F.strUnitMeasure		
		,B.dblAvailable
		,D.intCommodityId
		,strItemDescription = D.strDescription
		,B.dblPrice
		,B.intLineNo
		,B.dblContracted
		,D.strItemNo
	FROM tblCTItemContractHeader A
	INNER JOIN tblCTItemContractDetail B
		ON A.intItemContractHeaderId = B.intItemContractHeaderId
	INNER JOIN tblEMEntity C
		ON A.intEntityId = C.intEntityId
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	INNER JOIN tblICItemUOM E
		ON B.intItemUOMId = E.intItemUOMId
	INNER JOIN tblICUnitMeasure F
		ON E.intUnitMeasureId = F.intUnitMeasureId
GO
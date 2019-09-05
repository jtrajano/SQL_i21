CREATE VIEW [dbo].[vyuARItemContractSequenceSearch]
AS 
SELECT intItemContractHeaderId		= ICH.intItemContractHeaderId
	 , intItemContractDetailId		= ICD.intItemContractDetailId
	 , strItemContractNumber		= ICH.strContractNumber
	 , intItemContractSeq			= ICD.intLineNo
	 , strContractCategoryId		= ICH.strContractCategoryId
	 , intContractTypeId			= ICH.intContractTypeId
	 , intEntityCustomerId			= ICH.intEntityId
	 , intItemId					= ICD.intItemId
	 , intItemUOMId					= ICD.intItemUOMId
	 , strItemNo					= I.strItemNo	 
	 , strItemDescription			= ISNULL(ICD.strItemDescription, I.strDescription)
	 , strUnitMeasure				= UOM.strUnitMeasure
	 , intCompanyLocationId			= ICH.intCompanyLocationId
	 , dtmContractDate				= ICH.dtmContractDate
	 , dtmExpirationDate			= ICH.dtmExpirationDate
	 , dtmDeliveryDate				= ICD.dtmDeliveryDate
	 , intTaxGroupId				= ICD.intTaxGroupId
	 , strTaxGroup					= TG.strTaxGroup
	 , dblContracted				= ICD.dblContracted
	 , dblAvailable					= ICD.dblAvailable
	 , dblBalance					= ICD.dblBalance
	 , dblPrice						= ICD.dblPrice
	 , dblTotal						= ICD.dblTotal
	 , ysnPrepaid					= NULL  
	 , intSubLocationId				= IL.intSubLocationId
	 , intStorageLocationId			= IL.intStorageLocationId
	 , strStorageLocation			= STOLOC.strName
	 , strSubLocationName			= SUBLOC.strSubLocationName
	 , strLotTracking				= I.strLotTracking		
FROM dbo.tblCTItemContractDetail ICD
INNER JOIN dbo.tblCTItemContractHeader ICH ON ICD.intItemContractHeaderId = ICH.intItemContractHeaderId
INNER JOIN dbo.tblICItem I ON ICD.intItemId = I.intItemId
INNER JOIN dbo.tblICItemUOM IUOM ON ICD.intItemUOMId = IUOM.intItemUOMId
INNER JOIN dbo.tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
INNER JOIN dbo.tblICItemLocation IL ON I.intItemId = IL.intItemId AND ICH.intCompanyLocationId = IL.intLocationId
LEFT JOIN dbo.tblSMTaxGroup TG ON ICD.intTaxGroupId = TG.intTaxGroupId
LEFT JOIN dbo.tblICStorageLocation STOLOC ON STOLOC.intStorageLocationId = IL.intStorageLocationId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation SUBLOC ON SUBLOC.intCompanyLocationSubLocationId = IL.intSubLocationId
WHERE ICD.intContractStatusId IN (1, 4)
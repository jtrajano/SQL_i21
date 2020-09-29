CREATE VIEW vyuIPLoadDetailView
AS
SELECT LoadDetail.intLoadId
	,LoadDetail.intLoadDetailId
	,Item.strItemNo
	,Item.strDescription AS strItemDescription
	,LoadDetail.dblQuantity
	,strItemUOM = UOM.strUnitMeasure
	,LoadDetail.dblGross
	,LoadDetail.dblTare
	,LoadDetail.dblNet
	,LoadDetail.dblDeliveredQuantity
	,LoadDetail.dblDeliveredGross
	,LoadDetail.dblDeliveredTare
	,LoadDetail.dblDeliveredNet
	,PCLSL.strSubLocationName AS strPSubLocationName
	,SCLSL.strSubLocationName AS strSSubLocationName
	,strWeightItemUOM = WeightUOM.strUnitMeasure
	,LoadDetail.intPContractDetailId
	-- Customer Info
	,strCustomer = CEN.strName
	,strShipTo = CEL.strLocationName
	,LoadDetail.intSContractDetailId
	-- Schedule, Load Directions
	,LoadDetail.strScheduleInfoMsg
	,LoadDetail.ysnUpdateScheduleInfo
	,LoadDetail.ysnPrintScheduleInfo
	,LoadDetail.strLoadDirectionMsg
	,LoadDetail.ysnUpdateLoadDirections
	,LoadDetail.ysnPrintLoadDirections
	-- Load Header
	,strInboundTaxGroup = VendorTax.strTaxGroup
	,strOutboundTaxGroup = CustomerTax.strTaxGroup
	,LoadDetail.intNumberOfContainers
	,strDetailVendorReference = LoadDetail.strVendorReference
	,strDetailCustomerReference = LoadDetail.strCustomerReference
FROM tblLGLoadDetail LoadDetail
LEFT JOIN tblICItem Item ON Item.intItemId = LoadDetail.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LoadDetail.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId
LEFT JOIN tblSMTaxGroup VendorTax ON VendorTax.intTaxGroupId = VEL.intTaxGroupId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LoadDetail.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
LEFT JOIN tblSMTaxGroup CustomerTax ON CustomerTax.intTaxGroupId = CEL.intTaxGroupId
LEFT JOIN tblSMCompanyLocationSubLocation PCLSL ON PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SCLSL ON SCLSL.intCompanyLocationSubLocationId = LoadDetail.intSSubLocationId


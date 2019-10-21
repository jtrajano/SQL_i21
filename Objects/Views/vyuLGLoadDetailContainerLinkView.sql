CREATE VIEW vyuLGLoadDetailContainerLinkView
AS
SELECT LDCL.[intLoadContainerId]
	,LDCL.[intLoadDetailId]
	,LDCL.[dblQuantity]
	,IU.[intItemUOMId]
	,LDCL.[dblReceivedQty]
	,LDCL.[dblLinkGrossWt]
	,LDCL.[dblLinkTareWt]
	,LDCL.[dblLinkNetWt]
	,LDCL.[dblUnitCost]
	,LDCL.[strIntegrationOrderNumber]
	,LDCL.[dblIntegrationOrderPrice]
	,LDCL.[strExternalContainerId]
	,LDCL.[ysnExported]
	,LDCL.[dtmExportedDate]
	,LDCL.[dtmIntegrationOrderDate]
	,LDCL.[intLoadDetailContainerLinkRefId]
	,UM.strUnitMeasure AS strItemUOM
	,I.strItemNo
	,LDCL.intLoadDetailContainerLinkId
	,LDCL.[strIntegrationNumber]
FROM dbo.tblLGLoadDetailContainerLink LDCL
Left JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = LDCL.intItemUOMId
Left JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
Left JOIN dbo.tblICItem I ON I.intItemId = IU.intItemId


CREATE TABLE tblARInvoiceStage (
	intInvoiceStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intInvoiceId INT
	,strInvoiceNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strHeaderXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strDetailXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strRowState NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblARInvoiceStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,intMultiCompanyId INT
	,intEntityId INT
	,intCompanyLocationId INT
	,strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,intToBookId INT NULL
	,intTransactionId INT
	,intCompanyId INT
	,ysnMailSent BIT NULL
	)

	Go

Go
ALTER VIEW vyuIPGetInvoice
AS
SELECT IV.strTransactionType
	,B.strBook
	,SB.strSubBook
	,IV.dtmDate AS dtmInvoiceDate
	,CL.strLocationName
	,IV.strInvoiceNumber
	,C.strCurrency
	,IV.strComments
	,IV.intInvoiceId
FROM tblARInvoice IV
JOIN tblCTBook B ON B.intBookId = IV.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = IV.intSubBookId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IV.intCompanyLocationId
JOIN tblSMCurrency C ON C.intCurrencyID = IV.intCurrencyId



GO

ALTER VIEW vyuIPGetInvoiceDetail
AS
SELECT strTransactionType
	,B.strBook
	,SB.strSubBook
	,IV.strInvoiceNumber
	,I.strItemNo
	,CH.strContractNumber
	,CD.intContractSeq
	,IVD.dblQtyOrdered
	,IVD.dblQtyShipped
	,UM.strUnitMeasure
	,IVD.dblPrice
	,IVD.dblTotal
	,IVD.dblShipmentNetWt
	,IVD.dblItemWeight
	,WUM.strUnitMeasure AS strWeightUnitMeasure
	,IV.intInvoiceId
FROM tblARInvoice IV
JOIN tblARInvoiceDetail IVD ON IV.intInvoiceId = IVD.intInvoiceId
JOIN tblCTBook B ON B.intBookId = IV.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = IV.intSubBookId
JOIN tblICItem I ON I.intItemId = IVD.intItemId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = IVD.intContractHeaderId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = IVD.intContractDetailId
JOIN tblICItemUOM IU ON IU.intItemUOMId = IVD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
Left JOIN tblICItemUOM WIU ON WIU.intItemUOMId = IVD.intItemWeightUOMId
Left JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WIU.intUnitMeasureId



CREATE TABLE tblWHContainerInboundOrder (
	intContainerInboundOrderId INT identity(1, 1)
	,intContainerId INT NULL
	,intOrderHeaderId INT NULL
	,CONSTRAINT PK_tblWHContainerInboundOrder_intContainerInboundOrderId PRIMARY KEY (intContainerInboundOrderId)
	)

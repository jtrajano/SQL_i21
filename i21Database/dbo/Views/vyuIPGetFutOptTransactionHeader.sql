CREATE VIEW vyuIPGetFutOptTransactionHeader
AS
SELECT T.intFutOptTransactionHeaderId
	,T.intConcurrencyId
	,T.dtmTransactionDate
	,T.intSelectedInstrumentTypeId
	,T.strSelectedInstrumentType
	,T.intFutOptTransactionHeaderRefId
FROM tblRKFutOptTransactionHeader T

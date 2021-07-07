CREATE VIEW [dbo].[vyuTRQuote]
    AS
SELECT H.intQuoteHeaderId
, H.strQuoteNumber
, H.strQuoteStatus
, H.dtmQuoteDate
, H.dtmQuoteEffectiveDate
, H.intEntityCustomerId
, C.strName strCustomerName
, U.strName strUserName
, H.dtmGenerateDateTime
, H.strSource
, H.strMessage
, H.ysnDelete
, H.intConcurrencyId

FROM tblTRQuoteHeader H
LEFT JOIN tblEMEntity C ON C.intEntityId = H.intEntityCustomerId
LEFT JOIN tblEMEntity U ON U.intEntityId = H.intUserId
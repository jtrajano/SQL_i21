CREATE VIEW [dbo].[vyuApiTicketSplits]
AS

SELECT guiId = NEWID()
    , tv.intTicketId
    , tv.strTicketNumber
    , dtmDate = tv.dtmTicketDateTime
    , strScaleStation = tv.strStationShortDescription
    , strTicketType = tv.strTicketType
    , tv.intEntityId
    , strEntityName = tv.strSplitEntityName
    , strDistributionType = tv.strSplitEntityDistribution
    , tv.strLocationName
    , strItemNo = tv.strItemNumber
    , tv.intItemId
    , tv.strItemDescription
    , tv.dblNetUnits
    , tv.dblUnitPrice
    , tv.dblSplitPercent
    , tv.strContractNumber
    , tv.intContractSequence
FROM vyuSCTicketSplitView tv

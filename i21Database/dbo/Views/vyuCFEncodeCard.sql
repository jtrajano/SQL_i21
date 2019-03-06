CREATE VIEW [dbo].[vyuCFEncodeCard]
AS


SELECT 

strISO = (CASE WHEN (LOWER(cfNet.strNetworkType) != 'nbs')
				THEN ISNULL(cfNet.strIso,'')
				ELSE 
				CASE 
					WHEN ISNULL(cfCard.intCardTypeId,0) = 0
					THEN ISNULL(cfNet.strIso,'')
					ELSE
						CASE 
							WHEN (ISNULL(cfCardType.intAccountLength,0) + ISNULL(cfCardType.intCardLength,0) > 0) AND (ISNULL(cfCardType.intAccountLength,0) + ISNULL(cfCardType.intCardLength,0) <= 11)
							THEN ISNULL(cfCardType.strIso,'')
							ELSE ISNULL(cfNet.strIso,'')
						END
				END
			END)
,intAccountLength = (CASE WHEN (LOWER(cfNet.strNetworkType) != 'nbs')
				THEN ISNULL(cfNet.intAccountLength,0)
				ELSE 
				CASE 
					WHEN ISNULL(cfCard.intCardTypeId,0) = 0
					THEN ISNULL(cfNet.intAccountLength,0)
					ELSE
						CASE 
							WHEN (ISNULL(cfCardType.intAccountLength,0) + ISNULL(cfCardType.intCardLength,0) > 0) AND (ISNULL(cfCardType.intAccountLength,0) + ISNULL(cfCardType.intCardLength,0) <= 11)
							THEN ISNULL(cfCardType.intAccountLength,0)
							ELSE ISNULL(cfNet.intAccountLength,0)
						END
				END
			END)
,intCardLength = (CASE WHEN (LOWER(cfNet.strNetworkType) != 'nbs')
				THEN ISNULL(cfNet.intCardLength,0)
				ELSE 
				CASE 
					WHEN ISNULL(cfCard.intCardTypeId,0) = 0
					THEN ISNULL(cfNet.intCardLength,0)
					ELSE
						CASE 
							WHEN (ISNULL(cfCardType.intAccountLength,0) + ISNULL(cfCardType.intCardLength,0) > 0) AND (ISNULL(cfCardType.intAccountLength,0) + ISNULL(cfCardType.intCardLength,0) <= 11)
							THEN ISNULL(cfCardType.intCardLength,0)
							ELSE ISNULL(cfNet.intCardLength,0)
						END
				END
			END)
,strNetworkISO = ISNULL(cfNet.strIso,'')
,intNetworkAccountLength = ISNULL(cfNet.intAccountLength,0)
,intNetworkCardLength = ISNULL(cfNet.intCardLength,0)
,strCardTypeISO = ISNULL(cfCardType.strIso,'')
,intCardTypeAccountLength = ISNULL(cfCardType.intAccountLength,0)
,intCardTypeCardLength = ISNULL(cfCardType.intCardLength,0)
,intEntryCode = ISNULL(cfCard.intEntryCode,0)
,cfNet.strNetworkType
,strCustomerNumber = emEnt.strEntityNo
,strCustomerName = emEnt.strName
,cfCard.strCardNumber
,cfCard.strCardDescription
,cfCard.strCardNotation
,cfCardType.strCardType
,cfCard.strCardPinNumber
,cfAct.intCustomerId
,cfCard.intCardId
,cfCardType.intCardTypeId
,cfCard.intNetworkId
,cfEncodeCard.intEncodeCardId
,cfEncodeCard.intConcurrencyId
,cfCard.dtmCardExpiratioYearMonth
,cfNet.dtmGlobalCardExpirationDate
FROM tblCFEncodeCard as cfEncodeCard
INNER JOIN tblCFCard as cfCard
ON cfEncodeCard.intCardId = cfCard.intCardId
INNER JOIN tblCFCardType as cfCardType
ON cfCard.intCardTypeId = cfCardType.intCardTypeId
INNER JOIN tblCFAccount as cfAct
ON cfAct.intAccountId = cfCard.intAccountId
INNER JOIN tblEMEntity as emEnt
ON emEnt.intEntityId = cfAct.intCustomerId
INNER JOIN tblCFNetwork as cfNet
ON cfNet.intNetworkId = cfCard.intNetworkId

GO



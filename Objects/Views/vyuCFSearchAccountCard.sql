
CREATE VIEW [dbo].[vyuCFSearchAccountCard]
AS

SELECT 
    [cfAcc].[intAccountId]					AS [intAccountId], 
	[cfAcc].[intCardId]						AS [intCardId],
    [cfAcc].[strName]						AS [strName], 
    [cfAcc].[strCustomerNumber]				AS [strCustomerNumber], 
    [cfAcc].[strPhone]						AS [strPhone], 
    [cfAcc].[strAddress]					AS [strAddress], 
    [cfAcc].[strCity]						AS [strCity], 
    [cfAcc].[strState]						AS [strState], 
    [cfAcc].[strCardNumber]					AS [strCardNumber], 
    [cfAcc].[strCardDescription]			AS [strCardDescription], 
    [cfAcc].[strNetwork]					AS [strNetwork], 
    [cfAcc].[ysnCustomerActive]				AS [ysnCustomerActive], 
    [cfAcc].[ysnActive]						AS [ysnActive], 
    [cfCrdType].[strCardType]				AS [strCardType], 
    [cfAcc].[dtmIssueDate]					AS [dtmIssueDate], 
    [cfAcc].[dtmLastUsedDated]				AS [dtmLastUsedDated], 
    [cfAcc].[ysnCardForOwnUse]				AS [ysnCardForOwnUse], 
    [cfAcc].[ysnIgnoreCardTransaction]		AS [ysnIgnoreCardTransaction], 
    [cfExpenseItem].[strItemNo]				AS [strItemNo], 
    [cfAcc].[strDepartment]					AS [strDepartment], 
    [cfDefaultVehicle].[strVehicleNumber]	AS [strVehicleNumber], 
    [cfCard].[strComment]					AS [strComment], 
    [cfAcc].[ysnCardLocked]					AS [ysnCardLocked], 
    [cfAcc].[strCardPinNumber]				AS [strCardPinNumber], 
    [cfAcc].[dtmCardExpiratioYearMonth]		AS [dtmCardExpiratioYearMonth], 
    [cfAcc].[strCardValidationCode]			AS [strCardValidationCode], 
    [cfAcc].[intNumberOfCardsIssued]		AS [intNumberOfCardsIssued], 
    [cfAcc].[intCardLimitedCode]			AS [intCardLimitedCode], 
    [cfAcc].[intCardFuelCode]				AS [intCardFuelCode], 
    [cfAcc].[strCardTierCode]				AS [strCardTierCode], 
    [cfAcc].[strCardOdometerCode]			AS [strCardOdometerCode], 
    [cfAcc].[strCardWCCode]					AS [strCardWCCode], 
    [cfCard].[strCardXReference]			AS [strCardXReference]
    FROM          [dbo].[vyuCFCardAccount] AS [cfAcc]
    OUTER APPLY  (SELECT TOP (1) [Extent6].[strCardType] AS [strCardType]
        FROM [dbo].[tblCFCardType] AS [Extent6]
        WHERE [Extent6].[intCardTypeId] = [cfAcc].[intCardTypeId] ) AS [cfCrdType]
    OUTER APPLY  (SELECT TOP (1) [Extent7].[strItemNo] AS [strItemNo]
        FROM [dbo].[tblICItem] AS [Extent7]
        WHERE [Extent7].[intItemId] = [cfAcc].[intExpenseItemId] ) AS [cfExpenseItem]
    OUTER APPLY  (SELECT TOP (1) [Extent8].[strVehicleNumber] AS [strVehicleNumber]
        FROM [dbo].[tblCFVehicle] AS [Extent8]
        WHERE [Extent8].[intVehicleId] = [cfAcc].[intDefaultFixVehicleNumber] ) AS [cfDefaultVehicle]
    OUTER APPLY  (SELECT TOP (1) [Extent9].[intCardId] AS [intCardId], [Extent9].[strCardXReference] AS [strCardXReference], [Extent9].[strComment] AS [strComment]
        FROM [dbo].[tblCFCard] AS [Extent9]
        WHERE [Extent9].[intCardId] = [cfAcc].[intCardId] ) AS [cfCard]
    WHERE [cfCard].[intCardId] IS NOT NULL

GO


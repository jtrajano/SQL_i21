
CREATE VIEW [dbo].[vyuCFSearchAccount]
AS

SELECT 
    [cfAcc].[intAccountId]										AS [intAccountId], 
    [cfCust].[ysnActive]										AS [ysnCustomerActive], 
    [cfDisc].[strDiscountSchedule]								AS [strDiscountSchedule], 
    [cfInvCycle].[strInvoiceCycle]								AS [strInvoiceCycle], 
    [cfLocalProfile].[strPriceProfile]							AS [strLocalPriceProfile], 
    [cfRemoteProfile].[strPriceProfile]							AS [strRemotePriceProfile], 
    [cfExtendedProfile].[strPriceProfile]						AS [strExtendedPriceProfile], 
    [cfFee].[strFeeProfileId]									AS [strFeeProfile], 
    [cfSalesPerson].[strName]									AS [strSalesPerson], 
    [cfCust].[strName]											AS [strName], 
    [cfCust].[strCustomerNumber]								AS [strCustomerNumber], 
    [cfCust].[strPhone]											AS [strPhone], 
    [cfCust].[strAddress]										AS [strAddress], 
    [cfCust].[strCity]											AS [strCity], 
    [cfCust].[strState]											AS [strState]
    FROM         [dbo].[tblCFAccount] AS [cfAcc]
    OUTER APPLY  (
		SELECT TOP (1) 
			[strCustomerNumber] AS [strCustomerNumber], 
			[strName]			AS [strName], 
			[strPhone]			AS [strPhone], 
			[strState]			AS [strState], 
			[strAddress]		AS [strAddress], 
			[strCity]			AS [strCity], 
			[ysnActive]			AS [ysnActive]
        FROM [dbo].[vyuCFCustomerEntity] 
        WHERE [intEntityId] = [cfAcc].[intCustomerId] ) AS [cfCust]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strDiscountSchedule] AS [strDiscountSchedule]
        FROM [dbo].[tblCFDiscountSchedule] 
        WHERE [intDiscountScheduleId] = [cfAcc].[intDiscountScheduleId] ) AS [cfDisc]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strInvoiceCycle] AS [strInvoiceCycle]
        FROM [dbo].[tblCFInvoiceCycle] 
        WHERE [intInvoiceCycleId] = [cfAcc].[intInvoiceCycle] ) AS [cfInvCycle]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strPriceProfile] AS [strPriceProfile]
        FROM [dbo].[tblCFPriceProfileHeader] 
        WHERE [intPriceProfileHeaderId] = [cfAcc].[intLocalPriceProfileId] ) AS [cfLocalProfile]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strPriceProfile] AS [strPriceProfile]
        FROM [dbo].[tblCFPriceProfileHeader] 
        WHERE [intPriceProfileHeaderId] = [cfAcc].[intRemotePriceProfileId] ) AS [cfRemoteProfile]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strPriceProfile] AS [strPriceProfile]
        FROM [dbo].[tblCFPriceProfileHeader]
        WHERE [intPriceProfileHeaderId] = [cfAcc].[intExtRemotePriceProfileId] ) AS [cfExtendedProfile]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strFeeProfileId] AS [strFeeProfileId]
        FROM [dbo].[tblCFFeeProfile] 
        WHERE [intFeeProfileId] = [cfAcc].[intFeeProfileId] ) AS [cfFee]
    OUTER APPLY  
		(SELECT TOP (1) 
			[strName] AS [strName]
        FROM [dbo].[tblEMEntity] 
        WHERE [intEntityId] = [cfAcc].[intSalesPersonId] ) AS [cfSalesPerson]
   
   GO

